 section .rodata

section .bss
    curr_dist: resd 1
    CURR: resd 1
    rad_temp: resd 1
    id: resd 1
    x_print: resd 1
    y_print: resd 1
    alpha_print: resd 1
    kills_print: resd 1
    id_print: resd 1
section .data
    ang_generated: dd 0
    MAXINT: dd 65535
    ang_size: dd 120
    ang_sub: dd 60
    dist_size: dd 50
    calc_ang: dd 180
    format_2_floats: db "%.2f, %.2f",10,0
    format_drone: db "%d, %.2f, %.2f, %.2f, %d" ,10,0

    
section .text
    align 16
    global function_printer
    extern resume
    extern cors
    extern K
    extern N
    extern printf
    extern generate_random_number
    extern seed
    extern cois
    extern drones_arr
    extern mayDestroy
    extern T
    extern x_target
    extern y_target

;insert the target, y and then x, the sub esp 9 iits for the qword
function_printer:
    sub esp , 8
    finit
    fld dword [y_target]
    fstp qword [esp]
    ffree
    sub esp , 8
    finit
    fld dword [x_target]
    fstp qword [esp]
    ffree
    ;pushing the print format
    push format_2_floats
    call printf
    ;return the esp back to his place before the print
    add esp , 20
    ;prepare
    mov eax , 0
    mov ebx , eax
    inc ebx
    print_drones_loop:
        cmp dword eax , [N]
        je finish_all_print
        
        ;67-74 calculate the drones cell in the drones _arr 
        pushad
        mov ecx , 0
        mov ecx , 20
        mul ecx

        mov ecx , 0
        mov ecx , [drones_arr]
        add ecx , eax

        ;77-88 move the x,y,alpha kills and id of the drones to global varibels
        mov edx , ecx

        mov ecx , [edx]
        mov dword [x_print] , ecx
        mov ecx , [edx+4]
        mov dword [y_print] , ecx
        mov ecx , [edx+8]
        mov dword [alpha_print] , ecx
        mov ecx , [edx+12]
        mov dword [kills_print] , ecx
        mov ecx , [edx+16]
        mov dword [id_print] , ecx

        popad
        
        push eax
        push ebx
        ; push all the fields into the stack to prepare for printing
        push dword [kills_print]
        sub esp , 8
        finit
        ;alpha, y,x are floating point numbers hence we need to push them from the FPU
        fld dword [alpha_print]
        fstp qword [esp]
        ffree
        sub esp , 8
        finit
        fld dword [y_print]
        fstp qword [esp]
        ffree
        sub esp , 8
        finit
        fld dword [x_print]
        fstp qword [esp]
        ffree
        push dword [id_print]
        push format_drone
        call printf
        
        add esp ,36

        pop ebx
        pop eax 
        ; increment for the next drones
        inc eax
        inc ebx
        jmp print_drones_loop

    ;prepare the next function in the co-routins (sched)
    finish_all_print:
        mov ebx , 0
        mov dword ebx , [cois]
        call resume
        jmp function_printer


            



