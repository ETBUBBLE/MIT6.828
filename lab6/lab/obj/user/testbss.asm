
obj/user/testbss.debug：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 60 23 80 00       	push   $0x802360
  80003e:	e8 d2 01 00 00       	call   800215 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 db 23 80 00       	push   $0x8023db
  80005b:	6a 11                	push   $0x11
  80005d:	68 f8 23 80 00       	push   $0x8023f8
  800062:	e8 d5 00 00 00       	call   80013c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 80 23 80 00       	push   $0x802380
  80009b:	6a 16                	push   $0x16
  80009d:	68 f8 23 80 00       	push   $0x8023f8
  8000a2:	e8 95 00 00 00       	call   80013c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 a8 23 80 00       	push   $0x8023a8
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 07 24 80 00       	push   $0x802407
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 f8 23 80 00       	push   $0x8023f8
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000e7:	e8 f2 0a 00 00       	call   800bde <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 40 c0 00       	mov    %eax,0xc04020

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
        binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 ea 0e 00 00       	call   801017 <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 66 0a 00 00       	call   800b9d <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 8f 0a 00 00       	call   800bde <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 28 24 80 00       	push   $0x802428
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 f6 23 80 00 	movl   $0x8023f6,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 ae 09 00 00       	call   800b60 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 1a 01 00 00       	call   800312 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 53 09 00 00       	call   800b60 <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800250:	39 d3                	cmp    %edx,%ebx
  800252:	72 05                	jb     800259 <printnum+0x30>
  800254:	39 45 10             	cmp    %eax,0x10(%ebp)
  800257:	77 45                	ja     80029e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	8b 45 14             	mov    0x14(%ebp),%eax
  800262:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800265:	53                   	push   %ebx
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 53 1e 00 00       	call   8020d0 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 18                	jmp    8002a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	eb 03                	jmp    8002a1 <printnum+0x78>
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f e8                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bb:	e8 40 1f 00 00       	call   802200 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 4b 24 80 00 	movsbl 0x80244b(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002de:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e7:	73 0a                	jae    8002f3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ec:	89 08                	mov    %ecx,(%eax)
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	88 02                	mov    %al,(%edx)
}
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fe:	50                   	push   %eax
  8002ff:	ff 75 10             	pushl  0x10(%ebp)
  800302:	ff 75 0c             	pushl  0xc(%ebp)
  800305:	ff 75 08             	pushl  0x8(%ebp)
  800308:	e8 05 00 00 00       	call   800312 <vprintfmt>
	va_end(ap);
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 2c             	sub    $0x2c,%esp
  80031b:	8b 75 08             	mov    0x8(%ebp),%esi
  80031e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800321:	8b 7d 10             	mov    0x10(%ebp),%edi
  800324:	eb 12                	jmp    800338 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800326:	85 c0                	test   %eax,%eax
  800328:	0f 84 42 04 00 00    	je     800770 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80032e:	83 ec 08             	sub    $0x8,%esp
  800331:	53                   	push   %ebx
  800332:	50                   	push   %eax
  800333:	ff d6                	call   *%esi
  800335:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800338:	83 c7 01             	add    $0x1,%edi
  80033b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80033f:	83 f8 25             	cmp    $0x25,%eax
  800342:	75 e2                	jne    800326 <vprintfmt+0x14>
  800344:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800348:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800356:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	eb 07                	jmp    80036b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800367:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8d 47 01             	lea    0x1(%edi),%eax
  80036e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800371:	0f b6 07             	movzbl (%edi),%eax
  800374:	0f b6 d0             	movzbl %al,%edx
  800377:	83 e8 23             	sub    $0x23,%eax
  80037a:	3c 55                	cmp    $0x55,%al
  80037c:	0f 87 d3 03 00 00    	ja     800755 <vprintfmt+0x443>
  800382:	0f b6 c0             	movzbl %al,%eax
  800385:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800393:	eb d6                	jmp    80036b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800398:	b8 00 00 00 00       	mov    $0x0,%eax
  80039d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003aa:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ad:	83 f9 09             	cmp    $0x9,%ecx
  8003b0:	77 3f                	ja     8003f1 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b5:	eb e9                	jmp    8003a0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8d 40 04             	lea    0x4(%eax),%eax
  8003c5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003cb:	eb 2a                	jmp    8003f7 <vprintfmt+0xe5>
  8003cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	0f 49 d0             	cmovns %eax,%edx
  8003da:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e0:	eb 89                	jmp    80036b <vprintfmt+0x59>
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ec:	e9 7a ff ff ff       	jmp    80036b <vprintfmt+0x59>
  8003f1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fb:	0f 89 6a ff ff ff    	jns    80036b <vprintfmt+0x59>
				width = precision, precision = -1;
  800401:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800404:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800407:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040e:	e9 58 ff ff ff       	jmp    80036b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800413:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800419:	e9 4d ff ff ff       	jmp    80036b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 78 04             	lea    0x4(%eax),%edi
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	53                   	push   %ebx
  800428:	ff 30                	pushl  (%eax)
  80042a:	ff d6                	call   *%esi
			break;
  80042c:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800435:	e9 fe fe ff ff       	jmp    800338 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 78 04             	lea    0x4(%eax),%edi
  800440:	8b 00                	mov    (%eax),%eax
  800442:	99                   	cltd   
  800443:	31 d0                	xor    %edx,%eax
  800445:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800447:	83 f8 0f             	cmp    $0xf,%eax
  80044a:	7f 0b                	jg     800457 <vprintfmt+0x145>
  80044c:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  800453:	85 d2                	test   %edx,%edx
  800455:	75 1b                	jne    800472 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800457:	50                   	push   %eax
  800458:	68 63 24 80 00       	push   $0x802463
  80045d:	53                   	push   %ebx
  80045e:	56                   	push   %esi
  80045f:	e8 91 fe ff ff       	call   8002f5 <printfmt>
  800464:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800467:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046d:	e9 c6 fe ff ff       	jmp    800338 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800472:	52                   	push   %edx
  800473:	68 19 28 80 00       	push   $0x802819
  800478:	53                   	push   %ebx
  800479:	56                   	push   %esi
  80047a:	e8 76 fe ff ff       	call   8002f5 <printfmt>
  80047f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800482:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800488:	e9 ab fe ff ff       	jmp    800338 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	83 c0 04             	add    $0x4,%eax
  800493:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80049b:	85 ff                	test   %edi,%edi
  80049d:	b8 5c 24 80 00       	mov    $0x80245c,%eax
  8004a2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a9:	0f 8e 94 00 00 00    	jle    800543 <vprintfmt+0x231>
  8004af:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b3:	0f 84 98 00 00 00    	je     800551 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004bf:	57                   	push   %edi
  8004c0:	e8 33 03 00 00       	call   8007f8 <strnlen>
  8004c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c8:	29 c1                	sub    %eax,%ecx
  8004ca:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004cd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004da:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	eb 0f                	jmp    8004ed <vprintfmt+0x1db>
					putch(padc, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	83 ef 01             	sub    $0x1,%edi
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	7f ed                	jg     8004de <vprintfmt+0x1cc>
  8004f1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f7:	85 c9                	test   %ecx,%ecx
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	0f 49 c1             	cmovns %ecx,%eax
  800501:	29 c1                	sub    %eax,%ecx
  800503:	89 75 08             	mov    %esi,0x8(%ebp)
  800506:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800509:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050c:	89 cb                	mov    %ecx,%ebx
  80050e:	eb 4d                	jmp    80055d <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800510:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800514:	74 1b                	je     800531 <vprintfmt+0x21f>
  800516:	0f be c0             	movsbl %al,%eax
  800519:	83 e8 20             	sub    $0x20,%eax
  80051c:	83 f8 5e             	cmp    $0x5e,%eax
  80051f:	76 10                	jbe    800531 <vprintfmt+0x21f>
					putch('?', putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	6a 3f                	push   $0x3f
  800529:	ff 55 08             	call   *0x8(%ebp)
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	eb 0d                	jmp    80053e <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	ff 75 0c             	pushl  0xc(%ebp)
  800537:	52                   	push   %edx
  800538:	ff 55 08             	call   *0x8(%ebp)
  80053b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053e:	83 eb 01             	sub    $0x1,%ebx
  800541:	eb 1a                	jmp    80055d <vprintfmt+0x24b>
  800543:	89 75 08             	mov    %esi,0x8(%ebp)
  800546:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800549:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054f:	eb 0c                	jmp    80055d <vprintfmt+0x24b>
  800551:	89 75 08             	mov    %esi,0x8(%ebp)
  800554:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800557:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055d:	83 c7 01             	add    $0x1,%edi
  800560:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800564:	0f be d0             	movsbl %al,%edx
  800567:	85 d2                	test   %edx,%edx
  800569:	74 23                	je     80058e <vprintfmt+0x27c>
  80056b:	85 f6                	test   %esi,%esi
  80056d:	78 a1                	js     800510 <vprintfmt+0x1fe>
  80056f:	83 ee 01             	sub    $0x1,%esi
  800572:	79 9c                	jns    800510 <vprintfmt+0x1fe>
  800574:	89 df                	mov    %ebx,%edi
  800576:	8b 75 08             	mov    0x8(%ebp),%esi
  800579:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057c:	eb 18                	jmp    800596 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	53                   	push   %ebx
  800582:	6a 20                	push   $0x20
  800584:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800586:	83 ef 01             	sub    $0x1,%edi
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	eb 08                	jmp    800596 <vprintfmt+0x284>
  80058e:	89 df                	mov    %ebx,%edi
  800590:	8b 75 08             	mov    0x8(%ebp),%esi
  800593:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800596:	85 ff                	test   %edi,%edi
  800598:	7f e4                	jg     80057e <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a3:	e9 90 fd ff ff       	jmp    800338 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a8:	83 f9 01             	cmp    $0x1,%ecx
  8005ab:	7e 19                	jle    8005c6 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 50 04             	mov    0x4(%eax),%edx
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 40 08             	lea    0x8(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c4:	eb 38                	jmp    8005fe <vprintfmt+0x2ec>
	else if (lflag)
  8005c6:	85 c9                	test   %ecx,%ecx
  8005c8:	74 1b                	je     8005e5 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 00                	mov    (%eax),%eax
  8005cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d2:	89 c1                	mov    %eax,%ecx
  8005d4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 40 04             	lea    0x4(%eax),%eax
  8005e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e3:	eb 19                	jmp    8005fe <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ed:	89 c1                	mov    %eax,%ecx
  8005ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800601:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800609:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060d:	0f 89 0e 01 00 00    	jns    800721 <vprintfmt+0x40f>
				putch('-', putdat);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	6a 2d                	push   $0x2d
  800619:	ff d6                	call   *%esi
				num = -(long long) num;
  80061b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800621:	f7 da                	neg    %edx
  800623:	83 d1 00             	adc    $0x0,%ecx
  800626:	f7 d9                	neg    %ecx
  800628:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800630:	e9 ec 00 00 00       	jmp    800721 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800635:	83 f9 01             	cmp    $0x1,%ecx
  800638:	7e 18                	jle    800652 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 10                	mov    (%eax),%edx
  80063f:	8b 48 04             	mov    0x4(%eax),%ecx
  800642:	8d 40 08             	lea    0x8(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800648:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064d:	e9 cf 00 00 00       	jmp    800721 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800652:	85 c9                	test   %ecx,%ecx
  800654:	74 1a                	je     800670 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800660:	8d 40 04             	lea    0x4(%eax),%eax
  800663:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	e9 b1 00 00 00       	jmp    800721 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 10                	mov    (%eax),%edx
  800675:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067a:	8d 40 04             	lea    0x4(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800680:	b8 0a 00 00 00       	mov    $0xa,%eax
  800685:	e9 97 00 00 00       	jmp    800721 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 58                	push   $0x58
  800690:	ff d6                	call   *%esi
			putch('X', putdat);
  800692:	83 c4 08             	add    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 58                	push   $0x58
  800698:	ff d6                	call   *%esi
			putch('X', putdat);
  80069a:	83 c4 08             	add    $0x8,%esp
  80069d:	53                   	push   %ebx
  80069e:	6a 58                	push   $0x58
  8006a0:	ff d6                	call   *%esi
			break;
  8006a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006a8:	e9 8b fc ff ff       	jmp    800338 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 30                	push   $0x30
  8006b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b5:	83 c4 08             	add    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 78                	push   $0x78
  8006bb:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 10                	mov    (%eax),%edx
  8006c2:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c7:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ca:	8d 40 04             	lea    0x4(%eax),%eax
  8006cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d5:	eb 4a                	jmp    800721 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d7:	83 f9 01             	cmp    $0x1,%ecx
  8006da:	7e 15                	jle    8006f1 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e4:	8d 40 08             	lea    0x8(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ea:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ef:	eb 30                	jmp    800721 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006f1:	85 c9                	test   %ecx,%ecx
  8006f3:	74 17                	je     80070c <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8b 10                	mov    (%eax),%edx
  8006fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ff:	8d 40 04             	lea    0x4(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800705:	b8 10 00 00 00       	mov    $0x10,%eax
  80070a:	eb 15                	jmp    800721 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	b9 00 00 00 00       	mov    $0x0,%ecx
  800716:	8d 40 04             	lea    0x4(%eax),%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80071c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800721:	83 ec 0c             	sub    $0xc,%esp
  800724:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800728:	57                   	push   %edi
  800729:	ff 75 e0             	pushl  -0x20(%ebp)
  80072c:	50                   	push   %eax
  80072d:	51                   	push   %ecx
  80072e:	52                   	push   %edx
  80072f:	89 da                	mov    %ebx,%edx
  800731:	89 f0                	mov    %esi,%eax
  800733:	e8 f1 fa ff ff       	call   800229 <printnum>
			break;
  800738:	83 c4 20             	add    $0x20,%esp
  80073b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073e:	e9 f5 fb ff ff       	jmp    800338 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	53                   	push   %ebx
  800747:	52                   	push   %edx
  800748:	ff d6                	call   *%esi
			break;
  80074a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800750:	e9 e3 fb ff ff       	jmp    800338 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	53                   	push   %ebx
  800759:	6a 25                	push   $0x25
  80075b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	eb 03                	jmp    800765 <vprintfmt+0x453>
  800762:	83 ef 01             	sub    $0x1,%edi
  800765:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800769:	75 f7                	jne    800762 <vprintfmt+0x450>
  80076b:	e9 c8 fb ff ff       	jmp    800338 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5f                   	pop    %edi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 18             	sub    $0x18,%esp
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800784:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800787:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800795:	85 c0                	test   %eax,%eax
  800797:	74 26                	je     8007bf <vsnprintf+0x47>
  800799:	85 d2                	test   %edx,%edx
  80079b:	7e 22                	jle    8007bf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079d:	ff 75 14             	pushl  0x14(%ebp)
  8007a0:	ff 75 10             	pushl  0x10(%ebp)
  8007a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	68 d8 02 80 00       	push   $0x8002d8
  8007ac:	e8 61 fb ff ff       	call   800312 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb 05                	jmp    8007c4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cf:	50                   	push   %eax
  8007d0:	ff 75 10             	pushl  0x10(%ebp)
  8007d3:	ff 75 0c             	pushl  0xc(%ebp)
  8007d6:	ff 75 08             	pushl  0x8(%ebp)
  8007d9:	e8 9a ff ff ff       	call   800778 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	eb 03                	jmp    8007f0 <strlen+0x10>
		n++;
  8007ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f4:	75 f7                	jne    8007ed <strlen+0xd>
		n++;
	return n;
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fe:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800801:	ba 00 00 00 00       	mov    $0x0,%edx
  800806:	eb 03                	jmp    80080b <strnlen+0x13>
		n++;
  800808:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080b:	39 c2                	cmp    %eax,%edx
  80080d:	74 08                	je     800817 <strnlen+0x1f>
  80080f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800813:	75 f3                	jne    800808 <strnlen+0x10>
  800815:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	53                   	push   %ebx
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800823:	89 c2                	mov    %eax,%edx
  800825:	83 c2 01             	add    $0x1,%edx
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80082f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800832:	84 db                	test   %bl,%bl
  800834:	75 ef                	jne    800825 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800836:	5b                   	pop    %ebx
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	53                   	push   %ebx
  80083d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800840:	53                   	push   %ebx
  800841:	e8 9a ff ff ff       	call   8007e0 <strlen>
  800846:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	01 d8                	add    %ebx,%eax
  80084e:	50                   	push   %eax
  80084f:	e8 c5 ff ff ff       	call   800819 <strcpy>
	return dst;
}
  800854:	89 d8                	mov    %ebx,%eax
  800856:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	8b 75 08             	mov    0x8(%ebp),%esi
  800863:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800866:	89 f3                	mov    %esi,%ebx
  800868:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086b:	89 f2                	mov    %esi,%edx
  80086d:	eb 0f                	jmp    80087e <strncpy+0x23>
		*dst++ = *src;
  80086f:	83 c2 01             	add    $0x1,%edx
  800872:	0f b6 01             	movzbl (%ecx),%eax
  800875:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800878:	80 39 01             	cmpb   $0x1,(%ecx)
  80087b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087e:	39 da                	cmp    %ebx,%edx
  800880:	75 ed                	jne    80086f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800882:	89 f0                	mov    %esi,%eax
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	56                   	push   %esi
  80088c:	53                   	push   %ebx
  80088d:	8b 75 08             	mov    0x8(%ebp),%esi
  800890:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800893:	8b 55 10             	mov    0x10(%ebp),%edx
  800896:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800898:	85 d2                	test   %edx,%edx
  80089a:	74 21                	je     8008bd <strlcpy+0x35>
  80089c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a0:	89 f2                	mov    %esi,%edx
  8008a2:	eb 09                	jmp    8008ad <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a4:	83 c2 01             	add    $0x1,%edx
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ad:	39 c2                	cmp    %eax,%edx
  8008af:	74 09                	je     8008ba <strlcpy+0x32>
  8008b1:	0f b6 19             	movzbl (%ecx),%ebx
  8008b4:	84 db                	test   %bl,%bl
  8008b6:	75 ec                	jne    8008a4 <strlcpy+0x1c>
  8008b8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008ba:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008bd:	29 f0                	sub    %esi,%eax
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5e                   	pop    %esi
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cc:	eb 06                	jmp    8008d4 <strcmp+0x11>
		p++, q++;
  8008ce:	83 c1 01             	add    $0x1,%ecx
  8008d1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d4:	0f b6 01             	movzbl (%ecx),%eax
  8008d7:	84 c0                	test   %al,%al
  8008d9:	74 04                	je     8008df <strcmp+0x1c>
  8008db:	3a 02                	cmp    (%edx),%al
  8008dd:	74 ef                	je     8008ce <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008df:	0f b6 c0             	movzbl %al,%eax
  8008e2:	0f b6 12             	movzbl (%edx),%edx
  8008e5:	29 d0                	sub    %edx,%eax
}
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	53                   	push   %ebx
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f3:	89 c3                	mov    %eax,%ebx
  8008f5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f8:	eb 06                	jmp    800900 <strncmp+0x17>
		n--, p++, q++;
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800900:	39 d8                	cmp    %ebx,%eax
  800902:	74 15                	je     800919 <strncmp+0x30>
  800904:	0f b6 08             	movzbl (%eax),%ecx
  800907:	84 c9                	test   %cl,%cl
  800909:	74 04                	je     80090f <strncmp+0x26>
  80090b:	3a 0a                	cmp    (%edx),%cl
  80090d:	74 eb                	je     8008fa <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090f:	0f b6 00             	movzbl (%eax),%eax
  800912:	0f b6 12             	movzbl (%edx),%edx
  800915:	29 d0                	sub    %edx,%eax
  800917:	eb 05                	jmp    80091e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80091e:	5b                   	pop    %ebx
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092b:	eb 07                	jmp    800934 <strchr+0x13>
		if (*s == c)
  80092d:	38 ca                	cmp    %cl,%dl
  80092f:	74 0f                	je     800940 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800931:	83 c0 01             	add    $0x1,%eax
  800934:	0f b6 10             	movzbl (%eax),%edx
  800937:	84 d2                	test   %dl,%dl
  800939:	75 f2                	jne    80092d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094c:	eb 03                	jmp    800951 <strfind+0xf>
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800954:	38 ca                	cmp    %cl,%dl
  800956:	74 04                	je     80095c <strfind+0x1a>
  800958:	84 d2                	test   %dl,%dl
  80095a:	75 f2                	jne    80094e <strfind+0xc>
			break;
	return (char *) s;
}
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	57                   	push   %edi
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	8b 7d 08             	mov    0x8(%ebp),%edi
  800967:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096a:	85 c9                	test   %ecx,%ecx
  80096c:	74 36                	je     8009a4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800974:	75 28                	jne    80099e <memset+0x40>
  800976:	f6 c1 03             	test   $0x3,%cl
  800979:	75 23                	jne    80099e <memset+0x40>
		c &= 0xFF;
  80097b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097f:	89 d3                	mov    %edx,%ebx
  800981:	c1 e3 08             	shl    $0x8,%ebx
  800984:	89 d6                	mov    %edx,%esi
  800986:	c1 e6 18             	shl    $0x18,%esi
  800989:	89 d0                	mov    %edx,%eax
  80098b:	c1 e0 10             	shl    $0x10,%eax
  80098e:	09 f0                	or     %esi,%eax
  800990:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800992:	89 d8                	mov    %ebx,%eax
  800994:	09 d0                	or     %edx,%eax
  800996:	c1 e9 02             	shr    $0x2,%ecx
  800999:	fc                   	cld    
  80099a:	f3 ab                	rep stos %eax,%es:(%edi)
  80099c:	eb 06                	jmp    8009a4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a1:	fc                   	cld    
  8009a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a4:	89 f8                	mov    %edi,%eax
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b9:	39 c6                	cmp    %eax,%esi
  8009bb:	73 35                	jae    8009f2 <memmove+0x47>
  8009bd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c0:	39 d0                	cmp    %edx,%eax
  8009c2:	73 2e                	jae    8009f2 <memmove+0x47>
		s += n;
		d += n;
  8009c4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c7:	89 d6                	mov    %edx,%esi
  8009c9:	09 fe                	or     %edi,%esi
  8009cb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d1:	75 13                	jne    8009e6 <memmove+0x3b>
  8009d3:	f6 c1 03             	test   $0x3,%cl
  8009d6:	75 0e                	jne    8009e6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d8:	83 ef 04             	sub    $0x4,%edi
  8009db:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009de:	c1 e9 02             	shr    $0x2,%ecx
  8009e1:	fd                   	std    
  8009e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e4:	eb 09                	jmp    8009ef <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e6:	83 ef 01             	sub    $0x1,%edi
  8009e9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ec:	fd                   	std    
  8009ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ef:	fc                   	cld    
  8009f0:	eb 1d                	jmp    800a0f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f2:	89 f2                	mov    %esi,%edx
  8009f4:	09 c2                	or     %eax,%edx
  8009f6:	f6 c2 03             	test   $0x3,%dl
  8009f9:	75 0f                	jne    800a0a <memmove+0x5f>
  8009fb:	f6 c1 03             	test   $0x3,%cl
  8009fe:	75 0a                	jne    800a0a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a00:	c1 e9 02             	shr    $0x2,%ecx
  800a03:	89 c7                	mov    %eax,%edi
  800a05:	fc                   	cld    
  800a06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a08:	eb 05                	jmp    800a0f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a0a:	89 c7                	mov    %eax,%edi
  800a0c:	fc                   	cld    
  800a0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a16:	ff 75 10             	pushl  0x10(%ebp)
  800a19:	ff 75 0c             	pushl  0xc(%ebp)
  800a1c:	ff 75 08             	pushl  0x8(%ebp)
  800a1f:	e8 87 ff ff ff       	call   8009ab <memmove>
}
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a31:	89 c6                	mov    %eax,%esi
  800a33:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a36:	eb 1a                	jmp    800a52 <memcmp+0x2c>
		if (*s1 != *s2)
  800a38:	0f b6 08             	movzbl (%eax),%ecx
  800a3b:	0f b6 1a             	movzbl (%edx),%ebx
  800a3e:	38 d9                	cmp    %bl,%cl
  800a40:	74 0a                	je     800a4c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a42:	0f b6 c1             	movzbl %cl,%eax
  800a45:	0f b6 db             	movzbl %bl,%ebx
  800a48:	29 d8                	sub    %ebx,%eax
  800a4a:	eb 0f                	jmp    800a5b <memcmp+0x35>
		s1++, s2++;
  800a4c:	83 c0 01             	add    $0x1,%eax
  800a4f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a52:	39 f0                	cmp    %esi,%eax
  800a54:	75 e2                	jne    800a38 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	53                   	push   %ebx
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a66:	89 c1                	mov    %eax,%ecx
  800a68:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6f:	eb 0a                	jmp    800a7b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a71:	0f b6 10             	movzbl (%eax),%edx
  800a74:	39 da                	cmp    %ebx,%edx
  800a76:	74 07                	je     800a7f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a78:	83 c0 01             	add    $0x1,%eax
  800a7b:	39 c8                	cmp    %ecx,%eax
  800a7d:	72 f2                	jb     800a71 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8e:	eb 03                	jmp    800a93 <strtol+0x11>
		s++;
  800a90:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a93:	0f b6 01             	movzbl (%ecx),%eax
  800a96:	3c 20                	cmp    $0x20,%al
  800a98:	74 f6                	je     800a90 <strtol+0xe>
  800a9a:	3c 09                	cmp    $0x9,%al
  800a9c:	74 f2                	je     800a90 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a9e:	3c 2b                	cmp    $0x2b,%al
  800aa0:	75 0a                	jne    800aac <strtol+0x2a>
		s++;
  800aa2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa5:	bf 00 00 00 00       	mov    $0x0,%edi
  800aaa:	eb 11                	jmp    800abd <strtol+0x3b>
  800aac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab1:	3c 2d                	cmp    $0x2d,%al
  800ab3:	75 08                	jne    800abd <strtol+0x3b>
		s++, neg = 1;
  800ab5:	83 c1 01             	add    $0x1,%ecx
  800ab8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac3:	75 15                	jne    800ada <strtol+0x58>
  800ac5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac8:	75 10                	jne    800ada <strtol+0x58>
  800aca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ace:	75 7c                	jne    800b4c <strtol+0xca>
		s += 2, base = 16;
  800ad0:	83 c1 02             	add    $0x2,%ecx
  800ad3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad8:	eb 16                	jmp    800af0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ada:	85 db                	test   %ebx,%ebx
  800adc:	75 12                	jne    800af0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ade:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae6:	75 08                	jne    800af0 <strtol+0x6e>
		s++, base = 8;
  800ae8:	83 c1 01             	add    $0x1,%ecx
  800aeb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
  800af5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af8:	0f b6 11             	movzbl (%ecx),%edx
  800afb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afe:	89 f3                	mov    %esi,%ebx
  800b00:	80 fb 09             	cmp    $0x9,%bl
  800b03:	77 08                	ja     800b0d <strtol+0x8b>
			dig = *s - '0';
  800b05:	0f be d2             	movsbl %dl,%edx
  800b08:	83 ea 30             	sub    $0x30,%edx
  800b0b:	eb 22                	jmp    800b2f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b0d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b10:	89 f3                	mov    %esi,%ebx
  800b12:	80 fb 19             	cmp    $0x19,%bl
  800b15:	77 08                	ja     800b1f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b17:	0f be d2             	movsbl %dl,%edx
  800b1a:	83 ea 57             	sub    $0x57,%edx
  800b1d:	eb 10                	jmp    800b2f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b1f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b22:	89 f3                	mov    %esi,%ebx
  800b24:	80 fb 19             	cmp    $0x19,%bl
  800b27:	77 16                	ja     800b3f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b29:	0f be d2             	movsbl %dl,%edx
  800b2c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b2f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b32:	7d 0b                	jge    800b3f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b34:	83 c1 01             	add    $0x1,%ecx
  800b37:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b3d:	eb b9                	jmp    800af8 <strtol+0x76>

	if (endptr)
  800b3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b43:	74 0d                	je     800b52 <strtol+0xd0>
		*endptr = (char *) s;
  800b45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b48:	89 0e                	mov    %ecx,(%esi)
  800b4a:	eb 06                	jmp    800b52 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b4c:	85 db                	test   %ebx,%ebx
  800b4e:	74 98                	je     800ae8 <strtol+0x66>
  800b50:	eb 9e                	jmp    800af0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b52:	89 c2                	mov    %eax,%edx
  800b54:	f7 da                	neg    %edx
  800b56:	85 ff                	test   %edi,%edi
  800b58:	0f 45 c2             	cmovne %edx,%eax
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	89 c3                	mov    %eax,%ebx
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	89 c6                	mov    %eax,%esi
  800b77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bab:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	89 cb                	mov    %ecx,%ebx
  800bb5:	89 cf                	mov    %ecx,%edi
  800bb7:	89 ce                	mov    %ecx,%esi
  800bb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	7e 17                	jle    800bd6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	50                   	push   %eax
  800bc3:	6a 03                	push   $0x3
  800bc5:	68 3f 27 80 00       	push   $0x80273f
  800bca:	6a 23                	push   $0x23
  800bcc:	68 5c 27 80 00       	push   $0x80275c
  800bd1:	e8 66 f5 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_yield>:

void
sys_yield(void)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	ba 00 00 00 00       	mov    $0x0,%edx
  800c08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0d:	89 d1                	mov    %edx,%ecx
  800c0f:	89 d3                	mov    %edx,%ebx
  800c11:	89 d7                	mov    %edx,%edi
  800c13:	89 d6                	mov    %edx,%esi
  800c15:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	be 00 00 00 00       	mov    $0x0,%esi
  800c2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c38:	89 f7                	mov    %esi,%edi
  800c3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	7e 17                	jle    800c57 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 04                	push   $0x4
  800c46:	68 3f 27 80 00       	push   $0x80273f
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 5c 27 80 00       	push   $0x80275c
  800c52:	e8 e5 f4 ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c79:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 17                	jle    800c99 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	50                   	push   %eax
  800c86:	6a 05                	push   $0x5
  800c88:	68 3f 27 80 00       	push   $0x80273f
  800c8d:	6a 23                	push   $0x23
  800c8f:	68 5c 27 80 00       	push   $0x80275c
  800c94:	e8 a3 f4 ff ff       	call   80013c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caf:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	89 df                	mov    %ebx,%edi
  800cbc:	89 de                	mov    %ebx,%esi
  800cbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7e 17                	jle    800cdb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	83 ec 0c             	sub    $0xc,%esp
  800cc7:	50                   	push   %eax
  800cc8:	6a 06                	push   $0x6
  800cca:	68 3f 27 80 00       	push   $0x80273f
  800ccf:	6a 23                	push   $0x23
  800cd1:	68 5c 27 80 00       	push   $0x80275c
  800cd6:	e8 61 f4 ff ff       	call   80013c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf1:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	89 df                	mov    %ebx,%edi
  800cfe:	89 de                	mov    %ebx,%esi
  800d00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d02:	85 c0                	test   %eax,%eax
  800d04:	7e 17                	jle    800d1d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	83 ec 0c             	sub    $0xc,%esp
  800d09:	50                   	push   %eax
  800d0a:	6a 08                	push   $0x8
  800d0c:	68 3f 27 80 00       	push   $0x80273f
  800d11:	6a 23                	push   $0x23
  800d13:	68 5c 27 80 00       	push   $0x80275c
  800d18:	e8 1f f4 ff ff       	call   80013c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d33:	b8 09 00 00 00       	mov    $0x9,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 df                	mov    %ebx,%edi
  800d40:	89 de                	mov    %ebx,%esi
  800d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 09                	push   $0x9
  800d4e:	68 3f 27 80 00       	push   $0x80273f
  800d53:	6a 23                	push   $0x23
  800d55:	68 5c 27 80 00       	push   $0x80275c
  800d5a:	e8 dd f3 ff ff       	call   80013c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	89 df                	mov    %ebx,%edi
  800d82:	89 de                	mov    %ebx,%esi
  800d84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 0a                	push   $0xa
  800d90:	68 3f 27 80 00       	push   $0x80273f
  800d95:	6a 23                	push   $0x23
  800d97:	68 5c 27 80 00       	push   $0x80275c
  800d9c:	e8 9b f3 ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	be 00 00 00 00       	mov    $0x0,%esi
  800db4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dda:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  800de2:	89 cb                	mov    %ecx,%ebx
  800de4:	89 cf                	mov    %ecx,%edi
  800de6:	89 ce                	mov    %ecx,%esi
  800de8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dea:	85 c0                	test   %eax,%eax
  800dec:	7e 17                	jle    800e05 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	50                   	push   %eax
  800df2:	6a 0d                	push   $0xd
  800df4:	68 3f 27 80 00       	push   $0x80273f
  800df9:	6a 23                	push   $0x23
  800dfb:	68 5c 27 80 00       	push   $0x80275c
  800e00:	e8 37 f3 ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	ba 00 00 00 00       	mov    $0x0,%edx
  800e18:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e1d:	89 d1                	mov    %edx,%ecx
  800e1f:	89 d3                	mov    %edx,%ebx
  800e21:	89 d7                	mov    %edx,%edi
  800e23:	89 d6                	mov    %edx,%esi
  800e25:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e37:	b8 10 00 00 00       	mov    $0x10,%eax
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	89 cb                	mov    %ecx,%ebx
  800e41:	89 cf                	mov    %ecx,%edi
  800e43:	89 ce                	mov    %ecx,%esi
  800e45:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	05 00 00 00 30       	add    $0x30000000,%eax
  800e57:	c1 e8 0c             	shr    $0xc,%eax
}
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	05 00 00 00 30       	add    $0x30000000,%eax
  800e67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e6c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e79:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e7e:	89 c2                	mov    %eax,%edx
  800e80:	c1 ea 16             	shr    $0x16,%edx
  800e83:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e8a:	f6 c2 01             	test   $0x1,%dl
  800e8d:	74 11                	je     800ea0 <fd_alloc+0x2d>
  800e8f:	89 c2                	mov    %eax,%edx
  800e91:	c1 ea 0c             	shr    $0xc,%edx
  800e94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e9b:	f6 c2 01             	test   $0x1,%dl
  800e9e:	75 09                	jne    800ea9 <fd_alloc+0x36>
			*fd_store = fd;
  800ea0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	eb 17                	jmp    800ec0 <fd_alloc+0x4d>
  800ea9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eb3:	75 c9                	jne    800e7e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eb5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ebb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ec8:	83 f8 1f             	cmp    $0x1f,%eax
  800ecb:	77 36                	ja     800f03 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ecd:	c1 e0 0c             	shl    $0xc,%eax
  800ed0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ed5:	89 c2                	mov    %eax,%edx
  800ed7:	c1 ea 16             	shr    $0x16,%edx
  800eda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee1:	f6 c2 01             	test   $0x1,%dl
  800ee4:	74 24                	je     800f0a <fd_lookup+0x48>
  800ee6:	89 c2                	mov    %eax,%edx
  800ee8:	c1 ea 0c             	shr    $0xc,%edx
  800eeb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef2:	f6 c2 01             	test   $0x1,%dl
  800ef5:	74 1a                	je     800f11 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ef7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efa:	89 02                	mov    %eax,(%edx)
	return 0;
  800efc:	b8 00 00 00 00       	mov    $0x0,%eax
  800f01:	eb 13                	jmp    800f16 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f08:	eb 0c                	jmp    800f16 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0f:	eb 05                	jmp    800f16 <fd_lookup+0x54>
  800f11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	83 ec 08             	sub    $0x8,%esp
  800f1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f21:	ba ec 27 80 00       	mov    $0x8027ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f26:	eb 13                	jmp    800f3b <dev_lookup+0x23>
  800f28:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f2b:	39 08                	cmp    %ecx,(%eax)
  800f2d:	75 0c                	jne    800f3b <dev_lookup+0x23>
			*dev = devtab[i];
  800f2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f32:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f34:	b8 00 00 00 00       	mov    $0x0,%eax
  800f39:	eb 2e                	jmp    800f69 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f3b:	8b 02                	mov    (%edx),%eax
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	75 e7                	jne    800f28 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f41:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f46:	8b 40 48             	mov    0x48(%eax),%eax
  800f49:	83 ec 04             	sub    $0x4,%esp
  800f4c:	51                   	push   %ecx
  800f4d:	50                   	push   %eax
  800f4e:	68 6c 27 80 00       	push   $0x80276c
  800f53:	e8 bd f2 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800f58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f69:	c9                   	leave  
  800f6a:	c3                   	ret    

00800f6b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	56                   	push   %esi
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 10             	sub    $0x10,%esp
  800f73:	8b 75 08             	mov    0x8(%ebp),%esi
  800f76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7c:	50                   	push   %eax
  800f7d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f83:	c1 e8 0c             	shr    $0xc,%eax
  800f86:	50                   	push   %eax
  800f87:	e8 36 ff ff ff       	call   800ec2 <fd_lookup>
  800f8c:	83 c4 08             	add    $0x8,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	78 05                	js     800f98 <fd_close+0x2d>
	    || fd != fd2)
  800f93:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f96:	74 0c                	je     800fa4 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f98:	84 db                	test   %bl,%bl
  800f9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9f:	0f 44 c2             	cmove  %edx,%eax
  800fa2:	eb 41                	jmp    800fe5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fa4:	83 ec 08             	sub    $0x8,%esp
  800fa7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800faa:	50                   	push   %eax
  800fab:	ff 36                	pushl  (%esi)
  800fad:	e8 66 ff ff ff       	call   800f18 <dev_lookup>
  800fb2:	89 c3                	mov    %eax,%ebx
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	78 1a                	js     800fd5 <fd_close+0x6a>
		if (dev->dev_close)
  800fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fbe:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fc1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	74 0b                	je     800fd5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	56                   	push   %esi
  800fce:	ff d0                	call   *%eax
  800fd0:	89 c3                	mov    %eax,%ebx
  800fd2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fd5:	83 ec 08             	sub    $0x8,%esp
  800fd8:	56                   	push   %esi
  800fd9:	6a 00                	push   $0x0
  800fdb:	e8 c1 fc ff ff       	call   800ca1 <sys_page_unmap>
	return r;
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	89 d8                	mov    %ebx,%eax
}
  800fe5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff5:	50                   	push   %eax
  800ff6:	ff 75 08             	pushl  0x8(%ebp)
  800ff9:	e8 c4 fe ff ff       	call   800ec2 <fd_lookup>
  800ffe:	83 c4 08             	add    $0x8,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	78 10                	js     801015 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801005:	83 ec 08             	sub    $0x8,%esp
  801008:	6a 01                	push   $0x1
  80100a:	ff 75 f4             	pushl  -0xc(%ebp)
  80100d:	e8 59 ff ff ff       	call   800f6b <fd_close>
  801012:	83 c4 10             	add    $0x10,%esp
}
  801015:	c9                   	leave  
  801016:	c3                   	ret    

