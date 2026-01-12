import cv2
import numpy as np
from skimage.metrics import structural_similarity as ssim
from skimage.metrics import peak_signal_noise_ratio as psnr
import os

# ================= CẤU HÌNH (SỬA LẠI CHO ĐÚNG) =================
# Kích thước ảnh của bạn (theo thông tin bạn cung cấp trước đó)
WIDTH  = 430
HEIGHT = 554

# Tên file
FILE_ANH_GOC     = 'baitap1_anhgoc.jpg'   # Ảnh gốc chưa bị nhiễu (Clean Image)
FILE_VERILOG_OUT = 'pic_output.txt'     # File Hex output từ ModelSim

# Số pixel muốn cắt bỏ ở mỗi cạnh (để loại bỏ viền đen/sai số)
# Chọn khoảng 5 đến 10 pixel là an toàn
CROP_BORDER = 8 
# ================================================================

def main():
    print(f"--- BẮT ĐẦU ĐÁNH GIÁ CHẤT LƯỢNG ẢNH ({WIDTH}x{HEIGHT}) ---")

    # 1. Đọc ảnh gốc (Reference)
    if not os.path.exists(FILE_ANH_GOC):
        print(f"❌ Lỗi: Không tìm thấy file ảnh gốc '{FILE_ANH_GOC}'")
        return

    print(f"📸 Đang đọc ảnh gốc: {FILE_ANH_GOC}...")
    # Đọc ảnh và chuyển sang Grayscale (Trắng đen)
    img_clean = cv2.imread(FILE_ANH_GOC, cv2.IMREAD_GRAYSCALE)
    
    # Resize ảnh gốc về đúng kích thước chuẩn (để tránh lệch 1-2 pixel gây lỗi)
    img_clean = cv2.resize(img_clean, (WIDTH, HEIGHT))

    # 2. Đọc file kết quả từ Verilog
    if not os.path.exists(FILE_VERILOG_OUT):
        print(f"❌ Lỗi: Không tìm thấy file output Verilog '{FILE_VERILOG_OUT}'")
        return

    print(f"📂 Đang đọc file Verilog: {FILE_VERILOG_OUT}...")
    with open(FILE_VERILOG_OUT, 'r') as f:
        # Đọc từng dòng, loại bỏ dòng trống
        lines = [line.strip() for line in f.readlines() if line.strip()]

    # Kiểm tra số lượng pixel
    if len(lines) != WIDTH * HEIGHT:
        print(f"⚠️ CẢNH BÁO: Số lượng pixel trong file txt ({len(lines)}) không khớp với {WIDTH}x{HEIGHT}!")
        # Vẫn cố chạy tiếp bằng cách cắt hoặc bù
    
    # Chuyển Hex sang số nguyên
    pixels = []
    for line in lines:
        try:
            pixels.append(int(line, 16))
        except:
            pixels.append(0)

    # Chuyển list thành mảng Numpy (Matrix)
    img_verilog = np.array(pixels, dtype=np.uint8)
    
    # Reshape về dạng ảnh 2D. Nếu thiếu dữ liệu thì resize mảng cho khớp.
    try:
        img_verilog = img_verilog.reshape((HEIGHT, WIDTH))
    except ValueError:
        print("❌ Lỗi: Không thể reshape mảng dữ liệu về đúng kích thước ảnh.")
        return

    # 3. LƯU ẢNH TÁI TẠO (Để xem bằng mắt thường)
    cv2.imwrite("anh_ket_qua_verilog.jpg", img_verilog)
    print("💾 Đã lưu ảnh tái tạo ra file 'anh_ket_qua_verilog.jpg'")

    # ============================================================
    # 4. CẮT BỎ VIỀN (QUAN TRỌNG NHẤT)
    # ============================================================
    print(f"✂️  Đang cắt bỏ {CROP_BORDER} pixel ở viền mỗi cạnh...")
    
    # Cú pháp slicing: [y_start : y_end, x_start : x_end]
    # Bỏ dòng 0->border, dòng (height-border)->hết. Tương tự với cột.
    img_clean_cropped   = img_clean[CROP_BORDER:-CROP_BORDER, CROP_BORDER:-CROP_BORDER]
    img_verilog_cropped = img_verilog[CROP_BORDER:-CROP_BORDER, CROP_BORDER:-CROP_BORDER]

    # 5. TÍNH TOÁN PSNR & SSIM
    print("🧮 Đang tính toán thông số...")

    # Tính PSNR
    val_psnr = psnr(img_clean_cropped, img_verilog_cropped, data_range=255)
    
    # Tính SSIM
    val_ssim = ssim(img_clean_cropped, img_verilog_cropped, data_range=255)

    # 6. HIỂN THỊ KẾT QUẢ
    print("\n" + "="*40)
    print(f"   KẾT QUẢ ĐÁNH GIÁ CHẤT LƯỢNG ẢNH   ")
    print("="*40)
    print(f"✅ PSNR: {val_psnr:.4f} dB")
    print(f"✅ SSIM: {val_ssim:.4f}")
    print("-" * 40)

    # Đưa ra nhận xét tự động
    if val_psnr > 30 and val_ssim > 0.9:
        print("🌟 XUẤT SẮC! Ảnh phục hồi rất tốt.")
    elif val_psnr > 25 and val_ssim > 0.85:
        print("👍 TỐT. Bộ lọc hoạt động hiệu quả.")
    elif val_psnr > 20:
        print("👌 KHÁ. Chấp nhận được với bộ lọc cơ bản.")
    else:
        print("⚠️ CẦN CẢI THIỆN. Kiểm tra lại thuật toán.")
    print("="*40)

if __name__ == "__main__":
    main()