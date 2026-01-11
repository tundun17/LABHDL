from PIL import Image
import os

# --- CẤU HÌNH KHỚP VỚI VERILOG ---
WIDTH = 2048
HEIGHT = 1365
HEX_FILE = 'gray_output.txt'
OUTPUT_IMG = 'ketqua_xam.jpg'

def view_image():
    if not os.path.exists(HEX_FILE):
        print(f"❌ Lỗi: Không tìm thấy file '{HEX_FILE}'")
        return

    print("⏳ Đang đọc file hex (file lớn, vui lòng chờ)...")
    with open(HEX_FILE, 'r') as f:
        # Đọc và lọc bỏ dòng trống
        lines = [line.strip() for line in f.readlines() if line.strip()]

    print(f"📊 Đã đọc {len(lines)} pixel.")

    if len(lines) != WIDTH * HEIGHT:
        print(f"⚠️ Cảnh báo: Số lượng pixel ({len(lines)}) không khớp với {WIDTH}x{HEIGHT} = {WIDTH*HEIGHT}")
        print("   -> Ảnh có thể bị lệch hoặc thiếu dữ liệu.")

    # Chuyển Hex sang Int
    pixels = []
    for line in lines:
        try:
            pixels.append(int(line, 16))
        except ValueError:
            pixels.append(0)

    # Tạo ảnh Grayscale (Mode 'L')
    try:
        img = Image.new('L', (WIDTH, HEIGHT))
        img.putdata(pixels)
        img.save(OUTPUT_IMG)
        print(f"✅ Thành công! Đã lưu ảnh tại: {OUTPUT_IMG}")
        img.show() # Tự động mở ảnh
    except Exception as e:
        print(f"❌ Lỗi khi tạo ảnh: {e}")

if __name__ == '__main__':
    view_image()