00801017 <close_all>:

void
close_all(void)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	53                   	push   %ebx
  80101b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80101e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	53                   	push   %ebx
  801027:	e8 c0 ff ff ff       	call   800fec <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80102c:	83 c3 01             	add    $0x1,%ebx
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	83 fb 20             	cmp    $0x20,%ebx
  801035:	75 ec                	jne    801023 <close_all+0xc>
		close(i);
}
  801037:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80103a:	c9                   	leave  
  80103b:	c3                   	ret    

0080103c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	57                   	push   %edi
  801040:	56                   	push   %esi
  801041:	53                   	push   %ebx
  801042:	83 ec 2c             	sub    $0x2c,%esp
  801045:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801048:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80104b:	50                   	push   %eax
  80104c:	ff 75 08             	pushl  0x8(%ebp)
  80104f:	e8 6e fe ff ff       	call   800ec2 <fd_lookup>
  801054:	83 c4 08             	add    $0x8,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	0f 88 c1 00 00 00    	js     801120 <dup+0xe4>
		return r;
	close(newfdnum);
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	56                   	push   %esi
  801063:	e8 84 ff ff ff       	call   800fec <close>

	newfd = INDEX2FD(newfdnum);
  801068:	89 f3                	mov    %esi,%ebx
  80106a:	c1 e3 0c             	shl    $0xc,%ebx
  80106d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801073:	83 c4 04             	add    $0x4,%esp
  801076:	ff 75 e4             	pushl  -0x1c(%ebp)
  801079:	e8 de fd ff ff       	call   800e5c <fd2data>
  80107e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801080:	89 1c 24             	mov    %ebx,(%esp)
  801083:	e8 d4 fd ff ff       	call   800e5c <fd2data>
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80108e:	89 f8                	mov    %edi,%eax
  801090:	c1 e8 16             	shr    $0x16,%eax
  801093:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109a:	a8 01                	test   $0x1,%al
  80109c:	74 37                	je     8010d5 <dup+0x99>
  80109e:	89 f8                	mov    %edi,%eax
  8010a0:	c1 e8 0c             	shr    $0xc,%eax
  8010a3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010aa:	f6 c2 01             	test   $0x1,%dl
  8010ad:	74 26                	je     8010d5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010af:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b6:	83 ec 0c             	sub    $0xc,%esp
  8010b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010be:	50                   	push   %eax
  8010bf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c2:	6a 00                	push   $0x0
  8010c4:	57                   	push   %edi
  8010c5:	6a 00                	push   $0x0
  8010c7:	e8 93 fb ff ff       	call   800c5f <sys_page_map>
  8010cc:	89 c7                	mov    %eax,%edi
  8010ce:	83 c4 20             	add    $0x20,%esp
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	78 2e                	js     801103 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010d8:	89 d0                	mov    %edx,%eax
  8010da:	c1 e8 0c             	shr    $0xc,%eax
  8010dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ec:	50                   	push   %eax
  8010ed:	53                   	push   %ebx
  8010ee:	6a 00                	push   $0x0
  8010f0:	52                   	push   %edx
  8010f1:	6a 00                	push   $0x0
  8010f3:	e8 67 fb ff ff       	call   800c5f <sys_page_map>
  8010f8:	89 c7                	mov    %eax,%edi
  8010fa:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010fd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ff:	85 ff                	test   %edi,%edi
  801101:	79 1d                	jns    801120 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801103:	83 ec 08             	sub    $0x8,%esp
  801106:	53                   	push   %ebx
  801107:	6a 00                	push   $0x0
  801109:	e8 93 fb ff ff       	call   800ca1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80110e:	83 c4 08             	add    $0x8,%esp
  801111:	ff 75 d4             	pushl  -0x2c(%ebp)
  801114:	6a 00                	push   $0x0
  801116:	e8 86 fb ff ff       	call   800ca1 <sys_page_unmap>
	return r;
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	89 f8                	mov    %edi,%eax
}
  801120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801123:	5b                   	pop    %ebx
  801124:	5e                   	pop    %esi
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	53                   	push   %ebx
  80112c:	83 ec 14             	sub    $0x14,%esp
  80112f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801132:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801135:	50                   	push   %eax
  801136:	53                   	push   %ebx
  801137:	e8 86 fd ff ff       	call   800ec2 <fd_lookup>
  80113c:	83 c4 08             	add    $0x8,%esp
  80113f:	89 c2                	mov    %eax,%edx
  801141:	85 c0                	test   %eax,%eax
  801143:	78 6d                	js     8011b2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801145:	83 ec 08             	sub    $0x8,%esp
  801148:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114b:	50                   	push   %eax
  80114c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114f:	ff 30                	pushl  (%eax)
  801151:	e8 c2 fd ff ff       	call   800f18 <dev_lookup>
  801156:	83 c4 10             	add    $0x10,%esp
  801159:	85 c0                	test   %eax,%eax
  80115b:	78 4c                	js     8011a9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80115d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801160:	8b 42 08             	mov    0x8(%edx),%eax
  801163:	83 e0 03             	and    $0x3,%eax
  801166:	83 f8 01             	cmp    $0x1,%eax
  801169:	75 21                	jne    80118c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80116b:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801170:	8b 40 48             	mov    0x48(%eax),%eax
  801173:	83 ec 04             	sub    $0x4,%esp
  801176:	53                   	push   %ebx
  801177:	50                   	push   %eax
  801178:	68 b0 27 80 00       	push   $0x8027b0
  80117d:	e8 93 f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80118a:	eb 26                	jmp    8011b2 <read+0x8a>
	}
	if (!dev->dev_read)
  80118c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118f:	8b 40 08             	mov    0x8(%eax),%eax
  801192:	85 c0                	test   %eax,%eax
  801194:	74 17                	je     8011ad <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801196:	83 ec 04             	sub    $0x4,%esp
  801199:	ff 75 10             	pushl  0x10(%ebp)
  80119c:	ff 75 0c             	pushl  0xc(%ebp)
  80119f:	52                   	push   %edx
  8011a0:	ff d0                	call   *%eax
  8011a2:	89 c2                	mov    %eax,%edx
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	eb 09                	jmp    8011b2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	eb 05                	jmp    8011b2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011b2:	89 d0                	mov    %edx,%eax
  8011b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	57                   	push   %edi
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 0c             	sub    $0xc,%esp
  8011c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cd:	eb 21                	jmp    8011f0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011cf:	83 ec 04             	sub    $0x4,%esp
  8011d2:	89 f0                	mov    %esi,%eax
  8011d4:	29 d8                	sub    %ebx,%eax
  8011d6:	50                   	push   %eax
  8011d7:	89 d8                	mov    %ebx,%eax
  8011d9:	03 45 0c             	add    0xc(%ebp),%eax
  8011dc:	50                   	push   %eax
  8011dd:	57                   	push   %edi
  8011de:	e8 45 ff ff ff       	call   801128 <read>
		if (m < 0)
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 10                	js     8011fa <readn+0x41>
			return m;
		if (m == 0)
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	74 0a                	je     8011f8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ee:	01 c3                	add    %eax,%ebx
  8011f0:	39 f3                	cmp    %esi,%ebx
  8011f2:	72 db                	jb     8011cf <readn+0x16>
  8011f4:	89 d8                	mov    %ebx,%eax
  8011f6:	eb 02                	jmp    8011fa <readn+0x41>
  8011f8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5f                   	pop    %edi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	53                   	push   %ebx
  801206:	83 ec 14             	sub    $0x14,%esp
  801209:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80120c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	53                   	push   %ebx
  801211:	e8 ac fc ff ff       	call   800ec2 <fd_lookup>
  801216:	83 c4 08             	add    $0x8,%esp
  801219:	89 c2                	mov    %eax,%edx
  80121b:	85 c0                	test   %eax,%eax
  80121d:	78 68                	js     801287 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801229:	ff 30                	pushl  (%eax)
  80122b:	e8 e8 fc ff ff       	call   800f18 <dev_lookup>
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	85 c0                	test   %eax,%eax
  801235:	78 47                	js     80127e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801237:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80123e:	75 21                	jne    801261 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801240:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801245:	8b 40 48             	mov    0x48(%eax),%eax
  801248:	83 ec 04             	sub    $0x4,%esp
  80124b:	53                   	push   %ebx
  80124c:	50                   	push   %eax
  80124d:	68 cc 27 80 00       	push   $0x8027cc
  801252:	e8 be ef ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80125f:	eb 26                	jmp    801287 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801261:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801264:	8b 52 0c             	mov    0xc(%edx),%edx
  801267:	85 d2                	test   %edx,%edx
  801269:	74 17                	je     801282 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80126b:	83 ec 04             	sub    $0x4,%esp
  80126e:	ff 75 10             	pushl  0x10(%ebp)
  801271:	ff 75 0c             	pushl  0xc(%ebp)
  801274:	50                   	push   %eax
  801275:	ff d2                	call   *%edx
  801277:	89 c2                	mov    %eax,%edx
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	eb 09                	jmp    801287 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127e:	89 c2                	mov    %eax,%edx
  801280:	eb 05                	jmp    801287 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801282:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801287:	89 d0                	mov    %edx,%eax
  801289:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80128c:	c9                   	leave  
  80128d:	c3                   	ret    

