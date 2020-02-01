
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
  800039:	68 c0 1e 80 00       	push   $0x801ec0
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
  800056:	68 3b 1f 80 00       	push   $0x801f3b
  80005b:	6a 11                	push   $0x11
  80005d:	68 58 1f 80 00       	push   $0x801f58
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
  800096:	68 e0 1e 80 00       	push   $0x801ee0
  80009b:	6a 16                	push   $0x16
  80009d:	68 58 1f 80 00       	push   $0x801f58
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
  8000b4:	68 08 1f 80 00       	push   $0x801f08
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 67 1f 80 00       	push   $0x801f67
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 58 1f 80 00       	push   $0x801f58
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
  800128:	e8 ab 0e 00 00       	call   800fd8 <close_all>
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
  80015a:	68 88 1f 80 00       	push   $0x801f88
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 56 1f 80 00 	movl   $0x801f56,(%esp)
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
  800278:	e8 b3 19 00 00       	call   801c30 <__udivdi3>
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
  8002bb:	e8 a0 1a 00 00       	call   801d60 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 ab 1f 80 00 	movsbl 0x801fab(%eax),%eax
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
  800385:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
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
  80044c:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  800453:	85 d2                	test   %edx,%edx
  800455:	75 1b                	jne    800472 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800457:	50                   	push   %eax
  800458:	68 c3 1f 80 00       	push   $0x801fc3
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
  800473:	68 75 23 80 00       	push   $0x802375
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
  80049d:	b8 bc 1f 80 00       	mov    $0x801fbc,%eax
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
  800bc5:	68 9f 22 80 00       	push   $0x80229f
  800bca:	6a 23                	push   $0x23
  800bcc:	68 bc 22 80 00       	push   $0x8022bc
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
  800c46:	68 9f 22 80 00       	push   $0x80229f
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 bc 22 80 00       	push   $0x8022bc
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
  800c88:	68 9f 22 80 00       	push   $0x80229f
  800c8d:	6a 23                	push   $0x23
  800c8f:	68 bc 22 80 00       	push   $0x8022bc
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
  800cca:	68 9f 22 80 00       	push   $0x80229f
  800ccf:	6a 23                	push   $0x23
  800cd1:	68 bc 22 80 00       	push   $0x8022bc
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
  800d0c:	68 9f 22 80 00       	push   $0x80229f
  800d11:	6a 23                	push   $0x23
  800d13:	68 bc 22 80 00       	push   $0x8022bc
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
  800d4e:	68 9f 22 80 00       	push   $0x80229f
  800d53:	6a 23                	push   $0x23
  800d55:	68 bc 22 80 00       	push   $0x8022bc
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
  800d90:	68 9f 22 80 00       	push   $0x80229f
  800d95:	6a 23                	push   $0x23
  800d97:	68 bc 22 80 00       	push   $0x8022bc
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
  800df4:	68 9f 22 80 00       	push   $0x80229f
  800df9:	6a 23                	push   $0x23
  800dfb:	68 bc 22 80 00       	push   $0x8022bc
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

00800e0d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	05 00 00 00 30       	add    $0x30000000,%eax
  800e18:	c1 e8 0c             	shr    $0xc,%eax
}
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	05 00 00 00 30       	add    $0x30000000,%eax
  800e28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e2d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e3f:	89 c2                	mov    %eax,%edx
  800e41:	c1 ea 16             	shr    $0x16,%edx
  800e44:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4b:	f6 c2 01             	test   $0x1,%dl
  800e4e:	74 11                	je     800e61 <fd_alloc+0x2d>
  800e50:	89 c2                	mov    %eax,%edx
  800e52:	c1 ea 0c             	shr    $0xc,%edx
  800e55:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5c:	f6 c2 01             	test   $0x1,%dl
  800e5f:	75 09                	jne    800e6a <fd_alloc+0x36>
			*fd_store = fd;
  800e61:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e63:	b8 00 00 00 00       	mov    $0x0,%eax
  800e68:	eb 17                	jmp    800e81 <fd_alloc+0x4d>
  800e6a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e6f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e74:	75 c9                	jne    800e3f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e76:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e7c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e89:	83 f8 1f             	cmp    $0x1f,%eax
  800e8c:	77 36                	ja     800ec4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e8e:	c1 e0 0c             	shl    $0xc,%eax
  800e91:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e96:	89 c2                	mov    %eax,%edx
  800e98:	c1 ea 16             	shr    $0x16,%edx
  800e9b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea2:	f6 c2 01             	test   $0x1,%dl
  800ea5:	74 24                	je     800ecb <fd_lookup+0x48>
  800ea7:	89 c2                	mov    %eax,%edx
  800ea9:	c1 ea 0c             	shr    $0xc,%edx
  800eac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb3:	f6 c2 01             	test   $0x1,%dl
  800eb6:	74 1a                	je     800ed2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebb:	89 02                	mov    %eax,(%edx)
	return 0;
  800ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec2:	eb 13                	jmp    800ed7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec9:	eb 0c                	jmp    800ed7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ecb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed0:	eb 05                	jmp    800ed7 <fd_lookup+0x54>
  800ed2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee2:	ba 4c 23 80 00       	mov    $0x80234c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ee7:	eb 13                	jmp    800efc <dev_lookup+0x23>
  800ee9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eec:	39 08                	cmp    %ecx,(%eax)
  800eee:	75 0c                	jne    800efc <dev_lookup+0x23>
			*dev = devtab[i];
  800ef0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  800efa:	eb 2e                	jmp    800f2a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800efc:	8b 02                	mov    (%edx),%eax
  800efe:	85 c0                	test   %eax,%eax
  800f00:	75 e7                	jne    800ee9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f02:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f07:	8b 40 48             	mov    0x48(%eax),%eax
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	51                   	push   %ecx
  800f0e:	50                   	push   %eax
  800f0f:	68 cc 22 80 00       	push   $0x8022cc
  800f14:	e8 fc f2 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800f19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f22:	83 c4 10             	add    $0x10,%esp
  800f25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f2a:	c9                   	leave  
  800f2b:	c3                   	ret    

00800f2c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
  800f31:	83 ec 10             	sub    $0x10,%esp
  800f34:	8b 75 08             	mov    0x8(%ebp),%esi
  800f37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3d:	50                   	push   %eax
  800f3e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f44:	c1 e8 0c             	shr    $0xc,%eax
  800f47:	50                   	push   %eax
  800f48:	e8 36 ff ff ff       	call   800e83 <fd_lookup>
  800f4d:	83 c4 08             	add    $0x8,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	78 05                	js     800f59 <fd_close+0x2d>
	    || fd != fd2)
  800f54:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f57:	74 0c                	je     800f65 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f59:	84 db                	test   %bl,%bl
  800f5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f60:	0f 44 c2             	cmove  %edx,%eax
  800f63:	eb 41                	jmp    800fa6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f65:	83 ec 08             	sub    $0x8,%esp
  800f68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f6b:	50                   	push   %eax
  800f6c:	ff 36                	pushl  (%esi)
  800f6e:	e8 66 ff ff ff       	call   800ed9 <dev_lookup>
  800f73:	89 c3                	mov    %eax,%ebx
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 1a                	js     800f96 <fd_close+0x6a>
		if (dev->dev_close)
  800f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f82:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f87:	85 c0                	test   %eax,%eax
  800f89:	74 0b                	je     800f96 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f8b:	83 ec 0c             	sub    $0xc,%esp
  800f8e:	56                   	push   %esi
  800f8f:	ff d0                	call   *%eax
  800f91:	89 c3                	mov    %eax,%ebx
  800f93:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	56                   	push   %esi
  800f9a:	6a 00                	push   $0x0
  800f9c:	e8 00 fd ff ff       	call   800ca1 <sys_page_unmap>
	return r;
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	89 d8                	mov    %ebx,%eax
}
  800fa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa9:	5b                   	pop    %ebx
  800faa:	5e                   	pop    %esi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb6:	50                   	push   %eax
  800fb7:	ff 75 08             	pushl  0x8(%ebp)
  800fba:	e8 c4 fe ff ff       	call   800e83 <fd_lookup>
  800fbf:	83 c4 08             	add    $0x8,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 10                	js     800fd6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fc6:	83 ec 08             	sub    $0x8,%esp
  800fc9:	6a 01                	push   $0x1
  800fcb:	ff 75 f4             	pushl  -0xc(%ebp)
  800fce:	e8 59 ff ff ff       	call   800f2c <fd_close>
  800fd3:	83 c4 10             	add    $0x10,%esp
}
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <close_all>:

void
close_all(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	53                   	push   %ebx
  800fdc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fdf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fe4:	83 ec 0c             	sub    $0xc,%esp
  800fe7:	53                   	push   %ebx
  800fe8:	e8 c0 ff ff ff       	call   800fad <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fed:	83 c3 01             	add    $0x1,%ebx
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	83 fb 20             	cmp    $0x20,%ebx
  800ff6:	75 ec                	jne    800fe4 <close_all+0xc>
		close(i);
}
  800ff8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	57                   	push   %edi
  801001:	56                   	push   %esi
  801002:	53                   	push   %ebx
  801003:	83 ec 2c             	sub    $0x2c,%esp
  801006:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801009:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80100c:	50                   	push   %eax
  80100d:	ff 75 08             	pushl  0x8(%ebp)
  801010:	e8 6e fe ff ff       	call   800e83 <fd_lookup>
  801015:	83 c4 08             	add    $0x8,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	0f 88 c1 00 00 00    	js     8010e1 <dup+0xe4>
		return r;
	close(newfdnum);
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	56                   	push   %esi
  801024:	e8 84 ff ff ff       	call   800fad <close>

	newfd = INDEX2FD(newfdnum);
  801029:	89 f3                	mov    %esi,%ebx
  80102b:	c1 e3 0c             	shl    $0xc,%ebx
  80102e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801034:	83 c4 04             	add    $0x4,%esp
  801037:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103a:	e8 de fd ff ff       	call   800e1d <fd2data>
  80103f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801041:	89 1c 24             	mov    %ebx,(%esp)
  801044:	e8 d4 fd ff ff       	call   800e1d <fd2data>
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80104f:	89 f8                	mov    %edi,%eax
  801051:	c1 e8 16             	shr    $0x16,%eax
  801054:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105b:	a8 01                	test   $0x1,%al
  80105d:	74 37                	je     801096 <dup+0x99>
  80105f:	89 f8                	mov    %edi,%eax
  801061:	c1 e8 0c             	shr    $0xc,%eax
  801064:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106b:	f6 c2 01             	test   $0x1,%dl
  80106e:	74 26                	je     801096 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801070:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	25 07 0e 00 00       	and    $0xe07,%eax
  80107f:	50                   	push   %eax
  801080:	ff 75 d4             	pushl  -0x2c(%ebp)
  801083:	6a 00                	push   $0x0
  801085:	57                   	push   %edi
  801086:	6a 00                	push   $0x0
  801088:	e8 d2 fb ff ff       	call   800c5f <sys_page_map>
  80108d:	89 c7                	mov    %eax,%edi
  80108f:	83 c4 20             	add    $0x20,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	78 2e                	js     8010c4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801096:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801099:	89 d0                	mov    %edx,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
  80109e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ad:	50                   	push   %eax
  8010ae:	53                   	push   %ebx
  8010af:	6a 00                	push   $0x0
  8010b1:	52                   	push   %edx
  8010b2:	6a 00                	push   $0x0
  8010b4:	e8 a6 fb ff ff       	call   800c5f <sys_page_map>
  8010b9:	89 c7                	mov    %eax,%edi
  8010bb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010be:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c0:	85 ff                	test   %edi,%edi
  8010c2:	79 1d                	jns    8010e1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c4:	83 ec 08             	sub    $0x8,%esp
  8010c7:	53                   	push   %ebx
  8010c8:	6a 00                	push   $0x0
  8010ca:	e8 d2 fb ff ff       	call   800ca1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010cf:	83 c4 08             	add    $0x8,%esp
  8010d2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d5:	6a 00                	push   $0x0
  8010d7:	e8 c5 fb ff ff       	call   800ca1 <sys_page_unmap>
	return r;
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	89 f8                	mov    %edi,%eax
}
  8010e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 14             	sub    $0x14,%esp
  8010f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f6:	50                   	push   %eax
  8010f7:	53                   	push   %ebx
  8010f8:	e8 86 fd ff ff       	call   800e83 <fd_lookup>
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	89 c2                	mov    %eax,%edx
  801102:	85 c0                	test   %eax,%eax
  801104:	78 6d                	js     801173 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801106:	83 ec 08             	sub    $0x8,%esp
  801109:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110c:	50                   	push   %eax
  80110d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801110:	ff 30                	pushl  (%eax)
  801112:	e8 c2 fd ff ff       	call   800ed9 <dev_lookup>
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 4c                	js     80116a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801121:	8b 42 08             	mov    0x8(%edx),%eax
  801124:	83 e0 03             	and    $0x3,%eax
  801127:	83 f8 01             	cmp    $0x1,%eax
  80112a:	75 21                	jne    80114d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80112c:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801131:	8b 40 48             	mov    0x48(%eax),%eax
  801134:	83 ec 04             	sub    $0x4,%esp
  801137:	53                   	push   %ebx
  801138:	50                   	push   %eax
  801139:	68 10 23 80 00       	push   $0x802310
  80113e:	e8 d2 f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114b:	eb 26                	jmp    801173 <read+0x8a>
	}
	if (!dev->dev_read)
  80114d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801150:	8b 40 08             	mov    0x8(%eax),%eax
  801153:	85 c0                	test   %eax,%eax
  801155:	74 17                	je     80116e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	ff 75 10             	pushl  0x10(%ebp)
  80115d:	ff 75 0c             	pushl  0xc(%ebp)
  801160:	52                   	push   %edx
  801161:	ff d0                	call   *%eax
  801163:	89 c2                	mov    %eax,%edx
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	eb 09                	jmp    801173 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116a:	89 c2                	mov    %eax,%edx
  80116c:	eb 05                	jmp    801173 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80116e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801173:	89 d0                	mov    %edx,%eax
  801175:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	8b 7d 08             	mov    0x8(%ebp),%edi
  801186:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801189:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118e:	eb 21                	jmp    8011b1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801190:	83 ec 04             	sub    $0x4,%esp
  801193:	89 f0                	mov    %esi,%eax
  801195:	29 d8                	sub    %ebx,%eax
  801197:	50                   	push   %eax
  801198:	89 d8                	mov    %ebx,%eax
  80119a:	03 45 0c             	add    0xc(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	57                   	push   %edi
  80119f:	e8 45 ff ff ff       	call   8010e9 <read>
		if (m < 0)
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 10                	js     8011bb <readn+0x41>
			return m;
		if (m == 0)
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	74 0a                	je     8011b9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011af:	01 c3                	add    %eax,%ebx
  8011b1:	39 f3                	cmp    %esi,%ebx
  8011b3:	72 db                	jb     801190 <readn+0x16>
  8011b5:	89 d8                	mov    %ebx,%eax
  8011b7:	eb 02                	jmp    8011bb <readn+0x41>
  8011b9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011be:	5b                   	pop    %ebx
  8011bf:	5e                   	pop    %esi
  8011c0:	5f                   	pop    %edi
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 14             	sub    $0x14,%esp
  8011ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d0:	50                   	push   %eax
  8011d1:	53                   	push   %ebx
  8011d2:	e8 ac fc ff ff       	call   800e83 <fd_lookup>
  8011d7:	83 c4 08             	add    $0x8,%esp
  8011da:	89 c2                	mov    %eax,%edx
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 68                	js     801248 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e0:	83 ec 08             	sub    $0x8,%esp
  8011e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e6:	50                   	push   %eax
  8011e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ea:	ff 30                	pushl  (%eax)
  8011ec:	e8 e8 fc ff ff       	call   800ed9 <dev_lookup>
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 47                	js     80123f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ff:	75 21                	jne    801222 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801201:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801206:	8b 40 48             	mov    0x48(%eax),%eax
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	53                   	push   %ebx
  80120d:	50                   	push   %eax
  80120e:	68 2c 23 80 00       	push   $0x80232c
  801213:	e8 fd ef ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801220:	eb 26                	jmp    801248 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801222:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801225:	8b 52 0c             	mov    0xc(%edx),%edx
  801228:	85 d2                	test   %edx,%edx
  80122a:	74 17                	je     801243 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	ff 75 10             	pushl  0x10(%ebp)
  801232:	ff 75 0c             	pushl  0xc(%ebp)
  801235:	50                   	push   %eax
  801236:	ff d2                	call   *%edx
  801238:	89 c2                	mov    %eax,%edx
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	eb 09                	jmp    801248 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123f:	89 c2                	mov    %eax,%edx
  801241:	eb 05                	jmp    801248 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801243:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801248:	89 d0                	mov    %edx,%eax
  80124a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <seek>:

int
seek(int fdnum, off_t offset)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801255:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	ff 75 08             	pushl  0x8(%ebp)
  80125c:	e8 22 fc ff ff       	call   800e83 <fd_lookup>
  801261:	83 c4 08             	add    $0x8,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	78 0e                	js     801276 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801268:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80126b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801276:	c9                   	leave  
  801277:	c3                   	ret    

00801278 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	53                   	push   %ebx
  80127c:	83 ec 14             	sub    $0x14,%esp
  80127f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801282:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	53                   	push   %ebx
  801287:	e8 f7 fb ff ff       	call   800e83 <fd_lookup>
  80128c:	83 c4 08             	add    $0x8,%esp
  80128f:	89 c2                	mov    %eax,%edx
  801291:	85 c0                	test   %eax,%eax
  801293:	78 65                	js     8012fa <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801295:	83 ec 08             	sub    $0x8,%esp
  801298:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129b:	50                   	push   %eax
  80129c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129f:	ff 30                	pushl  (%eax)
  8012a1:	e8 33 fc ff ff       	call   800ed9 <dev_lookup>
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 44                	js     8012f1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b4:	75 21                	jne    8012d7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012b6:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012bb:	8b 40 48             	mov    0x48(%eax),%eax
  8012be:	83 ec 04             	sub    $0x4,%esp
  8012c1:	53                   	push   %ebx
  8012c2:	50                   	push   %eax
  8012c3:	68 ec 22 80 00       	push   $0x8022ec
  8012c8:	e8 48 ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d5:	eb 23                	jmp    8012fa <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012da:	8b 52 18             	mov    0x18(%edx),%edx
  8012dd:	85 d2                	test   %edx,%edx
  8012df:	74 14                	je     8012f5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e1:	83 ec 08             	sub    $0x8,%esp
  8012e4:	ff 75 0c             	pushl  0xc(%ebp)
  8012e7:	50                   	push   %eax
  8012e8:	ff d2                	call   *%edx
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	eb 09                	jmp    8012fa <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f1:	89 c2                	mov    %eax,%edx
  8012f3:	eb 05                	jmp    8012fa <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012fa:	89 d0                	mov    %edx,%eax
  8012fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ff:	c9                   	leave  
  801300:	c3                   	ret    

00801301 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	53                   	push   %ebx
  801305:	83 ec 14             	sub    $0x14,%esp
  801308:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130e:	50                   	push   %eax
  80130f:	ff 75 08             	pushl  0x8(%ebp)
  801312:	e8 6c fb ff ff       	call   800e83 <fd_lookup>
  801317:	83 c4 08             	add    $0x8,%esp
  80131a:	89 c2                	mov    %eax,%edx
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 58                	js     801378 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132a:	ff 30                	pushl  (%eax)
  80132c:	e8 a8 fb ff ff       	call   800ed9 <dev_lookup>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 37                	js     80136f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801338:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80133f:	74 32                	je     801373 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801341:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801344:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80134b:	00 00 00 
	stat->st_isdir = 0;
  80134e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801355:	00 00 00 
	stat->st_dev = dev;
  801358:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80135e:	83 ec 08             	sub    $0x8,%esp
  801361:	53                   	push   %ebx
  801362:	ff 75 f0             	pushl  -0x10(%ebp)
  801365:	ff 50 14             	call   *0x14(%eax)
  801368:	89 c2                	mov    %eax,%edx
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	eb 09                	jmp    801378 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136f:	89 c2                	mov    %eax,%edx
  801371:	eb 05                	jmp    801378 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801373:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801378:	89 d0                	mov    %edx,%eax
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	56                   	push   %esi
  801383:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	6a 00                	push   $0x0
  801389:	ff 75 08             	pushl  0x8(%ebp)
  80138c:	e8 e3 01 00 00       	call   801574 <open>
  801391:	89 c3                	mov    %eax,%ebx
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	78 1b                	js     8013b5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	ff 75 0c             	pushl  0xc(%ebp)
  8013a0:	50                   	push   %eax
  8013a1:	e8 5b ff ff ff       	call   801301 <fstat>
  8013a6:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a8:	89 1c 24             	mov    %ebx,(%esp)
  8013ab:	e8 fd fb ff ff       	call   800fad <close>
	return r;
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	89 f0                	mov    %esi,%eax
}
  8013b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	89 c6                	mov    %eax,%esi
  8013c3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013cc:	75 12                	jne    8013e0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	6a 01                	push   $0x1
  8013d3:	e8 dc 07 00 00       	call   801bb4 <ipc_find_env>
  8013d8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013dd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013e0:	6a 07                	push   $0x7
  8013e2:	68 00 50 c0 00       	push   $0xc05000
  8013e7:	56                   	push   %esi
  8013e8:	ff 35 00 40 80 00    	pushl  0x804000
  8013ee:	e8 6d 07 00 00       	call   801b60 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013f3:	83 c4 0c             	add    $0xc,%esp
  8013f6:	6a 00                	push   $0x0
  8013f8:	53                   	push   %ebx
  8013f9:	6a 00                	push   $0x0
  8013fb:	e8 f7 06 00 00       	call   801af7 <ipc_recv>
}
  801400:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801403:	5b                   	pop    %ebx
  801404:	5e                   	pop    %esi
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
  801410:	8b 40 0c             	mov    0xc(%eax),%eax
  801413:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801418:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141b:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801420:	ba 00 00 00 00       	mov    $0x0,%edx
  801425:	b8 02 00 00 00       	mov    $0x2,%eax
  80142a:	e8 8d ff ff ff       	call   8013bc <fsipc>
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801437:	8b 45 08             	mov    0x8(%ebp),%eax
  80143a:	8b 40 0c             	mov    0xc(%eax),%eax
  80143d:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801442:	ba 00 00 00 00       	mov    $0x0,%edx
  801447:	b8 06 00 00 00       	mov    $0x6,%eax
  80144c:	e8 6b ff ff ff       	call   8013bc <fsipc>
}
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	53                   	push   %ebx
  801457:	83 ec 04             	sub    $0x4,%esp
  80145a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
  801460:	8b 40 0c             	mov    0xc(%eax),%eax
  801463:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801468:	ba 00 00 00 00       	mov    $0x0,%edx
  80146d:	b8 05 00 00 00       	mov    $0x5,%eax
  801472:	e8 45 ff ff ff       	call   8013bc <fsipc>
  801477:	85 c0                	test   %eax,%eax
  801479:	78 2c                	js     8014a7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	68 00 50 c0 00       	push   $0xc05000
  801483:	53                   	push   %ebx
  801484:	e8 90 f3 ff ff       	call   800819 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801489:	a1 80 50 c0 00       	mov    0xc05080,%eax
  80148e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801494:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801499:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 0c             	sub    $0xc,%esp
  8014b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8014b5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014ba:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014bf:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8014c8:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  8014ce:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014d3:	50                   	push   %eax
  8014d4:	ff 75 0c             	pushl  0xc(%ebp)
  8014d7:	68 08 50 c0 00       	push   $0xc05008
  8014dc:	e8 ca f4 ff ff       	call   8009ab <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e6:	b8 04 00 00 00       	mov    $0x4,%eax
  8014eb:	e8 cc fe ff ff       	call   8013bc <fsipc>
	//panic("devfile_write not implemented");
}
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	56                   	push   %esi
  8014f6:	53                   	push   %ebx
  8014f7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801500:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801505:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80150b:	ba 00 00 00 00       	mov    $0x0,%edx
  801510:	b8 03 00 00 00       	mov    $0x3,%eax
  801515:	e8 a2 fe ff ff       	call   8013bc <fsipc>
  80151a:	89 c3                	mov    %eax,%ebx
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 4b                	js     80156b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801520:	39 c6                	cmp    %eax,%esi
  801522:	73 16                	jae    80153a <devfile_read+0x48>
  801524:	68 5c 23 80 00       	push   $0x80235c
  801529:	68 63 23 80 00       	push   $0x802363
  80152e:	6a 7c                	push   $0x7c
  801530:	68 78 23 80 00       	push   $0x802378
  801535:	e8 02 ec ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  80153a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80153f:	7e 16                	jle    801557 <devfile_read+0x65>
  801541:	68 83 23 80 00       	push   $0x802383
  801546:	68 63 23 80 00       	push   $0x802363
  80154b:	6a 7d                	push   $0x7d
  80154d:	68 78 23 80 00       	push   $0x802378
  801552:	e8 e5 eb ff ff       	call   80013c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	50                   	push   %eax
  80155b:	68 00 50 c0 00       	push   $0xc05000
  801560:	ff 75 0c             	pushl  0xc(%ebp)
  801563:	e8 43 f4 ff ff       	call   8009ab <memmove>
	return r;
  801568:	83 c4 10             	add    $0x10,%esp
}
  80156b:	89 d8                	mov    %ebx,%eax
  80156d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801570:	5b                   	pop    %ebx
  801571:	5e                   	pop    %esi
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    

