
obj/user/yield.debug：     文件格式 elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 08 40 80 00       	mov    0x804008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 20 23 80 00       	push   $0x802320
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 1b 0b 00 00       	call   800b75 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 08 40 80 00       	mov    0x804008,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 40 23 80 00       	push   $0x802340
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 08 40 80 00       	mov    0x804008,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 6c 23 80 00       	push   $0x80236c
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 ac 0a 00 00       	call   800b56 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
        binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 a4 0e 00 00       	call   800f8f <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 20 0a 00 00       	call   800b15 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 ae 09 00 00       	call   800ad8 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 1a 01 00 00       	call   80028a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 53 09 00 00       	call   800ad8 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c8:	39 d3                	cmp    %edx,%ebx
  8001ca:	72 05                	jb     8001d1 <printnum+0x30>
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 45                	ja     800216 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 9b 1e 00 00       	call   802090 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 18                	jmp    800220 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb 03                	jmp    800219 <printnum+0x78>
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f e8                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 88 1f 00 00       	call   8021c0 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 95 23 80 00 	movsbl 0x802395(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800256:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	3b 50 04             	cmp    0x4(%eax),%edx
  80025f:	73 0a                	jae    80026b <sprintputch+0x1b>
		*b->buf++ = ch;
  800261:	8d 4a 01             	lea    0x1(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	88 02                	mov    %al,(%edx)
}
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	ff 75 0c             	pushl  0xc(%ebp)
  80027d:	ff 75 08             	pushl  0x8(%ebp)
  800280:	e8 05 00 00 00       	call   80028a <vprintfmt>
	va_end(ap);
}
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 2c             	sub    $0x2c,%esp
  800293:	8b 75 08             	mov    0x8(%ebp),%esi
  800296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800299:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029c:	eb 12                	jmp    8002b0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	0f 84 42 04 00 00    	je     8006e8 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	53                   	push   %ebx
  8002aa:	50                   	push   %eax
  8002ab:	ff d6                	call   *%esi
  8002ad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b0:	83 c7 01             	add    $0x1,%edi
  8002b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b7:	83 f8 25             	cmp    $0x25,%eax
  8002ba:	75 e2                	jne    80029e <vprintfmt+0x14>
  8002bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002da:	eb 07                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8d 47 01             	lea    0x1(%edi),%eax
  8002e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e9:	0f b6 07             	movzbl (%edi),%eax
  8002ec:	0f b6 d0             	movzbl %al,%edx
  8002ef:	83 e8 23             	sub    $0x23,%eax
  8002f2:	3c 55                	cmp    $0x55,%al
  8002f4:	0f 87 d3 03 00 00    	ja     8006cd <vprintfmt+0x443>
  8002fa:	0f b6 c0             	movzbl %al,%eax
  8002fd:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800307:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030b:	eb d6                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800310:	b8 00 00 00 00       	mov    $0x0,%eax
  800315:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800318:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80031f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800322:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800325:	83 f9 09             	cmp    $0x9,%ecx
  800328:	77 3f                	ja     800369 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80032d:	eb e9                	jmp    800318 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8b 00                	mov    (%eax),%eax
  800334:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8d 40 04             	lea    0x4(%eax),%eax
  80033d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800343:	eb 2a                	jmp    80036f <vprintfmt+0xe5>
  800345:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800348:	85 c0                	test   %eax,%eax
  80034a:	ba 00 00 00 00       	mov    $0x0,%edx
  80034f:	0f 49 d0             	cmovns %eax,%edx
  800352:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800358:	eb 89                	jmp    8002e3 <vprintfmt+0x59>
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800364:	e9 7a ff ff ff       	jmp    8002e3 <vprintfmt+0x59>
  800369:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80036c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80036f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800373:	0f 89 6a ff ff ff    	jns    8002e3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800379:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800386:	e9 58 ff ff ff       	jmp    8002e3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800391:	e9 4d ff ff ff       	jmp    8002e3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800396:	8b 45 14             	mov    0x14(%ebp),%eax
  800399:	8d 78 04             	lea    0x4(%eax),%edi
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	53                   	push   %ebx
  8003a0:	ff 30                	pushl  (%eax)
  8003a2:	ff d6                	call   *%esi
			break;
  8003a4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ad:	e9 fe fe ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 78 04             	lea    0x4(%eax),%edi
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	99                   	cltd   
  8003bb:	31 d0                	xor    %edx,%eax
  8003bd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bf:	83 f8 0f             	cmp    $0xf,%eax
  8003c2:	7f 0b                	jg     8003cf <vprintfmt+0x145>
  8003c4:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	75 1b                	jne    8003ea <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003cf:	50                   	push   %eax
  8003d0:	68 ad 23 80 00       	push   $0x8023ad
  8003d5:	53                   	push   %ebx
  8003d6:	56                   	push   %esi
  8003d7:	e8 91 fe ff ff       	call   80026d <printfmt>
  8003dc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003df:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e5:	e9 c6 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ea:	52                   	push   %edx
  8003eb:	68 75 27 80 00       	push   $0x802775
  8003f0:	53                   	push   %ebx
  8003f1:	56                   	push   %esi
  8003f2:	e8 76 fe ff ff       	call   80026d <printfmt>
  8003f7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fa:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800400:	e9 ab fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	83 c0 04             	add    $0x4,%eax
  80040b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800413:	85 ff                	test   %edi,%edi
  800415:	b8 a6 23 80 00       	mov    $0x8023a6,%eax
  80041a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800421:	0f 8e 94 00 00 00    	jle    8004bb <vprintfmt+0x231>
  800427:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042b:	0f 84 98 00 00 00    	je     8004c9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	ff 75 d0             	pushl  -0x30(%ebp)
  800437:	57                   	push   %edi
  800438:	e8 33 03 00 00       	call   800770 <strnlen>
  80043d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800440:	29 c1                	sub    %eax,%ecx
  800442:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800445:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800448:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800452:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800454:	eb 0f                	jmp    800465 <vprintfmt+0x1db>
					putch(padc, putdat);
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	53                   	push   %ebx
  80045a:	ff 75 e0             	pushl  -0x20(%ebp)
  80045d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	83 ef 01             	sub    $0x1,%edi
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	85 ff                	test   %edi,%edi
  800467:	7f ed                	jg     800456 <vprintfmt+0x1cc>
  800469:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80046f:	85 c9                	test   %ecx,%ecx
  800471:	b8 00 00 00 00       	mov    $0x0,%eax
  800476:	0f 49 c1             	cmovns %ecx,%eax
  800479:	29 c1                	sub    %eax,%ecx
  80047b:	89 75 08             	mov    %esi,0x8(%ebp)
  80047e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800481:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800484:	89 cb                	mov    %ecx,%ebx
  800486:	eb 4d                	jmp    8004d5 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800488:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048c:	74 1b                	je     8004a9 <vprintfmt+0x21f>
  80048e:	0f be c0             	movsbl %al,%eax
  800491:	83 e8 20             	sub    $0x20,%eax
  800494:	83 f8 5e             	cmp    $0x5e,%eax
  800497:	76 10                	jbe    8004a9 <vprintfmt+0x21f>
					putch('?', putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	ff 75 0c             	pushl  0xc(%ebp)
  80049f:	6a 3f                	push   $0x3f
  8004a1:	ff 55 08             	call   *0x8(%ebp)
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	eb 0d                	jmp    8004b6 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	ff 75 0c             	pushl  0xc(%ebp)
  8004af:	52                   	push   %edx
  8004b0:	ff 55 08             	call   *0x8(%ebp)
  8004b3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b6:	83 eb 01             	sub    $0x1,%ebx
  8004b9:	eb 1a                	jmp    8004d5 <vprintfmt+0x24b>
  8004bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c7:	eb 0c                	jmp    8004d5 <vprintfmt+0x24b>
  8004c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d5:	83 c7 01             	add    $0x1,%edi
  8004d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004dc:	0f be d0             	movsbl %al,%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	74 23                	je     800506 <vprintfmt+0x27c>
  8004e3:	85 f6                	test   %esi,%esi
  8004e5:	78 a1                	js     800488 <vprintfmt+0x1fe>
  8004e7:	83 ee 01             	sub    $0x1,%esi
  8004ea:	79 9c                	jns    800488 <vprintfmt+0x1fe>
  8004ec:	89 df                	mov    %ebx,%edi
  8004ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f4:	eb 18                	jmp    80050e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	53                   	push   %ebx
  8004fa:	6a 20                	push   $0x20
  8004fc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004fe:	83 ef 01             	sub    $0x1,%edi
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	eb 08                	jmp    80050e <vprintfmt+0x284>
  800506:	89 df                	mov    %ebx,%edi
  800508:	8b 75 08             	mov    0x8(%ebp),%esi
  80050b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050e:	85 ff                	test   %edi,%edi
  800510:	7f e4                	jg     8004f6 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800512:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800515:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051b:	e9 90 fd ff ff       	jmp    8002b0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800520:	83 f9 01             	cmp    $0x1,%ecx
  800523:	7e 19                	jle    80053e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8b 50 04             	mov    0x4(%eax),%edx
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800530:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 40 08             	lea    0x8(%eax),%eax
  800539:	89 45 14             	mov    %eax,0x14(%ebp)
  80053c:	eb 38                	jmp    800576 <vprintfmt+0x2ec>
	else if (lflag)
  80053e:	85 c9                	test   %ecx,%ecx
  800540:	74 1b                	je     80055d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8b 00                	mov    (%eax),%eax
  800547:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054a:	89 c1                	mov    %eax,%ecx
  80054c:	c1 f9 1f             	sar    $0x1f,%ecx
  80054f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 40 04             	lea    0x4(%eax),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	eb 19                	jmp    800576 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800576:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800579:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80057c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800581:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800585:	0f 89 0e 01 00 00    	jns    800699 <vprintfmt+0x40f>
				putch('-', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	53                   	push   %ebx
  80058f:	6a 2d                	push   $0x2d
  800591:	ff d6                	call   *%esi
				num = -(long long) num;
  800593:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800596:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800599:	f7 da                	neg    %edx
  80059b:	83 d1 00             	adc    $0x0,%ecx
  80059e:	f7 d9                	neg    %ecx
  8005a0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a8:	e9 ec 00 00 00       	jmp    800699 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ad:	83 f9 01             	cmp    $0x1,%ecx
  8005b0:	7e 18                	jle    8005ca <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ba:	8d 40 08             	lea    0x8(%eax),%eax
  8005bd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c5:	e9 cf 00 00 00       	jmp    800699 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005ca:	85 c9                	test   %ecx,%ecx
  8005cc:	74 1a                	je     8005e8 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 10                	mov    (%eax),%edx
  8005d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d8:	8d 40 04             	lea    0x4(%eax),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e3:	e9 b1 00 00 00       	jmp    800699 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fd:	e9 97 00 00 00       	jmp    800699 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 58                	push   $0x58
  800608:	ff d6                	call   *%esi
			putch('X', putdat);
  80060a:	83 c4 08             	add    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 58                	push   $0x58
  800610:	ff d6                	call   *%esi
			putch('X', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 58                	push   $0x58
  800618:	ff d6                	call   *%esi
			break;
  80061a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800620:	e9 8b fc ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 30                	push   $0x30
  80062b:	ff d6                	call   *%esi
			putch('x', putdat);
  80062d:	83 c4 08             	add    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 78                	push   $0x78
  800633:	ff d6                	call   *%esi
			num = (unsigned long long)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80063f:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800648:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064d:	eb 4a                	jmp    800699 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064f:	83 f9 01             	cmp    $0x1,%ecx
  800652:	7e 15                	jle    800669 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 10                	mov    (%eax),%edx
  800659:	8b 48 04             	mov    0x4(%eax),%ecx
  80065c:	8d 40 08             	lea    0x8(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800662:	b8 10 00 00 00       	mov    $0x10,%eax
  800667:	eb 30                	jmp    800699 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800669:	85 c9                	test   %ecx,%ecx
  80066b:	74 17                	je     800684 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 10                	mov    (%eax),%edx
  800672:	b9 00 00 00 00       	mov    $0x0,%ecx
  800677:	8d 40 04             	lea    0x4(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80067d:	b8 10 00 00 00       	mov    $0x10,%eax
  800682:	eb 15                	jmp    800699 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800694:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800699:	83 ec 0c             	sub    $0xc,%esp
  80069c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a0:	57                   	push   %edi
  8006a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a4:	50                   	push   %eax
  8006a5:	51                   	push   %ecx
  8006a6:	52                   	push   %edx
  8006a7:	89 da                	mov    %ebx,%edx
  8006a9:	89 f0                	mov    %esi,%eax
  8006ab:	e8 f1 fa ff ff       	call   8001a1 <printnum>
			break;
  8006b0:	83 c4 20             	add    $0x20,%esp
  8006b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b6:	e9 f5 fb ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	52                   	push   %edx
  8006c0:	ff d6                	call   *%esi
			break;
  8006c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c8:	e9 e3 fb ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 25                	push   $0x25
  8006d3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	eb 03                	jmp    8006dd <vprintfmt+0x453>
  8006da:	83 ef 01             	sub    $0x1,%edi
  8006dd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e1:	75 f7                	jne    8006da <vprintfmt+0x450>
  8006e3:	e9 c8 fb ff ff       	jmp    8002b0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006eb:	5b                   	pop    %ebx
  8006ec:	5e                   	pop    %esi
  8006ed:	5f                   	pop    %edi
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	83 ec 18             	sub    $0x18,%esp
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800703:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800706:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070d:	85 c0                	test   %eax,%eax
  80070f:	74 26                	je     800737 <vsnprintf+0x47>
  800711:	85 d2                	test   %edx,%edx
  800713:	7e 22                	jle    800737 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800715:	ff 75 14             	pushl  0x14(%ebp)
  800718:	ff 75 10             	pushl  0x10(%ebp)
  80071b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	68 50 02 80 00       	push   $0x800250
  800724:	e8 61 fb ff ff       	call   80028a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800729:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	eb 05                	jmp    80073c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800737:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800747:	50                   	push   %eax
  800748:	ff 75 10             	pushl  0x10(%ebp)
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	ff 75 08             	pushl  0x8(%ebp)
  800751:	e8 9a ff ff ff       	call   8006f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
  800763:	eb 03                	jmp    800768 <strlen+0x10>
		n++;
  800765:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800768:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076c:	75 f7                	jne    800765 <strlen+0xd>
		n++;
	return n;
}
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800776:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800779:	ba 00 00 00 00       	mov    $0x0,%edx
  80077e:	eb 03                	jmp    800783 <strnlen+0x13>
		n++;
  800780:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800783:	39 c2                	cmp    %eax,%edx
  800785:	74 08                	je     80078f <strnlen+0x1f>
  800787:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078b:	75 f3                	jne    800780 <strnlen+0x10>
  80078d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	53                   	push   %ebx
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079b:	89 c2                	mov    %eax,%edx
  80079d:	83 c2 01             	add    $0x1,%edx
  8007a0:	83 c1 01             	add    $0x1,%ecx
  8007a3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007aa:	84 db                	test   %bl,%bl
  8007ac:	75 ef                	jne    80079d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ae:	5b                   	pop    %ebx
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b8:	53                   	push   %ebx
  8007b9:	e8 9a ff ff ff       	call   800758 <strlen>
  8007be:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	01 d8                	add    %ebx,%eax
  8007c6:	50                   	push   %eax
  8007c7:	e8 c5 ff ff ff       	call   800791 <strcpy>
	return dst;
}
  8007cc:	89 d8                	mov    %ebx,%eax
  8007ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007de:	89 f3                	mov    %esi,%ebx
  8007e0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e3:	89 f2                	mov    %esi,%edx
  8007e5:	eb 0f                	jmp    8007f6 <strncpy+0x23>
		*dst++ = *src;
  8007e7:	83 c2 01             	add    $0x1,%edx
  8007ea:	0f b6 01             	movzbl (%ecx),%eax
  8007ed:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f0:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f6:	39 da                	cmp    %ebx,%edx
  8007f8:	75 ed                	jne    8007e7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fa:	89 f0                	mov    %esi,%eax
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080b:	8b 55 10             	mov    0x10(%ebp),%edx
  80080e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800810:	85 d2                	test   %edx,%edx
  800812:	74 21                	je     800835 <strlcpy+0x35>
  800814:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800818:	89 f2                	mov    %esi,%edx
  80081a:	eb 09                	jmp    800825 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081c:	83 c2 01             	add    $0x1,%edx
  80081f:	83 c1 01             	add    $0x1,%ecx
  800822:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800825:	39 c2                	cmp    %eax,%edx
  800827:	74 09                	je     800832 <strlcpy+0x32>
  800829:	0f b6 19             	movzbl (%ecx),%ebx
  80082c:	84 db                	test   %bl,%bl
  80082e:	75 ec                	jne    80081c <strlcpy+0x1c>
  800830:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800832:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800835:	29 f0                	sub    %esi,%eax
}
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800844:	eb 06                	jmp    80084c <strcmp+0x11>
		p++, q++;
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084c:	0f b6 01             	movzbl (%ecx),%eax
  80084f:	84 c0                	test   %al,%al
  800851:	74 04                	je     800857 <strcmp+0x1c>
  800853:	3a 02                	cmp    (%edx),%al
  800855:	74 ef                	je     800846 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800857:	0f b6 c0             	movzbl %al,%eax
  80085a:	0f b6 12             	movzbl (%edx),%edx
  80085d:	29 d0                	sub    %edx,%eax
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086b:	89 c3                	mov    %eax,%ebx
  80086d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800870:	eb 06                	jmp    800878 <strncmp+0x17>
		n--, p++, q++;
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800878:	39 d8                	cmp    %ebx,%eax
  80087a:	74 15                	je     800891 <strncmp+0x30>
  80087c:	0f b6 08             	movzbl (%eax),%ecx
  80087f:	84 c9                	test   %cl,%cl
  800881:	74 04                	je     800887 <strncmp+0x26>
  800883:	3a 0a                	cmp    (%edx),%cl
  800885:	74 eb                	je     800872 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 00             	movzbl (%eax),%eax
  80088a:	0f b6 12             	movzbl (%edx),%edx
  80088d:	29 d0                	sub    %edx,%eax
  80088f:	eb 05                	jmp    800896 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800896:	5b                   	pop    %ebx
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a3:	eb 07                	jmp    8008ac <strchr+0x13>
		if (*s == c)
  8008a5:	38 ca                	cmp    %cl,%dl
  8008a7:	74 0f                	je     8008b8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	0f b6 10             	movzbl (%eax),%edx
  8008af:	84 d2                	test   %dl,%dl
  8008b1:	75 f2                	jne    8008a5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c4:	eb 03                	jmp    8008c9 <strfind+0xf>
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 04                	je     8008d4 <strfind+0x1a>
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	75 f2                	jne    8008c6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e2:	85 c9                	test   %ecx,%ecx
  8008e4:	74 36                	je     80091c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ec:	75 28                	jne    800916 <memset+0x40>
  8008ee:	f6 c1 03             	test   $0x3,%cl
  8008f1:	75 23                	jne    800916 <memset+0x40>
		c &= 0xFF;
  8008f3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f7:	89 d3                	mov    %edx,%ebx
  8008f9:	c1 e3 08             	shl    $0x8,%ebx
  8008fc:	89 d6                	mov    %edx,%esi
  8008fe:	c1 e6 18             	shl    $0x18,%esi
  800901:	89 d0                	mov    %edx,%eax
  800903:	c1 e0 10             	shl    $0x10,%eax
  800906:	09 f0                	or     %esi,%eax
  800908:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090a:	89 d8                	mov    %ebx,%eax
  80090c:	09 d0                	or     %edx,%eax
  80090e:	c1 e9 02             	shr    $0x2,%ecx
  800911:	fc                   	cld    
  800912:	f3 ab                	rep stos %eax,%es:(%edi)
  800914:	eb 06                	jmp    80091c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	fc                   	cld    
  80091a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091c:	89 f8                	mov    %edi,%eax
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5f                   	pop    %edi
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	57                   	push   %edi
  800927:	56                   	push   %esi
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800931:	39 c6                	cmp    %eax,%esi
  800933:	73 35                	jae    80096a <memmove+0x47>
  800935:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800938:	39 d0                	cmp    %edx,%eax
  80093a:	73 2e                	jae    80096a <memmove+0x47>
		s += n;
		d += n;
  80093c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093f:	89 d6                	mov    %edx,%esi
  800941:	09 fe                	or     %edi,%esi
  800943:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800949:	75 13                	jne    80095e <memmove+0x3b>
  80094b:	f6 c1 03             	test   $0x3,%cl
  80094e:	75 0e                	jne    80095e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800950:	83 ef 04             	sub    $0x4,%edi
  800953:	8d 72 fc             	lea    -0x4(%edx),%esi
  800956:	c1 e9 02             	shr    $0x2,%ecx
  800959:	fd                   	std    
  80095a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095c:	eb 09                	jmp    800967 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095e:	83 ef 01             	sub    $0x1,%edi
  800961:	8d 72 ff             	lea    -0x1(%edx),%esi
  800964:	fd                   	std    
  800965:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800967:	fc                   	cld    
  800968:	eb 1d                	jmp    800987 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	89 f2                	mov    %esi,%edx
  80096c:	09 c2                	or     %eax,%edx
  80096e:	f6 c2 03             	test   $0x3,%dl
  800971:	75 0f                	jne    800982 <memmove+0x5f>
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 0a                	jne    800982 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800978:	c1 e9 02             	shr    $0x2,%ecx
  80097b:	89 c7                	mov    %eax,%edi
  80097d:	fc                   	cld    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb 05                	jmp    800987 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800987:	5e                   	pop    %esi
  800988:	5f                   	pop    %edi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098e:	ff 75 10             	pushl  0x10(%ebp)
  800991:	ff 75 0c             	pushl  0xc(%ebp)
  800994:	ff 75 08             	pushl  0x8(%ebp)
  800997:	e8 87 ff ff ff       	call   800923 <memmove>
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 c6                	mov    %eax,%esi
  8009ab:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	eb 1a                	jmp    8009ca <memcmp+0x2c>
		if (*s1 != *s2)
  8009b0:	0f b6 08             	movzbl (%eax),%ecx
  8009b3:	0f b6 1a             	movzbl (%edx),%ebx
  8009b6:	38 d9                	cmp    %bl,%cl
  8009b8:	74 0a                	je     8009c4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ba:	0f b6 c1             	movzbl %cl,%eax
  8009bd:	0f b6 db             	movzbl %bl,%ebx
  8009c0:	29 d8                	sub    %ebx,%eax
  8009c2:	eb 0f                	jmp    8009d3 <memcmp+0x35>
		s1++, s2++;
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ca:	39 f0                	cmp    %esi,%eax
  8009cc:	75 e2                	jne    8009b0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009de:	89 c1                	mov    %eax,%ecx
  8009e0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e7:	eb 0a                	jmp    8009f3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e9:	0f b6 10             	movzbl (%eax),%edx
  8009ec:	39 da                	cmp    %ebx,%edx
  8009ee:	74 07                	je     8009f7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	39 c8                	cmp    %ecx,%eax
  8009f5:	72 f2                	jb     8009e9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	57                   	push   %edi
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a06:	eb 03                	jmp    800a0b <strtol+0x11>
		s++;
  800a08:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0b:	0f b6 01             	movzbl (%ecx),%eax
  800a0e:	3c 20                	cmp    $0x20,%al
  800a10:	74 f6                	je     800a08 <strtol+0xe>
  800a12:	3c 09                	cmp    $0x9,%al
  800a14:	74 f2                	je     800a08 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a16:	3c 2b                	cmp    $0x2b,%al
  800a18:	75 0a                	jne    800a24 <strtol+0x2a>
		s++;
  800a1a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a22:	eb 11                	jmp    800a35 <strtol+0x3b>
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a29:	3c 2d                	cmp    $0x2d,%al
  800a2b:	75 08                	jne    800a35 <strtol+0x3b>
		s++, neg = 1;
  800a2d:	83 c1 01             	add    $0x1,%ecx
  800a30:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3b:	75 15                	jne    800a52 <strtol+0x58>
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	75 10                	jne    800a52 <strtol+0x58>
  800a42:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a46:	75 7c                	jne    800ac4 <strtol+0xca>
		s += 2, base = 16;
  800a48:	83 c1 02             	add    $0x2,%ecx
  800a4b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a50:	eb 16                	jmp    800a68 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a52:	85 db                	test   %ebx,%ebx
  800a54:	75 12                	jne    800a68 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a56:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5e:	75 08                	jne    800a68 <strtol+0x6e>
		s++, base = 8;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a70:	0f b6 11             	movzbl (%ecx),%edx
  800a73:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 09             	cmp    $0x9,%bl
  800a7b:	77 08                	ja     800a85 <strtol+0x8b>
			dig = *s - '0';
  800a7d:	0f be d2             	movsbl %dl,%edx
  800a80:	83 ea 30             	sub    $0x30,%edx
  800a83:	eb 22                	jmp    800aa7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a85:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 19             	cmp    $0x19,%bl
  800a8d:	77 08                	ja     800a97 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 57             	sub    $0x57,%edx
  800a95:	eb 10                	jmp    800aa7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a97:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 19             	cmp    $0x19,%bl
  800a9f:	77 16                	ja     800ab7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aaa:	7d 0b                	jge    800ab7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aac:	83 c1 01             	add    $0x1,%ecx
  800aaf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab5:	eb b9                	jmp    800a70 <strtol+0x76>

	if (endptr)
  800ab7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abb:	74 0d                	je     800aca <strtol+0xd0>
		*endptr = (char *) s;
  800abd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac0:	89 0e                	mov    %ecx,(%esi)
  800ac2:	eb 06                	jmp    800aca <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac4:	85 db                	test   %ebx,%ebx
  800ac6:	74 98                	je     800a60 <strtol+0x66>
  800ac8:	eb 9e                	jmp    800a68 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aca:	89 c2                	mov    %eax,%edx
  800acc:	f7 da                	neg    %edx
  800ace:	85 ff                	test   %edi,%edi
  800ad0:	0f 45 c2             	cmovne %edx,%eax
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	89 c6                	mov    %eax,%esi
  800aef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 01 00 00 00       	mov    $0x1,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b23:	b8 03 00 00 00       	mov    $0x3,%eax
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	89 cb                	mov    %ecx,%ebx
  800b2d:	89 cf                	mov    %ecx,%edi
  800b2f:	89 ce                	mov    %ecx,%esi
  800b31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b33:	85 c0                	test   %eax,%eax
  800b35:	7e 17                	jle    800b4e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	50                   	push   %eax
  800b3b:	6a 03                	push   $0x3
  800b3d:	68 9f 26 80 00       	push   $0x80269f
  800b42:	6a 23                	push   $0x23
  800b44:	68 bc 26 80 00       	push   $0x8026bc
  800b49:	e8 c7 13 00 00       	call   801f15 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 02 00 00 00       	mov    $0x2,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_yield>:

void
sys_yield(void)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b85:	89 d1                	mov    %edx,%ecx
  800b87:	89 d3                	mov    %edx,%ebx
  800b89:	89 d7                	mov    %edx,%edi
  800b8b:	89 d6                	mov    %edx,%esi
  800b8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9d:	be 00 00 00 00       	mov    $0x0,%esi
  800ba2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb0:	89 f7                	mov    %esi,%edi
  800bb2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	7e 17                	jle    800bcf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	50                   	push   %eax
  800bbc:	6a 04                	push   $0x4
  800bbe:	68 9f 26 80 00       	push   $0x80269f
  800bc3:	6a 23                	push   $0x23
  800bc5:	68 bc 26 80 00       	push   $0x8026bc
  800bca:	e8 46 13 00 00       	call   801f15 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	b8 05 00 00 00       	mov    $0x5,%eax
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf1:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf6:	85 c0                	test   %eax,%eax
  800bf8:	7e 17                	jle    800c11 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 05                	push   $0x5
  800c00:	68 9f 26 80 00       	push   $0x80269f
  800c05:	6a 23                	push   $0x23
  800c07:	68 bc 26 80 00       	push   $0x8026bc
  800c0c:	e8 04 13 00 00       	call   801f15 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c27:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	89 df                	mov    %ebx,%edi
  800c34:	89 de                	mov    %ebx,%esi
  800c36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	7e 17                	jle    800c53 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 06                	push   $0x6
  800c42:	68 9f 26 80 00       	push   $0x80269f
  800c47:	6a 23                	push   $0x23
  800c49:	68 bc 26 80 00       	push   $0x8026bc
  800c4e:	e8 c2 12 00 00       	call   801f15 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c69:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	89 df                	mov    %ebx,%edi
  800c76:	89 de                	mov    %ebx,%esi
  800c78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7e 17                	jle    800c95 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 08                	push   $0x8
  800c84:	68 9f 26 80 00       	push   $0x80269f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 bc 26 80 00       	push   $0x8026bc
  800c90:	e8 80 12 00 00       	call   801f15 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cab:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 df                	mov    %ebx,%edi
  800cb8:	89 de                	mov    %ebx,%esi
  800cba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 09                	push   $0x9
  800cc6:	68 9f 26 80 00       	push   $0x80269f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 bc 26 80 00       	push   $0x8026bc
  800cd2:	e8 3e 12 00 00       	call   801f15 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ced:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	89 df                	mov    %ebx,%edi
  800cfa:	89 de                	mov    %ebx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 0a                	push   $0xa
  800d08:	68 9f 26 80 00       	push   $0x80269f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 bc 26 80 00       	push   $0x8026bc
  800d14:	e8 fc 11 00 00       	call   801f15 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	be 00 00 00 00       	mov    $0x0,%esi
  800d2c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d52:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 cb                	mov    %ecx,%ebx
  800d5c:	89 cf                	mov    %ecx,%edi
  800d5e:	89 ce                	mov    %ecx,%esi
  800d60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 17                	jle    800d7d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0d                	push   $0xd
  800d6c:	68 9f 26 80 00       	push   $0x80269f
  800d71:	6a 23                	push   $0x23
  800d73:	68 bc 26 80 00       	push   $0x8026bc
  800d78:	e8 98 11 00 00       	call   801f15 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d90:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d95:	89 d1                	mov    %edx,%ecx
  800d97:	89 d3                	mov    %edx,%ebx
  800d99:	89 d7                	mov    %edx,%edi
  800d9b:	89 d6                	mov    %edx,%esi
  800d9d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800daf:	b8 10 00 00 00       	mov    $0x10,%eax
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	89 cb                	mov    %ecx,%ebx
  800db9:	89 cf                	mov    %ecx,%edi
  800dbb:	89 ce                	mov    %ecx,%esi
  800dbd:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	05 00 00 00 30       	add    $0x30000000,%eax
  800dcf:	c1 e8 0c             	shr    $0xc,%eax
}
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dda:	05 00 00 00 30       	add    $0x30000000,%eax
  800ddf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800de4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800df6:	89 c2                	mov    %eax,%edx
  800df8:	c1 ea 16             	shr    $0x16,%edx
  800dfb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e02:	f6 c2 01             	test   $0x1,%dl
  800e05:	74 11                	je     800e18 <fd_alloc+0x2d>
  800e07:	89 c2                	mov    %eax,%edx
  800e09:	c1 ea 0c             	shr    $0xc,%edx
  800e0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e13:	f6 c2 01             	test   $0x1,%dl
  800e16:	75 09                	jne    800e21 <fd_alloc+0x36>
			*fd_store = fd;
  800e18:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1f:	eb 17                	jmp    800e38 <fd_alloc+0x4d>
  800e21:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e26:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e2b:	75 c9                	jne    800df6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e2d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e33:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e40:	83 f8 1f             	cmp    $0x1f,%eax
  800e43:	77 36                	ja     800e7b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e45:	c1 e0 0c             	shl    $0xc,%eax
  800e48:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e4d:	89 c2                	mov    %eax,%edx
  800e4f:	c1 ea 16             	shr    $0x16,%edx
  800e52:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e59:	f6 c2 01             	test   $0x1,%dl
  800e5c:	74 24                	je     800e82 <fd_lookup+0x48>
  800e5e:	89 c2                	mov    %eax,%edx
  800e60:	c1 ea 0c             	shr    $0xc,%edx
  800e63:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e6a:	f6 c2 01             	test   $0x1,%dl
  800e6d:	74 1a                	je     800e89 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e72:	89 02                	mov    %eax,(%edx)
	return 0;
  800e74:	b8 00 00 00 00       	mov    $0x0,%eax
  800e79:	eb 13                	jmp    800e8e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e80:	eb 0c                	jmp    800e8e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e87:	eb 05                	jmp    800e8e <fd_lookup+0x54>
  800e89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 08             	sub    $0x8,%esp
  800e96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e99:	ba 48 27 80 00       	mov    $0x802748,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e9e:	eb 13                	jmp    800eb3 <dev_lookup+0x23>
  800ea0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ea3:	39 08                	cmp    %ecx,(%eax)
  800ea5:	75 0c                	jne    800eb3 <dev_lookup+0x23>
			*dev = devtab[i];
  800ea7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaa:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb1:	eb 2e                	jmp    800ee1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eb3:	8b 02                	mov    (%edx),%eax
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	75 e7                	jne    800ea0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eb9:	a1 08 40 80 00       	mov    0x804008,%eax
  800ebe:	8b 40 48             	mov    0x48(%eax),%eax
  800ec1:	83 ec 04             	sub    $0x4,%esp
  800ec4:	51                   	push   %ecx
  800ec5:	50                   	push   %eax
  800ec6:	68 cc 26 80 00       	push   $0x8026cc
  800ecb:	e8 bd f2 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    

00800ee3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 10             	sub    $0x10,%esp
  800eeb:	8b 75 08             	mov    0x8(%ebp),%esi
  800eee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef4:	50                   	push   %eax
  800ef5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800efb:	c1 e8 0c             	shr    $0xc,%eax
  800efe:	50                   	push   %eax
  800eff:	e8 36 ff ff ff       	call   800e3a <fd_lookup>
  800f04:	83 c4 08             	add    $0x8,%esp
  800f07:	85 c0                	test   %eax,%eax
  800f09:	78 05                	js     800f10 <fd_close+0x2d>
	    || fd != fd2)
  800f0b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f0e:	74 0c                	je     800f1c <fd_close+0x39>
		return (must_exist ? r : 0);
  800f10:	84 db                	test   %bl,%bl
  800f12:	ba 00 00 00 00       	mov    $0x0,%edx
  800f17:	0f 44 c2             	cmove  %edx,%eax
  800f1a:	eb 41                	jmp    800f5d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f1c:	83 ec 08             	sub    $0x8,%esp
  800f1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f22:	50                   	push   %eax
  800f23:	ff 36                	pushl  (%esi)
  800f25:	e8 66 ff ff ff       	call   800e90 <dev_lookup>
  800f2a:	89 c3                	mov    %eax,%ebx
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	78 1a                	js     800f4d <fd_close+0x6a>
		if (dev->dev_close)
  800f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f36:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f39:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	74 0b                	je     800f4d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f42:	83 ec 0c             	sub    $0xc,%esp
  800f45:	56                   	push   %esi
  800f46:	ff d0                	call   *%eax
  800f48:	89 c3                	mov    %eax,%ebx
  800f4a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f4d:	83 ec 08             	sub    $0x8,%esp
  800f50:	56                   	push   %esi
  800f51:	6a 00                	push   $0x0
  800f53:	e8 c1 fc ff ff       	call   800c19 <sys_page_unmap>
	return r;
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	89 d8                	mov    %ebx,%eax
}
  800f5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6d:	50                   	push   %eax
  800f6e:	ff 75 08             	pushl  0x8(%ebp)
  800f71:	e8 c4 fe ff ff       	call   800e3a <fd_lookup>
  800f76:	83 c4 08             	add    $0x8,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	78 10                	js     800f8d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f7d:	83 ec 08             	sub    $0x8,%esp
  800f80:	6a 01                	push   $0x1
  800f82:	ff 75 f4             	pushl  -0xc(%ebp)
  800f85:	e8 59 ff ff ff       	call   800ee3 <fd_close>
  800f8a:	83 c4 10             	add    $0x10,%esp
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <close_all>:

