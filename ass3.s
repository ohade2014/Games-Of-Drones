section	.rodata

section .bss
    STKSIZE equ 16*1024
    CODEP equ 0 ; offset of pointer to co-routine function in co-routine struct
    SPP equ 4 ; offset of pointer to co-routine stack in co-routine struct 
    global N
    global T
    global K
    global B
    global dis
    global seed
    global cors
    global stacks
    global cois
    global drones_arr
    global x_target
    global y_target
    global CURR
    N: resd 1
    T: resd 1
    K: resd 1
    B: resd 1
    dis: resd 1
    SPT: resd 1
    seed: resd 1
    cors: resd 1
    cois: resd 1
    stacks: resd 1
    drones_arr: resd 1
    temp: resd 1
    temp2:resd 1
    rad_temp: resd 1
    SPMAIN: resd 1
    CURR: resd 1
    x_target: resd 1
    y_target: resd 1
    curr_dist: resd 1
section .data
    calc_ang: dd 180
    ang_generated: dd 0
    MAXINT: dd 65535
    ang_size: dd 360
    ang_sub: dd 60
    dist_size: dd 50
    board_size: dd 100
    format_int: db "%d",10,0
    format_2_floats: db "%.2f , %.2f",10,0

section .text
    align 16
    global main
    global resume
    global cors
    ;global K
    ;global B
    ;global N
    ;global d
    ;global T
    global generate_random_number
    ;global seed
    ;global cois
    ;global drones_arr
    ;global y_target
    ;global x_target
    extern malloc
    extern printf
    extern sscanf
    extern atoi
    extern function_schedeuler
    extern function_drone
    extern function_printer
    extern createTarget
    

%macro get_arg 2
        mov ecx, [ebp+12]
        pushad
        push dword %2
        push dword format_int
        push dword [ecx+%1]
        call sscanf
        add esp , 12
        popad
%endmacro

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

    jmp main
    
    _start:
        ;Handle user input
        mov dword eax,4
            get_arg eax, N 
            add eax, 4
            get_arg eax, T 
            add eax, 4
            get_arg eax, K
            add eax, 4
            get_arg eax, B 
            add eax, 4
            get_arg eax, dis
            add eax, 4
            get_arg eax, seed
        lul:
        ; Create space for drones_arr
        mov eax , 0
        mov eax , [N]
        mov ebx , 0
        mov ebx , 4
        mul ebx
        push eax
        call malloc
        mov dword [drones_arr] , eax
        
        mov ebx , 0
        mov ecx , [drones_arr]
        create_drone_info_space:
            cmp ebx , [N]
            je create_all_cors
            mov eax , 20
            pushad
            push eax
            call malloc
            pop eax
            popad
            mov [ecx] , eax
            add ecx , 4
            add ebx , 1
            jmp create_drone_info_space
     
        create_all_cors:
        ; Create space for Cors Array
        mov ebx , [N]
        add ebx , 3
        mov dword eax , ebx
        create_cors:
            mov dword ebx , 4
            mul ebx
            push eax
            call malloc
            mov dword [cors] , eax
        
        ;Create space for coi's
        mov ebx , [N]
        add ebx , 3
        mov dword eax , ebx
        create_cois:
            mov dword ebx , 8
            mul ebx
            push eax
            call malloc
            mov dword [cois] , eax
            
        ;Create space for all stacks
        mov ebx , [N]
        add ebx , 3
        mov dword eax , ebx
        create_stacks:
            mov dword ebx , STKSIZE
            mul ebx
            push eax
            call malloc
            mov dword [stacks] , eax

        ;creates pointers    
        mov dword eax, 0
        mov dword ebx, 0
        mov eax, [cois]
        add eax, 24
        mov ebx, [stacks]
        add ebx, STKSIZE
        add ebx, STKSIZE
        add ebx, STKSIZE
        mov dword ecx, 0
        init_point_to_stacks:
            cmp dword  ecx, [N]
            je init_point_to_cois
            add dword ebx, STKSIZE
            mov dword [eax], function_drone ;init function of coi
            mov dword [eax+4],ebx;init the pointer to the stack
            inc ecx
            add eax ,8
            jmp init_point_to_stacks

        init_point_to_cois:
            mov dword eax, 0
            mov dword ebx, 0
            mov eax, [cors]
            add eax, 12
            mov ebx, [cois]
            add ebx, 24
            mov dword ecx,0
            init_pointers:
                cmp dword  ecx, [N]
                je init_scheduler
                mov [eax], ebx
                add eax, 4
                add ebx, 8
                inc ecx
                jmp init_pointers
        
        init_scheduler:
            mov dword eax, 0
            mov dword eax, [cors] 
            mov dword ebx, 0
            mov ebx, [cois]
            mov [eax], ebx 
            mov dword [ebx] , function_schedeuler
            add ebx, 4
            mov dword ecx, 0
            mov dword ecx, [stacks]
            add ecx, STKSIZE
            mov [ebx], ecx

        init_printer:
            mov dword eax, 0
            mov dword eax, [cors]
            add eax , 4
            mov dword ebx, 0
            mov dword ebx, [cois]
            add ebx , 8
            mov [eax], ebx 
            mov dword [ebx] , function_printer
            add ebx, 4
            mov dword ecx, 0
            mov dword ecx, [stacks]
            add ecx, STKSIZE
            add ecx, STKSIZE
            mov [ebx], ecx
            
        init_target:
            mov dword eax, 0
            mov dword eax, [cors]
            add eax , 8
            mov dword ebx, 0
            mov dword ebx, [cois]
            add ebx , 16
            mov [eax], ebx 
            mov dword [ebx] , createTarget
            add ebx, 4
            mov dword ecx, 0
            mov dword ecx, [stacks]
            add ecx, STKSIZE
            add ecx, STKSIZE
            add ecx, STKSIZE
            mov [ebx], ecx

            ;generate the target x index
            generate_random_number
            finit
            fild dword [seed]
            fild dword [MAXINT]
            fdivp
            fild dword [board_size]
            fmulp
            fstp dword [x_target]
            ffree
            
            ;generate the target y index
            generate_random_number
            finit
            fild dword [seed]
            fild dword [MAXINT]
            fdivp
            fild dword [board_size]
            fmulp
            fstp dword [y_target]
            ffree

        ;init every drone, push the function (the starting adress), and push the flages and registers
        init_co:
            mov ebx, [cois]
            mov edx, -3
            loop_init_co:
            cmp edx, [N]
            je finish_loop_init_co
            mov eax, [ebx] ; get initial EIP value – pointer to COi function
            mov [SPT], ESP ; save ESP value
            mov esp, [EBX+4] ; get initial ESP value – pointer to COi stack
            push eax ; push initial “return” address
            pushfd ; push flags
            pushad ; push all other registers
            mov [ebx+4], esp ; save new SPi value (after all the pushes)
            mov ESP, [SPT] 
            add ebx,8 
            inc edx
            jmp loop_init_co

        finish_loop_init_co:
            jmp after_init

