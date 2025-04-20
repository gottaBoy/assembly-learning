# Makefile for Greedy Snake on macOS with DOSBox
# brew install dosbox nasm
# brew install --cask utm
# make        # 构建程序
# make run    # 在 DOSBox 中运行
# make clean  # 清理构建文件

# Compiler and assembler
ASM = nasm
ASMFLAGS = -f bin

# Output files
TARGET = snake.com
BUILD_DIR = build

# Source files
SRC = snake.asm

all: $(BUILD_DIR)/$(TARGET)

$(BUILD_DIR)/$(TARGET): $(SRC)
	@mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

run: $(BUILD_DIR)/$(TARGET)
	# dosbox -c "mount c: ." -c "c:" -c "$(BUILD_DIR)/$(TARGET)"
	# dosbox -c "mount c: ." -c "c:" -c "masm snake.asm;" -c "link snake.obj;"
	# brew install qemu
	qemu-x86_64 ./snake.com

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean