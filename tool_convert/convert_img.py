from PIL import Image
import os

# --- CẤU HÌNH ---
INPUT_IMAGE = 'baitap1_nhieu.jpg'  # Tên file ảnh của bạn
OUTPUT_FILE = 'pic_input.txt'      # Tên file output cho Verilog
TARGET_WIDTH = 430                 # Chiều rộng (phải khớp parameter W trong Verilog)
TARGET_HEIGHT = 554                # Chiều cao (phải khớp parameter H trong Verilog)

def convert_to_hex():
    # 1. Kiểm tra file ảnh tồn tại không
    if not os.path.exists(INPUT_IMAGE):
        print(f"❌ Lỗi: Không tìm thấy file '{INPUT_IMAGE}'")
        return

    print(f"🖼️  Đang xử lý ảnh '{INPUT_IMAGE}'...")

    try:
        # 2. Mở ảnh
        img = Image.open(INPUT_IMAGE)

        # 3. Chuyển sang ảnh xám (Mode 'L' = Luminance)
        img = img.convert('L')

        # 4. Resize về đúng kích thước mong muốn
        # (Bước này cực quan trọng để khớp với mảng nhớ trong Verilog)
        img = img.resize((TARGET_WIDTH, TARGET_HEIGHT))
        print(f"📏 Đã resize về: {TARGET_WIDTH}x{TARGET_HEIGHT}")

        # 5. Lấy dữ liệu pixel
        pixels = list(img.getdata())
        total_pixels = len(pixels)

        # 6. Ghi ra file text
        print(f"💾 Đang ghi file '{OUTPUT_FILE}'...")
        with open(OUTPUT_FILE, 'w') as f:
            for val in pixels:
                # Format: 02X -> Số Hex in hoa, luôn đủ 2 ký tự (VD: 5 -> 05, 255 -> FF)
                f.write(f'{val:02X}\n')
        
        print(f"✅ XONG! Đã tạo file Hex thành công.")
        print(f"📊 Tổng số dòng: {total_pixels} (Khớp {TARGET_WIDTH}*{TARGET_HEIGHT})")

    except Exception as e:
        print(f"❌ Có lỗi xảy ra: {e}")

# Chạy hàm
if __name__ == "__main__":
    convert_to_hex()