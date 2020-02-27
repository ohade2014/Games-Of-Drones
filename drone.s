section .rodata

section .bss
    curr_dist: resd 1
    ;CURR: resd 1
    rad_temp: resd 1
    id: resd 1
    val_to_check: resd 1

section .data
    ang_generated: dd 0
    MAXINT: dd 65535
    MAX_ANG: dd 360
    MAX_PLACE: dd 100
    MIN_PLACE: dd 0
    ang_size: dd 120
    ang_sub: dd 60
    dist_size: dd 50
    calc_ang: dd 180
    format_int: db "Drone id %d : I am a winner ",10,0
    
section .text
    align 16
    global function_drone
    extern printf
    extern resume
    extern N
    extern free
    extern cors
    extern K
    ;extern generate_random_number
    extern seed
    extern cois
    extern stacks
    extern drones_arr
    extern mayDestroy
    extern T
    extern CURR


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


function_drone:
    ; generate random number using LFSR , seed is initial value
    calculate_random_angle:
        generate_random_number
        after_gen_4:
        pushad
        finit
        fild dword [seed]
        fild dword [MAXINT]
        fdiv
        fild dword [ang_size]
        fmul
        fild dword [ang_sub]
        fsub
        fstp dword [ang_generated]
        popad
        ffree
    calculate_random_distance:
        generate_random_number
        after_gen_5:
        finit
        fild dword [seed]
        fild dword [MAXINT]
        fdiv
        fild dword [dist_size]
        fmul
        fstp dword [curr_dist]
        ffree
    update_position:
        ;pushad
        mov ebx, 0
        mov eax, 0
        mov ebx, [cois]
        mov eax, [CURR]
        sub eax, ebx
        mov ecx , 0
        mov ecx , 8
        cwd
        div ecx
        sub eax , 3
        mov [id], eax
        mov ecx , 0
        mov ecx , 20
        mul ecx
        add eax,8
        mov edx,0
        mov edx, [drones_arr]
        add edx, eax

        check_angle:
        ;start calculate angle and update
        finit
        fld dword [edx]
        fld dword [ang_generated]
        faddp
        fstp dword [edx]
        ffree

        ;mov edx, [edx]

        finit
        fild dword [MAX_ANG]
        fld dword [edx]
        fcomip
        ja above_360
        ffree

        finit
        fild dword [MIN_PLACE]
        fld dword [edx]
        fcomip
        jb neg_ang
        ffree

        jmp in_range

        above_360:
            finit
            fld dword [edx]
            fild dword [MAX_ANG]
            fsubp
            fstp dword [edx]
            ffree
            jmp in_range
        
        neg_ang:
            finit
            fld dword [edx]
            fild dword [MAX_ANG]
            faddp
            fstp dword [edx]
            ffree
        
        in_range:   
            mov ecx,0
            mov ecx, [drones_arr]
            add ecx, eax
            ;mov [ecx], edx
            
            ;calculate angle in radians
            finit 
            fld dword [ecx]
            fldpi
            fmulp
            fild dword [calc_ang]
            fdivp
            fstp dword [rad_temp]
            ffree
            
            ;calculate y
            finit
            fld dword [rad_temp] 
            fsin
            fld dword [curr_dist]
            fmulp

            sub ecx,4 ; move ecx to point on the y value in drone struct
            fld dword [ecx]
            faddp
            fild dword [MAX_PLACE]
            fcomip
            jb y_above_100

            fild dword [MIN_PLACE]
            fcomip
            ja y_is_neg

            fstp dword [val_to_check]
            jmp y_is_almost_ok
            y_above_100:
                fild dword [MAX_PLACE]
                fsubp
                fstp dword [ecx]
                jmp y_is_ok
            y_is_neg:
                fild dword [MAX_PLACE]
                faddp
                fstp dword [ecx]
                jmp y_is_ok
            y_is_almost_ok:
                mov dword ebx , [val_to_check]
                mov [ecx] , ebx
            y_is_ok:
            ffree

            ;calculate x
            finit
            fld dword [rad_temp]
            fcos
            fld dword [curr_dist]
            fmulp

            sub ecx,4 ; move ecx to point on the x value in drone struct
            fld dword [ecx]
            faddp
            fild dword [MAX_PLACE]
            fcomip
            jb x_above_100

            fild dword [MIN_PLACE]
            fcomip
            ja x_is_neg

            fstp dword [val_to_check]
            jmp x_is_almost_ok
    
            x_above_100:
                fild dword [MAX_PLACE]
                fsubp
                fstp dword [ecx]
                jmp x_is_ok
            x_is_neg:
                fild dword [MAX_PLACE]
                faddp
                fstp dword [ecx]
                jmp x_is_ok
            x_is_almost_ok:
                mov dword ebx , [val_to_check]
                mov [ecx] , ebx
            x_is_ok:
    
        push ecx
        call mayDestroy
        cmp eax,1 ;hit target
        je do_destroy
        mov dword ebx ,[cois]
        call resume
        jmp function_drone
        
        do_destroy:
            pushad
            mov dword eax, [id]
            mov edx , 0
            mov edx , 20
            mul edx
            add eax, 12
            add dword eax, [drones_arr]
            mov dword ebx, [eax]
            inc ebx
            mov dword [eax], ebx
            cmp dword ebx, [T]
            je we_found_the_winner
            popad
            mov ebx,0
            mov dword ebx, [cois]
            add ebx, 16
            call resume
            jmp function_drone
            
            mov dword ebx,[cois]
            call resume
            jmp function_drone
            
        we_found_the_winner:
            mov eax , 0
            mov dword eax , [id]
            inc eax
            push eax ;print the winner message
            push format_int
            call printf

            free_all:
            ;Free all memory allocated
            push dword [stacks]
            call free
            add esp , 4
            push dword [cois]
            call free
            add esp , 4
            push dword [cors]
            call free
            add esp , 4
            push dword [drones_arr]
            call free
            add esp , 4

            mov eax, 1;call exit
            mov ebx, 0
            int 0x80
            