void
close_all(void)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	53                   	push   %ebx
  800f93:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f96:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f9b:	83 ec 0c             	sub    $0xc,%esp
  800f9e:	53                   	push   %ebx
  800f9f:	e8 c0 ff ff ff       	call   800f64 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fa4:	83 c3 01             	add    $0x1,%ebx
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	83 fb 20             	cmp    $0x20,%ebx
  800fad:	75 ec                	jne    800f9b <close_all+0xc>
		close(i);
}
  800faf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
  800fba:	83 ec 2c             	sub    $0x2c,%esp
  800fbd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fc0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc3:	50                   	push   %eax
  800fc4:	ff 75 08             	pushl  0x8(%ebp)
  800fc7:	e8 6e fe ff ff       	call   800e3a <fd_lookup>
  800fcc:	83 c4 08             	add    $0x8,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	0f 88 c1 00 00 00    	js     801098 <dup+0xe4>
		return r;
	close(newfdnum);
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	56                   	push   %esi
  800fdb:	e8 84 ff ff ff       	call   800f64 <close>

	newfd = INDEX2FD(newfdnum);
  800fe0:	89 f3                	mov    %esi,%ebx
  800fe2:	c1 e3 0c             	shl    $0xc,%ebx
  800fe5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800feb:	83 c4 04             	add    $0x4,%esp
  800fee:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff1:	e8 de fd ff ff       	call   800dd4 <fd2data>
  800ff6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800ff8:	89 1c 24             	mov    %ebx,(%esp)
  800ffb:	e8 d4 fd ff ff       	call   800dd4 <fd2data>
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801006:	89 f8                	mov    %edi,%eax
  801008:	c1 e8 16             	shr    $0x16,%eax
  80100b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801012:	a8 01                	test   $0x1,%al
  801014:	74 37                	je     80104d <dup+0x99>
  801016:	89 f8                	mov    %edi,%eax
  801018:	c1 e8 0c             	shr    $0xc,%eax
  80101b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801022:	f6 c2 01             	test   $0x1,%dl
  801025:	74 26                	je     80104d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801027:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	25 07 0e 00 00       	and    $0xe07,%eax
  801036:	50                   	push   %eax
  801037:	ff 75 d4             	pushl  -0x2c(%ebp)
  80103a:	6a 00                	push   $0x0
  80103c:	57                   	push   %edi
  80103d:	6a 00                	push   $0x0
  80103f:	e8 93 fb ff ff       	call   800bd7 <sys_page_map>
  801044:	89 c7                	mov    %eax,%edi
  801046:	83 c4 20             	add    $0x20,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	78 2e                	js     80107b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80104d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801050:	89 d0                	mov    %edx,%eax
  801052:	c1 e8 0c             	shr    $0xc,%eax
  801055:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105c:	83 ec 0c             	sub    $0xc,%esp
  80105f:	25 07 0e 00 00       	and    $0xe07,%eax
  801064:	50                   	push   %eax
  801065:	53                   	push   %ebx
  801066:	6a 00                	push   $0x0
  801068:	52                   	push   %edx
  801069:	6a 00                	push   $0x0
  80106b:	e8 67 fb ff ff       	call   800bd7 <sys_page_map>
  801070:	89 c7                	mov    %eax,%edi
  801072:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801075:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801077:	85 ff                	test   %edi,%edi
  801079:	79 1d                	jns    801098 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80107b:	83 ec 08             	sub    $0x8,%esp
  80107e:	53                   	push   %ebx
  80107f:	6a 00                	push   $0x0
  801081:	e8 93 fb ff ff       	call   800c19 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801086:	83 c4 08             	add    $0x8,%esp
  801089:	ff 75 d4             	pushl  -0x2c(%ebp)
  80108c:	6a 00                	push   $0x0
  80108e:	e8 86 fb ff ff       	call   800c19 <sys_page_unmap>
	return r;
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	89 f8                	mov    %edi,%eax
}
  801098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109b:	5b                   	pop    %ebx
  80109c:	5e                   	pop    %esi
  80109d:	5f                   	pop    %edi
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 14             	sub    $0x14,%esp
  8010a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ad:	50                   	push   %eax
  8010ae:	53                   	push   %ebx
  8010af:	e8 86 fd ff ff       	call   800e3a <fd_lookup>
  8010b4:	83 c4 08             	add    $0x8,%esp
  8010b7:	89 c2                	mov    %eax,%edx
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 6d                	js     80112a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010bd:	83 ec 08             	sub    $0x8,%esp
  8010c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c3:	50                   	push   %eax
  8010c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c7:	ff 30                	pushl  (%eax)
  8010c9:	e8 c2 fd ff ff       	call   800e90 <dev_lookup>
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	78 4c                	js     801121 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010d8:	8b 42 08             	mov    0x8(%edx),%eax
  8010db:	83 e0 03             	and    $0x3,%eax
  8010de:	83 f8 01             	cmp    $0x1,%eax
  8010e1:	75 21                	jne    801104 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e3:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e8:	8b 40 48             	mov    0x48(%eax),%eax
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	53                   	push   %ebx
  8010ef:	50                   	push   %eax
  8010f0:	68 0d 27 80 00       	push   $0x80270d
  8010f5:	e8 93 f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801102:	eb 26                	jmp    80112a <read+0x8a>
	}
	if (!dev->dev_read)
  801104:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801107:	8b 40 08             	mov    0x8(%eax),%eax
  80110a:	85 c0                	test   %eax,%eax
  80110c:	74 17                	je     801125 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	ff 75 10             	pushl  0x10(%ebp)
  801114:	ff 75 0c             	pushl  0xc(%ebp)
  801117:	52                   	push   %edx
  801118:	ff d0                	call   *%eax
  80111a:	89 c2                	mov    %eax,%edx
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	eb 09                	jmp    80112a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801121:	89 c2                	mov    %eax,%edx
  801123:	eb 05                	jmp    80112a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801125:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80112a:	89 d0                	mov    %edx,%eax
  80112c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112f:	c9                   	leave  
  801130:	c3                   	ret    

