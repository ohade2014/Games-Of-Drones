section .rodata

section .bss
    curr_dist: resd 1
    CURR: resd 1
    rad_temp: resd 1
    temp_x: resd 1
    temp_y: resd 1
    temp_x_argt: resd 1
    temp_y_argt: resd 1
    power_temp_x_argt: resd 1
    ;power_temp_y_argt: resd 1
    f_sqrt: resd 1
    gamma: resd 1
    sub_abs_gamma_alpha: resd 1
    patan_result: resd 1
    temp_alpha: resd 1
section .data
    ang_generated: dd 0
    MAXINT: dd 65535
    ang_size: dd 120
    ang_sub: dd 60
    degrees_pi: dd 180
    dist_size: dd 50
    calc_ang: dd 180
    board_size: dd 100
    
section .text
    align 16
    global main
    global function_schedeuler
    global mayDestroy
    global createTarget
    extern x_target
    extern y_target
    extern resume
    extern cors
    extern K
    ;extern generate_random_number
    extern seed
    extern cois
    extern drones_arr
    extern B
    extern dis
    extern x_target
    extern y_target

%macro generate_random_number 0
        pushad
        mov dword edi, 0
        %%loop_seed:
        cmp edi, 16
        je %%final_number_genrated

        ; calculate the left-most digit in the new generated number
        mov edx , 0
        mov dx , [seed]
        mov ecx , 0
        mov cx , [seed]
        shr cx , 1
        mov eax , 0
        jnc %%is_zero_16
        mov eax , 1
        %%is_zero_16:
        shr cx , 2
        mov ebx , 0
        jnc %%is_zero_14
        mov ebx , 1
        %%is_zero_14:
        xor eax , ebx
        shr cx, 1
        mov ebx,0
        jnc %%is_zero_13
        mov ebx,1
        %%is_zero_13:
        xor eax, ebx
        mov ebx , 0
        shr cx , 2
        jnc %%is_zero_11
        mov ebx , 1
        %%is_zero_11:
        xor eax , ebx
        
        ;shift right the seed number
        shr dx , 1
        ;add the generated digit to the new number
        cmp eax , 0
        je %%number_generated
        add dx , 32768
        %%number_generated:
        
        ;put the new value in seed , so we can use it to generate the next number
        mov [seed] , dx
        inc edi
        jmp %%loop_seed
        %%final_number_genrated:
        popad
%endmacro

mayDestroy:
    ; Get the address of activated drone
    mov ebx, [esp+4]

    ; get x and y values of activated drone
    mov ecx,0
    mov ecx, [ebx]
    mov dword [temp_x],ecx
    mov ecx, 0
    mov ecx , [ebx+4]
    mov dword [temp_y],ecx
    mov edx, 0

    ;gamma calculate

    ;substraction of x's
    finit
    fld dword [x_target]
    fld dword [temp_x]
    fsubp
    fstp dword [temp_x_argt]
    ffree

    ;substraction of y's
    finit
    fld dword [y_target]
    fld dword [temp_y]
    fsubp
    fstp dword [temp_y_argt]
    ffree

    ;calculate arctan
    finit
    fld dword [temp_y_argt]
    fld dword [temp_x_argt]
    fpatan
    fstp dword [patan_result]
    ffree

    ; convert gamma to degrees
    finit
    fld dword [patan_result]
    fild dword [degrees_pi]
    fmulp
    fldpi
    fdivp
    fstp dword [gamma]
    ffree

    mov ecx,0
    mov ecx, [ebx+8]
    mov [temp_alpha],ecx

    ;abs calculate

    ;check if need to fix one of the angles
    finit
    fld dword [gamma]
    fld dword [temp_alpha]
    fsubp
    fabs
    fstp dword [sub_abs_gamma_alpha]
    ffree
    
    finit
    fld dword [sub_abs_gamma_alpha]
    fild dword [degrees_pi]
    fcomi
    jae dont_fix_abs
    ffree

    fix_one_of_angles:
    finit
    fld dword [gamma]
    fld dword [temp_alpha]
    fcomi
    ja alpha_is_bigger

    gamma_is_bigger:
    ffree
    finit
    fld dword [temp_alpha]
    fild dword [degrees_pi]
    faddp
    fild dword [degrees_pi]
    faddp
    fld dword [gamma]
    fsubp
    fabs
    fstp dword [sub_abs_gamma_alpha]
    jmp dont_fix_abs

    alpha_is_bigger:
    ffree
    finit
    fld dword [gamma]
    fild dword [degrees_pi]
    faddp
    fild dword [degrees_pi]
    faddp
    fld dword [temp_alpha]
    fsubp
    fabs
    fstp dword [sub_abs_gamma_alpha]
    
    dont_fix_abs:
    ffree

    ;calculate sqrt
    finit
    fld dword [temp_x_argt]
    fld dword [temp_x_argt]
    fmulp
    fstp dword [power_temp_x_argt]
    ffree

    finit
    fld dword [temp_y_argt]
    fld dword [temp_y_argt]
    fmulp
    fld dword [power_temp_x_argt]
    faddp
    fsqrt
    fstp dword [f_sqrt]
    ffree

    check_conditions:
    
    ;first condition
    finit
    fld dword [f_sqrt]
    fild dword [dis]
    fcomi
    jbe ret_0
    ffree

    ;second condition
    finit
    fld dword [sub_abs_gamma_alpha]
    fild dword [B]
    fcomi
    jbe ret_0

    ret_1: ; Target MAY be destroyed
    ffree
    mov eax,1
    ret

    ret_0: ; Target may NOT be destroyed
    ffree
    mov eax,0
    ret

createTarget:
    generate_random_number
    after_generated1:
    finit
    fild dword [seed]
    fild dword [MAXINT]
    fdivp
    fild dword [board_size]
    fmulp
    fstp dword [x_target]
    ffree
    
    generate_random_number
    after_generated2:
    finit
    fild dword [seed]
    fild dword [MAXINT]
    fdivp
    fild dword [board_size]
    fmulp
    fstp dword [y_target]
    ffree
    
    mov ebx,0
    mov dword ebx, [cois]
    call resume
    jmp createTarget


    
    



    