00801574 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	53                   	push   %ebx
  801578:	83 ec 20             	sub    $0x20,%esp
  80157b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80157e:	53                   	push   %ebx
  80157f:	e8 5c f2 ff ff       	call   8007e0 <strlen>
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80158c:	7f 67                	jg     8015f5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	e8 9a f8 ff ff       	call   800e34 <fd_alloc>
  80159a:	83 c4 10             	add    $0x10,%esp
		return r;
  80159d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 57                	js     8015fa <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	68 00 50 c0 00       	push   $0xc05000
  8015ac:	e8 68 f2 ff ff       	call   800819 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b4:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c1:	e8 f6 fd ff ff       	call   8013bc <fsipc>
  8015c6:	89 c3                	mov    %eax,%ebx
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	79 14                	jns    8015e3 <open+0x6f>
		fd_close(fd, 0);
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	6a 00                	push   $0x0
  8015d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d7:	e8 50 f9 ff ff       	call   800f2c <fd_close>
		return r;
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	89 da                	mov    %ebx,%edx
  8015e1:	eb 17                	jmp    8015fa <open+0x86>
	}

	return fd2num(fd);
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e9:	e8 1f f8 ff ff       	call   800e0d <fd2num>
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	eb 05                	jmp    8015fa <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015f5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015fa:	89 d0                	mov    %edx,%eax
  8015fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    