0080128e <seek>:

int
seek(int fdnum, off_t offset)
{
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801294:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801297:	50                   	push   %eax
  801298:	ff 75 08             	pushl  0x8(%ebp)
  80129b:	e8 22 fc ff ff       	call   800ec2 <fd_lookup>
  8012a0:	83 c4 08             	add    $0x8,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 0e                	js     8012b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b5:	c9                   	leave  
  8012b6:	c3                   	ret    

008012b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	53                   	push   %ebx
  8012bb:	83 ec 14             	sub    $0x14,%esp
  8012be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	53                   	push   %ebx
  8012c6:	e8 f7 fb ff ff       	call   800ec2 <fd_lookup>
  8012cb:	83 c4 08             	add    $0x8,%esp
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 65                	js     801339 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d4:	83 ec 08             	sub    $0x8,%esp
  8012d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012da:	50                   	push   %eax
  8012db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012de:	ff 30                	pushl  (%eax)
  8012e0:	e8 33 fc ff ff       	call   800f18 <dev_lookup>
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 44                	js     801330 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f3:	75 21                	jne    801316 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012f5:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012fa:	8b 40 48             	mov    0x48(%eax),%eax
  8012fd:	83 ec 04             	sub    $0x4,%esp
  801300:	53                   	push   %ebx
  801301:	50                   	push   %eax
  801302:	68 8c 27 80 00       	push   $0x80278c
  801307:	e8 09 ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801314:	eb 23                	jmp    801339 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801316:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801319:	8b 52 18             	mov    0x18(%edx),%edx
  80131c:	85 d2                	test   %edx,%edx
  80131e:	74 14                	je     801334 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	ff 75 0c             	pushl  0xc(%ebp)
  801326:	50                   	push   %eax
  801327:	ff d2                	call   *%edx
  801329:	89 c2                	mov    %eax,%edx
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	eb 09                	jmp    801339 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801330:	89 c2                	mov    %eax,%edx
  801332:	eb 05                	jmp    801339 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801334:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801339:	89 d0                	mov    %edx,%eax
  80133b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	53                   	push   %ebx
  801344:	83 ec 14             	sub    $0x14,%esp
  801347:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	ff 75 08             	pushl  0x8(%ebp)
  801351:	e8 6c fb ff ff       	call   800ec2 <fd_lookup>
  801356:	83 c4 08             	add    $0x8,%esp
  801359:	89 c2                	mov    %eax,%edx
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 58                	js     8013b7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135f:	83 ec 08             	sub    $0x8,%esp
  801362:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801365:	50                   	push   %eax
  801366:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801369:	ff 30                	pushl  (%eax)
  80136b:	e8 a8 fb ff ff       	call   800f18 <dev_lookup>
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 37                	js     8013ae <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801377:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80137e:	74 32                	je     8013b2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801380:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801383:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80138a:	00 00 00 
	stat->st_isdir = 0;
  80138d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801394:	00 00 00 
	stat->st_dev = dev;
  801397:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	53                   	push   %ebx
  8013a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a4:	ff 50 14             	call   *0x14(%eax)
  8013a7:	89 c2                	mov    %eax,%edx
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	eb 09                	jmp    8013b7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	eb 05                	jmp    8013b7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013b7:	89 d0                	mov    %edx,%eax
  8013b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	6a 00                	push   $0x0
  8013c8:	ff 75 08             	pushl  0x8(%ebp)
  8013cb:	e8 e3 01 00 00       	call   8015b3 <open>
  8013d0:	89 c3                	mov    %eax,%ebx
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 1b                	js     8013f4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	ff 75 0c             	pushl  0xc(%ebp)
  8013df:	50                   	push   %eax
  8013e0:	e8 5b ff ff ff       	call   801340 <fstat>
  8013e5:	89 c6                	mov    %eax,%esi
	close(fd);
  8013e7:	89 1c 24             	mov    %ebx,(%esp)
  8013ea:	e8 fd fb ff ff       	call   800fec <close>
	return r;
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	89 f0                	mov    %esi,%eax
}
  8013f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f7:	5b                   	pop    %ebx
  8013f8:	5e                   	pop    %esi
  8013f9:	5d                   	pop    %ebp
  8013fa:	c3                   	ret    

