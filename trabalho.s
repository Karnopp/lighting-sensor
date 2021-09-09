.equ oito, 0b01111111
.equ nove, 0b00011111
.equ quatro, 0b00011011
.equ sete, 0b00011101
.equ zero, 0b01111101
.equ um, 0b00011000
.equ tres, 0b00111110
.equ cinco, 0b00110111
.equ seis, 0b01110111
.equ dois, 0b01101110
.equ DDRB, 0x04
.equ DDRC, 0x07
.equ DDRD, 0x0A
.equ PORTD, 0x0B
.equ PORTB, 0x05
.equ PINC, 0x06
.equ ADCH, 0x79
.equ ADCL, 0x78
.equ ADMUX, 0x7C
.equ ADCSRA, 0x7A

.global main
    .type main, @function
main:
    ldi r16, oito
    out DDRB, r16 ;portas de 0 a 6 como saida
    out DDRD, r16 ;portas de 0 a 6 como saida

    rcall inicializa_ADC

loop:
    rcall delay_omic

    rcall atualiza_ADC

    lds r24, ADCL  ; primeiro ler ADCL (parte baixa)
    lds r25, ADCH  ; depois ler ADCH (parte alta)

    ldi r18,100  ;carregando r18 com 100 (r18 eh o divisor)
    rcall divWordByByte

    mov r26, r24 ;em r24 esta o valor da divisao
    rcall calcula_valor_display
    cpi r24, 10
    breq loop ;se printado noventa e nove, volta para inicio do loop
    out PORTB, r17 ;printa valor no display da esquerda

    mov r24, r23 ;parte baixa recebe o resto da ultima divisao
    eor r25, r25 ;zerando r25
    ldi r18,10 ;carregando r18 com 10 (r18 eh o divisor)
    rcall divWordByByte

    mov r26, r24 ;em r24 esta o valor da divisao
    rcall calcula_valor_display
    out PORTD, r17 ;printa valor no display da direita

    jmp loop

inicializa_ADC:
    ldi r16, 0b01000000
    sts ADMUX, r16
    ; Voltage Reference: AVcc with external capacitor at AREF pin
    ; Input: ADC0
    ; ADLAR = 0 (bits mais significativos em ADCH, e menos significativos em ADCL)

    ldi r16, 0b10000000   ; habilitando ADC
    sts ADCSRA, r16

    ret

atualiza_ADC:
    ldi r16, 0b01000000  ; ADSC = 1 para iniciar conversao do sinal analogico para digital
    lds r17, ADCSRA;
    or  r17, r16;
    sts  ADCSRA, r17
    ret

calcula_valor_display:
    cpi r26, 0
    breq zeroo
    cpi r26, 1
    breq umm
    cpi r26, 2
    breq doiss
    cpi r26, 3
    breq tress
    cpi r26, 4
    breq quatroo
    cpi r26, 5
    breq cincoo
    cpi r26, 6
    breq seiss
    cpi r26, 7
    breq setee
    cpi r26, 8
    breq oitoo
    cpi r26, 9
    breq novee
    ;se o valor passar de 9, print noventa e nove (valor maximo)
noventaenove:
    ldi r17, nove
    out PORTB, r17 ;printa valor no display da esquerda
    out PORTD, r17 ;printa valor no display da direita
    ret

zeroo:
    ldi r17, zero
    ret
umm:
    ldi r17, um
    ret
doiss:
    ldi r17, dois
    ret
tress:
    ldi r17, tres
    ret
quatroo:
    ldi r17, quatro
    ret
cincoo:
    ldi r17, cinco
    ret
seiss:
    ldi r17, seis
    ret
setee:
    ldi r17, sete
    ret
oitoo:
    ldi r17, oito
    ret
novee:
    ldi r17, nove
    ret

;as funcoes a baixo foram vistas em aula
delay_omic:
    #a função destrói o conteúdo de r16 e r17. Cuidado
    ldi  r16, 0xFF ; carrega 0xFF para r16
    ldi  r17, 0xFF ; carrega 0xFF para r17
delay_loop:
    nop
    nop
    nop
    nop
    nop
    nop
    dec  r17 ; decremente 1 de r17
    brne delay_loop ;salta se o flag ZERO não está setado
    dec  r16 ; decrementa r16
    brne delay_loop ; salta se o flag ZERO não está setado
    ret

;para a funcao de divisao:
;em r25 e r24 estao o valor do divisor, sem que em r5 estao os bit mais significativos
;em r18 esta o divisor
;e o resultado da divisao (quociente) ficara em 24
divWordByByte:
    push r16
    clr r23 ;for remainder
    ldi r16, 17 ;loop counter
div_lp:
    rol r24  ;store quot bit and start
    rol r25
    dec r16
    breq exit_div ;exit on 9th iteration
    rol r23  ;complete shift into dividend window
    sub r23, r18 ;trial division
    brcc goesinto  ;cc means quot bit is 1
    add r23, r18 ;undo subtraction
    clc ;next quot bit is 0
    rjmp div_lp
goesinto:
    sec ;next quot bit is 1
    rjmp div_lp
exit_div:
    pop r16
    ret