00801601 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801607:	ba 00 00 00 00       	mov    $0x0,%edx
  80160c:	b8 08 00 00 00       	mov    $0x8,%eax
  801611:	e8 a6 fd ff ff       	call   8013bc <fsipc>
}
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	56                   	push   %esi
  80161c:	53                   	push   %ebx
  80161d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801620:	83 ec 0c             	sub    $0xc,%esp
  801623:	ff 75 08             	pushl  0x8(%ebp)
  801626:	e8 f2 f7 ff ff       	call   800e1d <fd2data>
  80162b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80162d:	83 c4 08             	add    $0x8,%esp
  801630:	68 8f 23 80 00       	push   $0x80238f
  801635:	53                   	push   %ebx
  801636:	e8 de f1 ff ff       	call   800819 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80163b:	8b 46 04             	mov    0x4(%esi),%eax
  80163e:	2b 06                	sub    (%esi),%eax
  801640:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801646:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80164d:	00 00 00 
	stat->st_dev = &devpipe;
  801650:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801657:	30 80 00 
	return 0;
}
  80165a:	b8 00 00 00 00       	mov    $0x0,%eax
  80165f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801662:	5b                   	pop    %ebx
  801663:	5e                   	pop    %esi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 0c             	sub    $0xc,%esp
  80166d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801670:	53                   	push   %ebx
  801671:	6a 00                	push   $0x0
  801673:	e8 29 f6 ff ff       	call   800ca1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801678:	89 1c 24             	mov    %ebx,(%esp)
  80167b:	e8 9d f7 ff ff       	call   800e1d <fd2data>
  801680:	83 c4 08             	add    $0x8,%esp
  801683:	50                   	push   %eax
  801684:	6a 00                	push   $0x0
  801686:	e8 16 f6 ff ff       	call   800ca1 <sys_page_unmap>
}
  80168b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	57                   	push   %edi
  801694:	56                   	push   %esi
  801695:	53                   	push   %ebx
  801696:	83 ec 1c             	sub    $0x1c,%esp
  801699:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80169c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80169e:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8016a3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016a6:	83 ec 0c             	sub    $0xc,%esp
  8016a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ac:	e8 3c 05 00 00       	call   801bed <pageref>
  8016b1:	89 c3                	mov    %eax,%ebx
  8016b3:	89 3c 24             	mov    %edi,(%esp)
  8016b6:	e8 32 05 00 00       	call   801bed <pageref>
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	39 c3                	cmp    %eax,%ebx
  8016c0:	0f 94 c1             	sete   %cl
  8016c3:	0f b6 c9             	movzbl %cl,%ecx
  8016c6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016c9:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  8016cf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016d2:	39 ce                	cmp    %ecx,%esi
  8016d4:	74 1b                	je     8016f1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016d6:	39 c3                	cmp    %eax,%ebx
  8016d8:	75 c4                	jne    80169e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016da:	8b 42 58             	mov    0x58(%edx),%eax
  8016dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e0:	50                   	push   %eax
  8016e1:	56                   	push   %esi
  8016e2:	68 96 23 80 00       	push   $0x802396
  8016e7:	e8 29 eb ff ff       	call   800215 <cprintf>
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	eb ad                	jmp    80169e <_pipeisclosed+0xe>
	}
}
  8016f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5e                   	pop    %esi
  8016f9:	5f                   	pop    %edi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	57                   	push   %edi
  801700:	56                   	push   %esi
  801701:	53                   	push   %ebx
  801702:	83 ec 28             	sub    $0x28,%esp
  801705:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801708:	56                   	push   %esi
  801709:	e8 0f f7 ff ff       	call   800e1d <fd2data>
  80170e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	bf 00 00 00 00       	mov    $0x0,%edi
  801718:	eb 4b                	jmp    801765 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80171a:	89 da                	mov    %ebx,%edx
  80171c:	89 f0                	mov    %esi,%eax
  80171e:	e8 6d ff ff ff       	call   801690 <_pipeisclosed>
  801723:	85 c0                	test   %eax,%eax
  801725:	75 48                	jne    80176f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801727:	e8 d1 f4 ff ff       	call   800bfd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80172c:	8b 43 04             	mov    0x4(%ebx),%eax
  80172f:	8b 0b                	mov    (%ebx),%ecx
  801731:	8d 51 20             	lea    0x20(%ecx),%edx
  801734:	39 d0                	cmp    %edx,%eax
  801736:	73 e2                	jae    80171a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801738:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80173f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801742:	89 c2                	mov    %eax,%edx
  801744:	c1 fa 1f             	sar    $0x1f,%edx
  801747:	89 d1                	mov    %edx,%ecx
  801749:	c1 e9 1b             	shr    $0x1b,%ecx
  80174c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80174f:	83 e2 1f             	and    $0x1f,%edx
  801752:	29 ca                	sub    %ecx,%edx
  801754:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801758:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80175c:	83 c0 01             	add    $0x1,%eax
  80175f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801762:	83 c7 01             	add    $0x1,%edi
  801765:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801768:	75 c2                	jne    80172c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80176a:	8b 45 10             	mov    0x10(%ebp),%eax
  80176d:	eb 05                	jmp    801774 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80176f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801774:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801777:	5b                   	pop    %ebx
  801778:	5e                   	pop    %esi
  801779:	5f                   	pop    %edi
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	57                   	push   %edi
  801780:	56                   	push   %esi
  801781:	53                   	push   %ebx
  801782:	83 ec 18             	sub    $0x18,%esp
  801785:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801788:	57                   	push   %edi
  801789:	e8 8f f6 ff ff       	call   800e1d <fd2data>
  80178e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	bb 00 00 00 00       	mov    $0x0,%ebx
  801798:	eb 3d                	jmp    8017d7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80179a:	85 db                	test   %ebx,%ebx
  80179c:	74 04                	je     8017a2 <devpipe_read+0x26>
				return i;
  80179e:	89 d8                	mov    %ebx,%eax
  8017a0:	eb 44                	jmp    8017e6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017a2:	89 f2                	mov    %esi,%edx
  8017a4:	89 f8                	mov    %edi,%eax
  8017a6:	e8 e5 fe ff ff       	call   801690 <_pipeisclosed>
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	75 32                	jne    8017e1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017af:	e8 49 f4 ff ff       	call   800bfd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017b4:	8b 06                	mov    (%esi),%eax
  8017b6:	3b 46 04             	cmp    0x4(%esi),%eax
  8017b9:	74 df                	je     80179a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017bb:	99                   	cltd   
  8017bc:	c1 ea 1b             	shr    $0x1b,%edx
  8017bf:	01 d0                	add    %edx,%eax
  8017c1:	83 e0 1f             	and    $0x1f,%eax
  8017c4:	29 d0                	sub    %edx,%eax
  8017c6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ce:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017d1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d4:	83 c3 01             	add    $0x1,%ebx
  8017d7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017da:	75 d8                	jne    8017b4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8017df:	eb 05                	jmp    8017e6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017e1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e9:	5b                   	pop    %ebx
  8017ea:	5e                   	pop    %esi
  8017eb:	5f                   	pop    %edi
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	56                   	push   %esi
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f9:	50                   	push   %eax
  8017fa:	e8 35 f6 ff ff       	call   800e34 <fd_alloc>
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	89 c2                	mov    %eax,%edx
  801804:	85 c0                	test   %eax,%eax
  801806:	0f 88 2c 01 00 00    	js     801938 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180c:	83 ec 04             	sub    $0x4,%esp
  80180f:	68 07 04 00 00       	push   $0x407
  801814:	ff 75 f4             	pushl  -0xc(%ebp)
  801817:	6a 00                	push   $0x0
  801819:	e8 fe f3 ff ff       	call   800c1c <sys_page_alloc>
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	89 c2                	mov    %eax,%edx
  801823:	85 c0                	test   %eax,%eax
  801825:	0f 88 0d 01 00 00    	js     801938 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80182b:	83 ec 0c             	sub    $0xc,%esp
  80182e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	e8 fd f5 ff ff       	call   800e34 <fd_alloc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	0f 88 e2 00 00 00    	js     801926 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801844:	83 ec 04             	sub    $0x4,%esp
  801847:	68 07 04 00 00       	push   $0x407
  80184c:	ff 75 f0             	pushl  -0x10(%ebp)
  80184f:	6a 00                	push   $0x0
  801851:	e8 c6 f3 ff ff       	call   800c1c <sys_page_alloc>
  801856:	89 c3                	mov    %eax,%ebx
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	85 c0                	test   %eax,%eax
  80185d:	0f 88 c3 00 00 00    	js     801926 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801863:	83 ec 0c             	sub    $0xc,%esp
  801866:	ff 75 f4             	pushl  -0xc(%ebp)
  801869:	e8 af f5 ff ff       	call   800e1d <fd2data>
  80186e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801870:	83 c4 0c             	add    $0xc,%esp
  801873:	68 07 04 00 00       	push   $0x407
  801878:	50                   	push   %eax
  801879:	6a 00                	push   $0x0
  80187b:	e8 9c f3 ff ff       	call   800c1c <sys_page_alloc>
  801880:	89 c3                	mov    %eax,%ebx
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	85 c0                	test   %eax,%eax
  801887:	0f 88 89 00 00 00    	js     801916 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188d:	83 ec 0c             	sub    $0xc,%esp
  801890:	ff 75 f0             	pushl  -0x10(%ebp)
  801893:	e8 85 f5 ff ff       	call   800e1d <fd2data>
  801898:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80189f:	50                   	push   %eax
  8018a0:	6a 00                	push   $0x0
  8018a2:	56                   	push   %esi
  8018a3:	6a 00                	push   $0x0
  8018a5:	e8 b5 f3 ff ff       	call   800c5f <sys_page_map>
  8018aa:	89 c3                	mov    %eax,%ebx
  8018ac:	83 c4 20             	add    $0x20,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 55                	js     801908 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018b3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018c8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e3:	e8 25 f5 ff ff       	call   800e0d <fd2num>
  8018e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018eb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018ed:	83 c4 04             	add    $0x4,%esp
  8018f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f3:	e8 15 f5 ff ff       	call   800e0d <fd2num>
  8018f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018fb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	ba 00 00 00 00       	mov    $0x0,%edx
  801906:	eb 30                	jmp    801938 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801908:	83 ec 08             	sub    $0x8,%esp
  80190b:	56                   	push   %esi
  80190c:	6a 00                	push   $0x0
  80190e:	e8 8e f3 ff ff       	call   800ca1 <sys_page_unmap>
  801913:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	ff 75 f0             	pushl  -0x10(%ebp)
  80191c:	6a 00                	push   $0x0
  80191e:	e8 7e f3 ff ff       	call   800ca1 <sys_page_unmap>
  801923:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	ff 75 f4             	pushl  -0xc(%ebp)
  80192c:	6a 00                	push   $0x0
  80192e:	e8 6e f3 ff ff       	call   800ca1 <sys_page_unmap>
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801938:	89 d0                	mov    %edx,%eax
  80193a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5e                   	pop    %esi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801947:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194a:	50                   	push   %eax
  80194b:	ff 75 08             	pushl  0x8(%ebp)
  80194e:	e8 30 f5 ff ff       	call   800e83 <fd_lookup>
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	85 c0                	test   %eax,%eax
  801958:	78 18                	js     801972 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80195a:	83 ec 0c             	sub    $0xc,%esp
  80195d:	ff 75 f4             	pushl  -0xc(%ebp)
  801960:	e8 b8 f4 ff ff       	call   800e1d <fd2data>
	return _pipeisclosed(fd, p);
  801965:	89 c2                	mov    %eax,%edx
  801967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196a:	e8 21 fd ff ff       	call   801690 <_pipeisclosed>
  80196f:	83 c4 10             	add    $0x10,%esp
}
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801977:	b8 00 00 00 00       	mov    $0x0,%eax
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801984:	68 ae 23 80 00       	push   $0x8023ae
  801989:	ff 75 0c             	pushl  0xc(%ebp)
  80198c:	e8 88 ee ff ff       	call   800819 <strcpy>
	return 0;
}
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	57                   	push   %edi
  80199c:	56                   	push   %esi
  80199d:	53                   	push   %ebx
  80199e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019a9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019af:	eb 2d                	jmp    8019de <devcons_write+0x46>
		m = n - tot;
  8019b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019b4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019b6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019b9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019be:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019c1:	83 ec 04             	sub    $0x4,%esp
  8019c4:	53                   	push   %ebx
  8019c5:	03 45 0c             	add    0xc(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	57                   	push   %edi
  8019ca:	e8 dc ef ff ff       	call   8009ab <memmove>
		sys_cputs(buf, m);
  8019cf:	83 c4 08             	add    $0x8,%esp
  8019d2:	53                   	push   %ebx
  8019d3:	57                   	push   %edi
  8019d4:	e8 87 f1 ff ff       	call   800b60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d9:	01 de                	add    %ebx,%esi
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	89 f0                	mov    %esi,%eax
  8019e0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019e3:	72 cc                	jb     8019b1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e8:	5b                   	pop    %ebx
  8019e9:	5e                   	pop    %esi
  8019ea:	5f                   	pop    %edi
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    

008019ed <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	83 ec 08             	sub    $0x8,%esp
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019fc:	74 2a                	je     801a28 <devcons_read+0x3b>
  8019fe:	eb 05                	jmp    801a05 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a00:	e8 f8 f1 ff ff       	call   800bfd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a05:	e8 74 f1 ff ff       	call   800b7e <sys_cgetc>
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	74 f2                	je     801a00 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 16                	js     801a28 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a12:	83 f8 04             	cmp    $0x4,%eax
  801a15:	74 0c                	je     801a23 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1a:	88 02                	mov    %al,(%edx)
	return 1;
  801a1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a21:	eb 05                	jmp    801a28 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a30:	8b 45 08             	mov    0x8(%ebp),%eax
  801a33:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a36:	6a 01                	push   $0x1
  801a38:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a3b:	50                   	push   %eax
  801a3c:	e8 1f f1 ff ff       	call   800b60 <sys_cputs>
}
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <getchar>:

int
getchar(void)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a4c:	6a 01                	push   $0x1
  801a4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a51:	50                   	push   %eax
  801a52:	6a 00                	push   $0x0
  801a54:	e8 90 f6 ff ff       	call   8010e9 <read>
	if (r < 0)
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 0f                	js     801a6f <getchar+0x29>
		return r;
	if (r < 1)
  801a60:	85 c0                	test   %eax,%eax
  801a62:	7e 06                	jle    801a6a <getchar+0x24>
		return -E_EOF;
	return c;
  801a64:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a68:	eb 05                	jmp    801a6f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a6a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7a:	50                   	push   %eax
  801a7b:	ff 75 08             	pushl  0x8(%ebp)
  801a7e:	e8 00 f4 ff ff       	call   800e83 <fd_lookup>
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	85 c0                	test   %eax,%eax
  801a88:	78 11                	js     801a9b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a93:	39 10                	cmp    %edx,(%eax)
  801a95:	0f 94 c0             	sete   %al
  801a98:	0f b6 c0             	movzbl %al,%eax
}
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <opencons>:

int
opencons(void)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa6:	50                   	push   %eax
  801aa7:	e8 88 f3 ff ff       	call   800e34 <fd_alloc>
  801aac:	83 c4 10             	add    $0x10,%esp
		return r;
  801aaf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 3e                	js     801af3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab5:	83 ec 04             	sub    $0x4,%esp
  801ab8:	68 07 04 00 00       	push   $0x407
  801abd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac0:	6a 00                	push   $0x0
  801ac2:	e8 55 f1 ff ff       	call   800c1c <sys_page_alloc>
  801ac7:	83 c4 10             	add    $0x10,%esp
		return r;
  801aca:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 23                	js     801af3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ad0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ade:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ae5:	83 ec 0c             	sub    $0xc,%esp
  801ae8:	50                   	push   %eax
  801ae9:	e8 1f f3 ff ff       	call   800e0d <fd2num>
  801aee:	89 c2                	mov    %eax,%edx
  801af0:	83 c4 10             	add    $0x10,%esp
}
  801af3:	89 d0                	mov    %edx,%eax
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
  801afc:	8b 75 08             	mov    0x8(%ebp),%esi
  801aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801b05:	85 c0                	test   %eax,%eax
  801b07:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b0c:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	50                   	push   %eax
  801b13:	e8 b4 f2 ff ff       	call   800dcc <sys_ipc_recv>
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	79 16                	jns    801b35 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801b1f:	85 f6                	test   %esi,%esi
  801b21:	74 06                	je     801b29 <ipc_recv+0x32>
            *from_env_store = 0;
  801b23:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801b29:	85 db                	test   %ebx,%ebx
  801b2b:	74 2c                	je     801b59 <ipc_recv+0x62>
            *perm_store = 0;
  801b2d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b33:	eb 24                	jmp    801b59 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801b35:	85 f6                	test   %esi,%esi
  801b37:	74 0a                	je     801b43 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801b39:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b3e:	8b 40 74             	mov    0x74(%eax),%eax
  801b41:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801b43:	85 db                	test   %ebx,%ebx
  801b45:	74 0a                	je     801b51 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801b47:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b4c:	8b 40 78             	mov    0x78(%eax),%eax
  801b4f:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801b51:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b56:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801b59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5c:	5b                   	pop    %ebx
  801b5d:	5e                   	pop    %esi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	57                   	push   %edi
  801b64:	56                   	push   %esi
  801b65:	53                   	push   %ebx
  801b66:	83 ec 0c             	sub    $0xc,%esp
  801b69:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b6f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b72:	85 c0                	test   %eax,%eax
  801b74:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b79:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b7c:	eb 1c                	jmp    801b9a <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801b7e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b81:	74 12                	je     801b95 <ipc_send+0x35>
  801b83:	50                   	push   %eax
  801b84:	68 ba 23 80 00       	push   $0x8023ba
  801b89:	6a 3a                	push   $0x3a
  801b8b:	68 d0 23 80 00       	push   $0x8023d0
  801b90:	e8 a7 e5 ff ff       	call   80013c <_panic>
		sys_yield();
  801b95:	e8 63 f0 ff ff       	call   800bfd <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b9a:	ff 75 14             	pushl  0x14(%ebp)
  801b9d:	53                   	push   %ebx
  801b9e:	56                   	push   %esi
  801b9f:	57                   	push   %edi
  801ba0:	e8 04 f2 ff ff       	call   800da9 <sys_ipc_try_send>
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	78 d2                	js     801b7e <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801bac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801baf:	5b                   	pop    %ebx
  801bb0:	5e                   	pop    %esi
  801bb1:	5f                   	pop    %edi
  801bb2:	5d                   	pop    %ebp
  801bb3:	c3                   	ret    