00801131 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	57                   	push   %edi
  801135:	56                   	push   %esi
  801136:	53                   	push   %ebx
  801137:	83 ec 0c             	sub    $0xc,%esp
  80113a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80113d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801140:	bb 00 00 00 00       	mov    $0x0,%ebx
  801145:	eb 21                	jmp    801168 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801147:	83 ec 04             	sub    $0x4,%esp
  80114a:	89 f0                	mov    %esi,%eax
  80114c:	29 d8                	sub    %ebx,%eax
  80114e:	50                   	push   %eax
  80114f:	89 d8                	mov    %ebx,%eax
  801151:	03 45 0c             	add    0xc(%ebp),%eax
  801154:	50                   	push   %eax
  801155:	57                   	push   %edi
  801156:	e8 45 ff ff ff       	call   8010a0 <read>
		if (m < 0)
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 10                	js     801172 <readn+0x41>
			return m;
		if (m == 0)
  801162:	85 c0                	test   %eax,%eax
  801164:	74 0a                	je     801170 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801166:	01 c3                	add    %eax,%ebx
  801168:	39 f3                	cmp    %esi,%ebx
  80116a:	72 db                	jb     801147 <readn+0x16>
  80116c:	89 d8                	mov    %ebx,%eax
  80116e:	eb 02                	jmp    801172 <readn+0x41>
  801170:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801172:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801175:	5b                   	pop    %ebx
  801176:	5e                   	pop    %esi
  801177:	5f                   	pop    %edi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	53                   	push   %ebx
  80117e:	83 ec 14             	sub    $0x14,%esp
  801181:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801184:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801187:	50                   	push   %eax
  801188:	53                   	push   %ebx
  801189:	e8 ac fc ff ff       	call   800e3a <fd_lookup>
  80118e:	83 c4 08             	add    $0x8,%esp
  801191:	89 c2                	mov    %eax,%edx
  801193:	85 c0                	test   %eax,%eax
  801195:	78 68                	js     8011ff <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801197:	83 ec 08             	sub    $0x8,%esp
  80119a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a1:	ff 30                	pushl  (%eax)
  8011a3:	e8 e8 fc ff ff       	call   800e90 <dev_lookup>
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	78 47                	js     8011f6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011b6:	75 21                	jne    8011d9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b8:	a1 08 40 80 00       	mov    0x804008,%eax
  8011bd:	8b 40 48             	mov    0x48(%eax),%eax
  8011c0:	83 ec 04             	sub    $0x4,%esp
  8011c3:	53                   	push   %ebx
  8011c4:	50                   	push   %eax
  8011c5:	68 29 27 80 00       	push   $0x802729
  8011ca:	e8 be ef ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d7:	eb 26                	jmp    8011ff <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8011df:	85 d2                	test   %edx,%edx
  8011e1:	74 17                	je     8011fa <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011e3:	83 ec 04             	sub    $0x4,%esp
  8011e6:	ff 75 10             	pushl  0x10(%ebp)
  8011e9:	ff 75 0c             	pushl  0xc(%ebp)
  8011ec:	50                   	push   %eax
  8011ed:	ff d2                	call   *%edx
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	eb 09                	jmp    8011ff <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	eb 05                	jmp    8011ff <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011ff:	89 d0                	mov    %edx,%eax
  801201:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801204:	c9                   	leave  
  801205:	c3                   	ret    

