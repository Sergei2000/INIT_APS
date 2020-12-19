use16
org 1000h

PML4_addr equ 200000h
PDPE_addr equ 201000h
PDE_addr  equ 202000h
cli;
xor ax,ax
mov ds,ax;

lgdt [gdt_reg];


mov eax,cr0;
or al,1;
mov cr0,eax; enable protected mode

jmp  8:moy_cod;

moy_cod:
use32

mov ax,16;
mov es,ax;
mov ds,ax;

mov dword [es:PDE_addr], 10000011b    ; элемент каталога страниц
mov dword [es:PDE_addr+4], 0
mov dword [es:PDPE_addr], PDE_addr or 3    ; элемент таблицы указателей на каталоги страниц
mov dword [es:PDPE_addr+4], 0
mov dword [es:PML4_addr], PDPE_addr or 3   ; элемент в 4ом уровне
mov dword [es:PML4_addr+4], 0

mov eax, PML4_addr
mov cr3, eax		;базовый адрес цепочки таблиц в cr3

mov ecx, 0xC0000080
rdmsr
bts eax,8
wrmsr			;режим longmode 

mov eax, cr0
bts eax, 31 ; табличная трансляция
mov cr0, eax
jmp LM_CODE_START

LM_CODE_START:
use64
mov rdi,0x100;
mov byte[rdi],0;

mov rdi,80000100h; это адрес видеобуфера
add rdi,100000;
mov rcx,0x1000;
cikl:
mov word[rdi],0xe144;
;mov [video_buf],0xe144;
inc rdi;
inc rdi; 
loop cikl;
mov rdi,0x100;
mov word[rdi],0xffff;
add rdi,2
mov word[rdi],0xffff;
jmp $;



align 8
gdt: 
zero db 0,0,0,0,0,0,0,0;
code db 0xff,0xff,0,0,0,10011010b,11001111b,0; pamyat dlya coda v 32 mode
data_seg db 0xff, 0xff, 0, 0, 0,10010110b,11001111b,0; pamyat dlya dannyh v 32 mode 
gdtend:
gdt_reg:
	.size dw gdtend-gdt-1;
	.address dd gdt;