008013fb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	56                   	push   %esi
  8013ff:	53                   	push   %ebx
  801400:	89 c6                	mov    %eax,%esi
  801402:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801404:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80140b:	75 12                	jne    80141f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80140d:	83 ec 0c             	sub    $0xc,%esp
  801410:	6a 01                	push   $0x1
  801412:	e8 43 0c 00 00       	call   80205a <ipc_find_env>
  801417:	a3 00 40 80 00       	mov    %eax,0x804000
  80141c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80141f:	6a 07                	push   $0x7
  801421:	68 00 50 c0 00       	push   $0xc05000
  801426:	56                   	push   %esi
  801427:	ff 35 00 40 80 00    	pushl  0x804000
  80142d:	e8 d4 0b 00 00       	call   802006 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801432:	83 c4 0c             	add    $0xc,%esp
  801435:	6a 00                	push   $0x0
  801437:	53                   	push   %ebx
  801438:	6a 00                	push   $0x0
  80143a:	e8 5e 0b 00 00       	call   801f9d <ipc_recv>
}
  80143f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801442:	5b                   	pop    %ebx
  801443:	5e                   	pop    %esi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    

00801446 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80144c:	8b 45 08             	mov    0x8(%ebp),%eax
  80144f:	8b 40 0c             	mov    0xc(%eax),%eax
  801452:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145a:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80145f:	ba 00 00 00 00       	mov    $0x0,%edx
  801464:	b8 02 00 00 00       	mov    $0x2,%eax
  801469:	e8 8d ff ff ff       	call   8013fb <fsipc>
}
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    