00801206 <seek>:

int
seek(int fdnum, off_t offset)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80120c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	ff 75 08             	pushl  0x8(%ebp)
  801213:	e8 22 fc ff ff       	call   800e3a <fd_lookup>
  801218:	83 c4 08             	add    $0x8,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	78 0e                	js     80122d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80121f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801222:	8b 55 0c             	mov    0xc(%ebp),%edx
  801225:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801228:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80122d:	c9                   	leave  
  80122e:	c3                   	ret    

0080122f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	53                   	push   %ebx
  801233:	83 ec 14             	sub    $0x14,%esp
  801236:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801239:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123c:	50                   	push   %eax
  80123d:	53                   	push   %ebx
  80123e:	e8 f7 fb ff ff       	call   800e3a <fd_lookup>
  801243:	83 c4 08             	add    $0x8,%esp
  801246:	89 c2                	mov    %eax,%edx
  801248:	85 c0                	test   %eax,%eax
  80124a:	78 65                	js     8012b1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801252:	50                   	push   %eax
  801253:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801256:	ff 30                	pushl  (%eax)
  801258:	e8 33 fc ff ff       	call   800e90 <dev_lookup>
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	78 44                	js     8012a8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801264:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801267:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80126b:	75 21                	jne    80128e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80126d:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801272:	8b 40 48             	mov    0x48(%eax),%eax
  801275:	83 ec 04             	sub    $0x4,%esp
  801278:	53                   	push   %ebx
  801279:	50                   	push   %eax
  80127a:	68 ec 26 80 00       	push   $0x8026ec
  80127f:	e8 09 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80128c:	eb 23                	jmp    8012b1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80128e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801291:	8b 52 18             	mov    0x18(%edx),%edx
  801294:	85 d2                	test   %edx,%edx
  801296:	74 14                	je     8012ac <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801298:	83 ec 08             	sub    $0x8,%esp
  80129b:	ff 75 0c             	pushl  0xc(%ebp)
  80129e:	50                   	push   %eax
  80129f:	ff d2                	call   *%edx
  8012a1:	89 c2                	mov    %eax,%edx
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	eb 09                	jmp    8012b1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a8:	89 c2                	mov    %eax,%edx
  8012aa:	eb 05                	jmp    8012b1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012b1:	89 d0                	mov    %edx,%eax
  8012b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b6:	c9                   	leave  
  8012b7:	c3                   	ret    

008012b8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 14             	sub    $0x14,%esp
  8012bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c5:	50                   	push   %eax
  8012c6:	ff 75 08             	pushl  0x8(%ebp)
  8012c9:	e8 6c fb ff ff       	call   800e3a <fd_lookup>
  8012ce:	83 c4 08             	add    $0x8,%esp
  8012d1:	89 c2                	mov    %eax,%edx
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 58                	js     80132f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d7:	83 ec 08             	sub    $0x8,%esp
  8012da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012dd:	50                   	push   %eax
  8012de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e1:	ff 30                	pushl  (%eax)
  8012e3:	e8 a8 fb ff ff       	call   800e90 <dev_lookup>
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 37                	js     801326 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012f6:	74 32                	je     80132a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012f8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012fb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801302:	00 00 00 
	stat->st_isdir = 0;
  801305:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80130c:	00 00 00 
	stat->st_dev = dev;
  80130f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	53                   	push   %ebx
  801319:	ff 75 f0             	pushl  -0x10(%ebp)
  80131c:	ff 50 14             	call   *0x14(%eax)
  80131f:	89 c2                	mov    %eax,%edx
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	eb 09                	jmp    80132f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801326:	89 c2                	mov    %eax,%edx
  801328:	eb 05                	jmp    80132f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80132a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80132f:	89 d0                	mov    %edx,%eax
  801331:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801334:	c9                   	leave  
  801335:	c3                   	ret    

00801336 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	56                   	push   %esi
  80133a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	6a 00                	push   $0x0
  801340:	ff 75 08             	pushl  0x8(%ebp)
  801343:	e8 e3 01 00 00       	call   80152b <open>
  801348:	89 c3                	mov    %eax,%ebx
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 1b                	js     80136c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	ff 75 0c             	pushl  0xc(%ebp)
  801357:	50                   	push   %eax
  801358:	e8 5b ff ff ff       	call   8012b8 <fstat>
  80135d:	89 c6                	mov    %eax,%esi
	close(fd);
  80135f:	89 1c 24             	mov    %ebx,(%esp)
  801362:	e8 fd fb ff ff       	call   800f64 <close>
	return r;
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	89 f0                	mov    %esi,%eax
}
  80136c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
  801378:	89 c6                	mov    %eax,%esi
  80137a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80137c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801383:	75 12                	jne    801397 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801385:	83 ec 0c             	sub    $0xc,%esp
  801388:	6a 01                	push   $0x1
  80138a:	e8 89 0c 00 00       	call   802018 <ipc_find_env>
  80138f:	a3 00 40 80 00       	mov    %eax,0x804000
  801394:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801397:	6a 07                	push   $0x7
  801399:	68 00 50 80 00       	push   $0x805000
  80139e:	56                   	push   %esi
  80139f:	ff 35 00 40 80 00    	pushl  0x804000
  8013a5:	e8 1a 0c 00 00       	call   801fc4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013aa:	83 c4 0c             	add    $0xc,%esp
  8013ad:	6a 00                	push   $0x0
  8013af:	53                   	push   %ebx
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 a4 0b 00 00       	call   801f5b <ipc_recv>
}
  8013b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ba:	5b                   	pop    %ebx
  8013bb:	5e                   	pop    %esi
  8013bc:	5d                   	pop    %ebp
  8013bd:	c3                   	ret    

