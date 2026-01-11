from PIL import Image
import os

# --- CẤU HÌNH KÍCH THƯỚC ẢNH ---
# Lưu ý: Phải khớp với parameter trong file Verilog (LAB2_TOP.v / LAB2_tb.v)
WIDTH = 430
HEIGHT = 554

def hex_to_image(hex_file, output_image_name):
    # 1. Kiểm tra file tồn tại
    if not os.path.exists(hex_file):
        print(f"❌ Lỗi: Không tìm thấy file '{hex_file}'.")
        print("   Hãy chạy mô phỏng Verilog trên ModelSim để tạo file này trước!")
        return

    print(f"📂 Đang đọc file {hex_file}...")

    try:
        # 2. Đọc dữ liệu từ file Hex
        with open(hex_file, 'r') as f:
            # Đọc từng dòng, bỏ dòng trống và khoảng trắng thừa
            lines = [line.strip() for line in f.readlines() if line.strip()]

        # 3. Chuyển đổi Hex String -> Số nguyên (Integer)
        # Ví dụ: "FF" -> 255, "0A" -> 10
        pixel_values = []
        for line in lines:
            try:
                pixel_values.append(int(line, 16))
            except ValueError:
                print(f"⚠️ Cảnh báo: Dòng lỗi '{line}' không phải mã Hex.")
                pixel_values.append(0) # Điền màu đen nếu lỗi

        actual_pixels = len(pixel_values)
        print(f"📊 Số pixel thu được: {actual_pixels}")

        # 4. Tính toán kích thước dự kiến
        full_size = WIDTH * HEIGHT
        valid_w = WIDTH - 2
        valid_h = HEIGHT - 2
        valid_size = valid_w * valid_h

        # 5. Logic xử lý ảnh (Dùng Pillow thay cho Numpy)
        img = None

        if actual_pixels == full_size:
            print("✅ Kích thước khớp: FULL ẢNH (Bao gồm cả viền).")
            # Tạo ảnh mới chế độ 'L' (Grayscale 8-bit)
            img = Image.new('L', (WIDTH, HEIGHT))
            # Nạp dữ liệu pixel vào ảnh
            img.putdata(pixel_values)

        elif actual_pixels == valid_size:
            print("✅ Kích thước khớp: VALID AREA (Đã cắt bỏ viền).")
            img = Image.new('L', (valid_w, valid_h))
            img.putdata(pixel_values)

        else:
            print("⚠️ CẢNH BÁO: Số lượng pixel không khớp kích thước nào cả!")
            print(f"   - Input Verilog: {WIDTH}x{HEIGHT} = {full_size}")
            print(f"   - File Output:   {actual_pixels}")
            print("   -> Đang cố gắng hiển thị ở dạng vuông (Square) để debug...")
            
            # Tính cạnh hình vuông gần nhất
            side = int(actual_pixels**0.5)
            img = Image.new('L', (side, side))
            # Cắt bớt dữ liệu thừa để nhét vừa hình vuông
            img.putdata(pixel_values[:side*side])

        # 6. Hiển thị và Lưu ảnh
        if img:
            print(f"💾 Đang lưu ảnh: {output_image_name}")
            img.save(output_image_name)
            
            print("👁️ Đang mở ảnh lên xem...")
            img.show() # Mở trình xem ảnh mặc định của Windows
            
    except Exception as e:
        print(f"❌ Có lỗi nghiêm trọng xảy ra: {e}")

# Chạy chương trình
if __name__ == "__main__":
    hex_to_image('pic_output.txt', 'result_image.jpg')