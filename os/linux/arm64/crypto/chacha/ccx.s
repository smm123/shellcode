
	#define l x0    // length
	#define p x1    // input
	#define s x2    // state
	
	#define x x3    // unsigned char x[64]
	#define a x4
	#define b x5
	#define c x6
	#define d x7
	
	#define j x8
	
	#define q x9
	#define r x10
	
	#define t x11
	#define u x12
	#define v x13
	#define w x13
	
	// void P(W*s,W*x);
P:
    adr     v, cc_v
	
	// F(16)x[i]=s[i];
P0:
	ldr     w, [s, i, lsl 2]
	str     w, [x, i, lsl 2]
	
    add     i, i, 1
	cmp     i, 16
	bne     P0
	
	mov     i, 0
P1:
    // d=v[i%8];
    and     u, i, 7
    ldrh    u, [v, u, lsl 1]
	
	// a=(d&15);b=(d>>4&15);
	// c=(d>>8&15);d>>=12;
	ubfx    a, u,  0, 4
	ubfx    b, u,  4, 4
	ubfx    c, u,  8, 4
	ubfx    d, u, 12, 4
	
	movl    r, 0x19181410
P2:
    // x[a]+=x[b],
	ldr     t, [x, a, lsl 2]
	ldr     u, [x, b, lsl 2]
	add     t, t, u
	str     t, [x, a, lsl 2]
	
	// x[d]=R(x[d]^x[a],(r&255))
	ldr     u, [x, d, lsl 2]
	eor     u, u, t
	and     w, r, 255
	ror     u, u, w
	str     u, [x, d, lsl 2]
	
	// X(a,c),X(b,d);
	stp     a, c, [sp, -16]
	ldp     c, a, [sp], 16
	stp     b, d, [sp, -16]
	ldp     d, b, [sp], 16
	
	lsr     r, r, 8
	cbnz    r, P2
	
	add     i, i, 1                // i++
	cmp     i, 80                  // i < 80
	bne     P1
	
	// F(16)x[i]+=s[i];
	mov     i, 0
P3:
    ldr     t, [s, i, lsl 2]
	ldr     u, [x, i, lsl 2]
	add     t, t, u
	str     t, [x, i, lsl 2]
	
	add     i, i, 1
	cmp     i, 16
	bne     P3
	
	// s[12]++;
	ldr     t, [s, 12*4]
	add     t, t, 1
	str     t, [s, 12*4]
	ret
cc_v:	
	.2byte  0xC840, 0xD951, 0xEA62, 0xFB73
	.2byte  0xFA50, 0xCB61, 0xD872, 0xE943
			
	// void chacha(W l, void *in, void *state);
chacha:
	str     lr, [sp, -96]!
	add     x, sp, 16
	
	mov     q, 64
L0:
    // P(s,(W*)c);
    bl      P
	
	// r = (l > 64) ? 64 : l;
	cmp     l, 64
	csel    r, l, q, ls
	
	//F(r)*p++^=c[i];
	mov     i, 0
L1:
    ldrb    x, [c, i]
	ldrb    y, [p]
	eor     x, x, y
	strb    x, [p]!
	
    add     i, i, 1
	cmp     i, r
	bne     L1
	
	// l-=r;
	subs    l, l, r
	bne     L0
	
    b       L
	
    // else {
L:
    // s[0]=0x61707865;s[1]=0x3320646E;
	movl    t, 0x61707865
	movl    u, 0x3320646E
	stp     t, u, [s], 8
	
	// s[2]=0x79622D32;s[3]=0x6B206574;
	movl    t, 0x79622D32
	movl    u, 0x6B206574
	stp     t, u, [s], 8
	
	// F(12)s[i+4]=k[i];
	mov     i, 12
L:
    ldr     t, [k], 4
	str     t, [s], 4
	
	subs    i, i, 1
	bne     L
	
L:
	ldr     lr, [sp], 96
	ret