008013be <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013dc:	b8 02 00 00 00       	mov    $0x2,%eax
  8013e1:	e8 8d ff ff ff       	call   801373 <fsipc>
}
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    

008013e8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fe:	b8 06 00 00 00       	mov    $0x6,%eax
  801403:	e8 6b ff ff ff       	call   801373 <fsipc>
}
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	53                   	push   %ebx
  80140e:	83 ec 04             	sub    $0x4,%esp
  801411:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801414:	8b 45 08             	mov    0x8(%ebp),%eax
  801417:	8b 40 0c             	mov    0xc(%eax),%eax
  80141a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80141f:	ba 00 00 00 00       	mov    $0x0,%edx
  801424:	b8 05 00 00 00       	mov    $0x5,%eax
  801429:	e8 45 ff ff ff       	call   801373 <fsipc>
  80142e:	85 c0                	test   %eax,%eax
  801430:	78 2c                	js     80145e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801432:	83 ec 08             	sub    $0x8,%esp
  801435:	68 00 50 80 00       	push   $0x805000
  80143a:	53                   	push   %ebx
  80143b:	e8 51 f3 ff ff       	call   800791 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801440:	a1 80 50 80 00       	mov    0x805080,%eax
  801445:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80144b:	a1 84 50 80 00       	mov    0x805084,%eax
  801450:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80145e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801461:	c9                   	leave  
  801462:	c3                   	ret    

00801463 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	83 ec 0c             	sub    $0xc,%esp
  801469:	8b 45 10             	mov    0x10(%ebp),%eax
  80146c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801471:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801476:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801479:	8b 55 08             	mov    0x8(%ebp),%edx
  80147c:	8b 52 0c             	mov    0xc(%edx),%edx
  80147f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801485:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80148a:	50                   	push   %eax
  80148b:	ff 75 0c             	pushl  0xc(%ebp)
  80148e:	68 08 50 80 00       	push   $0x805008
  801493:	e8 8b f4 ff ff       	call   800923 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801498:	ba 00 00 00 00       	mov    $0x0,%edx
  80149d:	b8 04 00 00 00       	mov    $0x4,%eax
  8014a2:	e8 cc fe ff ff       	call   801373 <fsipc>
	//panic("devfile_write not implemented");
}
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	56                   	push   %esi
  8014ad:	53                   	push   %ebx
  8014ae:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014bc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c7:	b8 03 00 00 00       	mov    $0x3,%eax
  8014cc:	e8 a2 fe ff ff       	call   801373 <fsipc>
  8014d1:	89 c3                	mov    %eax,%ebx
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	78 4b                	js     801522 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014d7:	39 c6                	cmp    %eax,%esi
  8014d9:	73 16                	jae    8014f1 <devfile_read+0x48>
  8014db:	68 5c 27 80 00       	push   $0x80275c
  8014e0:	68 63 27 80 00       	push   $0x802763
  8014e5:	6a 7c                	push   $0x7c
  8014e7:	68 78 27 80 00       	push   $0x802778
  8014ec:	e8 24 0a 00 00       	call   801f15 <_panic>
	assert(r <= PGSIZE);
  8014f1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014f6:	7e 16                	jle    80150e <devfile_read+0x65>
  8014f8:	68 83 27 80 00       	push   $0x802783
  8014fd:	68 63 27 80 00       	push   $0x802763
  801502:	6a 7d                	push   $0x7d
  801504:	68 78 27 80 00       	push   $0x802778
  801509:	e8 07 0a 00 00       	call   801f15 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	50                   	push   %eax
  801512:	68 00 50 80 00       	push   $0x805000
  801517:	ff 75 0c             	pushl  0xc(%ebp)
  80151a:	e8 04 f4 ff ff       	call   800923 <memmove>
	return r;
  80151f:	83 c4 10             	add    $0x10,%esp
}
  801522:	89 d8                	mov    %ebx,%eax
  801524:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    

0080152b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	53                   	push   %ebx
  80152f:	83 ec 20             	sub    $0x20,%esp
  801532:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801535:	53                   	push   %ebx
  801536:	e8 1d f2 ff ff       	call   800758 <strlen>
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801543:	7f 67                	jg     8015ac <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	e8 9a f8 ff ff       	call   800deb <fd_alloc>
  801551:	83 c4 10             	add    $0x10,%esp
		return r;
  801554:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801556:	85 c0                	test   %eax,%eax
  801558:	78 57                	js     8015b1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	53                   	push   %ebx
  80155e:	68 00 50 80 00       	push   $0x805000
  801563:	e8 29 f2 ff ff       	call   800791 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801570:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801573:	b8 01 00 00 00       	mov    $0x1,%eax
  801578:	e8 f6 fd ff ff       	call   801373 <fsipc>
  80157d:	89 c3                	mov    %eax,%ebx
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	79 14                	jns    80159a <open+0x6f>
		fd_close(fd, 0);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	6a 00                	push   $0x0
  80158b:	ff 75 f4             	pushl  -0xc(%ebp)
  80158e:	e8 50 f9 ff ff       	call   800ee3 <fd_close>
		return r;
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	89 da                	mov    %ebx,%edx
  801598:	eb 17                	jmp    8015b1 <open+0x86>
	}

	return fd2num(fd);
  80159a:	83 ec 0c             	sub    $0xc,%esp
  80159d:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a0:	e8 1f f8 ff ff       	call   800dc4 <fd2num>
  8015a5:	89 c2                	mov    %eax,%edx
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	eb 05                	jmp    8015b1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015ac:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015b1:	89 d0                	mov    %edx,%eax
  8015b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015be:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c3:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c8:	e8 a6 fd ff ff       	call   801373 <fsipc>
}
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015d5:	68 8f 27 80 00       	push   $0x80278f
  8015da:	ff 75 0c             	pushl  0xc(%ebp)
  8015dd:	e8 af f1 ff ff       	call   800791 <strcpy>
	return 0;
}
  8015e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    

008015e9 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 10             	sub    $0x10,%esp
  8015f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015f3:	53                   	push   %ebx
  8015f4:	e8 58 0a 00 00       	call   802051 <pageref>
  8015f9:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015fc:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801601:	83 f8 01             	cmp    $0x1,%eax
  801604:	75 10                	jne    801616 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801606:	83 ec 0c             	sub    $0xc,%esp
  801609:	ff 73 0c             	pushl  0xc(%ebx)
  80160c:	e8 c0 02 00 00       	call   8018d1 <nsipc_close>
  801611:	89 c2                	mov    %eax,%edx
  801613:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801616:	89 d0                	mov    %edx,%eax
  801618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801623:	6a 00                	push   $0x0
  801625:	ff 75 10             	pushl  0x10(%ebp)
  801628:	ff 75 0c             	pushl  0xc(%ebp)
  80162b:	8b 45 08             	mov    0x8(%ebp),%eax
  80162e:	ff 70 0c             	pushl  0xc(%eax)
  801631:	e8 78 03 00 00       	call   8019ae <nsipc_send>
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80163e:	6a 00                	push   $0x0
  801640:	ff 75 10             	pushl  0x10(%ebp)
  801643:	ff 75 0c             	pushl  0xc(%ebp)
  801646:	8b 45 08             	mov    0x8(%ebp),%eax
  801649:	ff 70 0c             	pushl  0xc(%eax)
  80164c:	e8 f1 02 00 00       	call   801942 <nsipc_recv>
}
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801659:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80165c:	52                   	push   %edx
  80165d:	50                   	push   %eax
  80165e:	e8 d7 f7 ff ff       	call   800e3a <fd_lookup>
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	85 c0                	test   %eax,%eax
  801668:	78 17                	js     801681 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80166a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801673:	39 08                	cmp    %ecx,(%eax)
  801675:	75 05                	jne    80167c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801677:	8b 40 0c             	mov    0xc(%eax),%eax
  80167a:	eb 05                	jmp    801681 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80167c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	56                   	push   %esi
  801687:	53                   	push   %ebx
  801688:	83 ec 1c             	sub    $0x1c,%esp
  80168b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80168d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	e8 55 f7 ff ff       	call   800deb <fd_alloc>
  801696:	89 c3                	mov    %eax,%ebx
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 1b                	js     8016ba <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	68 07 04 00 00       	push   $0x407
  8016a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8016aa:	6a 00                	push   $0x0
  8016ac:	e8 e3 f4 ff ff       	call   800b94 <sys_page_alloc>
  8016b1:	89 c3                	mov    %eax,%ebx
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	79 10                	jns    8016ca <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8016ba:	83 ec 0c             	sub    $0xc,%esp
  8016bd:	56                   	push   %esi
  8016be:	e8 0e 02 00 00       	call   8018d1 <nsipc_close>
		return r;
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	89 d8                	mov    %ebx,%eax
  8016c8:	eb 24                	jmp    8016ee <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016ca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d3:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016df:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016e2:	83 ec 0c             	sub    $0xc,%esp
  8016e5:	50                   	push   %eax
  8016e6:	e8 d9 f6 ff ff       	call   800dc4 <fd2num>
  8016eb:	83 c4 10             	add    $0x10,%esp
}
  8016ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5e                   	pop    %esi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	e8 50 ff ff ff       	call   801653 <fd2sockid>
		return r;
  801703:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801705:	85 c0                	test   %eax,%eax
  801707:	78 1f                	js     801728 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801709:	83 ec 04             	sub    $0x4,%esp
  80170c:	ff 75 10             	pushl  0x10(%ebp)
  80170f:	ff 75 0c             	pushl  0xc(%ebp)
  801712:	50                   	push   %eax
  801713:	e8 12 01 00 00       	call   80182a <nsipc_accept>
  801718:	83 c4 10             	add    $0x10,%esp
		return r;
  80171b:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80171d:	85 c0                	test   %eax,%eax
  80171f:	78 07                	js     801728 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801721:	e8 5d ff ff ff       	call   801683 <alloc_sockfd>
  801726:	89 c1                	mov    %eax,%ecx
}
  801728:	89 c8                	mov    %ecx,%eax
  80172a:	c9                   	leave  
  80172b:	c3                   	ret    

0080172c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801732:	8b 45 08             	mov    0x8(%ebp),%eax
  801735:	e8 19 ff ff ff       	call   801653 <fd2sockid>
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 12                	js     801750 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80173e:	83 ec 04             	sub    $0x4,%esp
  801741:	ff 75 10             	pushl  0x10(%ebp)
  801744:	ff 75 0c             	pushl  0xc(%ebp)
  801747:	50                   	push   %eax
  801748:	e8 2d 01 00 00       	call   80187a <nsipc_bind>
  80174d:	83 c4 10             	add    $0x10,%esp
}
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <shutdown>:

int
shutdown(int s, int how)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	e8 f3 fe ff ff       	call   801653 <fd2sockid>
  801760:	85 c0                	test   %eax,%eax
  801762:	78 0f                	js     801773 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801764:	83 ec 08             	sub    $0x8,%esp
  801767:	ff 75 0c             	pushl  0xc(%ebp)
  80176a:	50                   	push   %eax
  80176b:	e8 3f 01 00 00       	call   8018af <nsipc_shutdown>
  801770:	83 c4 10             	add    $0x10,%esp
}
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80177b:	8b 45 08             	mov    0x8(%ebp),%eax
  80177e:	e8 d0 fe ff ff       	call   801653 <fd2sockid>
  801783:	85 c0                	test   %eax,%eax
  801785:	78 12                	js     801799 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801787:	83 ec 04             	sub    $0x4,%esp
  80178a:	ff 75 10             	pushl  0x10(%ebp)
  80178d:	ff 75 0c             	pushl  0xc(%ebp)
  801790:	50                   	push   %eax
  801791:	e8 55 01 00 00       	call   8018eb <nsipc_connect>
  801796:	83 c4 10             	add    $0x10,%esp
}
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <listen>:

int
listen(int s, int backlog)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a4:	e8 aa fe ff ff       	call   801653 <fd2sockid>
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 0f                	js     8017bc <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8017ad:	83 ec 08             	sub    $0x8,%esp
  8017b0:	ff 75 0c             	pushl  0xc(%ebp)
  8017b3:	50                   	push   %eax
  8017b4:	e8 67 01 00 00       	call   801920 <nsipc_listen>
  8017b9:	83 c4 10             	add    $0x10,%esp
}
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017c4:	ff 75 10             	pushl  0x10(%ebp)
  8017c7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ca:	ff 75 08             	pushl  0x8(%ebp)
  8017cd:	e8 3a 02 00 00       	call   801a0c <nsipc_socket>
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 05                	js     8017de <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8017d9:	e8 a5 fe ff ff       	call   801683 <alloc_sockfd>
}
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	53                   	push   %ebx
  8017e4:	83 ec 04             	sub    $0x4,%esp
  8017e7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017e9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017f0:	75 12                	jne    801804 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017f2:	83 ec 0c             	sub    $0xc,%esp
  8017f5:	6a 02                	push   $0x2
  8017f7:	e8 1c 08 00 00       	call   802018 <ipc_find_env>
  8017fc:	a3 04 40 80 00       	mov    %eax,0x804004
  801801:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801804:	6a 07                	push   $0x7
  801806:	68 00 60 80 00       	push   $0x806000
  80180b:	53                   	push   %ebx
  80180c:	ff 35 04 40 80 00    	pushl  0x804004
  801812:	e8 ad 07 00 00       	call   801fc4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801817:	83 c4 0c             	add    $0xc,%esp
  80181a:	6a 00                	push   $0x0
  80181c:	6a 00                	push   $0x0
  80181e:	6a 00                	push   $0x0
  801820:	e8 36 07 00 00       	call   801f5b <ipc_recv>
}
  801825:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	56                   	push   %esi
  80182e:	53                   	push   %ebx
  80182f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801832:	8b 45 08             	mov    0x8(%ebp),%eax
  801835:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80183a:	8b 06                	mov    (%esi),%eax
  80183c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801841:	b8 01 00 00 00       	mov    $0x1,%eax
  801846:	e8 95 ff ff ff       	call   8017e0 <nsipc>
  80184b:	89 c3                	mov    %eax,%ebx
  80184d:	85 c0                	test   %eax,%eax
  80184f:	78 20                	js     801871 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801851:	83 ec 04             	sub    $0x4,%esp
  801854:	ff 35 10 60 80 00    	pushl  0x806010
  80185a:	68 00 60 80 00       	push   $0x806000
  80185f:	ff 75 0c             	pushl  0xc(%ebp)
  801862:	e8 bc f0 ff ff       	call   800923 <memmove>
		*addrlen = ret->ret_addrlen;
  801867:	a1 10 60 80 00       	mov    0x806010,%eax
  80186c:	89 06                	mov    %eax,(%esi)
  80186e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801871:	89 d8                	mov    %ebx,%eax
  801873:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801876:	5b                   	pop    %ebx
  801877:	5e                   	pop    %esi
  801878:	5d                   	pop    %ebp
  801879:	c3                   	ret    

0080187a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	53                   	push   %ebx
  80187e:	83 ec 08             	sub    $0x8,%esp
  801881:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801884:	8b 45 08             	mov    0x8(%ebp),%eax
  801887:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80188c:	53                   	push   %ebx
  80188d:	ff 75 0c             	pushl  0xc(%ebp)
  801890:	68 04 60 80 00       	push   $0x806004
  801895:	e8 89 f0 ff ff       	call   800923 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80189a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8018a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a5:	e8 36 ff ff ff       	call   8017e0 <nsipc>
}
  8018aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018c5:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ca:	e8 11 ff ff ff       	call   8017e0 <nsipc>
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <nsipc_close>:

int
nsipc_close(int s)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018df:	b8 04 00 00 00       	mov    $0x4,%eax
  8018e4:	e8 f7 fe ff ff       	call   8017e0 <nsipc>
}
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    

008018eb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 08             	sub    $0x8,%esp
  8018f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018fd:	53                   	push   %ebx
  8018fe:	ff 75 0c             	pushl  0xc(%ebp)
  801901:	68 04 60 80 00       	push   $0x806004
  801906:	e8 18 f0 ff ff       	call   800923 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80190b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801911:	b8 05 00 00 00       	mov    $0x5,%eax
  801916:	e8 c5 fe ff ff       	call   8017e0 <nsipc>
}
  80191b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
  801929:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80192e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801931:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801936:	b8 06 00 00 00       	mov    $0x6,%eax
  80193b:	e8 a0 fe ff ff       	call   8017e0 <nsipc>
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	56                   	push   %esi
  801946:	53                   	push   %ebx
  801947:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80194a:	8b 45 08             	mov    0x8(%ebp),%eax
  80194d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801952:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801958:	8b 45 14             	mov    0x14(%ebp),%eax
  80195b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801960:	b8 07 00 00 00       	mov    $0x7,%eax
  801965:	e8 76 fe ff ff       	call   8017e0 <nsipc>
  80196a:	89 c3                	mov    %eax,%ebx
  80196c:	85 c0                	test   %eax,%eax
  80196e:	78 35                	js     8019a5 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801970:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801975:	7f 04                	jg     80197b <nsipc_recv+0x39>
  801977:	39 c6                	cmp    %eax,%esi
  801979:	7d 16                	jge    801991 <nsipc_recv+0x4f>
  80197b:	68 9b 27 80 00       	push   $0x80279b
  801980:	68 63 27 80 00       	push   $0x802763
  801985:	6a 62                	push   $0x62
  801987:	68 b0 27 80 00       	push   $0x8027b0
  80198c:	e8 84 05 00 00       	call   801f15 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801991:	83 ec 04             	sub    $0x4,%esp
  801994:	50                   	push   %eax
  801995:	68 00 60 80 00       	push   $0x806000
  80199a:	ff 75 0c             	pushl  0xc(%ebp)
  80199d:	e8 81 ef ff ff       	call   800923 <memmove>
  8019a2:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019a5:	89 d8                	mov    %ebx,%eax
  8019a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019aa:	5b                   	pop    %ebx
  8019ab:	5e                   	pop    %esi
  8019ac:	5d                   	pop    %ebp
  8019ad:	c3                   	ret    

008019ae <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	53                   	push   %ebx
  8019b2:	83 ec 04             	sub    $0x4,%esp
  8019b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019c0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019c6:	7e 16                	jle    8019de <nsipc_send+0x30>
  8019c8:	68 bc 27 80 00       	push   $0x8027bc
  8019cd:	68 63 27 80 00       	push   $0x802763
  8019d2:	6a 6d                	push   $0x6d
  8019d4:	68 b0 27 80 00       	push   $0x8027b0
  8019d9:	e8 37 05 00 00       	call   801f15 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019de:	83 ec 04             	sub    $0x4,%esp
  8019e1:	53                   	push   %ebx
  8019e2:	ff 75 0c             	pushl  0xc(%ebp)
  8019e5:	68 0c 60 80 00       	push   $0x80600c
  8019ea:	e8 34 ef ff ff       	call   800923 <memmove>
	nsipcbuf.send.req_size = size;
  8019ef:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019fd:	b8 08 00 00 00       	mov    $0x8,%eax
  801a02:	e8 d9 fd ff ff       	call   8017e0 <nsipc>
}
  801a07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1d:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a22:	8b 45 10             	mov    0x10(%ebp),%eax
  801a25:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a2a:	b8 09 00 00 00       	mov    $0x9,%eax
  801a2f:	e8 ac fd ff ff       	call   8017e0 <nsipc>
}
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	56                   	push   %esi
  801a3a:	53                   	push   %ebx
  801a3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	ff 75 08             	pushl  0x8(%ebp)
  801a44:	e8 8b f3 ff ff       	call   800dd4 <fd2data>
  801a49:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a4b:	83 c4 08             	add    $0x8,%esp
  801a4e:	68 c8 27 80 00       	push   $0x8027c8
  801a53:	53                   	push   %ebx
  801a54:	e8 38 ed ff ff       	call   800791 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a59:	8b 46 04             	mov    0x4(%esi),%eax
  801a5c:	2b 06                	sub    (%esi),%eax
  801a5e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a64:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a6b:	00 00 00 
	stat->st_dev = &devpipe;
  801a6e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a75:	30 80 00 
	return 0;
}
  801a78:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	53                   	push   %ebx
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a8e:	53                   	push   %ebx
  801a8f:	6a 00                	push   $0x0
  801a91:	e8 83 f1 ff ff       	call   800c19 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a96:	89 1c 24             	mov    %ebx,(%esp)
  801a99:	e8 36 f3 ff ff       	call   800dd4 <fd2data>
  801a9e:	83 c4 08             	add    $0x8,%esp
  801aa1:	50                   	push   %eax
  801aa2:	6a 00                	push   $0x0
  801aa4:	e8 70 f1 ff ff       	call   800c19 <sys_page_unmap>
}
  801aa9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	57                   	push   %edi
  801ab2:	56                   	push   %esi
  801ab3:	53                   	push   %ebx
  801ab4:	83 ec 1c             	sub    $0x1c,%esp
  801ab7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aba:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801abc:	a1 08 40 80 00       	mov    0x804008,%eax
  801ac1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	ff 75 e0             	pushl  -0x20(%ebp)
  801aca:	e8 82 05 00 00       	call   802051 <pageref>
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	89 3c 24             	mov    %edi,(%esp)
  801ad4:	e8 78 05 00 00       	call   802051 <pageref>
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	39 c3                	cmp    %eax,%ebx
  801ade:	0f 94 c1             	sete   %cl
  801ae1:	0f b6 c9             	movzbl %cl,%ecx
  801ae4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ae7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801aed:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801af0:	39 ce                	cmp    %ecx,%esi
  801af2:	74 1b                	je     801b0f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801af4:	39 c3                	cmp    %eax,%ebx
  801af6:	75 c4                	jne    801abc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801af8:	8b 42 58             	mov    0x58(%edx),%eax
  801afb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801afe:	50                   	push   %eax
  801aff:	56                   	push   %esi
  801b00:	68 cf 27 80 00       	push   $0x8027cf
  801b05:	e8 83 e6 ff ff       	call   80018d <cprintf>
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	eb ad                	jmp    801abc <_pipeisclosed+0xe>
	}
}
  801b0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5e                   	pop    %esi
  801b17:	5f                   	pop    %edi
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    

00801b1a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	57                   	push   %edi
  801b1e:	56                   	push   %esi
  801b1f:	53                   	push   %ebx
  801b20:	83 ec 28             	sub    $0x28,%esp
  801b23:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b26:	56                   	push   %esi
  801b27:	e8 a8 f2 ff ff       	call   800dd4 <fd2data>
  801b2c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	bf 00 00 00 00       	mov    $0x0,%edi
  801b36:	eb 4b                	jmp    801b83 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b38:	89 da                	mov    %ebx,%edx
  801b3a:	89 f0                	mov    %esi,%eax
  801b3c:	e8 6d ff ff ff       	call   801aae <_pipeisclosed>
  801b41:	85 c0                	test   %eax,%eax
  801b43:	75 48                	jne    801b8d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b45:	e8 2b f0 ff ff       	call   800b75 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b4a:	8b 43 04             	mov    0x4(%ebx),%eax
  801b4d:	8b 0b                	mov    (%ebx),%ecx
  801b4f:	8d 51 20             	lea    0x20(%ecx),%edx
  801b52:	39 d0                	cmp    %edx,%eax
  801b54:	73 e2                	jae    801b38 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b59:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b5d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	c1 fa 1f             	sar    $0x1f,%edx
  801b65:	89 d1                	mov    %edx,%ecx
  801b67:	c1 e9 1b             	shr    $0x1b,%ecx
  801b6a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b6d:	83 e2 1f             	and    $0x1f,%edx
  801b70:	29 ca                	sub    %ecx,%edx
  801b72:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b76:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b7a:	83 c0 01             	add    $0x1,%eax
  801b7d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b80:	83 c7 01             	add    $0x1,%edi
  801b83:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b86:	75 c2                	jne    801b4a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b88:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8b:	eb 05                	jmp    801b92 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b8d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5e                   	pop    %esi
  801b97:	5f                   	pop    %edi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	57                   	push   %edi
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 18             	sub    $0x18,%esp
  801ba3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ba6:	57                   	push   %edi
  801ba7:	e8 28 f2 ff ff       	call   800dd4 <fd2data>
  801bac:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb6:	eb 3d                	jmp    801bf5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bb8:	85 db                	test   %ebx,%ebx
  801bba:	74 04                	je     801bc0 <devpipe_read+0x26>
				return i;
  801bbc:	89 d8                	mov    %ebx,%eax
  801bbe:	eb 44                	jmp    801c04 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bc0:	89 f2                	mov    %esi,%edx
  801bc2:	89 f8                	mov    %edi,%eax
  801bc4:	e8 e5 fe ff ff       	call   801aae <_pipeisclosed>
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	75 32                	jne    801bff <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bcd:	e8 a3 ef ff ff       	call   800b75 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bd2:	8b 06                	mov    (%esi),%eax
  801bd4:	3b 46 04             	cmp    0x4(%esi),%eax
  801bd7:	74 df                	je     801bb8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bd9:	99                   	cltd   
  801bda:	c1 ea 1b             	shr    $0x1b,%edx
  801bdd:	01 d0                	add    %edx,%eax
  801bdf:	83 e0 1f             	and    $0x1f,%eax
  801be2:	29 d0                	sub    %edx,%eax
  801be4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bec:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bef:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf2:	83 c3 01             	add    $0x1,%ebx
  801bf5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bf8:	75 d8                	jne    801bd2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bfa:	8b 45 10             	mov    0x10(%ebp),%eax
  801bfd:	eb 05                	jmp    801c04 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c07:	5b                   	pop    %ebx
  801c08:	5e                   	pop    %esi
  801c09:	5f                   	pop    %edi
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    

