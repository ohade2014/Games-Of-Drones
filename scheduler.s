section	.rodata

section .bss

section .data
    k_counter: dd 1

section .text
    align 16
    global main
    global function_schedeuler
    extern resume
    extern cors
    extern K
    extern N
function_schedeuler:
    mov eax, 1
    sch_loop:
        cmp dword eax , [N]; for round robin, we make modulo N
        jbe not_N
        mov eax , 1
        not_N:
        mov edx ,eax
        add edx, 2; the first 3 is the sched, target and printer
        push eax; save the right drone
        mov eax , edx; 26-30 calculcate the offset of the drones in the cors array
        mov ecx , 4
        mul ecx
        mov edx , 0
        mov edx ,eax
        pop eax
        mov ebx , 0;32-35 move to ebx the right drone func for calling "resume"
        mov dword ebx, [cors]
        add ebx, edx
        mov ebx, [ebx]
    
        call resume
        
        mov ebx , 0;39-42 check if the number of routition is modulo k if it is the program eill call the Print co-routine
        mov dword ebx , [K]
        cmp dword [k_counter], ebx
        jne not_print

        ;prepare ebx to include the print func before calling resume, and intialize k_counter with 0
        do_print:
        push edx
        mov edx , 0
        mov dword [k_counter] , edx
        pop edx
        mov ebx , 0
        mov dword ebx, [cors]
        add ebx,4
        mov ebx, [ebx]
        call resume

        ; increment k_counter and jump back to the start of the loop
        not_print:
        inc eax
        push ebx
        mov ebx , 0
        mov dword ebx , [k_counter]
        inc ebx
        mov dword [k_counter] , ebx
        pop ebx
        jmp sch_loop