# assembly on mac 
-t
-u
-d
-a

## 汇编语言例子
### 默认例子 
```asm
data segment;定义数据段
  x db 'A'; define byte定义x为一个值为A的ASCII码的字节型变量
  y dw 30h; define word定义y为一个值为30h(48)的字型变量
  z dd 40h; define double word定义z为一个值为40h(64)的双字型变量
  a dw ?;定义一个变量
data ends;段结束的标记

stack1 segment para stack;不需要堆栈段可以不要这部分
  db 10h dup(0)
stack1 ends

code segment
assume cs:code,ds:data; assume伪指令用于确定段与段寄存器的关系，assume不会翻译成机器指令，但会存在于exe的文件头中，这会方便DOS重新分配内存时改变对应地址指针寄存器的值
start:mov ax,data;汇编后段名变成立即数，立即数不能直接赋值给段寄存器
  mov ds,ax;段寄存器将指向data数据段
  mov dl,x;显示字符前将字符移动到dl
  mov ah,02h;调用字符显示
  int 21h
  mov ah,4ch;4ch对应返回控制台子程序
  int 21h;根据ah确定子程序，自动跳转到子程序入口地址
 code ends
end start
```
 
### 大小写转换
```
data segment;数据段
  errs db 'error!$'
data ends

stack1 segment para stack;堆栈段
  
stack1 ends

code segment;代码段
assume cs:code,ds:data
start:mov ax,data;程序起点
      mov ds,ax
input:mov ah,08h;控制台输入到al
      int 21h
      cmp al,'0';是否=0
      jz zero
      cmp al,'A';是否>=A，大于等于则cf=0，对应jnc
      jc err;<A且！=0的情况
      ;下面的情况>=A
      cmp al,5bh;是否<=Z，和Z的后一个字符比较，小于则cf=1，对应jc
      jc plus
      ;下面的情况>Z
      cmp al,'a'
      jc err
      cmp al,7bh
      jc minus
      jnc err
zero: mov dl,'0';移动到dl供显示
      mov ah,02h;字符显示
      int 21h
      mov ah,4ch;返回控制台
      int 21h
plus: add al,20h
      mov dl,al
      jmp show
minus: sub al,20h
       mov dl,al
       jmp show
show: mov ah,02h;字符显示
      int 21h
      loop input
err:  mov dx,offset errs;将errs首地址传送给dx
      mov ah,09h;召唤字符串
      int 21h;芝麻开门
      loop input

code ends;代码段结束
 end start
```


## mac下运行debug
- [在mac平台运行debug.exe](https://www.jianshu.com/p/9fb6fb475539)
- [vscode官网](https://code.visualstudio.com)
- [dosbox](https://www.dosbox.com/)
- [x86assembly](https://cs.lmu.edu/~ray/notes/x86assembly/)
- [masm(语法高亮插件)](https://marketplace.visualstudio.com/items?itemName=blindtiger.masm)
- [MASM/TASM(DOS环境)](https://marketplace.visualstudio.com/items?itemName=xsro.masm-tasm)
- [Linux201-docs](https://github.com/ustclug/Linux201-docs)
- [armv8](https://armv8-doc.readthedocs.io/en/latest/index.html)
- [js-dos](https://js-dos.com/)
- [freedos](https://www.freedos.org/)
- [archbase](https://foxsen.github.io/archbase/)
- [microchip](https://ww1.microchip.com/downloads/cn/DeviceDoc/70202c_cn.pdf)
- [kernel_memory_management](https://github.com/0voice/kernel_memory_management)
- [寄存器](https://github.com/0voice/kernel_memory_management/blob/main/%E2%9C%8D%20%E6%96%87%E7%AB%A0/%E5%B8%B8%E7%94%A8%E5%AF%84%E5%AD%98%E5%99%A8%E6%80%BB%E7%BB%93.md)
- [8086学习笔记](https://github.com/blueSky1825821/8086assembly/tree/main)
- [思维脑图](https://www.yuque.com/docs/share/d7ccd3d3-87ca-4f31-b099-61d7d8c18276?#%20《8086》)
- [MacOS上的汇编入门](https://github.com/Evian-Zhang/Assembly-on-macOS)
- [Linux内幕](https://www.yuque.com/chris-zpich/ag0rz1/fs2goqhx1l9dx3gd)
- [Assembly-Language](https://github.com/bobli1128/Assembly-Language)
- [assembly-language-learning](https://github.com/FriendLey/assembly-language-learning)
- [learn-assembly-on-Apple-Silicon-Mac](https://github.com/Evian-Zhang/learn-assembly-on-Apple-Silicon-Mac)
- [codeOfAssembly](https://github.com/liracle/codeOfAssembly)
- [x86-asm-book-source](https://github.com/lichuang/x86-asm-book-source)
- [assembly-exercises](https://github.com/Yibo-Li/assembly-exercises)
- [assembly-language-learning](https://github.com/FriendLey/assembly-language-learning)
- [Assembly-Lib](https://github.com/oded8bit/Assembly-Lib)
- [coranac](https://www.coranac.com/tonc/text/)
- [reddit](https://www.reddit.com/r/asm/comments/krwtg2/how_does_game_development_work_in_assembly)
- [vga](https://www.wagemakers.be/english/doc/vga/)
- [x86-bare-metal-examples](https://github.com/cirosantilli/x86-bare-metal-examples)
- [go](https://github.com/chai2010/advanced-go-programming-book)
- [grapeos-course](https://gitee.com/jackchengyujia/grapeos-course)
- [sokobanDOS](https://github.com/adamsmasher/sokobanDOS)
- [floppybird](https://github.com/icebreaker/floppybird)
- [asmbook](http://www.genie52.com/asmbook/cover.html)
- [modern-x86-assembly-language-programming-3e](https://github.com/Apress/modern-x86-assembly-language-programming-3e)