00801c0c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	56                   	push   %esi
  801c10:	53                   	push   %ebx
  801c11:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c17:	50                   	push   %eax
  801c18:	e8 ce f1 ff ff       	call   800deb <fd_alloc>
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	89 c2                	mov    %eax,%edx
  801c22:	85 c0                	test   %eax,%eax
  801c24:	0f 88 2c 01 00 00    	js     801d56 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2a:	83 ec 04             	sub    $0x4,%esp
  801c2d:	68 07 04 00 00       	push   $0x407
  801c32:	ff 75 f4             	pushl  -0xc(%ebp)
  801c35:	6a 00                	push   $0x0
  801c37:	e8 58 ef ff ff       	call   800b94 <sys_page_alloc>
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	89 c2                	mov    %eax,%edx
  801c41:	85 c0                	test   %eax,%eax
  801c43:	0f 88 0d 01 00 00    	js     801d56 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c49:	83 ec 0c             	sub    $0xc,%esp
  801c4c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c4f:	50                   	push   %eax
  801c50:	e8 96 f1 ff ff       	call   800deb <fd_alloc>
  801c55:	89 c3                	mov    %eax,%ebx
  801c57:	83 c4 10             	add    $0x10,%esp
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	0f 88 e2 00 00 00    	js     801d44 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c62:	83 ec 04             	sub    $0x4,%esp
  801c65:	68 07 04 00 00       	push   $0x407
  801c6a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6d:	6a 00                	push   $0x0
  801c6f:	e8 20 ef ff ff       	call   800b94 <sys_page_alloc>
  801c74:	89 c3                	mov    %eax,%ebx
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	0f 88 c3 00 00 00    	js     801d44 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c81:	83 ec 0c             	sub    $0xc,%esp
  801c84:	ff 75 f4             	pushl  -0xc(%ebp)
  801c87:	e8 48 f1 ff ff       	call   800dd4 <fd2data>
  801c8c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8e:	83 c4 0c             	add    $0xc,%esp
  801c91:	68 07 04 00 00       	push   $0x407
  801c96:	50                   	push   %eax
  801c97:	6a 00                	push   $0x0
  801c99:	e8 f6 ee ff ff       	call   800b94 <sys_page_alloc>
  801c9e:	89 c3                	mov    %eax,%ebx
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	0f 88 89 00 00 00    	js     801d34 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cab:	83 ec 0c             	sub    $0xc,%esp
  801cae:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb1:	e8 1e f1 ff ff       	call   800dd4 <fd2data>
  801cb6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cbd:	50                   	push   %eax
  801cbe:	6a 00                	push   $0x0
  801cc0:	56                   	push   %esi
  801cc1:	6a 00                	push   $0x0
  801cc3:	e8 0f ef ff ff       	call   800bd7 <sys_page_map>
  801cc8:	89 c3                	mov    %eax,%ebx
  801cca:	83 c4 20             	add    $0x20,%esp
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	78 55                	js     801d26 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cd1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cda:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ce6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cfb:	83 ec 0c             	sub    $0xc,%esp
  801cfe:	ff 75 f4             	pushl  -0xc(%ebp)
  801d01:	e8 be f0 ff ff       	call   800dc4 <fd2num>
  801d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d09:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d0b:	83 c4 04             	add    $0x4,%esp
  801d0e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d11:	e8 ae f0 ff ff       	call   800dc4 <fd2num>
  801d16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d19:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d24:	eb 30                	jmp    801d56 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d26:	83 ec 08             	sub    $0x8,%esp
  801d29:	56                   	push   %esi
  801d2a:	6a 00                	push   $0x0
  801d2c:	e8 e8 ee ff ff       	call   800c19 <sys_page_unmap>
  801d31:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d34:	83 ec 08             	sub    $0x8,%esp
  801d37:	ff 75 f0             	pushl  -0x10(%ebp)
  801d3a:	6a 00                	push   $0x0
  801d3c:	e8 d8 ee ff ff       	call   800c19 <sys_page_unmap>
  801d41:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d44:	83 ec 08             	sub    $0x8,%esp
  801d47:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4a:	6a 00                	push   $0x0
  801d4c:	e8 c8 ee ff ff       	call   800c19 <sys_page_unmap>
  801d51:	83 c4 10             	add    $0x10,%esp
  801d54:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d56:	89 d0                	mov    %edx,%eax
  801d58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5b:	5b                   	pop    %ebx
  801d5c:	5e                   	pop    %esi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d68:	50                   	push   %eax
  801d69:	ff 75 08             	pushl  0x8(%ebp)
  801d6c:	e8 c9 f0 ff ff       	call   800e3a <fd_lookup>
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	85 c0                	test   %eax,%eax
  801d76:	78 18                	js     801d90 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d78:	83 ec 0c             	sub    $0xc,%esp
  801d7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7e:	e8 51 f0 ff ff       	call   800dd4 <fd2data>
	return _pipeisclosed(fd, p);
  801d83:	89 c2                	mov    %eax,%edx
  801d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d88:	e8 21 fd ff ff       	call   801aae <_pipeisclosed>
  801d8d:	83 c4 10             	add    $0x10,%esp
}
  801d90:	c9                   	leave  
  801d91:	c3                   	ret    

00801d92 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d95:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    

00801d9c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801da2:	68 e7 27 80 00       	push   $0x8027e7
  801da7:	ff 75 0c             	pushl  0xc(%ebp)
  801daa:	e8 e2 e9 ff ff       	call   800791 <strcpy>
	return 0;
}
  801daf:	b8 00 00 00 00       	mov    $0x0,%eax
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    

00801db6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	57                   	push   %edi
  801dba:	56                   	push   %esi
  801dbb:	53                   	push   %ebx
  801dbc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dcd:	eb 2d                	jmp    801dfc <devcons_write+0x46>
		m = n - tot;
  801dcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dd2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dd4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dd7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ddc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ddf:	83 ec 04             	sub    $0x4,%esp
  801de2:	53                   	push   %ebx
  801de3:	03 45 0c             	add    0xc(%ebp),%eax
  801de6:	50                   	push   %eax
  801de7:	57                   	push   %edi
  801de8:	e8 36 eb ff ff       	call   800923 <memmove>
		sys_cputs(buf, m);
  801ded:	83 c4 08             	add    $0x8,%esp
  801df0:	53                   	push   %ebx
  801df1:	57                   	push   %edi
  801df2:	e8 e1 ec ff ff       	call   800ad8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df7:	01 de                	add    %ebx,%esi
  801df9:	83 c4 10             	add    $0x10,%esp
  801dfc:	89 f0                	mov    %esi,%eax
  801dfe:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e01:	72 cc                	jb     801dcf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e06:	5b                   	pop    %ebx
  801e07:	5e                   	pop    %esi
  801e08:	5f                   	pop    %edi
  801e09:	5d                   	pop    %ebp
  801e0a:	c3                   	ret    

00801e0b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	83 ec 08             	sub    $0x8,%esp
  801e11:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e1a:	74 2a                	je     801e46 <devcons_read+0x3b>
  801e1c:	eb 05                	jmp    801e23 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e1e:	e8 52 ed ff ff       	call   800b75 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e23:	e8 ce ec ff ff       	call   800af6 <sys_cgetc>
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	74 f2                	je     801e1e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	78 16                	js     801e46 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e30:	83 f8 04             	cmp    $0x4,%eax
  801e33:	74 0c                	je     801e41 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e35:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e38:	88 02                	mov    %al,(%edx)
	return 1;
  801e3a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3f:	eb 05                	jmp    801e46 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e41:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e46:	c9                   	leave  
  801e47:	c3                   	ret    

00801e48 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e51:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e54:	6a 01                	push   $0x1
  801e56:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e59:	50                   	push   %eax
  801e5a:	e8 79 ec ff ff       	call   800ad8 <sys_cputs>
}
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	c9                   	leave  
  801e63:	c3                   	ret    

00801e64 <getchar>:

int
getchar(void)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e6a:	6a 01                	push   $0x1
  801e6c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e6f:	50                   	push   %eax
  801e70:	6a 00                	push   $0x0
  801e72:	e8 29 f2 ff ff       	call   8010a0 <read>
	if (r < 0)
  801e77:	83 c4 10             	add    $0x10,%esp
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	78 0f                	js     801e8d <getchar+0x29>
		return r;
	if (r < 1)
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	7e 06                	jle    801e88 <getchar+0x24>
		return -E_EOF;
	return c;
  801e82:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e86:	eb 05                	jmp    801e8d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e88:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e98:	50                   	push   %eax
  801e99:	ff 75 08             	pushl  0x8(%ebp)
  801e9c:	e8 99 ef ff ff       	call   800e3a <fd_lookup>
  801ea1:	83 c4 10             	add    $0x10,%esp
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	78 11                	js     801eb9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eab:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eb1:	39 10                	cmp    %edx,(%eax)
  801eb3:	0f 94 c0             	sete   %al
  801eb6:	0f b6 c0             	movzbl %al,%eax
}
  801eb9:	c9                   	leave  
  801eba:	c3                   	ret    

00801ebb <opencons>:

int
opencons(void)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec4:	50                   	push   %eax
  801ec5:	e8 21 ef ff ff       	call   800deb <fd_alloc>
  801eca:	83 c4 10             	add    $0x10,%esp
		return r;
  801ecd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	78 3e                	js     801f11 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed3:	83 ec 04             	sub    $0x4,%esp
  801ed6:	68 07 04 00 00       	push   $0x407
  801edb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ede:	6a 00                	push   $0x0
  801ee0:	e8 af ec ff ff       	call   800b94 <sys_page_alloc>
  801ee5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eea:	85 c0                	test   %eax,%eax
  801eec:	78 23                	js     801f11 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eee:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f03:	83 ec 0c             	sub    $0xc,%esp
  801f06:	50                   	push   %eax
  801f07:	e8 b8 ee ff ff       	call   800dc4 <fd2num>
  801f0c:	89 c2                	mov    %eax,%edx
  801f0e:	83 c4 10             	add    $0x10,%esp
}
  801f11:	89 d0                	mov    %edx,%eax
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	56                   	push   %esi
  801f19:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f1a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f1d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f23:	e8 2e ec ff ff       	call   800b56 <sys_getenvid>
  801f28:	83 ec 0c             	sub    $0xc,%esp
  801f2b:	ff 75 0c             	pushl  0xc(%ebp)
  801f2e:	ff 75 08             	pushl  0x8(%ebp)
  801f31:	56                   	push   %esi
  801f32:	50                   	push   %eax
  801f33:	68 f4 27 80 00       	push   $0x8027f4
  801f38:	e8 50 e2 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f3d:	83 c4 18             	add    $0x18,%esp
  801f40:	53                   	push   %ebx
  801f41:	ff 75 10             	pushl  0x10(%ebp)
  801f44:	e8 f3 e1 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801f49:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  801f50:	e8 38 e2 ff ff       	call   80018d <cprintf>
  801f55:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f58:	cc                   	int3   
  801f59:	eb fd                	jmp    801f58 <_panic+0x43>

00801f5b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f5b:	55                   	push   %ebp
  801f5c:	89 e5                	mov    %esp,%ebp
  801f5e:	56                   	push   %esi
  801f5f:	53                   	push   %ebx
  801f60:	8b 75 08             	mov    0x8(%ebp),%esi
  801f63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f70:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f73:	83 ec 0c             	sub    $0xc,%esp
  801f76:	50                   	push   %eax
  801f77:	e8 c8 ed ff ff       	call   800d44 <sys_ipc_recv>
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	79 16                	jns    801f99 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f83:	85 f6                	test   %esi,%esi
  801f85:	74 06                	je     801f8d <ipc_recv+0x32>
            *from_env_store = 0;
  801f87:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f8d:	85 db                	test   %ebx,%ebx
  801f8f:	74 2c                	je     801fbd <ipc_recv+0x62>
            *perm_store = 0;
  801f91:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f97:	eb 24                	jmp    801fbd <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f99:	85 f6                	test   %esi,%esi
  801f9b:	74 0a                	je     801fa7 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f9d:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa2:	8b 40 74             	mov    0x74(%eax),%eax
  801fa5:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801fa7:	85 db                	test   %ebx,%ebx
  801fa9:	74 0a                	je     801fb5 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801fab:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb0:	8b 40 78             	mov    0x78(%eax),%eax
  801fb3:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801fb5:	a1 08 40 80 00       	mov    0x804008,%eax
  801fba:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801fbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc0:	5b                   	pop    %ebx
  801fc1:	5e                   	pop    %esi
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    

