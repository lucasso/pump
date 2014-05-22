.nolist
.include "m8def.inc"
.list

.cseg
.org 0

cli
ldi R16, HIGH(RAMEND)
ldi R17, LOW(RAMEND)
out SPH, R16
out SPL, R17

; SETUP klawiatury na pd0-5
; pd0, pd1 wejsciowe, czytamy czujniki ze studni
; pd2, pd3 wyjsciowe, (2-studnia, 3-baniak) nadajemy normalnie '1', '0' jak chcemy czytac czy wcisniete
; pd2, pd3 wejsciowe, czytamy czujniki z baniaka

ldi R16, 0b11001100 ; reszta pd6-7 wyjsciowa, niewazne to jest
out DDRD, R16
ldi R16, 0xFF ; pd0-7 podciagamy do napiecia '1'
out PORTD, R16

; SETUP diody od pompy na pb0-1, diod stanowych na pb2-3
ldi R16, 0b00000011 ; oba wyjsciowe
out DDRB, R16
ldi R16, 0b00000000 ; nie swieci na razie
out PORTB, R16

; glowna petla
; stan: 
;  czekamy_studnie:    na pelna     na pusta
;  czekamy_baniak
;         na pelny     0            1            
;         na pusty     0            0
;


; ------------------------
b1s0:

cbi PORTB, 0 ; pompa stop
sbi PORTB, 2 ; dioda od studni swieci (bo pusta, alarm)
sbi PORTB, 3 ; dioda od baniaka swieci (bo pelny, alarm)

b1s0impl:

rcall czy_studnia_pelna
cpi R20, 1
brlo b1s1 ; 

rcall czy_baniak_pusty
cpi R20, 1
brlo b0s0


rjmp b1s0impl

; ------------------------
b1s1:

cbi PORTB, 0 ; pompa stop
cbi PORTB, 2 ; dioda od studni zgaszona (bo pelna, czyli OK)
sbi PORTB, 3 ; dioda od baniaka swieci (bo pelny, alarm)

b1s1impl:

rcall czy_studnia_pusta
cpi R20, 1
brlo b1s0

rcall czy_baniak_pusty
cpi R20, 1
brlo b0s1

rjmp b1s1impl


; ------------------------
b0s0:

cbi PORTB, 0 ; pompa stop
sbi PORTB, 2 ; dioda od studni swieci (bo pusta, alarm)
cbi PORTB, 3 ; dioda od baniaka zgaszona (bo pusty, czyli OK)

b0s0impl:

rcall czy_studnia_pelna
cpi R20, 1
brlo b0s1; skoczJesliMniejsze

rcall czy_baniak_pelny
cpi R20, 1
brlo b1s0

rjmp b0s0impl

; ------------------------
b0s1:

sbi PORTB, 0 ; pompa start
cbi PORTB, 2 ; dioda od studni zgaszona (bo pelna, czyli OK)
cbi PORTB, 3 ; dioda od baniaka zgaszona (bo pusty, czyli OK)

b0s1impl:

rcall czy_studnia_pusta
cpi R20, 1
brlo b0s0 ; skocz do b0s0 jesli 0 (true)

rcall czy_baniak_pelny
cpi R20, 1
brlo b1s1

rjmp b0s1impl

; ------------------------
; puszczamy sygnal na pd2 lub pd3 (studnia lub baniak)
; czytamy z pd0 i pd1 czy sa jedynki (pelne) czy zera (puste) dla studni
; czytamy z pd4 i pd5 czy sa jedynki dla baniaka
; pd32 niska, pd01 wysoka


; ------------------------
; zwraca w R20 0 jesli TAK, 1 jesli NIE
czy_studnia_pelna:
cbi PORTD, 2 ; puszczamy 0 na pd2 (ten od studni)

ldi R20, 0 ; jesli oba guziki wcisniete - return true
sbic PIND, 0 ; jesli pd0==0, guzik wcisniety, nic nie rob 
ldi R20, 1 ; wpp guzik zwolniony, return false
sbic PIND, 1 ; jesli pd1==0, guzik wcisniety, nic nie rob
ldi R20, 1 ; wpp guzik zwolniony, return false

sbi PORTD, 2 ; kasujemy 0 na
ret

; ------------------------
; zwraca w R20 0 jesli TAK, 1 jesli NIE
czy_studnia_pusta:
cbi PORTD, 2 ; puszczamy 0 na pd2 (ten od studni)

ldi R20, 0 ; jesli oba guziki zwolnione - return true
sbis PIND, 0 ; jesli pd0==1, guzik zwolniony, nic nie rob
ldi R20, 1 ; wpp guzik wcisniety, return false
sbis PIND, 1 ; jesli pd1==1, guzik zwolniony, nic nie rob
ldi R20, 1 ; wpp guzik wcisniety, return false

sbi PORTD, 2 ; kasujemy 0 na pd2
ret


; ------------------------
czy_baniak_pelny:
cbi PORTD, 3 ; puszczamy 0 na pd3 (od baniaka)

ldi R20, 0 ; jesli oba wcisniete, return true
sbic PIND, 4 ; jesli pd4==0, guzik wcisniety, nic nie rob
ldi R20, 1 ; wpp guzik zwolniony, return false
sbic PIND, 5 ; jesli pd5==0, guzik wcisniety, nic nie rob
ldi R20, 1 ; wpp guzik zwolniony, return false

sbi PORTD, 3 ; kasujemy 0 na pd3
ret


; ------------------------
; zwraca w R20 0 jesli TAK, 1 jesli NIE
czy_baniak_pusty:
cbi PORTD, 3 ; puszczamy 0 na pd3 (ten od baniaka)

ldi R20, 0 ; jesli oba puszczone, return true
sbis PIND, 4 ; jesli pd4==1, puszczony guzik, nic nie rob
ldi R20, 1 ; wpp, guzik wcisniety, pd4==0, zwroc false
sbis PIND, 5 ; jesli pd5==1, puszczony guzik, nic nie rob
ldi R20, 1 ; wpp, guzik wcisniety, pd5==0, zwroc false

sbi PORTD, 3 ; kasujemy 0 na pd3
ret


; ------------------------------
czekaj:
ldi R16, 0
ldi R17, 0

czekaj1:
inc R17
cpi R17, 250
brlo czekaj1
ldi R17, 0

inc R16
cpi R16, 249
brlo czekaj1
ret