00801470 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	8b 40 0c             	mov    0xc(%eax),%eax
  80147c:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801481:	ba 00 00 00 00       	mov    $0x0,%edx
  801486:	b8 06 00 00 00       	mov    $0x6,%eax
  80148b:	e8 6b ff ff ff       	call   8013fb <fsipc>
}
  801490:	c9                   	leave  
  801491:	c3                   	ret    

00801492 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	53                   	push   %ebx
  801496:	83 ec 04             	sub    $0x4,%esp
  801499:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80149c:	8b 45 08             	mov    0x8(%ebp),%eax
  80149f:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a2:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8014b1:	e8 45 ff ff ff       	call   8013fb <fsipc>
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	78 2c                	js     8014e6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	68 00 50 c0 00       	push   $0xc05000
  8014c2:	53                   	push   %ebx
  8014c3:	e8 51 f3 ff ff       	call   800819 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014c8:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8014cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014d3:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8014d8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8014f4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014f9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014fe:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801501:	8b 55 08             	mov    0x8(%ebp),%edx
  801504:	8b 52 0c             	mov    0xc(%edx),%edx
  801507:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  80150d:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801512:	50                   	push   %eax
  801513:	ff 75 0c             	pushl  0xc(%ebp)
  801516:	68 08 50 c0 00       	push   $0xc05008
  80151b:	e8 8b f4 ff ff       	call   8009ab <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801520:	ba 00 00 00 00       	mov    $0x0,%edx
  801525:	b8 04 00 00 00       	mov    $0x4,%eax
  80152a:	e8 cc fe ff ff       	call   8013fb <fsipc>
	//panic("devfile_write not implemented");
}
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801539:	8b 45 08             	mov    0x8(%ebp),%eax
  80153c:	8b 40 0c             	mov    0xc(%eax),%eax
  80153f:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801544:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80154a:	ba 00 00 00 00       	mov    $0x0,%edx
  80154f:	b8 03 00 00 00       	mov    $0x3,%eax
  801554:	e8 a2 fe ff ff       	call   8013fb <fsipc>
  801559:	89 c3                	mov    %eax,%ebx
  80155b:	85 c0                	test   %eax,%eax
  80155d:	78 4b                	js     8015aa <devfile_read+0x79>
		return r;
	assert(r <= n);
  80155f:	39 c6                	cmp    %eax,%esi
  801561:	73 16                	jae    801579 <devfile_read+0x48>
  801563:	68 00 28 80 00       	push   $0x802800
  801568:	68 07 28 80 00       	push   $0x802807
  80156d:	6a 7c                	push   $0x7c
  80156f:	68 1c 28 80 00       	push   $0x80281c
  801574:	e8 c3 eb ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  801579:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80157e:	7e 16                	jle    801596 <devfile_read+0x65>
  801580:	68 27 28 80 00       	push   $0x802827
  801585:	68 07 28 80 00       	push   $0x802807
  80158a:	6a 7d                	push   $0x7d
  80158c:	68 1c 28 80 00       	push   $0x80281c
  801591:	e8 a6 eb ff ff       	call   80013c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801596:	83 ec 04             	sub    $0x4,%esp
  801599:	50                   	push   %eax
  80159a:	68 00 50 c0 00       	push   $0xc05000
  80159f:	ff 75 0c             	pushl  0xc(%ebp)
  8015a2:	e8 04 f4 ff ff       	call   8009ab <memmove>
	return r;
  8015a7:	83 c4 10             	add    $0x10,%esp
}
  8015aa:	89 d8                	mov    %ebx,%eax
  8015ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 20             	sub    $0x20,%esp
  8015ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015bd:	53                   	push   %ebx
  8015be:	e8 1d f2 ff ff       	call   8007e0 <strlen>
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015cb:	7f 67                	jg     801634 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015cd:	83 ec 0c             	sub    $0xc,%esp
  8015d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d3:	50                   	push   %eax
  8015d4:	e8 9a f8 ff ff       	call   800e73 <fd_alloc>
  8015d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8015dc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 57                	js     801639 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	53                   	push   %ebx
  8015e6:	68 00 50 c0 00       	push   $0xc05000
  8015eb:	e8 29 f2 ff ff       	call   800819 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f3:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015fb:	b8 01 00 00 00       	mov    $0x1,%eax
  801600:	e8 f6 fd ff ff       	call   8013fb <fsipc>
  801605:	89 c3                	mov    %eax,%ebx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	85 c0                	test   %eax,%eax
  80160c:	79 14                	jns    801622 <open+0x6f>
		fd_close(fd, 0);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	6a 00                	push   $0x0
  801613:	ff 75 f4             	pushl  -0xc(%ebp)
  801616:	e8 50 f9 ff ff       	call   800f6b <fd_close>
		return r;
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	89 da                	mov    %ebx,%edx
  801620:	eb 17                	jmp    801639 <open+0x86>
	}

	return fd2num(fd);
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	ff 75 f4             	pushl  -0xc(%ebp)
  801628:	e8 1f f8 ff ff       	call   800e4c <fd2num>
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	eb 05                	jmp    801639 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801634:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801639:	89 d0                	mov    %edx,%eax
  80163b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    

00801640 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801646:	ba 00 00 00 00       	mov    $0x0,%edx
  80164b:	b8 08 00 00 00       	mov    $0x8,%eax
  801650:	e8 a6 fd ff ff       	call   8013fb <fsipc>
}
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80165d:	68 33 28 80 00       	push   $0x802833
  801662:	ff 75 0c             	pushl  0xc(%ebp)
  801665:	e8 af f1 ff ff       	call   800819 <strcpy>
	return 0;
}
  80166a:	b8 00 00 00 00       	mov    $0x0,%eax
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	53                   	push   %ebx
  801675:	83 ec 10             	sub    $0x10,%esp
  801678:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80167b:	53                   	push   %ebx
  80167c:	e8 12 0a 00 00       	call   802093 <pageref>
  801681:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801684:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801689:	83 f8 01             	cmp    $0x1,%eax
  80168c:	75 10                	jne    80169e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80168e:	83 ec 0c             	sub    $0xc,%esp
  801691:	ff 73 0c             	pushl  0xc(%ebx)
  801694:	e8 c0 02 00 00       	call   801959 <nsipc_close>
  801699:	89 c2                	mov    %eax,%edx
  80169b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80169e:	89 d0                	mov    %edx,%eax
  8016a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016ab:	6a 00                	push   $0x0
  8016ad:	ff 75 10             	pushl  0x10(%ebp)
  8016b0:	ff 75 0c             	pushl  0xc(%ebp)
  8016b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b6:	ff 70 0c             	pushl  0xc(%eax)
  8016b9:	e8 78 03 00 00       	call   801a36 <nsipc_send>
}
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016c6:	6a 00                	push   $0x0
  8016c8:	ff 75 10             	pushl  0x10(%ebp)
  8016cb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d1:	ff 70 0c             	pushl  0xc(%eax)
  8016d4:	e8 f1 02 00 00       	call   8019ca <nsipc_recv>
}
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016e1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016e4:	52                   	push   %edx
  8016e5:	50                   	push   %eax
  8016e6:	e8 d7 f7 ff ff       	call   800ec2 <fd_lookup>
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 17                	js     801709 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016fb:	39 08                	cmp    %ecx,(%eax)
  8016fd:	75 05                	jne    801704 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801702:	eb 05                	jmp    801709 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801704:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	56                   	push   %esi
  80170f:	53                   	push   %ebx
  801710:	83 ec 1c             	sub    $0x1c,%esp
  801713:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801715:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801718:	50                   	push   %eax
  801719:	e8 55 f7 ff ff       	call   800e73 <fd_alloc>
  80171e:	89 c3                	mov    %eax,%ebx
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	85 c0                	test   %eax,%eax
  801725:	78 1b                	js     801742 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801727:	83 ec 04             	sub    $0x4,%esp
  80172a:	68 07 04 00 00       	push   $0x407
  80172f:	ff 75 f4             	pushl  -0xc(%ebp)
  801732:	6a 00                	push   $0x0
  801734:	e8 e3 f4 ff ff       	call   800c1c <sys_page_alloc>
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	85 c0                	test   %eax,%eax
  801740:	79 10                	jns    801752 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801742:	83 ec 0c             	sub    $0xc,%esp
  801745:	56                   	push   %esi
  801746:	e8 0e 02 00 00       	call   801959 <nsipc_close>
		return r;
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	89 d8                	mov    %ebx,%eax
  801750:	eb 24                	jmp    801776 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801752:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80175d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801760:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801767:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80176a:	83 ec 0c             	sub    $0xc,%esp
  80176d:	50                   	push   %eax
  80176e:	e8 d9 f6 ff ff       	call   800e4c <fd2num>
  801773:	83 c4 10             	add    $0x10,%esp
}
  801776:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801783:	8b 45 08             	mov    0x8(%ebp),%eax
  801786:	e8 50 ff ff ff       	call   8016db <fd2sockid>
		return r;
  80178b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 1f                	js     8017b0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801791:	83 ec 04             	sub    $0x4,%esp
  801794:	ff 75 10             	pushl  0x10(%ebp)
  801797:	ff 75 0c             	pushl  0xc(%ebp)
  80179a:	50                   	push   %eax
  80179b:	e8 12 01 00 00       	call   8018b2 <nsipc_accept>
  8017a0:	83 c4 10             	add    $0x10,%esp
		return r;
  8017a3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	78 07                	js     8017b0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017a9:	e8 5d ff ff ff       	call   80170b <alloc_sockfd>
  8017ae:	89 c1                	mov    %eax,%ecx
}
  8017b0:	89 c8                	mov    %ecx,%eax
  8017b2:	c9                   	leave  
  8017b3:	c3                   	ret    

008017b4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	e8 19 ff ff ff       	call   8016db <fd2sockid>
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 12                	js     8017d8 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017c6:	83 ec 04             	sub    $0x4,%esp
  8017c9:	ff 75 10             	pushl  0x10(%ebp)
  8017cc:	ff 75 0c             	pushl  0xc(%ebp)
  8017cf:	50                   	push   %eax
  8017d0:	e8 2d 01 00 00       	call   801902 <nsipc_bind>
  8017d5:	83 c4 10             	add    $0x10,%esp
}
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <shutdown>:

int
shutdown(int s, int how)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	e8 f3 fe ff ff       	call   8016db <fd2sockid>
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 0f                	js     8017fb <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	ff 75 0c             	pushl  0xc(%ebp)
  8017f2:	50                   	push   %eax
  8017f3:	e8 3f 01 00 00       	call   801937 <nsipc_shutdown>
  8017f8:	83 c4 10             	add    $0x10,%esp
}
  8017fb:	c9                   	leave  
  8017fc:	c3                   	ret    