00801bb4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bba:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bbf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bc2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bc8:	8b 52 50             	mov    0x50(%edx),%edx
  801bcb:	39 ca                	cmp    %ecx,%edx
  801bcd:	75 0d                	jne    801bdc <ipc_find_env+0x28>
			return envs[i].env_id;
  801bcf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bd2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bd7:	8b 40 48             	mov    0x48(%eax),%eax
  801bda:	eb 0f                	jmp    801beb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bdc:	83 c0 01             	add    $0x1,%eax
  801bdf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801be4:	75 d9                	jne    801bbf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801be6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bf3:	89 d0                	mov    %edx,%eax
  801bf5:	c1 e8 16             	shr    $0x16,%eax
  801bf8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c04:	f6 c1 01             	test   $0x1,%cl
  801c07:	74 1d                	je     801c26 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c09:	c1 ea 0c             	shr    $0xc,%edx
  801c0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c13:	f6 c2 01             	test   $0x1,%dl
  801c16:	74 0e                	je     801c26 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c18:	c1 ea 0c             	shr    $0xc,%edx
  801c1b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c22:	ef 
  801c23:	0f b7 c0             	movzwl %ax,%eax
}
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	66 90                	xchg   %ax,%ax
  801c2a:	66 90                	xchg   %ax,%ax
  801c2c:	66 90                	xchg   %ax,%ax
  801c2e:	66 90                	xchg   %ax,%ax