main:
    
    push ebp
    mov ebp,esp
    jmp _start
    
    after_init:
        mov ebx , [drones_arr]
        mov edx , 0
        create_drone_info:
            cmp edx , [N]
            je drone_info_calculated
            
            ;Calculate X value
            generate_random_number
            after_gen_1:
            finit
            fild dword [seed]
            fild dword [MAXINT]
            fdiv
            fild dword [board_size]
            fmul
            mov eax , 0
            fstp dword [temp2]
            ffree
            mov eax, [temp2]
            mov [ebx] , eax
            
            ;Calculate Y value
            generate_random_number
            after_gen_2:
            finit
            fild dword [seed]
            fild dword [MAXINT]
            fdiv
            fild dword [board_size]
            fmul
            mov eax , 0
            fstp dword [temp2]
            ffree
            mov eax, [temp2]
            mov [ebx+4] , eax
            
            ;Calculate angle Value
            generate_random_number
            after_gen_3:
            finit
            fild dword [seed]
            fild dword [MAXINT]
            fdiv
            fild dword [ang_size]
            fmul
            ;fild dword [ang_sub]
            ;fsub
            mov eax , 0
            put_angle:
            fstp dword [temp2]
            ffree
            mov eax, [temp2]
            mov [ebx+8] , eax
            
            ;Calculate Number Of kills
            mov eax , 0
            mov [ebx+12] , eax
            
            ;Calculate Id value
            inc edx
            mov [ebx+16] , edx
            dec edx
            
            inc edx
            add ebx , 20
            jmp create_drone_info
            
        drone_info_calculated:



    startCo:
        pushad ; save registers of main ()
        mov [SPMAIN], ESP ; save ESP of main ()
        mov EBX, [cors] 
        mov ebx, [ebx]; gets a pointer to a scheduler struct
        jmp do_resume

    
    resume: ; save state of current co-routine
        pushfd
        pushad
        mov EDX, [CURR]
        mov [EDX+SPP], ESP ; save current ESP
        do_resume: ; load ESP for resumed co-routine
            mov ESP, [EBX+SPP]
            mov [CURR], EBX
            popad ; restore resumed co-routine state
            popfd
            ret ; "return" to resumed co-routine
    
    
    endCo:
        mov ESP, [SPMAIN] ; restore ESP of main()
        popad 

    
finish_all:
            
            
            
            
        
    
    