008017fd <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	e8 d0 fe ff ff       	call   8016db <fd2sockid>
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 12                	js     801821 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80180f:	83 ec 04             	sub    $0x4,%esp
  801812:	ff 75 10             	pushl  0x10(%ebp)
  801815:	ff 75 0c             	pushl  0xc(%ebp)
  801818:	50                   	push   %eax
  801819:	e8 55 01 00 00       	call   801973 <nsipc_connect>
  80181e:	83 c4 10             	add    $0x10,%esp
}
  801821:	c9                   	leave  
  801822:	c3                   	ret    

00801823 <listen>:

int
listen(int s, int backlog)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	e8 aa fe ff ff       	call   8016db <fd2sockid>
  801831:	85 c0                	test   %eax,%eax
  801833:	78 0f                	js     801844 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801835:	83 ec 08             	sub    $0x8,%esp
  801838:	ff 75 0c             	pushl  0xc(%ebp)
  80183b:	50                   	push   %eax
  80183c:	e8 67 01 00 00       	call   8019a8 <nsipc_listen>
  801841:	83 c4 10             	add    $0x10,%esp
}
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80184c:	ff 75 10             	pushl  0x10(%ebp)
  80184f:	ff 75 0c             	pushl  0xc(%ebp)
  801852:	ff 75 08             	pushl  0x8(%ebp)
  801855:	e8 3a 02 00 00       	call   801a94 <nsipc_socket>
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 05                	js     801866 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801861:	e8 a5 fe ff ff       	call   80170b <alloc_sockfd>
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	53                   	push   %ebx
  80186c:	83 ec 04             	sub    $0x4,%esp
  80186f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801871:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801878:	75 12                	jne    80188c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80187a:	83 ec 0c             	sub    $0xc,%esp
  80187d:	6a 02                	push   $0x2
  80187f:	e8 d6 07 00 00       	call   80205a <ipc_find_env>
  801884:	a3 04 40 80 00       	mov    %eax,0x804004
  801889:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80188c:	6a 07                	push   $0x7
  80188e:	68 00 60 c0 00       	push   $0xc06000
  801893:	53                   	push   %ebx
  801894:	ff 35 04 40 80 00    	pushl  0x804004
  80189a:	e8 67 07 00 00       	call   802006 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80189f:	83 c4 0c             	add    $0xc,%esp
  8018a2:	6a 00                	push   $0x0
  8018a4:	6a 00                	push   $0x0
  8018a6:	6a 00                	push   $0x0
  8018a8:	e8 f0 06 00 00       	call   801f9d <ipc_recv>
}
  8018ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018c2:	8b 06                	mov    (%esi),%eax
  8018c4:	a3 04 60 c0 00       	mov    %eax,0xc06004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ce:	e8 95 ff ff ff       	call   801868 <nsipc>
  8018d3:	89 c3                	mov    %eax,%ebx
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	78 20                	js     8018f9 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018d9:	83 ec 04             	sub    $0x4,%esp
  8018dc:	ff 35 10 60 c0 00    	pushl  0xc06010
  8018e2:	68 00 60 c0 00       	push   $0xc06000
  8018e7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ea:	e8 bc f0 ff ff       	call   8009ab <memmove>
		*addrlen = ret->ret_addrlen;
  8018ef:	a1 10 60 c0 00       	mov    0xc06010,%eax
  8018f4:	89 06                	mov    %eax,(%esi)
  8018f6:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8018f9:	89 d8                	mov    %ebx,%eax
  8018fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80190c:	8b 45 08             	mov    0x8(%ebp),%eax
  80190f:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801914:	53                   	push   %ebx
  801915:	ff 75 0c             	pushl  0xc(%ebp)
  801918:	68 04 60 c0 00       	push   $0xc06004
  80191d:	e8 89 f0 ff ff       	call   8009ab <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801922:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_BIND);
  801928:	b8 02 00 00 00       	mov    $0x2,%eax
  80192d:	e8 36 ff ff ff       	call   801868 <nsipc>
}
  801932:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.shutdown.req_how = how;
  801945:	8b 45 0c             	mov    0xc(%ebp),%eax
  801948:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_SHUTDOWN);
  80194d:	b8 03 00 00 00       	mov    $0x3,%eax
  801952:	e8 11 ff ff ff       	call   801868 <nsipc>
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <nsipc_close>:

int
nsipc_close(int s)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80195f:	8b 45 08             	mov    0x8(%ebp),%eax
  801962:	a3 00 60 c0 00       	mov    %eax,0xc06000
	return nsipc(NSREQ_CLOSE);
  801967:	b8 04 00 00 00       	mov    $0x4,%eax
  80196c:	e8 f7 fe ff ff       	call   801868 <nsipc>
}
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	53                   	push   %ebx
  801977:	83 ec 08             	sub    $0x8,%esp
  80197a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80197d:	8b 45 08             	mov    0x8(%ebp),%eax
  801980:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801985:	53                   	push   %ebx
  801986:	ff 75 0c             	pushl  0xc(%ebp)
  801989:	68 04 60 c0 00       	push   $0xc06004
  80198e:	e8 18 f0 ff ff       	call   8009ab <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801993:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_CONNECT);
  801999:	b8 05 00 00 00       	mov    $0x5,%eax
  80199e:	e8 c5 fe ff ff       	call   801868 <nsipc>
}
  8019a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.listen.req_backlog = backlog;
  8019b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b9:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_LISTEN);
  8019be:	b8 06 00 00 00       	mov    $0x6,%eax
  8019c3:	e8 a0 fe ff ff       	call   801868 <nsipc>
}
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	56                   	push   %esi
  8019ce:	53                   	push   %ebx
  8019cf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d5:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.recv.req_len = len;
  8019da:	89 35 04 60 c0 00    	mov    %esi,0xc06004
	nsipcbuf.recv.req_flags = flags;
  8019e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e3:	a3 08 60 c0 00       	mov    %eax,0xc06008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019e8:	b8 07 00 00 00       	mov    $0x7,%eax
  8019ed:	e8 76 fe ff ff       	call   801868 <nsipc>
  8019f2:	89 c3                	mov    %eax,%ebx
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 35                	js     801a2d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8019f8:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8019fd:	7f 04                	jg     801a03 <nsipc_recv+0x39>
  8019ff:	39 c6                	cmp    %eax,%esi
  801a01:	7d 16                	jge    801a19 <nsipc_recv+0x4f>
  801a03:	68 3f 28 80 00       	push   $0x80283f
  801a08:	68 07 28 80 00       	push   $0x802807
  801a0d:	6a 62                	push   $0x62
  801a0f:	68 54 28 80 00       	push   $0x802854
  801a14:	e8 23 e7 ff ff       	call   80013c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a19:	83 ec 04             	sub    $0x4,%esp
  801a1c:	50                   	push   %eax
  801a1d:	68 00 60 c0 00       	push   $0xc06000
  801a22:	ff 75 0c             	pushl  0xc(%ebp)
  801a25:	e8 81 ef ff ff       	call   8009ab <memmove>
  801a2a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a2d:	89 d8                	mov    %ebx,%eax
  801a2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a32:	5b                   	pop    %ebx
  801a33:	5e                   	pop    %esi
  801a34:	5d                   	pop    %ebp
  801a35:	c3                   	ret    

00801a36 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	53                   	push   %ebx
  801a3a:	83 ec 04             	sub    $0x4,%esp
  801a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a40:	8b 45 08             	mov    0x8(%ebp),%eax
  801a43:	a3 00 60 c0 00       	mov    %eax,0xc06000
	assert(size < 1600);
  801a48:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a4e:	7e 16                	jle    801a66 <nsipc_send+0x30>
  801a50:	68 60 28 80 00       	push   $0x802860
  801a55:	68 07 28 80 00       	push   $0x802807
  801a5a:	6a 6d                	push   $0x6d
  801a5c:	68 54 28 80 00       	push   $0x802854
  801a61:	e8 d6 e6 ff ff       	call   80013c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a66:	83 ec 04             	sub    $0x4,%esp
  801a69:	53                   	push   %ebx
  801a6a:	ff 75 0c             	pushl  0xc(%ebp)
  801a6d:	68 0c 60 c0 00       	push   $0xc0600c
  801a72:	e8 34 ef ff ff       	call   8009ab <memmove>
	nsipcbuf.send.req_size = size;
  801a77:	89 1d 04 60 c0 00    	mov    %ebx,0xc06004
	nsipcbuf.send.req_flags = flags;
  801a7d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a80:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SEND);
  801a85:	b8 08 00 00 00       	mov    $0x8,%eax
  801a8a:	e8 d9 fd ff ff       	call   801868 <nsipc>
}
  801a8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a92:	c9                   	leave  
  801a93:	c3                   	ret    

00801a94 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9d:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.socket.req_type = type;
  801aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa5:	a3 04 60 c0 00       	mov    %eax,0xc06004
	nsipcbuf.socket.req_protocol = protocol;
  801aaa:	8b 45 10             	mov    0x10(%ebp),%eax
  801aad:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SOCKET);
  801ab2:	b8 09 00 00 00       	mov    $0x9,%eax
  801ab7:	e8 ac fd ff ff       	call   801868 <nsipc>
}
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    

00801abe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	56                   	push   %esi
  801ac2:	53                   	push   %ebx
  801ac3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ac6:	83 ec 0c             	sub    $0xc,%esp
  801ac9:	ff 75 08             	pushl  0x8(%ebp)
  801acc:	e8 8b f3 ff ff       	call   800e5c <fd2data>
  801ad1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ad3:	83 c4 08             	add    $0x8,%esp
  801ad6:	68 6c 28 80 00       	push   $0x80286c
  801adb:	53                   	push   %ebx
  801adc:	e8 38 ed ff ff       	call   800819 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ae1:	8b 46 04             	mov    0x4(%esi),%eax
  801ae4:	2b 06                	sub    (%esi),%eax
  801ae6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801af3:	00 00 00 
	stat->st_dev = &devpipe;
  801af6:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801afd:	30 80 00 
	return 0;
}
  801b00:	b8 00 00 00 00       	mov    $0x0,%eax
  801b05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b08:	5b                   	pop    %ebx
  801b09:	5e                   	pop    %esi
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 0c             	sub    $0xc,%esp
  801b13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b16:	53                   	push   %ebx
  801b17:	6a 00                	push   $0x0
  801b19:	e8 83 f1 ff ff       	call   800ca1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b1e:	89 1c 24             	mov    %ebx,(%esp)
  801b21:	e8 36 f3 ff ff       	call   800e5c <fd2data>
  801b26:	83 c4 08             	add    $0x8,%esp
  801b29:	50                   	push   %eax
  801b2a:	6a 00                	push   $0x0
  801b2c:	e8 70 f1 ff ff       	call   800ca1 <sys_page_unmap>
}
  801b31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    

00801b36 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	57                   	push   %edi
  801b3a:	56                   	push   %esi
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 1c             	sub    $0x1c,%esp
  801b3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b42:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b44:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b49:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b4c:	83 ec 0c             	sub    $0xc,%esp
  801b4f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b52:	e8 3c 05 00 00       	call   802093 <pageref>
  801b57:	89 c3                	mov    %eax,%ebx
  801b59:	89 3c 24             	mov    %edi,(%esp)
  801b5c:	e8 32 05 00 00       	call   802093 <pageref>
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	39 c3                	cmp    %eax,%ebx
  801b66:	0f 94 c1             	sete   %cl
  801b69:	0f b6 c9             	movzbl %cl,%ecx
  801b6c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b6f:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801b75:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b78:	39 ce                	cmp    %ecx,%esi
  801b7a:	74 1b                	je     801b97 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b7c:	39 c3                	cmp    %eax,%ebx
  801b7e:	75 c4                	jne    801b44 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b80:	8b 42 58             	mov    0x58(%edx),%eax
  801b83:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b86:	50                   	push   %eax
  801b87:	56                   	push   %esi
  801b88:	68 73 28 80 00       	push   $0x802873
  801b8d:	e8 83 e6 ff ff       	call   800215 <cprintf>
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	eb ad                	jmp    801b44 <_pipeisclosed+0xe>
	}
}
  801b97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5f                   	pop    %edi
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    

00801ba2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	57                   	push   %edi
  801ba6:	56                   	push   %esi
  801ba7:	53                   	push   %ebx
  801ba8:	83 ec 28             	sub    $0x28,%esp
  801bab:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bae:	56                   	push   %esi
  801baf:	e8 a8 f2 ff ff       	call   800e5c <fd2data>
  801bb4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	bf 00 00 00 00       	mov    $0x0,%edi
  801bbe:	eb 4b                	jmp    801c0b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bc0:	89 da                	mov    %ebx,%edx
  801bc2:	89 f0                	mov    %esi,%eax
  801bc4:	e8 6d ff ff ff       	call   801b36 <_pipeisclosed>
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	75 48                	jne    801c15 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bcd:	e8 2b f0 ff ff       	call   800bfd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bd2:	8b 43 04             	mov    0x4(%ebx),%eax
  801bd5:	8b 0b                	mov    (%ebx),%ecx
  801bd7:	8d 51 20             	lea    0x20(%ecx),%edx
  801bda:	39 d0                	cmp    %edx,%eax
  801bdc:	73 e2                	jae    801bc0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801be5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801be8:	89 c2                	mov    %eax,%edx
  801bea:	c1 fa 1f             	sar    $0x1f,%edx
  801bed:	89 d1                	mov    %edx,%ecx
  801bef:	c1 e9 1b             	shr    $0x1b,%ecx
  801bf2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bf5:	83 e2 1f             	and    $0x1f,%edx
  801bf8:	29 ca                	sub    %ecx,%edx
  801bfa:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bfe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c02:	83 c0 01             	add    $0x1,%eax
  801c05:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c08:	83 c7 01             	add    $0x1,%edi
  801c0b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c0e:	75 c2                	jne    801bd2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c10:	8b 45 10             	mov    0x10(%ebp),%eax
  801c13:	eb 05                	jmp    801c1a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c15:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5f                   	pop    %edi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    

