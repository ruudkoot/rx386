
;-------------------------------------------------------------------------------
; SCHEDULING
;-------------------------------------------------------------------------------

%macro SCHEDULER_PROLOGUE 0
  pusha
  xor eax, eax
  mov ax, ds
  push eax
  mov ax, es
  push eax
  mov ax, fs
  push eax
  mov ax, gs
  push eax
  mov eax, SELECTOR_DATA0
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ebp, esp
%endmacro

%macro SCHEDULER_SAVESTATE 2
  mov %1, [CurrentThread]
  mov %2, [ebp+64]
  mov [%1+TCB_SS], %2
  mov %2, [ebp+60]
  mov [%1+TCB_ESP], %2
  mov %2, [ebp+56]
  mov [%1+TCB_EFLAGS], %2
  mov %2, [ebp+52]
  mov [%1+TCB_CS], %2
  mov %2, [ebp+48]
  mov [%1+TCB_EIP], %2
  mov %2, [ebp+12]
  mov [%1+TCB_DS], %2
  mov %2, [ebp+8]
  mov [%1+TCB_ES], %2
  mov %2, [ebp+4]
  mov [%1+TCB_FS], %2
  mov %2, [ebp+0]
  mov [%1+TCB_GS], %2
  mov %2, [ebp+44]
  mov [%1+TCB_EAX], %2
  mov %2, [ebp+40]
  mov [%1+TCB_ECX], %2
  mov %2, [ebp+36]
  mov [%1+TCB_EDX], %2
  mov %2, [ebp+32]
  mov [%1+TCB_EBX], %2
  mov %2, [ebp+24]
  mov [%1+TCB_EBP], %2
  mov %2, [ebp+20]
  mov [%1+TCB_ESI], %2
  mov %2, [ebp+16]
  mov [%1+TCB_EDI], %2
%endmacro

%macro SCHEDULER_LINKTHREAD 3
  mov %2, [CurrentThread]
  mov %3, [%2+TCB_NEXT]
  mov [%2+TCB_NEXT], %1
  mov [%1+TCB_PREV], %2
  mov [%1+TCB_NEXT], %3
  mov [%3+TCB_PREV], %1
%endmacro

%macro SCHEDULER_LINKANDSELECTTHREAD 3
  mov %2, [CurrentThread]
  mov %3, [%2+TCB_NEXT]
  mov [%2+TCB_NEXT], %1
  mov [%1+TCB_PREV], %2
  mov [%1+TCB_NEXT], %3
  mov [%3+TCB_PREV], %1
  mov [CurrentThread], %1
%endmacro

%macro SCHEDULER_UNLINKFROMRUNQUEUE 3
  mov %2, [%1+TCB_PREV]
  mov %3, [%1+TCB_NEXT]
  ; FIXME: edge case when %1 = %2 = %3
  mov [%2+TCB_NEXT], %3
  mov [%3+TCB_PREV], %2
%endmacro

%macro SCHEDULER_NEXTTHREAD 1
  mov %1, [%1+TCB_NEXT]
  mov [CurrentThread], %1
%endmacro

%macro SCHEDULER_SWITCHTASK 2
  mov %2, [%1+TCB_SS]
  mov [ebp+64], %2
  mov %2, [%1+TCB_ESP]
  mov [ebp+60], %2
  mov %2, [%1+TCB_EFLAGS]
  mov [ebp+56], %2
  mov %2, [%1+TCB_CS]
  mov [ebp+52], %2
  mov %2, [%1+TCB_EIP]
  mov [ebp+48], %2
  mov %2, [%1+TCB_DS]
  mov [ebp+12], %2
  mov %2, [%1+TCB_ES]
  mov [ebp+8], %2
  mov %2, [%1+TCB_FS]
  mov [ebp+4], %2
  mov %2, [%1+TCB_GS]
  mov [ebp+0], %2
  mov %2, [%1+TCB_EAX]
  mov [ebp+44], %2
  mov %2, [%1+TCB_ECX]
  mov [ebp+40], %2
  mov %2, [%1+TCB_EDX]
  mov [ebp+36], %2
  mov %2, [%1+TCB_EBX]
  mov [ebp+32], %2
  mov %2, [%1+TCB_EBP]
  mov [ebp+24], %2
  mov %2, [%1+TCB_ESI]
  mov [ebp+20], %2
  mov %2, [%1+TCB_EDI]
  mov [ebp+16], %2
%endmacro

%macro SCHEDULER_EPILOGUE 0
  pop gs
  pop fs
  pop es
  pop ds
  popa
  iret
%endmacro

;-------------------------------------------------------------------------------
; NOTIFICATIONS
;-------------------------------------------------------------------------------

;
; NOTIFICATION_POP - Pop TCB from queue and set state to idle if empty
;
%macro NOTIFICATION_POP 4
  mov %2, [NotificationQueueNext+4*%1]
  mov %3, [NotificationQueuePrev+4*%1]
  cmp %2, %3
  jne %%queue_multiple
%%queue_single:
  mov dword [NotificationState+4*%1], NOTIFICATION_IDLE
  jmp %%done
%%queue_multiple:
  ; FIXME: overly complicated as we maintain a ring, while we only need a stack
  mov %4, [%2+TCB_NEXT]
  mov [%4+TCB_PREV], %3
  mov [NotificationQueueNext+4*%1], %4
%%done:
%endmacro
