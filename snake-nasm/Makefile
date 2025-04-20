# Makefile for Greedy Snake on macOS with DOSBox
# brew install nasm
# brew install --cask dosbox-x
# brew install --cask utm
# brew install qemu
# make        # 构建程序
# make run    # 在 DOSBox 中运行
# make clean  # 清理构建文件
# https://dos.zczc.cz/
# https://github.com/rwv/chinese-dos-games
# https://zaixianwan.app/games/custom
# https://blog.csdn.net/kangkanglhb88008/article/details/126299695
# https://www.cnblogs.com/lygin/p/16937983.html

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
    # sudo ln -s /Applications/dosbox-x.app/Contents/MacOS/DOSBox-X /usr/local/bin/dosbox-x
	# /Applications/dosbox-x.app/Contents/MacOS/dosbox-x -fastlaunch -c "mount c: ." -c "c:" -c "$(BUILD_DIR)/$(TARGET)"
	# dosbox-x -conf dosbox-x.conf -fastlaunch -c "$(BUILD_DIR)/$(TARGET)"
	# dosbox -c "mount c: ." -c "c:" -c "masm snake.asm;" -c "link snake.obj;"
	# brew install qemu
	# qemu-system-x86_64 $(BUILD_DIR)/$(TARGET)
	# 下载 FreeDOS 镜像
    # wget https://www.freedos.org/download/download/fd11src.iso
    # 运行 QEMU 并将 snake.com 作为软盘注入
	# qemu-system-x86_64 \
	# 	-boot d -cdrom fd11src.iso \
	# 	-drive file=fat:rw:build/,format=raw,media=disk
	/Applications/dosbox-x.app/Contents/MacOS/DOSBox-X \
		-fastlaunch -machine voodoo -set "sdl=usesdl2=true" \
		-set "keyboardlayout=auto" \
  		-set "cycles=fixed 30000" \
		-c "mount c: $(shell pwd)" \
		-c "c:" \
		-c "cd build" \
		-c "snake.com"
	

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean