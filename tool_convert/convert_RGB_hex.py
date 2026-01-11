from PIL import Image
import os

INPUT_IMG = 'baitap2_anhgoc.jpg' # Ảnh bất kỳ
OUTPUT_TXT = 'rgb_input.txt'

def create_hex_input():
    if not os.path.exists(INPUT_IMG):
        print(f"❌ Lỗi: Không tìm thấy {INPUT_IMG}")
        return

    img = Image.open(INPUT_IMG)
    img = img.convert('RGB')
    
    # Lấy kích thước thật của ảnh
    real_w, real_h = img.size 
    
    pixels = list(img.getdata())
    
    with open(OUTPUT_TXT, 'w') as f:
        for r, g, b in pixels:
            f.write(f'{r:02X}{g:02X}{b:02X}\n')
            
    print("✅ Xong! Bạn hãy COPY dòng dưới đây vào đầu file Verilog TB:")
    print("-" * 50)
    print(f"parameter WIDTH  = {real_w};")
    print(f"parameter HEIGHT = {real_h};")
    print("-" * 50)

if __name__ == '__main__':
    create_hex_input()