00801fc4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	57                   	push   %edi
  801fc8:	56                   	push   %esi
  801fc9:	53                   	push   %ebx
  801fca:	83 ec 0c             	sub    $0xc,%esp
  801fcd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fd0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fd3:	8b 45 10             	mov    0x10(%ebp),%eax
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fdd:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fe0:	eb 1c                	jmp    801ffe <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801fe2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fe5:	74 12                	je     801ff9 <ipc_send+0x35>
  801fe7:	50                   	push   %eax
  801fe8:	68 18 28 80 00       	push   $0x802818
  801fed:	6a 3b                	push   $0x3b
  801fef:	68 2e 28 80 00       	push   $0x80282e
  801ff4:	e8 1c ff ff ff       	call   801f15 <_panic>
		sys_yield();
  801ff9:	e8 77 eb ff ff       	call   800b75 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801ffe:	ff 75 14             	pushl  0x14(%ebp)
  802001:	53                   	push   %ebx
  802002:	56                   	push   %esi
  802003:	57                   	push   %edi
  802004:	e8 18 ed ff ff       	call   800d21 <sys_ipc_try_send>
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	85 c0                	test   %eax,%eax
  80200e:	78 d2                	js     801fe2 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802010:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    

00802018 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80201e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802023:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802026:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80202c:	8b 52 50             	mov    0x50(%edx),%edx
  80202f:	39 ca                	cmp    %ecx,%edx
  802031:	75 0d                	jne    802040 <ipc_find_env+0x28>
			return envs[i].env_id;
  802033:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802036:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80203b:	8b 40 48             	mov    0x48(%eax),%eax
  80203e:	eb 0f                	jmp    80204f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802040:	83 c0 01             	add    $0x1,%eax
  802043:	3d 00 04 00 00       	cmp    $0x400,%eax
  802048:	75 d9                	jne    802023 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80204a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80204f:	5d                   	pop    %ebp
  802050:	c3                   	ret    

00802051 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802057:	89 d0                	mov    %edx,%eax
  802059:	c1 e8 16             	shr    $0x16,%eax
  80205c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802063:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802068:	f6 c1 01             	test   $0x1,%cl
  80206b:	74 1d                	je     80208a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80206d:	c1 ea 0c             	shr    $0xc,%edx
  802070:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802077:	f6 c2 01             	test   $0x1,%dl
  80207a:	74 0e                	je     80208a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80207c:	c1 ea 0c             	shr    $0xc,%edx
  80207f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802086:	ef 
  802087:	0f b7 c0             	movzwl %ax,%eax
}
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    
  80208c:	66 90                	xchg   %ax,%ax
  80208e:	66 90                	xchg   %ax,%ax

00802090 <__udivdi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80209b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80209f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 f6                	test   %esi,%esi
  8020a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ad:	89 ca                	mov    %ecx,%edx
  8020af:	89 f8                	mov    %edi,%eax
  8020b1:	75 3d                	jne    8020f0 <__udivdi3+0x60>
  8020b3:	39 cf                	cmp    %ecx,%edi
  8020b5:	0f 87 c5 00 00 00    	ja     802180 <__udivdi3+0xf0>
  8020bb:	85 ff                	test   %edi,%edi
  8020bd:	89 fd                	mov    %edi,%ebp
  8020bf:	75 0b                	jne    8020cc <__udivdi3+0x3c>
  8020c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c6:	31 d2                	xor    %edx,%edx
  8020c8:	f7 f7                	div    %edi
  8020ca:	89 c5                	mov    %eax,%ebp
  8020cc:	89 c8                	mov    %ecx,%eax
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	f7 f5                	div    %ebp
  8020d2:	89 c1                	mov    %eax,%ecx
  8020d4:	89 d8                	mov    %ebx,%eax
  8020d6:	89 cf                	mov    %ecx,%edi
  8020d8:	f7 f5                	div    %ebp
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	89 fa                	mov    %edi,%edx
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	90                   	nop
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	39 ce                	cmp    %ecx,%esi
  8020f2:	77 74                	ja     802168 <__udivdi3+0xd8>
  8020f4:	0f bd fe             	bsr    %esi,%edi
  8020f7:	83 f7 1f             	xor    $0x1f,%edi
  8020fa:	0f 84 98 00 00 00    	je     802198 <__udivdi3+0x108>
  802100:	bb 20 00 00 00       	mov    $0x20,%ebx
  802105:	89 f9                	mov    %edi,%ecx
  802107:	89 c5                	mov    %eax,%ebp
  802109:	29 fb                	sub    %edi,%ebx
  80210b:	d3 e6                	shl    %cl,%esi
  80210d:	89 d9                	mov    %ebx,%ecx
  80210f:	d3 ed                	shr    %cl,%ebp
  802111:	89 f9                	mov    %edi,%ecx
  802113:	d3 e0                	shl    %cl,%eax
  802115:	09 ee                	or     %ebp,%esi
  802117:	89 d9                	mov    %ebx,%ecx
  802119:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80211d:	89 d5                	mov    %edx,%ebp
  80211f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802123:	d3 ed                	shr    %cl,%ebp
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e2                	shl    %cl,%edx
  802129:	89 d9                	mov    %ebx,%ecx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	09 c2                	or     %eax,%edx
  80212f:	89 d0                	mov    %edx,%eax
  802131:	89 ea                	mov    %ebp,%edx
  802133:	f7 f6                	div    %esi
  802135:	89 d5                	mov    %edx,%ebp
  802137:	89 c3                	mov    %eax,%ebx
  802139:	f7 64 24 0c          	mull   0xc(%esp)
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	72 10                	jb     802151 <__udivdi3+0xc1>
  802141:	8b 74 24 08          	mov    0x8(%esp),%esi
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e6                	shl    %cl,%esi
  802149:	39 c6                	cmp    %eax,%esi
  80214b:	73 07                	jae    802154 <__udivdi3+0xc4>
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	75 03                	jne    802154 <__udivdi3+0xc4>
  802151:	83 eb 01             	sub    $0x1,%ebx
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 d8                	mov    %ebx,%eax
  802158:	89 fa                	mov    %edi,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	31 ff                	xor    %edi,%edi
  80216a:	31 db                	xor    %ebx,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d8                	mov    %ebx,%eax
  802182:	f7 f7                	div    %edi
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 c3                	mov    %eax,%ebx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 fa                	mov    %edi,%edx
  80218c:	83 c4 1c             	add    $0x1c,%esp
  80218f:	5b                   	pop    %ebx
  802190:	5e                   	pop    %esi
  802191:	5f                   	pop    %edi
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	39 ce                	cmp    %ecx,%esi
  80219a:	72 0c                	jb     8021a8 <__udivdi3+0x118>
  80219c:	31 db                	xor    %ebx,%ebx
  80219e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021a2:	0f 87 34 ff ff ff    	ja     8020dc <__udivdi3+0x4c>
  8021a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ad:	e9 2a ff ff ff       	jmp    8020dc <__udivdi3+0x4c>
  8021b2:	66 90                	xchg   %ax,%ax
  8021b4:	66 90                	xchg   %ax,%ax
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 d2                	test   %edx,%edx
  8021d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021e1:	89 f3                	mov    %esi,%ebx
  8021e3:	89 3c 24             	mov    %edi,(%esp)
  8021e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ea:	75 1c                	jne    802208 <__umoddi3+0x48>
  8021ec:	39 f7                	cmp    %esi,%edi
  8021ee:	76 50                	jbe    802240 <__umoddi3+0x80>
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	f7 f7                	div    %edi
  8021f6:	89 d0                	mov    %edx,%eax
  8021f8:	31 d2                	xor    %edx,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	89 d0                	mov    %edx,%eax
  80220c:	77 52                	ja     802260 <__umoddi3+0xa0>
  80220e:	0f bd ea             	bsr    %edx,%ebp
  802211:	83 f5 1f             	xor    $0x1f,%ebp
  802214:	75 5a                	jne    802270 <__umoddi3+0xb0>
  802216:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80221a:	0f 82 e0 00 00 00    	jb     802300 <__umoddi3+0x140>
  802220:	39 0c 24             	cmp    %ecx,(%esp)
  802223:	0f 86 d7 00 00 00    	jbe    802300 <__umoddi3+0x140>
  802229:	8b 44 24 08          	mov    0x8(%esp),%eax
  80222d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	85 ff                	test   %edi,%edi
  802242:	89 fd                	mov    %edi,%ebp
  802244:	75 0b                	jne    802251 <__umoddi3+0x91>
  802246:	b8 01 00 00 00       	mov    $0x1,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	f7 f7                	div    %edi
  80224f:	89 c5                	mov    %eax,%ebp
  802251:	89 f0                	mov    %esi,%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	f7 f5                	div    %ebp
  802257:	89 c8                	mov    %ecx,%eax
  802259:	f7 f5                	div    %ebp
  80225b:	89 d0                	mov    %edx,%eax
  80225d:	eb 99                	jmp    8021f8 <__umoddi3+0x38>
  80225f:	90                   	nop
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	83 c4 1c             	add    $0x1c,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	8b 34 24             	mov    (%esp),%esi
  802273:	bf 20 00 00 00       	mov    $0x20,%edi
  802278:	89 e9                	mov    %ebp,%ecx
  80227a:	29 ef                	sub    %ebp,%edi
  80227c:	d3 e0                	shl    %cl,%eax
  80227e:	89 f9                	mov    %edi,%ecx
  802280:	89 f2                	mov    %esi,%edx
  802282:	d3 ea                	shr    %cl,%edx
  802284:	89 e9                	mov    %ebp,%ecx
  802286:	09 c2                	or     %eax,%edx
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	89 14 24             	mov    %edx,(%esp)
  80228d:	89 f2                	mov    %esi,%edx
  80228f:	d3 e2                	shl    %cl,%edx
  802291:	89 f9                	mov    %edi,%ecx
  802293:	89 54 24 04          	mov    %edx,0x4(%esp)
  802297:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	89 c6                	mov    %eax,%esi
  8022a1:	d3 e3                	shl    %cl,%ebx
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 d0                	mov    %edx,%eax
  8022a7:	d3 e8                	shr    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	09 d8                	or     %ebx,%eax
  8022ad:	89 d3                	mov    %edx,%ebx
  8022af:	89 f2                	mov    %esi,%edx
  8022b1:	f7 34 24             	divl   (%esp)
  8022b4:	89 d6                	mov    %edx,%esi
  8022b6:	d3 e3                	shl    %cl,%ebx
  8022b8:	f7 64 24 04          	mull   0x4(%esp)
  8022bc:	39 d6                	cmp    %edx,%esi
  8022be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022c2:	89 d1                	mov    %edx,%ecx
  8022c4:	89 c3                	mov    %eax,%ebx
  8022c6:	72 08                	jb     8022d0 <__umoddi3+0x110>
  8022c8:	75 11                	jne    8022db <__umoddi3+0x11b>
  8022ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ce:	73 0b                	jae    8022db <__umoddi3+0x11b>
  8022d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022d4:	1b 14 24             	sbb    (%esp),%edx
  8022d7:	89 d1                	mov    %edx,%ecx
  8022d9:	89 c3                	mov    %eax,%ebx
  8022db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022df:	29 da                	sub    %ebx,%edx
  8022e1:	19 ce                	sbb    %ecx,%esi
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 f0                	mov    %esi,%eax
  8022e7:	d3 e0                	shl    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	d3 ea                	shr    %cl,%edx
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	d3 ee                	shr    %cl,%esi
  8022f1:	09 d0                	or     %edx,%eax
  8022f3:	89 f2                	mov    %esi,%edx
  8022f5:	83 c4 1c             	add    $0x1c,%esp
  8022f8:	5b                   	pop    %ebx
  8022f9:	5e                   	pop    %esi
  8022fa:	5f                   	pop    %edi
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    
  8022fd:	8d 76 00             	lea    0x0(%esi),%esi
  802300:	29 f9                	sub    %edi,%ecx
  802302:	19 d6                	sbb    %edx,%esi
  802304:	89 74 24 04          	mov    %esi,0x4(%esp)
  802308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80230c:	e9 18 ff ff ff       	jmp    802229 <__umoddi3+0x69>
