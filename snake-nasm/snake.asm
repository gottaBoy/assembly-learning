; =============================================
; 贪吃蛇游戏 - NASM 版本 (适用于 DOS .COM 文件)
; 从 MASM/TASM 原始代码转换而来
; 编译命令: nasm -f bin snake.asm -o snake.com
; =============================================

org 100h        ; DOS .COM 文件起始地址

; ----------------------------
; 数据段定义
; ----------------------------
section .data
    ; 游戏状态变量
    snake_length dw 3      ; 蛇的初始长度
    snake_body times 400 db 0 ; 蛇身坐标数组 (最大200节，每节2字节)
    food_pos dw 0, 0       ; 食物位置 (行, 列)
    direction db 1         ; 移动方向: 1=右, 2=下, 3=左, 4=上
    game_over db 0         ; 游戏结束标志
    score dw 0             ; 当前得分
    speed dw 0x0A000       ; 游戏速度 (延迟循环次数)
    
    ; 显示字符定义
    char_snake db 'O'      ; 蛇身显示字符
    char_food db '@'       ; 食物显示字符
    char_wall db '#'       ; 墙壁显示字符
    msg_score db 'Score: $'
    msg_gameover db 'Game Over! Press Q to quit$'
    msg_controls db 'Controls: Arrow Keys$'

    ; 增加调试
    debug_init db 'Debug: Game initialized. Direction=1, GameOver=0$'

; ----------------------------
; 未初始化数据段
; ----------------------------
section .bss
    head_pos resw 1        ; 蛇头位置临时存储
    tail_pos resw 1        ; 蛇尾位置临时存储

; ----------------------------
; 代码段
; ----------------------------
section .text
    global _start

_start:
    call init_game        ; 初始化游戏
    ; call game_loop        ; 进入主游戏循环
    
    ; 程序退出
    mov ax, 4C00h
    int 21h

; =============================================
; 初始化游戏
; =============================================
init_game:
    ; Push All，将AX/CX/DX/BX/SP/BP/SI/DI压栈保存
    pusha
    
    ; 设置80x25文本模式
    mov ax, 0003h
	; BIOS视频中断
    int 10h
    
    ; 设置光标形状功能, 隐藏光标
    mov ah, 01h
    mov cx, 2607h
    int 10h
    
    ; 初始化蛇身 (3节), 将行号（12）左移8位后与列号（12）合并，存储为0x0C0C（DH=12, DL=12）
    mov word [snake_length], 3
    mov word [snake_body], (12 << 8) | 12   ; 第1节: 行12, 列12
    mov word [snake_body+2], (12 << 8) | 13 ; 第2节
    mov word [snake_body+4], (12 << 8) | 14 ; 第3节
    
    ; 初始化方向 (向右)
    mov byte [direction], 1
    
    ; 重置游戏状态
    mov byte [game_over], 0
    mov word [score], 0
    
    ; 生成第一个食物
    call generate_food
    
    ; 绘制初始游戏界面
    call draw_walls
    call draw_game
    
    popa
    ret

; =============================================
; 主游戏循环
; =============================================
game_loop:
    call handle_input     ; 处理用户输入
    call update_snake     ; 更新蛇的位置
    call check_collisions ; 检查碰撞
    call draw_game        ; 重绘游戏界面
    
    ; 控制游戏速度的延迟
    mov cx, [speed]
    .delay_loop:
        nop
        loop .delay_loop
    
    ; 检查游戏是否结束
    cmp byte [game_over], 0
    je game_loop         ; 继续游戏
    
    ; 游戏结束处理
    call show_game_over
    ret