00801c30 <__udivdi3>:
  801c30:	55                   	push   %ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	83 ec 1c             	sub    $0x1c,%esp
  801c37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c47:	85 f6                	test   %esi,%esi
  801c49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c4d:	89 ca                	mov    %ecx,%edx
  801c4f:	89 f8                	mov    %edi,%eax
  801c51:	75 3d                	jne    801c90 <__udivdi3+0x60>
  801c53:	39 cf                	cmp    %ecx,%edi
  801c55:	0f 87 c5 00 00 00    	ja     801d20 <__udivdi3+0xf0>
  801c5b:	85 ff                	test   %edi,%edi
  801c5d:	89 fd                	mov    %edi,%ebp
  801c5f:	75 0b                	jne    801c6c <__udivdi3+0x3c>
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	31 d2                	xor    %edx,%edx
  801c68:	f7 f7                	div    %edi
  801c6a:	89 c5                	mov    %eax,%ebp
  801c6c:	89 c8                	mov    %ecx,%eax
  801c6e:	31 d2                	xor    %edx,%edx
  801c70:	f7 f5                	div    %ebp
  801c72:	89 c1                	mov    %eax,%ecx
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	89 cf                	mov    %ecx,%edi
  801c78:	f7 f5                	div    %ebp
  801c7a:	89 c3                	mov    %eax,%ebx
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	89 fa                	mov    %edi,%edx
  801c80:	83 c4 1c             	add    $0x1c,%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    
  801c88:	90                   	nop
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	39 ce                	cmp    %ecx,%esi
  801c92:	77 74                	ja     801d08 <__udivdi3+0xd8>
  801c94:	0f bd fe             	bsr    %esi,%edi
  801c97:	83 f7 1f             	xor    $0x1f,%edi
  801c9a:	0f 84 98 00 00 00    	je     801d38 <__udivdi3+0x108>
  801ca0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	89 c5                	mov    %eax,%ebp
  801ca9:	29 fb                	sub    %edi,%ebx
  801cab:	d3 e6                	shl    %cl,%esi
  801cad:	89 d9                	mov    %ebx,%ecx
  801caf:	d3 ed                	shr    %cl,%ebp
  801cb1:	89 f9                	mov    %edi,%ecx
  801cb3:	d3 e0                	shl    %cl,%eax
  801cb5:	09 ee                	or     %ebp,%esi
  801cb7:	89 d9                	mov    %ebx,%ecx
  801cb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cbd:	89 d5                	mov    %edx,%ebp
  801cbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cc3:	d3 ed                	shr    %cl,%ebp
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e2                	shl    %cl,%edx
  801cc9:	89 d9                	mov    %ebx,%ecx
  801ccb:	d3 e8                	shr    %cl,%eax
  801ccd:	09 c2                	or     %eax,%edx
  801ccf:	89 d0                	mov    %edx,%eax
  801cd1:	89 ea                	mov    %ebp,%edx
  801cd3:	f7 f6                	div    %esi
  801cd5:	89 d5                	mov    %edx,%ebp
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	f7 64 24 0c          	mull   0xc(%esp)
  801cdd:	39 d5                	cmp    %edx,%ebp
  801cdf:	72 10                	jb     801cf1 <__udivdi3+0xc1>
  801ce1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	d3 e6                	shl    %cl,%esi
  801ce9:	39 c6                	cmp    %eax,%esi
  801ceb:	73 07                	jae    801cf4 <__udivdi3+0xc4>
  801ced:	39 d5                	cmp    %edx,%ebp
  801cef:	75 03                	jne    801cf4 <__udivdi3+0xc4>
  801cf1:	83 eb 01             	sub    $0x1,%ebx
  801cf4:	31 ff                	xor    %edi,%edi
  801cf6:	89 d8                	mov    %ebx,%eax
  801cf8:	89 fa                	mov    %edi,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	31 ff                	xor    %edi,%edi
  801d0a:	31 db                	xor    %ebx,%ebx
  801d0c:	89 d8                	mov    %ebx,%eax
  801d0e:	89 fa                	mov    %edi,%edx
  801d10:	83 c4 1c             	add    $0x1c,%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5f                   	pop    %edi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    
  801d18:	90                   	nop
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	f7 f7                	div    %edi
  801d24:	31 ff                	xor    %edi,%edi
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	89 fa                	mov    %edi,%edx
  801d2c:	83 c4 1c             	add    $0x1c,%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5f                   	pop    %edi
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    
  801d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d38:	39 ce                	cmp    %ecx,%esi
  801d3a:	72 0c                	jb     801d48 <__udivdi3+0x118>
  801d3c:	31 db                	xor    %ebx,%ebx
  801d3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d42:	0f 87 34 ff ff ff    	ja     801c7c <__udivdi3+0x4c>
  801d48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d4d:	e9 2a ff ff ff       	jmp    801c7c <__udivdi3+0x4c>
  801d52:	66 90                	xchg   %ax,%ax
  801d54:	66 90                	xchg   %ax,%ax
  801d56:	66 90                	xchg   %ax,%ax
  801d58:	66 90                	xchg   %ax,%ax
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	66 90                	xchg   %ax,%ax
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <__umoddi3>:
  801d60:	55                   	push   %ebp
  801d61:	57                   	push   %edi
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	83 ec 1c             	sub    $0x1c,%esp
  801d67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d77:	85 d2                	test   %edx,%edx
  801d79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d81:	89 f3                	mov    %esi,%ebx
  801d83:	89 3c 24             	mov    %edi,(%esp)
  801d86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d8a:	75 1c                	jne    801da8 <__umoddi3+0x48>
  801d8c:	39 f7                	cmp    %esi,%edi
  801d8e:	76 50                	jbe    801de0 <__umoddi3+0x80>
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	f7 f7                	div    %edi
  801d96:	89 d0                	mov    %edx,%eax
  801d98:	31 d2                	xor    %edx,%edx
  801d9a:	83 c4 1c             	add    $0x1c,%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    
  801da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801da8:	39 f2                	cmp    %esi,%edx
  801daa:	89 d0                	mov    %edx,%eax
  801dac:	77 52                	ja     801e00 <__umoddi3+0xa0>
  801dae:	0f bd ea             	bsr    %edx,%ebp
  801db1:	83 f5 1f             	xor    $0x1f,%ebp
  801db4:	75 5a                	jne    801e10 <__umoddi3+0xb0>
  801db6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dba:	0f 82 e0 00 00 00    	jb     801ea0 <__umoddi3+0x140>
  801dc0:	39 0c 24             	cmp    %ecx,(%esp)
  801dc3:	0f 86 d7 00 00 00    	jbe    801ea0 <__umoddi3+0x140>
  801dc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dd1:	83 c4 1c             	add    $0x1c,%esp
  801dd4:	5b                   	pop    %ebx
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    
  801dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de0:	85 ff                	test   %edi,%edi
  801de2:	89 fd                	mov    %edi,%ebp
  801de4:	75 0b                	jne    801df1 <__umoddi3+0x91>
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f7                	div    %edi
  801def:	89 c5                	mov    %eax,%ebp
  801df1:	89 f0                	mov    %esi,%eax
  801df3:	31 d2                	xor    %edx,%edx
  801df5:	f7 f5                	div    %ebp
  801df7:	89 c8                	mov    %ecx,%eax
  801df9:	f7 f5                	div    %ebp
  801dfb:	89 d0                	mov    %edx,%eax
  801dfd:	eb 99                	jmp    801d98 <__umoddi3+0x38>
  801dff:	90                   	nop
  801e00:	89 c8                	mov    %ecx,%eax
  801e02:	89 f2                	mov    %esi,%edx
  801e04:	83 c4 1c             	add    $0x1c,%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5f                   	pop    %edi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    
  801e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e10:	8b 34 24             	mov    (%esp),%esi
  801e13:	bf 20 00 00 00       	mov    $0x20,%edi
  801e18:	89 e9                	mov    %ebp,%ecx
  801e1a:	29 ef                	sub    %ebp,%edi
  801e1c:	d3 e0                	shl    %cl,%eax
  801e1e:	89 f9                	mov    %edi,%ecx
  801e20:	89 f2                	mov    %esi,%edx
  801e22:	d3 ea                	shr    %cl,%edx
  801e24:	89 e9                	mov    %ebp,%ecx
  801e26:	09 c2                	or     %eax,%edx
  801e28:	89 d8                	mov    %ebx,%eax
  801e2a:	89 14 24             	mov    %edx,(%esp)
  801e2d:	89 f2                	mov    %esi,%edx
  801e2f:	d3 e2                	shl    %cl,%edx
  801e31:	89 f9                	mov    %edi,%ecx
  801e33:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e3b:	d3 e8                	shr    %cl,%eax
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	89 c6                	mov    %eax,%esi
  801e41:	d3 e3                	shl    %cl,%ebx
  801e43:	89 f9                	mov    %edi,%ecx
  801e45:	89 d0                	mov    %edx,%eax
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	09 d8                	or     %ebx,%eax
  801e4d:	89 d3                	mov    %edx,%ebx
  801e4f:	89 f2                	mov    %esi,%edx
  801e51:	f7 34 24             	divl   (%esp)
  801e54:	89 d6                	mov    %edx,%esi
  801e56:	d3 e3                	shl    %cl,%ebx
  801e58:	f7 64 24 04          	mull   0x4(%esp)
  801e5c:	39 d6                	cmp    %edx,%esi
  801e5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e62:	89 d1                	mov    %edx,%ecx
  801e64:	89 c3                	mov    %eax,%ebx
  801e66:	72 08                	jb     801e70 <__umoddi3+0x110>
  801e68:	75 11                	jne    801e7b <__umoddi3+0x11b>
  801e6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e6e:	73 0b                	jae    801e7b <__umoddi3+0x11b>
  801e70:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e74:	1b 14 24             	sbb    (%esp),%edx
  801e77:	89 d1                	mov    %edx,%ecx
  801e79:	89 c3                	mov    %eax,%ebx
  801e7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e7f:	29 da                	sub    %ebx,%edx
  801e81:	19 ce                	sbb    %ecx,%esi
  801e83:	89 f9                	mov    %edi,%ecx
  801e85:	89 f0                	mov    %esi,%eax
  801e87:	d3 e0                	shl    %cl,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	d3 ea                	shr    %cl,%edx
  801e8d:	89 e9                	mov    %ebp,%ecx
  801e8f:	d3 ee                	shr    %cl,%esi
  801e91:	09 d0                	or     %edx,%eax
  801e93:	89 f2                	mov    %esi,%edx
  801e95:	83 c4 1c             	add    $0x1c,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    
  801e9d:	8d 76 00             	lea    0x0(%esi),%esi
  801ea0:	29 f9                	sub    %edi,%ecx
  801ea2:	19 d6                	sbb    %edx,%esi
  801ea4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801eac:	e9 18 ff ff ff       	jmp    801dc9 <__umoddi3+0x69>