00801c22 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	57                   	push   %edi
  801c26:	56                   	push   %esi
  801c27:	53                   	push   %ebx
  801c28:	83 ec 18             	sub    $0x18,%esp
  801c2b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c2e:	57                   	push   %edi
  801c2f:	e8 28 f2 ff ff       	call   800e5c <fd2data>
  801c34:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c3e:	eb 3d                	jmp    801c7d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c40:	85 db                	test   %ebx,%ebx
  801c42:	74 04                	je     801c48 <devpipe_read+0x26>
				return i;
  801c44:	89 d8                	mov    %ebx,%eax
  801c46:	eb 44                	jmp    801c8c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c48:	89 f2                	mov    %esi,%edx
  801c4a:	89 f8                	mov    %edi,%eax
  801c4c:	e8 e5 fe ff ff       	call   801b36 <_pipeisclosed>
  801c51:	85 c0                	test   %eax,%eax
  801c53:	75 32                	jne    801c87 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c55:	e8 a3 ef ff ff       	call   800bfd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c5a:	8b 06                	mov    (%esi),%eax
  801c5c:	3b 46 04             	cmp    0x4(%esi),%eax
  801c5f:	74 df                	je     801c40 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c61:	99                   	cltd   
  801c62:	c1 ea 1b             	shr    $0x1b,%edx
  801c65:	01 d0                	add    %edx,%eax
  801c67:	83 e0 1f             	and    $0x1f,%eax
  801c6a:	29 d0                	sub    %edx,%eax
  801c6c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c74:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c77:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c7a:	83 c3 01             	add    $0x1,%ebx
  801c7d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c80:	75 d8                	jne    801c5a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c82:	8b 45 10             	mov    0x10(%ebp),%eax
  801c85:	eb 05                	jmp    801c8c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c87:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5f                   	pop    %edi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    

00801c94 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9f:	50                   	push   %eax
  801ca0:	e8 ce f1 ff ff       	call   800e73 <fd_alloc>
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	89 c2                	mov    %eax,%edx
  801caa:	85 c0                	test   %eax,%eax
  801cac:	0f 88 2c 01 00 00    	js     801dde <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb2:	83 ec 04             	sub    $0x4,%esp
  801cb5:	68 07 04 00 00       	push   $0x407
  801cba:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbd:	6a 00                	push   $0x0
  801cbf:	e8 58 ef ff ff       	call   800c1c <sys_page_alloc>
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	89 c2                	mov    %eax,%edx
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	0f 88 0d 01 00 00    	js     801dde <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cd1:	83 ec 0c             	sub    $0xc,%esp
  801cd4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cd7:	50                   	push   %eax
  801cd8:	e8 96 f1 ff ff       	call   800e73 <fd_alloc>
  801cdd:	89 c3                	mov    %eax,%ebx
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	0f 88 e2 00 00 00    	js     801dcc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cea:	83 ec 04             	sub    $0x4,%esp
  801ced:	68 07 04 00 00       	push   $0x407
  801cf2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf5:	6a 00                	push   $0x0
  801cf7:	e8 20 ef ff ff       	call   800c1c <sys_page_alloc>
  801cfc:	89 c3                	mov    %eax,%ebx
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	85 c0                	test   %eax,%eax
  801d03:	0f 88 c3 00 00 00    	js     801dcc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d09:	83 ec 0c             	sub    $0xc,%esp
  801d0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0f:	e8 48 f1 ff ff       	call   800e5c <fd2data>
  801d14:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d16:	83 c4 0c             	add    $0xc,%esp
  801d19:	68 07 04 00 00       	push   $0x407
  801d1e:	50                   	push   %eax
  801d1f:	6a 00                	push   $0x0
  801d21:	e8 f6 ee ff ff       	call   800c1c <sys_page_alloc>
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	83 c4 10             	add    $0x10,%esp
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	0f 88 89 00 00 00    	js     801dbc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d33:	83 ec 0c             	sub    $0xc,%esp
  801d36:	ff 75 f0             	pushl  -0x10(%ebp)
  801d39:	e8 1e f1 ff ff       	call   800e5c <fd2data>
  801d3e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d45:	50                   	push   %eax
  801d46:	6a 00                	push   $0x0
  801d48:	56                   	push   %esi
  801d49:	6a 00                	push   $0x0
  801d4b:	e8 0f ef ff ff       	call   800c5f <sys_page_map>
  801d50:	89 c3                	mov    %eax,%ebx
  801d52:	83 c4 20             	add    $0x20,%esp
  801d55:	85 c0                	test   %eax,%eax
  801d57:	78 55                	js     801dae <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d59:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d62:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d67:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d77:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d83:	83 ec 0c             	sub    $0xc,%esp
  801d86:	ff 75 f4             	pushl  -0xc(%ebp)
  801d89:	e8 be f0 ff ff       	call   800e4c <fd2num>
  801d8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d91:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d93:	83 c4 04             	add    $0x4,%esp
  801d96:	ff 75 f0             	pushl  -0x10(%ebp)
  801d99:	e8 ae f0 ff ff       	call   800e4c <fd2num>
  801d9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801da1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dac:	eb 30                	jmp    801dde <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dae:	83 ec 08             	sub    $0x8,%esp
  801db1:	56                   	push   %esi
  801db2:	6a 00                	push   $0x0
  801db4:	e8 e8 ee ff ff       	call   800ca1 <sys_page_unmap>
  801db9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dbc:	83 ec 08             	sub    $0x8,%esp
  801dbf:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc2:	6a 00                	push   $0x0
  801dc4:	e8 d8 ee ff ff       	call   800ca1 <sys_page_unmap>
  801dc9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dcc:	83 ec 08             	sub    $0x8,%esp
  801dcf:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd2:	6a 00                	push   $0x0
  801dd4:	e8 c8 ee ff ff       	call   800ca1 <sys_page_unmap>
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dde:	89 d0                	mov    %edx,%eax
  801de0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    

00801de7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ded:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df0:	50                   	push   %eax
  801df1:	ff 75 08             	pushl  0x8(%ebp)
  801df4:	e8 c9 f0 ff ff       	call   800ec2 <fd_lookup>
  801df9:	83 c4 10             	add    $0x10,%esp
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	78 18                	js     801e18 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e00:	83 ec 0c             	sub    $0xc,%esp
  801e03:	ff 75 f4             	pushl  -0xc(%ebp)
  801e06:	e8 51 f0 ff ff       	call   800e5c <fd2data>
	return _pipeisclosed(fd, p);
  801e0b:	89 c2                	mov    %eax,%edx
  801e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e10:	e8 21 fd ff ff       	call   801b36 <_pipeisclosed>
  801e15:	83 c4 10             	add    $0x10,%esp
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    

00801e24 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e2a:	68 8b 28 80 00       	push   $0x80288b
  801e2f:	ff 75 0c             	pushl  0xc(%ebp)
  801e32:	e8 e2 e9 ff ff       	call   800819 <strcpy>
	return 0;
}
  801e37:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	57                   	push   %edi
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e4a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e4f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e55:	eb 2d                	jmp    801e84 <devcons_write+0x46>
		m = n - tot;
  801e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e5a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e5c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e5f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e64:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e67:	83 ec 04             	sub    $0x4,%esp
  801e6a:	53                   	push   %ebx
  801e6b:	03 45 0c             	add    0xc(%ebp),%eax
  801e6e:	50                   	push   %eax
  801e6f:	57                   	push   %edi
  801e70:	e8 36 eb ff ff       	call   8009ab <memmove>
		sys_cputs(buf, m);
  801e75:	83 c4 08             	add    $0x8,%esp
  801e78:	53                   	push   %ebx
  801e79:	57                   	push   %edi
  801e7a:	e8 e1 ec ff ff       	call   800b60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7f:	01 de                	add    %ebx,%esi
  801e81:	83 c4 10             	add    $0x10,%esp
  801e84:	89 f0                	mov    %esi,%eax
  801e86:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e89:	72 cc                	jb     801e57 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8e:	5b                   	pop    %ebx
  801e8f:	5e                   	pop    %esi
  801e90:	5f                   	pop    %edi
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    

00801e93 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	83 ec 08             	sub    $0x8,%esp
  801e99:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ea2:	74 2a                	je     801ece <devcons_read+0x3b>
  801ea4:	eb 05                	jmp    801eab <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ea6:	e8 52 ed ff ff       	call   800bfd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eab:	e8 ce ec ff ff       	call   800b7e <sys_cgetc>
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	74 f2                	je     801ea6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	78 16                	js     801ece <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eb8:	83 f8 04             	cmp    $0x4,%eax
  801ebb:	74 0c                	je     801ec9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ebd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec0:	88 02                	mov    %al,(%edx)
	return 1;
  801ec2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec7:	eb 05                	jmp    801ece <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ec9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801edc:	6a 01                	push   $0x1
  801ede:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ee1:	50                   	push   %eax
  801ee2:	e8 79 ec ff ff       	call   800b60 <sys_cputs>
}
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    

00801eec <getchar>:

int
getchar(void)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ef2:	6a 01                	push   $0x1
  801ef4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ef7:	50                   	push   %eax
  801ef8:	6a 00                	push   $0x0
  801efa:	e8 29 f2 ff ff       	call   801128 <read>
	if (r < 0)
  801eff:	83 c4 10             	add    $0x10,%esp
  801f02:	85 c0                	test   %eax,%eax
  801f04:	78 0f                	js     801f15 <getchar+0x29>
		return r;
	if (r < 1)
  801f06:	85 c0                	test   %eax,%eax
  801f08:	7e 06                	jle    801f10 <getchar+0x24>
		return -E_EOF;
	return c;
  801f0a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f0e:	eb 05                	jmp    801f15 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f10:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    

00801f17 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f20:	50                   	push   %eax
  801f21:	ff 75 08             	pushl  0x8(%ebp)
  801f24:	e8 99 ef ff ff       	call   800ec2 <fd_lookup>
  801f29:	83 c4 10             	add    $0x10,%esp
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	78 11                	js     801f41 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f33:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f39:	39 10                	cmp    %edx,(%eax)
  801f3b:	0f 94 c0             	sete   %al
  801f3e:	0f b6 c0             	movzbl %al,%eax
}
  801f41:	c9                   	leave  
  801f42:	c3                   	ret    

00801f43 <opencons>:

int
opencons(void)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4c:	50                   	push   %eax
  801f4d:	e8 21 ef ff ff       	call   800e73 <fd_alloc>
  801f52:	83 c4 10             	add    $0x10,%esp
		return r;
  801f55:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f57:	85 c0                	test   %eax,%eax
  801f59:	78 3e                	js     801f99 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f5b:	83 ec 04             	sub    $0x4,%esp
  801f5e:	68 07 04 00 00       	push   $0x407
  801f63:	ff 75 f4             	pushl  -0xc(%ebp)
  801f66:	6a 00                	push   $0x0
  801f68:	e8 af ec ff ff       	call   800c1c <sys_page_alloc>
  801f6d:	83 c4 10             	add    $0x10,%esp
		return r;
  801f70:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f72:	85 c0                	test   %eax,%eax
  801f74:	78 23                	js     801f99 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f76:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f84:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f8b:	83 ec 0c             	sub    $0xc,%esp
  801f8e:	50                   	push   %eax
  801f8f:	e8 b8 ee ff ff       	call   800e4c <fd2num>
  801f94:	89 c2                	mov    %eax,%edx
  801f96:	83 c4 10             	add    $0x10,%esp
}
  801f99:	89 d0                	mov    %edx,%eax
  801f9b:	c9                   	leave  
  801f9c:	c3                   	ret    