; =============================================
; 处理键盘输入
; =============================================
handle_input:
    pusha
    
    ; 检查键盘缓冲区是否有按键
    mov ah, 01h
    int 16h
    jz .no_input         ; 无按键则跳过
    
    ; 获取按键扫描码
    mov ah, 00h
    int 16h
    
    ; 检查方向键
    cmp ah, 48h          ; 上箭头
    je .up
    cmp ah, 50h          ; 下箭头
    je .down
    cmp ah, 4Bh          ; 左箭头
    je .left
    cmp ah, 4Dh          ; 右箭头
    je .right
    cmp al, 'q'          ; Q键退出
    je .quit
    jmp .no_input
    
    .up:
        ; 不能直接从上变下
        cmp byte [direction], 2
        je .no_input
        mov byte [direction], 4
        jmp .no_input
    .down:
        cmp byte [direction], 4
        je .no_input
        mov byte [direction], 2
        jmp .no_input
    .left:
        cmp byte [direction], 1
        je .no_input
        mov byte [direction], 3
        jmp .no_input
    .right:
        cmp byte [direction], 3
        je .no_input
        mov byte [direction], 1
        jmp .no_input
    .quit:
        mov byte [game_over], 1
    
    .no_input:
    popa
    ret

; =============================================
; 更新蛇的位置
; =============================================
update_snake:
    pusha
    
    ; 1. 移动蛇身 (从尾部向前移动)
    mov cx, [snake_length]
    dec cx
    shl cx, 1           ; 每节2字节
    mov si, snake_body
    mov di, si
    add di, 2
    
    .move_loop:
        mov ax, [di]
        mov [si], ax
        add si, 2
        add di, 2
        loop .move_loop
    
    ; 2. 根据方向移动蛇头
    mov si, [snake_length]
    dec si
    shl si, 1
    add si, snake_body   ; SI指向蛇头
    
    mov dx, [si]        ; DH=行, DL=列
    
    cmp byte [direction], 1
    je .move_right
    cmp byte [direction], 2
    je .move_down
    cmp byte [direction], 3
    je .move_left
    cmp byte [direction], 4
    je .move_up
    
    .move_right:
        inc dl
        jmp .move_done
    .move_down:
        inc dh
        jmp .move_done
    .move_left:
        dec dl
        jmp .move_done
    .move_up:
        dec dh
    
    .move_done:
    mov [si], dx        ; 更新蛇头位置
    
    ; 3. 检查是否吃到食物
    cmp dx, [food_pos]
    jne .no_food
    
    ; 吃到食物 - 增加长度
    inc word [snake_length]
    add word [score], 10
    
    ; 生成新食物
    call generate_food
    
    .no_food:
    popa
    ret

; =============================================
; 生成食物位置
; =============================================
generate_food:
    pusha
    
    .try_again:
    ; 随机生成行(1-23)
    rdtsc               ; 使用时间戳作为简单随机数
    xor dx, dx
    mov cx, 23
    div cx
    inc dl              ; DL = 1-23
    mov dh, dl
    
    ; 随机生成列(1-78)
    rdtsc
    xor dx, dx
    mov cx, 78
    div cx
    inc dl              ; DL = 1-78
    xchg dh, dl         ; DH=行, DL=列
    
    ; 检查是否与蛇身重叠
    mov cx, [snake_length]
    mov si, snake_body
    .check_loop:
        cmp dx, [si]
        je .try_again   ; 重叠则重新生成
        add si, 2
        loop .check_loop
    
    ; 保存有效食物位置
    mov [food_pos], dx
    
    popa
    ret

; =============================================
; 检查碰撞
; =============================================
check_collisions:
    ret
    ; pusha
    
    ; ; 获取蛇头位置
    ; mov si, [snake_length]
    ; dec si
    ; shl si, 1
    ; add si, snake_body
    ; mov dx, [si]        ; DH=行, DL=列
    
    ; ; 检查墙壁碰撞
    ; cmp dh, 0           ; 上边界
    ; je .collision
    ; cmp dh, 24          ; 下边界
    ; je .collision
    ; cmp dl, 0           ; 左边界
    ; je .collision
    ; cmp dl, 79          ; 右边界
    ; je .collision
    
    ; ; 检查自身碰撞
    ; mov cx, [snake_length]
    ; dec cx              ; 不检查蛇头
    ; jle .no_collision   ; 长度<=1时不检查
    
    ; mov si, snake_body
    ; .self_check:
    ;     cmp dx, [si]
    ;     je .collision
    ;     add si, 2
    ;     loop .self_check
    
    ; .no_collision:
    ; popa
    ; ret
    
    ; .collision:
    ; mov byte [game_over], 1
    ; popa
    ; ret

; =============================================
; 绘制游戏界面
; =============================================
draw_game:
    pusha
    
    ; 清屏 (只清游戏区域)
    mov ax, 0600h
    mov bh, 07h         ; 属性
    mov cx, 0101h       ; 左上角 (1,1)
    mov dx, 184Eh       ; 右下角 (24,78)
    int 10h
    
    ; 绘制边界
    call draw_walls
    
    ; 绘制蛇
    mov cx, [snake_length]
    mov si, snake_body
    .draw_snake:
        mov dx, [si]    ; DH=行, DL=列
        mov al, [char_snake]
        call draw_char
        add si, 2
        loop .draw_snake
    
    ; 绘制食物
    mov dx, [food_pos]
    mov al, [char_food]
    call draw_char
    
    ; 显示分数
    call show_score
    
    popa
    ret

; =============================================
; 绘制字符到指定位置
; 输入: DH=行, DL=列, AL=字符
; =============================================
draw_char:
    pusha
    
    ; 设置光标位置
    mov ah, 02h
    mov bh, 0           ; 页号
    int 10h
    
    ; 绘制字符
    mov ah, 09h
    mov bh, 0
    mov bl, 0Ah         ; 颜色 (亮绿)
    mov cx, 1           ; 重复次数
    int 10h
    
    popa
    ret

; =============================================
; 绘制游戏边界
; =============================================
draw_walls:
    pusha
    
    ; 绘制上边界
    mov dh, 0
    mov dl, 0
    mov cx, 80
    .top:
        mov al, [char_wall]
        call draw_char
        inc dl
        loop .top
    
    ; 绘制下边界
    mov dh, 24
    mov dl, 0
    mov cx, 80
    .bottom:
        mov al, [char_wall]
        call draw_char
        inc dl
        loop .bottom
    
    ; 绘制左右边界
    mov dh, 1
    mov cx, 23
    .sides:
        ; 左边界
        mov dl, 0
        mov al, [char_wall]
        call draw_char
        
        ; 右边界
        mov dl, 79
        mov al, [char_wall]
        call draw_char
        
        inc dh
        loop .sides
    
    popa
    ret

; =============================================
; 显示分数
; =============================================
show_score:
    pusha
    
    ; 设置光标位置 (0,60)
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 60
    int 10h
    
    ; 显示"Score: "文本
    mov ah, 09h
    mov dx, msg_score
    int 21h
    
    ; 转换分数为ASCII并显示
    mov ax, [score]
    call print_number
    
    popa
    ret

; =============================================
; 显示游戏结束信息
; =============================================
show_game_over:
    pusha
    
    ; 设置光标位置 (12,30)
    mov ah, 02h
    mov bh, 0
    mov dh, 12
    mov dl, 30
    int 10h
    
    ; 显示游戏结束信息
    mov ah, 09h
    mov dx, msg_gameover
    int 21h
    
    ; 等待按键
    mov ah, 00h
    int 16h
    
    popa
    ret

; =============================================
; 辅助函数: 打印数字 (AX中的值)
; =============================================
print_number:
    pusha
    
    ; 跳过前导零
    mov bx, 10000
    call .print_digit
    mov bx, 1000
    call .print_digit
    mov bx, 100
    call .print_digit
    mov bx, 10
    call .print_digit
    
    ; 最后一位
    add al, '0'
    mov ah, 0Eh
    int 10h
    
    popa
    ret
    
    .print_digit:
        xor dx, dx
        div bx          ; AX = AX/BX, DX = AX%BX
        push dx         ; 保存余数
        or al, al
        jz .skip_zero   ; 如果商为零则跳过
        
        add al, '0'
        mov ah, 0Eh
        int 10h
        .skip_zero:
        pop ax          ; 恢复余数到AX
        ret

; =============================================
; 程序结束
; =============================================