00801f9d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	56                   	push   %esi
  801fa1:	53                   	push   %ebx
  801fa2:	8b 75 08             	mov    0x8(%ebp),%esi
  801fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801fab:	85 c0                	test   %eax,%eax
  801fad:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fb2:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801fb5:	83 ec 0c             	sub    $0xc,%esp
  801fb8:	50                   	push   %eax
  801fb9:	e8 0e ee ff ff       	call   800dcc <sys_ipc_recv>
  801fbe:	83 c4 10             	add    $0x10,%esp
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	79 16                	jns    801fdb <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801fc5:	85 f6                	test   %esi,%esi
  801fc7:	74 06                	je     801fcf <ipc_recv+0x32>
            *from_env_store = 0;
  801fc9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801fcf:	85 db                	test   %ebx,%ebx
  801fd1:	74 2c                	je     801fff <ipc_recv+0x62>
            *perm_store = 0;
  801fd3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fd9:	eb 24                	jmp    801fff <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801fdb:	85 f6                	test   %esi,%esi
  801fdd:	74 0a                	je     801fe9 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801fdf:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801fe4:	8b 40 74             	mov    0x74(%eax),%eax
  801fe7:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801fe9:	85 db                	test   %ebx,%ebx
  801feb:	74 0a                	je     801ff7 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801fed:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ff2:	8b 40 78             	mov    0x78(%eax),%eax
  801ff5:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801ff7:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ffc:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801fff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802002:	5b                   	pop    %ebx
  802003:	5e                   	pop    %esi
  802004:	5d                   	pop    %ebp
  802005:	c3                   	ret    

00802006 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	57                   	push   %edi
  80200a:	56                   	push   %esi
  80200b:	53                   	push   %ebx
  80200c:	83 ec 0c             	sub    $0xc,%esp
  80200f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802012:	8b 75 0c             	mov    0xc(%ebp),%esi
  802015:	8b 45 10             	mov    0x10(%ebp),%eax
  802018:	85 c0                	test   %eax,%eax
  80201a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80201f:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802022:	eb 1c                	jmp    802040 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  802024:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802027:	74 12                	je     80203b <ipc_send+0x35>
  802029:	50                   	push   %eax
  80202a:	68 97 28 80 00       	push   $0x802897
  80202f:	6a 3b                	push   $0x3b
  802031:	68 ad 28 80 00       	push   $0x8028ad
  802036:	e8 01 e1 ff ff       	call   80013c <_panic>
		sys_yield();
  80203b:	e8 bd eb ff ff       	call   800bfd <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802040:	ff 75 14             	pushl  0x14(%ebp)
  802043:	53                   	push   %ebx
  802044:	56                   	push   %esi
  802045:	57                   	push   %edi
  802046:	e8 5e ed ff ff       	call   800da9 <sys_ipc_try_send>
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	85 c0                	test   %eax,%eax
  802050:	78 d2                	js     802024 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802052:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5f                   	pop    %edi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    

0080205a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802060:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802065:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802068:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80206e:	8b 52 50             	mov    0x50(%edx),%edx
  802071:	39 ca                	cmp    %ecx,%edx
  802073:	75 0d                	jne    802082 <ipc_find_env+0x28>
			return envs[i].env_id;
  802075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80207d:	8b 40 48             	mov    0x48(%eax),%eax
  802080:	eb 0f                	jmp    802091 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802082:	83 c0 01             	add    $0x1,%eax
  802085:	3d 00 04 00 00       	cmp    $0x400,%eax
  80208a:	75 d9                	jne    802065 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80208c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802091:	5d                   	pop    %ebp
  802092:	c3                   	ret    

00802093 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
  802096:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802099:	89 d0                	mov    %edx,%eax
  80209b:	c1 e8 16             	shr    $0x16,%eax
  80209e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020a5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020aa:	f6 c1 01             	test   $0x1,%cl
  8020ad:	74 1d                	je     8020cc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020af:	c1 ea 0c             	shr    $0xc,%edx
  8020b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020b9:	f6 c2 01             	test   $0x1,%dl
  8020bc:	74 0e                	je     8020cc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020be:	c1 ea 0c             	shr    $0xc,%edx
  8020c1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020c8:	ef 
  8020c9:	0f b7 c0             	movzwl %ax,%eax
}
  8020cc:	5d                   	pop    %ebp
  8020cd:	c3                   	ret    
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__udivdi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 f6                	test   %esi,%esi
  8020e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ed:	89 ca                	mov    %ecx,%edx
  8020ef:	89 f8                	mov    %edi,%eax
  8020f1:	75 3d                	jne    802130 <__udivdi3+0x60>
  8020f3:	39 cf                	cmp    %ecx,%edi
  8020f5:	0f 87 c5 00 00 00    	ja     8021c0 <__udivdi3+0xf0>
  8020fb:	85 ff                	test   %edi,%edi
  8020fd:	89 fd                	mov    %edi,%ebp
  8020ff:	75 0b                	jne    80210c <__udivdi3+0x3c>
  802101:	b8 01 00 00 00       	mov    $0x1,%eax
  802106:	31 d2                	xor    %edx,%edx
  802108:	f7 f7                	div    %edi
  80210a:	89 c5                	mov    %eax,%ebp
  80210c:	89 c8                	mov    %ecx,%eax
  80210e:	31 d2                	xor    %edx,%edx
  802110:	f7 f5                	div    %ebp
  802112:	89 c1                	mov    %eax,%ecx
  802114:	89 d8                	mov    %ebx,%eax
  802116:	89 cf                	mov    %ecx,%edi
  802118:	f7 f5                	div    %ebp
  80211a:	89 c3                	mov    %eax,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	39 ce                	cmp    %ecx,%esi
  802132:	77 74                	ja     8021a8 <__udivdi3+0xd8>
  802134:	0f bd fe             	bsr    %esi,%edi
  802137:	83 f7 1f             	xor    $0x1f,%edi
  80213a:	0f 84 98 00 00 00    	je     8021d8 <__udivdi3+0x108>
  802140:	bb 20 00 00 00       	mov    $0x20,%ebx
  802145:	89 f9                	mov    %edi,%ecx
  802147:	89 c5                	mov    %eax,%ebp
  802149:	29 fb                	sub    %edi,%ebx
  80214b:	d3 e6                	shl    %cl,%esi
  80214d:	89 d9                	mov    %ebx,%ecx
  80214f:	d3 ed                	shr    %cl,%ebp
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e0                	shl    %cl,%eax
  802155:	09 ee                	or     %ebp,%esi
  802157:	89 d9                	mov    %ebx,%ecx
  802159:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80215d:	89 d5                	mov    %edx,%ebp
  80215f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802163:	d3 ed                	shr    %cl,%ebp
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e2                	shl    %cl,%edx
  802169:	89 d9                	mov    %ebx,%ecx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	09 c2                	or     %eax,%edx
  80216f:	89 d0                	mov    %edx,%eax
  802171:	89 ea                	mov    %ebp,%edx
  802173:	f7 f6                	div    %esi
  802175:	89 d5                	mov    %edx,%ebp
  802177:	89 c3                	mov    %eax,%ebx
  802179:	f7 64 24 0c          	mull   0xc(%esp)
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	72 10                	jb     802191 <__udivdi3+0xc1>
  802181:	8b 74 24 08          	mov    0x8(%esp),%esi
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e6                	shl    %cl,%esi
  802189:	39 c6                	cmp    %eax,%esi
  80218b:	73 07                	jae    802194 <__udivdi3+0xc4>
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	75 03                	jne    802194 <__udivdi3+0xc4>
  802191:	83 eb 01             	sub    $0x1,%ebx
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 d8                	mov    %ebx,%eax
  802198:	89 fa                	mov    %edi,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	31 ff                	xor    %edi,%edi
  8021aa:	31 db                	xor    %ebx,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 d8                	mov    %ebx,%eax
  8021c2:	f7 f7                	div    %edi
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 fa                	mov    %edi,%edx
  8021cc:	83 c4 1c             	add    $0x1c,%esp
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5f                   	pop    %edi
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	39 ce                	cmp    %ecx,%esi
  8021da:	72 0c                	jb     8021e8 <__udivdi3+0x118>
  8021dc:	31 db                	xor    %ebx,%ebx
  8021de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021e2:	0f 87 34 ff ff ff    	ja     80211c <__udivdi3+0x4c>
  8021e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ed:	e9 2a ff ff ff       	jmp    80211c <__udivdi3+0x4c>
  8021f2:	66 90                	xchg   %ax,%ax
  8021f4:	66 90                	xchg   %ax,%ax
  8021f6:	66 90                	xchg   %ax,%ax
  8021f8:	66 90                	xchg   %ax,%ax
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__umoddi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80220b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80220f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 d2                	test   %edx,%edx
  802219:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80221d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802221:	89 f3                	mov    %esi,%ebx
  802223:	89 3c 24             	mov    %edi,(%esp)
  802226:	89 74 24 04          	mov    %esi,0x4(%esp)
  80222a:	75 1c                	jne    802248 <__umoddi3+0x48>
  80222c:	39 f7                	cmp    %esi,%edi
  80222e:	76 50                	jbe    802280 <__umoddi3+0x80>
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	f7 f7                	div    %edi
  802236:	89 d0                	mov    %edx,%eax
  802238:	31 d2                	xor    %edx,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	39 f2                	cmp    %esi,%edx
  80224a:	89 d0                	mov    %edx,%eax
  80224c:	77 52                	ja     8022a0 <__umoddi3+0xa0>
  80224e:	0f bd ea             	bsr    %edx,%ebp
  802251:	83 f5 1f             	xor    $0x1f,%ebp
  802254:	75 5a                	jne    8022b0 <__umoddi3+0xb0>
  802256:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80225a:	0f 82 e0 00 00 00    	jb     802340 <__umoddi3+0x140>
  802260:	39 0c 24             	cmp    %ecx,(%esp)
  802263:	0f 86 d7 00 00 00    	jbe    802340 <__umoddi3+0x140>
  802269:	8b 44 24 08          	mov    0x8(%esp),%eax
  80226d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802271:	83 c4 1c             	add    $0x1c,%esp
  802274:	5b                   	pop    %ebx
  802275:	5e                   	pop    %esi
  802276:	5f                   	pop    %edi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	85 ff                	test   %edi,%edi
  802282:	89 fd                	mov    %edi,%ebp
  802284:	75 0b                	jne    802291 <__umoddi3+0x91>
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	f7 f7                	div    %edi
  80228f:	89 c5                	mov    %eax,%ebp
  802291:	89 f0                	mov    %esi,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f5                	div    %ebp
  802297:	89 c8                	mov    %ecx,%eax
  802299:	f7 f5                	div    %ebp
  80229b:	89 d0                	mov    %edx,%eax
  80229d:	eb 99                	jmp    802238 <__umoddi3+0x38>
  80229f:	90                   	nop
  8022a0:	89 c8                	mov    %ecx,%eax
  8022a2:	89 f2                	mov    %esi,%edx
  8022a4:	83 c4 1c             	add    $0x1c,%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    
  8022ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	8b 34 24             	mov    (%esp),%esi
  8022b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022b8:	89 e9                	mov    %ebp,%ecx
  8022ba:	29 ef                	sub    %ebp,%edi
  8022bc:	d3 e0                	shl    %cl,%eax
  8022be:	89 f9                	mov    %edi,%ecx
  8022c0:	89 f2                	mov    %esi,%edx
  8022c2:	d3 ea                	shr    %cl,%edx
  8022c4:	89 e9                	mov    %ebp,%ecx
  8022c6:	09 c2                	or     %eax,%edx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 14 24             	mov    %edx,(%esp)
  8022cd:	89 f2                	mov    %esi,%edx
  8022cf:	d3 e2                	shl    %cl,%edx
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	89 c6                	mov    %eax,%esi
  8022e1:	d3 e3                	shl    %cl,%ebx
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 d0                	mov    %edx,%eax
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	09 d8                	or     %ebx,%eax
  8022ed:	89 d3                	mov    %edx,%ebx
  8022ef:	89 f2                	mov    %esi,%edx
  8022f1:	f7 34 24             	divl   (%esp)
  8022f4:	89 d6                	mov    %edx,%esi
  8022f6:	d3 e3                	shl    %cl,%ebx
  8022f8:	f7 64 24 04          	mull   0x4(%esp)
  8022fc:	39 d6                	cmp    %edx,%esi
  8022fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802302:	89 d1                	mov    %edx,%ecx
  802304:	89 c3                	mov    %eax,%ebx
  802306:	72 08                	jb     802310 <__umoddi3+0x110>
  802308:	75 11                	jne    80231b <__umoddi3+0x11b>
  80230a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80230e:	73 0b                	jae    80231b <__umoddi3+0x11b>
  802310:	2b 44 24 04          	sub    0x4(%esp),%eax
  802314:	1b 14 24             	sbb    (%esp),%edx
  802317:	89 d1                	mov    %edx,%ecx
  802319:	89 c3                	mov    %eax,%ebx
  80231b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80231f:	29 da                	sub    %ebx,%edx
  802321:	19 ce                	sbb    %ecx,%esi
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 f0                	mov    %esi,%eax
  802327:	d3 e0                	shl    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	d3 ea                	shr    %cl,%edx
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	d3 ee                	shr    %cl,%esi
  802331:	09 d0                	or     %edx,%eax
  802333:	89 f2                	mov    %esi,%edx
  802335:	83 c4 1c             	add    $0x1c,%esp
  802338:	5b                   	pop    %ebx
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	29 f9                	sub    %edi,%ecx
  802342:	19 d6                	sbb    %edx,%esi
  802344:	89 74 24 04          	mov    %esi,0x4(%esp)
  802348:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80234c:	e9 18 ff ff ff       	jmp    802269 <__umoddi3+0x69>
