
obj/user/pingpongs.debug：     文件格式 elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 6c 10 00 00       	call   8010ad <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004e:	e8 67 0b 00 00       	call   800bba <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 c0 26 80 00       	push   $0x8026c0
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 50 0b 00 00       	call   800bba <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 da 26 80 00       	push   $0x8026da
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 a9 10 00 00       	call   801130 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 2d 10 00 00       	call   8010c7 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 07 0b 00 00       	call   800bba <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 f0 26 80 00       	push   $0x8026f0
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 08 40 80 00       	mov    %eax,0x804008
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 46 10 00 00       	call   801130 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 08 40 80 00 0a 	cmpl   $0xa,0x804008
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800109:	e8 ac 0a 00 00       	call   800bba <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 0c 40 80 00       	mov    %eax,0x80400c

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
        binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 39 12 00 00       	call   801388 <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 20 0a 00 00       	call   800b79 <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 ae 09 00 00       	call   800b3c <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 1a 01 00 00       	call   8002ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 53 09 00 00       	call   800b3c <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 c7 21 00 00       	call   802420 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 b4 22 00 00       	call   802550 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 20 27 80 00 	movsbl 0x802720(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c3:	73 0a                	jae    8002cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	88 02                	mov    %al,(%edx)
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002da:	50                   	push   %eax
  8002db:	ff 75 10             	pushl  0x10(%ebp)
  8002de:	ff 75 0c             	pushl  0xc(%ebp)
  8002e1:	ff 75 08             	pushl  0x8(%ebp)
  8002e4:	e8 05 00 00 00       	call   8002ee <vprintfmt>
	va_end(ap);
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 2c             	sub    $0x2c,%esp
  8002f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800300:	eb 12                	jmp    800314 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800302:	85 c0                	test   %eax,%eax
  800304:	0f 84 42 04 00 00    	je     80074c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80030a:	83 ec 08             	sub    $0x8,%esp
  80030d:	53                   	push   %ebx
  80030e:	50                   	push   %eax
  80030f:	ff d6                	call   *%esi
  800311:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800314:	83 c7 01             	add    $0x1,%edi
  800317:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80031b:	83 f8 25             	cmp    $0x25,%eax
  80031e:	75 e2                	jne    800302 <vprintfmt+0x14>
  800320:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800324:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800332:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800339:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033e:	eb 07                	jmp    800347 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800343:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8d 47 01             	lea    0x1(%edi),%eax
  80034a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034d:	0f b6 07             	movzbl (%edi),%eax
  800350:	0f b6 d0             	movzbl %al,%edx
  800353:	83 e8 23             	sub    $0x23,%eax
  800356:	3c 55                	cmp    $0x55,%al
  800358:	0f 87 d3 03 00 00    	ja     800731 <vprintfmt+0x443>
  80035e:	0f b6 c0             	movzbl %al,%eax
  800361:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036f:	eb d6                	jmp    800347 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800374:	b8 00 00 00 00       	mov    $0x0,%eax
  800379:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800383:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800386:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800389:	83 f9 09             	cmp    $0x9,%ecx
  80038c:	77 3f                	ja     8003cd <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800391:	eb e9                	jmp    80037c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8d 40 04             	lea    0x4(%eax),%eax
  8003a1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a7:	eb 2a                	jmp    8003d3 <vprintfmt+0xe5>
  8003a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	0f 49 d0             	cmovns %eax,%edx
  8003b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bc:	eb 89                	jmp    800347 <vprintfmt+0x59>
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c8:	e9 7a ff ff ff       	jmp    800347 <vprintfmt+0x59>
  8003cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d7:	0f 89 6a ff ff ff    	jns    800347 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ea:	e9 58 ff ff ff       	jmp    800347 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ef:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f5:	e9 4d ff ff ff       	jmp    800347 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 78 04             	lea    0x4(%eax),%edi
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	53                   	push   %ebx
  800404:	ff 30                	pushl  (%eax)
  800406:	ff d6                	call   *%esi
			break;
  800408:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800411:	e9 fe fe ff ff       	jmp    800314 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 78 04             	lea    0x4(%eax),%edi
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	99                   	cltd   
  80041f:	31 d0                	xor    %edx,%eax
  800421:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800423:	83 f8 0f             	cmp    $0xf,%eax
  800426:	7f 0b                	jg     800433 <vprintfmt+0x145>
  800428:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  80042f:	85 d2                	test   %edx,%edx
  800431:	75 1b                	jne    80044e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800433:	50                   	push   %eax
  800434:	68 38 27 80 00       	push   $0x802738
  800439:	53                   	push   %ebx
  80043a:	56                   	push   %esi
  80043b:	e8 91 fe ff ff       	call   8002d1 <printfmt>
  800440:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800443:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800449:	e9 c6 fe ff ff       	jmp    800314 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044e:	52                   	push   %edx
  80044f:	68 b9 2b 80 00       	push   $0x802bb9
  800454:	53                   	push   %ebx
  800455:	56                   	push   %esi
  800456:	e8 76 fe ff ff       	call   8002d1 <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800464:	e9 ab fe ff ff       	jmp    800314 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	83 c0 04             	add    $0x4,%eax
  80046f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800477:	85 ff                	test   %edi,%edi
  800479:	b8 31 27 80 00       	mov    $0x802731,%eax
  80047e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800481:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800485:	0f 8e 94 00 00 00    	jle    80051f <vprintfmt+0x231>
  80048b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048f:	0f 84 98 00 00 00    	je     80052d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	ff 75 d0             	pushl  -0x30(%ebp)
  80049b:	57                   	push   %edi
  80049c:	e8 33 03 00 00       	call   8007d4 <strnlen>
  8004a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a4:	29 c1                	sub    %eax,%ecx
  8004a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	eb 0f                	jmp    8004c9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	53                   	push   %ebx
  8004be:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ef 01             	sub    $0x1,%edi
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	7f ed                	jg     8004ba <vprintfmt+0x1cc>
  8004cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d3:	85 c9                	test   %ecx,%ecx
  8004d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004da:	0f 49 c1             	cmovns %ecx,%eax
  8004dd:	29 c1                	sub    %eax,%ecx
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	89 cb                	mov    %ecx,%ebx
  8004ea:	eb 4d                	jmp    800539 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f0:	74 1b                	je     80050d <vprintfmt+0x21f>
  8004f2:	0f be c0             	movsbl %al,%eax
  8004f5:	83 e8 20             	sub    $0x20,%eax
  8004f8:	83 f8 5e             	cmp    $0x5e,%eax
  8004fb:	76 10                	jbe    80050d <vprintfmt+0x21f>
					putch('?', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	ff 75 0c             	pushl  0xc(%ebp)
  800503:	6a 3f                	push   $0x3f
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb 0d                	jmp    80051a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	ff 75 0c             	pushl  0xc(%ebp)
  800513:	52                   	push   %edx
  800514:	ff 55 08             	call   *0x8(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051a:	83 eb 01             	sub    $0x1,%ebx
  80051d:	eb 1a                	jmp    800539 <vprintfmt+0x24b>
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052b:	eb 0c                	jmp    800539 <vprintfmt+0x24b>
  80052d:	89 75 08             	mov    %esi,0x8(%ebp)
  800530:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800533:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800536:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800539:	83 c7 01             	add    $0x1,%edi
  80053c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800540:	0f be d0             	movsbl %al,%edx
  800543:	85 d2                	test   %edx,%edx
  800545:	74 23                	je     80056a <vprintfmt+0x27c>
  800547:	85 f6                	test   %esi,%esi
  800549:	78 a1                	js     8004ec <vprintfmt+0x1fe>
  80054b:	83 ee 01             	sub    $0x1,%esi
  80054e:	79 9c                	jns    8004ec <vprintfmt+0x1fe>
  800550:	89 df                	mov    %ebx,%edi
  800552:	8b 75 08             	mov    0x8(%ebp),%esi
  800555:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800558:	eb 18                	jmp    800572 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	6a 20                	push   $0x20
  800560:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800562:	83 ef 01             	sub    $0x1,%edi
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	eb 08                	jmp    800572 <vprintfmt+0x284>
  80056a:	89 df                	mov    %ebx,%edi
  80056c:	8b 75 08             	mov    0x8(%ebp),%esi
  80056f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800572:	85 ff                	test   %edi,%edi
  800574:	7f e4                	jg     80055a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800576:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057f:	e9 90 fd ff ff       	jmp    800314 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800584:	83 f9 01             	cmp    $0x1,%ecx
  800587:	7e 19                	jle    8005a2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 50 04             	mov    0x4(%eax),%edx
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 40 08             	lea    0x8(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a0:	eb 38                	jmp    8005da <vprintfmt+0x2ec>
	else if (lflag)
  8005a2:	85 c9                	test   %ecx,%ecx
  8005a4:	74 1b                	je     8005c1 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	89 c1                	mov    %eax,%ecx
  8005b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 40 04             	lea    0x4(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bf:	eb 19                	jmp    8005da <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 c1                	mov    %eax,%ecx
  8005cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 40 04             	lea    0x4(%eax),%eax
  8005d7:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e9:	0f 89 0e 01 00 00    	jns    8006fd <vprintfmt+0x40f>
				putch('-', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	6a 2d                	push   $0x2d
  8005f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fd:	f7 da                	neg    %edx
  8005ff:	83 d1 00             	adc    $0x0,%ecx
  800602:	f7 d9                	neg    %ecx
  800604:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	e9 ec 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800611:	83 f9 01             	cmp    $0x1,%ecx
  800614:	7e 18                	jle    80062e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 10                	mov    (%eax),%edx
  80061b:	8b 48 04             	mov    0x4(%eax),%ecx
  80061e:	8d 40 08             	lea    0x8(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800624:	b8 0a 00 00 00       	mov    $0xa,%eax
  800629:	e9 cf 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	74 1a                	je     80064c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	e9 b1 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	b9 00 00 00 00       	mov    $0x0,%ecx
  800656:	8d 40 04             	lea    0x4(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800661:	e9 97 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	53                   	push   %ebx
  80066a:	6a 58                	push   $0x58
  80066c:	ff d6                	call   *%esi
			putch('X', putdat);
  80066e:	83 c4 08             	add    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	6a 58                	push   $0x58
  800674:	ff d6                	call   *%esi
			putch('X', putdat);
  800676:	83 c4 08             	add    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	6a 58                	push   $0x58
  80067c:	ff d6                	call   *%esi
			break;
  80067e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800684:	e9 8b fc ff ff       	jmp    800314 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	6a 30                	push   $0x30
  80068f:	ff d6                	call   *%esi
			putch('x', putdat);
  800691:	83 c4 08             	add    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 78                	push   $0x78
  800697:	ff d6                	call   *%esi
			num = (unsigned long long)
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ac:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b1:	eb 4a                	jmp    8006fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b3:	83 f9 01             	cmp    $0x1,%ecx
  8006b6:	7e 15                	jle    8006cd <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c0:	8d 40 08             	lea    0x8(%eax),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006cb:	eb 30                	jmp    8006fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	74 17                	je     8006e8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e6:	eb 15                	jmp    8006fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fd:	83 ec 0c             	sub    $0xc,%esp
  800700:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800704:	57                   	push   %edi
  800705:	ff 75 e0             	pushl  -0x20(%ebp)
  800708:	50                   	push   %eax
  800709:	51                   	push   %ecx
  80070a:	52                   	push   %edx
  80070b:	89 da                	mov    %ebx,%edx
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	e8 f1 fa ff ff       	call   800205 <printnum>
			break;
  800714:	83 c4 20             	add    $0x20,%esp
  800717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071a:	e9 f5 fb ff ff       	jmp    800314 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	52                   	push   %edx
  800724:	ff d6                	call   *%esi
			break;
  800726:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072c:	e9 e3 fb ff ff       	jmp    800314 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	6a 25                	push   $0x25
  800737:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 03                	jmp    800741 <vprintfmt+0x453>
  80073e:	83 ef 01             	sub    $0x1,%edi
  800741:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800745:	75 f7                	jne    80073e <vprintfmt+0x450>
  800747:	e9 c8 fb ff ff       	jmp    800314 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80074c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074f:	5b                   	pop    %ebx
  800750:	5e                   	pop    %esi
  800751:	5f                   	pop    %edi
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 18             	sub    $0x18,%esp
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800760:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800763:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800767:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800771:	85 c0                	test   %eax,%eax
  800773:	74 26                	je     80079b <vsnprintf+0x47>
  800775:	85 d2                	test   %edx,%edx
  800777:	7e 22                	jle    80079b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800779:	ff 75 14             	pushl  0x14(%ebp)
  80077c:	ff 75 10             	pushl  0x10(%ebp)
  80077f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800782:	50                   	push   %eax
  800783:	68 b4 02 80 00       	push   $0x8002b4
  800788:	e8 61 fb ff ff       	call   8002ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800790:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb 05                	jmp    8007a0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ab:	50                   	push   %eax
  8007ac:	ff 75 10             	pushl  0x10(%ebp)
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	ff 75 08             	pushl  0x8(%ebp)
  8007b5:	e8 9a ff ff ff       	call   800754 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	eb 03                	jmp    8007cc <strlen+0x10>
		n++;
  8007c9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d0:	75 f7                	jne    8007c9 <strlen+0xd>
		n++;
	return n;
}
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007da:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e2:	eb 03                	jmp    8007e7 <strnlen+0x13>
		n++;
  8007e4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	39 c2                	cmp    %eax,%edx
  8007e9:	74 08                	je     8007f3 <strnlen+0x1f>
  8007eb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ef:	75 f3                	jne    8007e4 <strnlen+0x10>
  8007f1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ff:	89 c2                	mov    %eax,%edx
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	83 c1 01             	add    $0x1,%ecx
  800807:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080e:	84 db                	test   %bl,%bl
  800810:	75 ef                	jne    800801 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800812:	5b                   	pop    %ebx
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081c:	53                   	push   %ebx
  80081d:	e8 9a ff ff ff       	call   8007bc <strlen>
  800822:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	01 d8                	add    %ebx,%eax
  80082a:	50                   	push   %eax
  80082b:	e8 c5 ff ff ff       	call   8007f5 <strcpy>
	return dst;
}
  800830:	89 d8                	mov    %ebx,%eax
  800832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 75 08             	mov    0x8(%ebp),%esi
  80083f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800842:	89 f3                	mov    %esi,%ebx
  800844:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800847:	89 f2                	mov    %esi,%edx
  800849:	eb 0f                	jmp    80085a <strncpy+0x23>
		*dst++ = *src;
  80084b:	83 c2 01             	add    $0x1,%edx
  80084e:	0f b6 01             	movzbl (%ecx),%eax
  800851:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800854:	80 39 01             	cmpb   $0x1,(%ecx)
  800857:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085a:	39 da                	cmp    %ebx,%edx
  80085c:	75 ed                	jne    80084b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085e:	89 f0                	mov    %esi,%eax
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086f:	8b 55 10             	mov    0x10(%ebp),%edx
  800872:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800874:	85 d2                	test   %edx,%edx
  800876:	74 21                	je     800899 <strlcpy+0x35>
  800878:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087c:	89 f2                	mov    %esi,%edx
  80087e:	eb 09                	jmp    800889 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	83 c1 01             	add    $0x1,%ecx
  800886:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800889:	39 c2                	cmp    %eax,%edx
  80088b:	74 09                	je     800896 <strlcpy+0x32>
  80088d:	0f b6 19             	movzbl (%ecx),%ebx
  800890:	84 db                	test   %bl,%bl
  800892:	75 ec                	jne    800880 <strlcpy+0x1c>
  800894:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800896:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800899:	29 f0                	sub    %esi,%eax
}
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a8:	eb 06                	jmp    8008b0 <strcmp+0x11>
		p++, q++;
  8008aa:	83 c1 01             	add    $0x1,%ecx
  8008ad:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b0:	0f b6 01             	movzbl (%ecx),%eax
  8008b3:	84 c0                	test   %al,%al
  8008b5:	74 04                	je     8008bb <strcmp+0x1c>
  8008b7:	3a 02                	cmp    (%edx),%al
  8008b9:	74 ef                	je     8008aa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 c0             	movzbl %al,%eax
  8008be:	0f b6 12             	movzbl (%edx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	53                   	push   %ebx
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d4:	eb 06                	jmp    8008dc <strncmp+0x17>
		n--, p++, q++;
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008dc:	39 d8                	cmp    %ebx,%eax
  8008de:	74 15                	je     8008f5 <strncmp+0x30>
  8008e0:	0f b6 08             	movzbl (%eax),%ecx
  8008e3:	84 c9                	test   %cl,%cl
  8008e5:	74 04                	je     8008eb <strncmp+0x26>
  8008e7:	3a 0a                	cmp    (%edx),%cl
  8008e9:	74 eb                	je     8008d6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 00             	movzbl (%eax),%eax
  8008ee:	0f b6 12             	movzbl (%edx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
  8008f3:	eb 05                	jmp    8008fa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800907:	eb 07                	jmp    800910 <strchr+0x13>
		if (*s == c)
  800909:	38 ca                	cmp    %cl,%dl
  80090b:	74 0f                	je     80091c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	0f b6 10             	movzbl (%eax),%edx
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f2                	jne    800909 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800928:	eb 03                	jmp    80092d <strfind+0xf>
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800930:	38 ca                	cmp    %cl,%dl
  800932:	74 04                	je     800938 <strfind+0x1a>
  800934:	84 d2                	test   %dl,%dl
  800936:	75 f2                	jne    80092a <strfind+0xc>
			break;
	return (char *) s;
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 7d 08             	mov    0x8(%ebp),%edi
  800943:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800946:	85 c9                	test   %ecx,%ecx
  800948:	74 36                	je     800980 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800950:	75 28                	jne    80097a <memset+0x40>
  800952:	f6 c1 03             	test   $0x3,%cl
  800955:	75 23                	jne    80097a <memset+0x40>
		c &= 0xFF;
  800957:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095b:	89 d3                	mov    %edx,%ebx
  80095d:	c1 e3 08             	shl    $0x8,%ebx
  800960:	89 d6                	mov    %edx,%esi
  800962:	c1 e6 18             	shl    $0x18,%esi
  800965:	89 d0                	mov    %edx,%eax
  800967:	c1 e0 10             	shl    $0x10,%eax
  80096a:	09 f0                	or     %esi,%eax
  80096c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096e:	89 d8                	mov    %ebx,%eax
  800970:	09 d0                	or     %edx,%eax
  800972:	c1 e9 02             	shr    $0x2,%ecx
  800975:	fc                   	cld    
  800976:	f3 ab                	rep stos %eax,%es:(%edi)
  800978:	eb 06                	jmp    800980 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097d:	fc                   	cld    
  80097e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800980:	89 f8                	mov    %edi,%eax
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800992:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800995:	39 c6                	cmp    %eax,%esi
  800997:	73 35                	jae    8009ce <memmove+0x47>
  800999:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099c:	39 d0                	cmp    %edx,%eax
  80099e:	73 2e                	jae    8009ce <memmove+0x47>
		s += n;
		d += n;
  8009a0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a3:	89 d6                	mov    %edx,%esi
  8009a5:	09 fe                	or     %edi,%esi
  8009a7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ad:	75 13                	jne    8009c2 <memmove+0x3b>
  8009af:	f6 c1 03             	test   $0x3,%cl
  8009b2:	75 0e                	jne    8009c2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b4:	83 ef 04             	sub    $0x4,%edi
  8009b7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
  8009bd:	fd                   	std    
  8009be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c0:	eb 09                	jmp    8009cb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c2:	83 ef 01             	sub    $0x1,%edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 1d                	jmp    8009eb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	89 f2                	mov    %esi,%edx
  8009d0:	09 c2                	or     %eax,%edx
  8009d2:	f6 c2 03             	test   $0x3,%dl
  8009d5:	75 0f                	jne    8009e6 <memmove+0x5f>
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 0a                	jne    8009e6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009dc:	c1 e9 02             	shr    $0x2,%ecx
  8009df:	89 c7                	mov    %eax,%edi
  8009e1:	fc                   	cld    
  8009e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e4:	eb 05                	jmp    8009eb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f2:	ff 75 10             	pushl  0x10(%ebp)
  8009f5:	ff 75 0c             	pushl  0xc(%ebp)
  8009f8:	ff 75 08             	pushl  0x8(%ebp)
  8009fb:	e8 87 ff ff ff       	call   800987 <memmove>
}
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 c6                	mov    %eax,%esi
  800a0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a12:	eb 1a                	jmp    800a2e <memcmp+0x2c>
		if (*s1 != *s2)
  800a14:	0f b6 08             	movzbl (%eax),%ecx
  800a17:	0f b6 1a             	movzbl (%edx),%ebx
  800a1a:	38 d9                	cmp    %bl,%cl
  800a1c:	74 0a                	je     800a28 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1e:	0f b6 c1             	movzbl %cl,%eax
  800a21:	0f b6 db             	movzbl %bl,%ebx
  800a24:	29 d8                	sub    %ebx,%eax
  800a26:	eb 0f                	jmp    800a37 <memcmp+0x35>
		s1++, s2++;
  800a28:	83 c0 01             	add    $0x1,%eax
  800a2b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	39 f0                	cmp    %esi,%eax
  800a30:	75 e2                	jne    800a14 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a42:	89 c1                	mov    %eax,%ecx
  800a44:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a47:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4b:	eb 0a                	jmp    800a57 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4d:	0f b6 10             	movzbl (%eax),%edx
  800a50:	39 da                	cmp    %ebx,%edx
  800a52:	74 07                	je     800a5b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a54:	83 c0 01             	add    $0x1,%eax
  800a57:	39 c8                	cmp    %ecx,%eax
  800a59:	72 f2                	jb     800a4d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6a:	eb 03                	jmp    800a6f <strtol+0x11>
		s++;
  800a6c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	0f b6 01             	movzbl (%ecx),%eax
  800a72:	3c 20                	cmp    $0x20,%al
  800a74:	74 f6                	je     800a6c <strtol+0xe>
  800a76:	3c 09                	cmp    $0x9,%al
  800a78:	74 f2                	je     800a6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7a:	3c 2b                	cmp    $0x2b,%al
  800a7c:	75 0a                	jne    800a88 <strtol+0x2a>
		s++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a81:	bf 00 00 00 00       	mov    $0x0,%edi
  800a86:	eb 11                	jmp    800a99 <strtol+0x3b>
  800a88:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8d:	3c 2d                	cmp    $0x2d,%al
  800a8f:	75 08                	jne    800a99 <strtol+0x3b>
		s++, neg = 1;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9f:	75 15                	jne    800ab6 <strtol+0x58>
  800aa1:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa4:	75 10                	jne    800ab6 <strtol+0x58>
  800aa6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aaa:	75 7c                	jne    800b28 <strtol+0xca>
		s += 2, base = 16;
  800aac:	83 c1 02             	add    $0x2,%ecx
  800aaf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab4:	eb 16                	jmp    800acc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab6:	85 db                	test   %ebx,%ebx
  800ab8:	75 12                	jne    800acc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aba:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac2:	75 08                	jne    800acc <strtol+0x6e>
		s++, base = 8;
  800ac4:	83 c1 01             	add    $0x1,%ecx
  800ac7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad4:	0f b6 11             	movzbl (%ecx),%edx
  800ad7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ada:	89 f3                	mov    %esi,%ebx
  800adc:	80 fb 09             	cmp    $0x9,%bl
  800adf:	77 08                	ja     800ae9 <strtol+0x8b>
			dig = *s - '0';
  800ae1:	0f be d2             	movsbl %dl,%edx
  800ae4:	83 ea 30             	sub    $0x30,%edx
  800ae7:	eb 22                	jmp    800b0b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aec:	89 f3                	mov    %esi,%ebx
  800aee:	80 fb 19             	cmp    $0x19,%bl
  800af1:	77 08                	ja     800afb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af3:	0f be d2             	movsbl %dl,%edx
  800af6:	83 ea 57             	sub    $0x57,%edx
  800af9:	eb 10                	jmp    800b0b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800afb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afe:	89 f3                	mov    %esi,%ebx
  800b00:	80 fb 19             	cmp    $0x19,%bl
  800b03:	77 16                	ja     800b1b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b05:	0f be d2             	movsbl %dl,%edx
  800b08:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0e:	7d 0b                	jge    800b1b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b10:	83 c1 01             	add    $0x1,%ecx
  800b13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b17:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b19:	eb b9                	jmp    800ad4 <strtol+0x76>

	if (endptr)
  800b1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1f:	74 0d                	je     800b2e <strtol+0xd0>
		*endptr = (char *) s;
  800b21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b24:	89 0e                	mov    %ecx,(%esi)
  800b26:	eb 06                	jmp    800b2e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b28:	85 db                	test   %ebx,%ebx
  800b2a:	74 98                	je     800ac4 <strtol+0x66>
  800b2c:	eb 9e                	jmp    800acc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	f7 da                	neg    %edx
  800b32:	85 ff                	test   %edi,%edi
  800b34:	0f 45 c2             	cmovne %edx,%eax
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
  800b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 c3                	mov    %eax,%ebx
  800b4f:	89 c7                	mov    %eax,%edi
  800b51:	89 c6                	mov    %eax,%esi
  800b53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b87:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	89 cb                	mov    %ecx,%ebx
  800b91:	89 cf                	mov    %ecx,%edi
  800b93:	89 ce                	mov    %ecx,%esi
  800b95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 17                	jle    800bb2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 03                	push   $0x3
  800ba1:	68 1f 2a 80 00       	push   $0x802a1f
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 3c 2a 80 00       	push   $0x802a3c
  800bad:	e8 5c 17 00 00       	call   80230e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_yield>:

void
sys_yield(void)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800be4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be9:	89 d1                	mov    %edx,%ecx
  800beb:	89 d3                	mov    %edx,%ebx
  800bed:	89 d7                	mov    %edx,%edi
  800bef:	89 d6                	mov    %edx,%esi
  800bf1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
  800bfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	be 00 00 00 00       	mov    $0x0,%esi
  800c06:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c14:	89 f7                	mov    %esi,%edi
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 04                	push   $0x4
  800c22:	68 1f 2a 80 00       	push   $0x802a1f
  800c27:	6a 23                	push   $0x23
  800c29:	68 3c 2a 80 00       	push   $0x802a3c
  800c2e:	e8 db 16 00 00       	call   80230e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	b8 05 00 00 00       	mov    $0x5,%eax
  800c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c55:	8b 75 18             	mov    0x18(%ebp),%esi
  800c58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 17                	jle    800c75 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 05                	push   $0x5
  800c64:	68 1f 2a 80 00       	push   $0x802a1f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 3c 2a 80 00       	push   $0x802a3c
  800c70:	e8 99 16 00 00       	call   80230e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	89 df                	mov    %ebx,%edi
  800c98:	89 de                	mov    %ebx,%esi
  800c9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	7e 17                	jle    800cb7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 06                	push   $0x6
  800ca6:	68 1f 2a 80 00       	push   $0x802a1f
  800cab:	6a 23                	push   $0x23
  800cad:	68 3c 2a 80 00       	push   $0x802a3c
  800cb2:	e8 57 16 00 00       	call   80230e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccd:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	89 df                	mov    %ebx,%edi
  800cda:	89 de                	mov    %ebx,%esi
  800cdc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	7e 17                	jle    800cf9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 08                	push   $0x8
  800ce8:	68 1f 2a 80 00       	push   $0x802a1f
  800ced:	6a 23                	push   $0x23
  800cef:	68 3c 2a 80 00       	push   $0x802a3c
  800cf4:	e8 15 16 00 00       	call   80230e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	89 df                	mov    %ebx,%edi
  800d1c:	89 de                	mov    %ebx,%esi
  800d1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 17                	jle    800d3b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 09                	push   $0x9
  800d2a:	68 1f 2a 80 00       	push   $0x802a1f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 3c 2a 80 00       	push   $0x802a3c
  800d36:	e8 d3 15 00 00       	call   80230e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 df                	mov    %ebx,%edi
  800d5e:	89 de                	mov    %ebx,%esi
  800d60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 17                	jle    800d7d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0a                	push   $0xa
  800d6c:	68 1f 2a 80 00       	push   $0x802a1f
  800d71:	6a 23                	push   $0x23
  800d73:	68 3c 2a 80 00       	push   $0x802a3c
  800d78:	e8 91 15 00 00       	call   80230e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800d8b:	be 00 00 00 00       	mov    $0x0,%esi
  800d90:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 cb                	mov    %ecx,%ebx
  800dc0:	89 cf                	mov    %ecx,%edi
  800dc2:	89 ce                	mov    %ecx,%esi
  800dc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 17                	jle    800de1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 0d                	push   $0xd
  800dd0:	68 1f 2a 80 00       	push   $0x802a1f
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 3c 2a 80 00       	push   $0x802a3c
  800ddc:	e8 2d 15 00 00       	call   80230e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800def:	ba 00 00 00 00       	mov    $0x0,%edx
  800df4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df9:	89 d1                	mov    %edx,%ecx
  800dfb:	89 d3                	mov    %edx,%ebx
  800dfd:	89 d7                	mov    %edx,%edi
  800dff:	89 d6                	mov    %edx,%esi
  800e01:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e13:	b8 10 00 00 00       	mov    $0x10,%eax
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 cb                	mov    %ecx,%ebx
  800e1d:	89 cf                	mov    %ecx,%edi
  800e1f:	89 ce                	mov    %ecx,%esi
  800e21:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 04             	sub    $0x4,%esp
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e32:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e34:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e38:	74 2d                	je     800e67 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e3a:	89 d8                	mov    %ebx,%eax
  800e3c:	c1 e8 16             	shr    $0x16,%eax
  800e3f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e46:	a8 01                	test   $0x1,%al
  800e48:	74 1d                	je     800e67 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e4a:	89 d8                	mov    %ebx,%eax
  800e4c:	c1 e8 0c             	shr    $0xc,%eax
  800e4f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e56:	f6 c2 01             	test   $0x1,%dl
  800e59:	74 0c                	je     800e67 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e5b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e62:	f6 c4 08             	test   $0x8,%ah
  800e65:	75 14                	jne    800e7b <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	68 4c 2a 80 00       	push   $0x802a4c
  800e6f:	6a 1f                	push   $0x1f
  800e71:	68 82 2a 80 00       	push   $0x802a82
  800e76:	e8 93 14 00 00       	call   80230e <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800e7b:	83 ec 04             	sub    $0x4,%esp
  800e7e:	6a 07                	push   $0x7
  800e80:	68 00 f0 7f 00       	push   $0x7ff000
  800e85:	6a 00                	push   $0x0
  800e87:	e8 6c fd ff ff       	call   800bf8 <sys_page_alloc>
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	79 12                	jns    800ea5 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800e93:	50                   	push   %eax
  800e94:	68 8d 2a 80 00       	push   $0x802a8d
  800e99:	6a 29                	push   $0x29
  800e9b:	68 82 2a 80 00       	push   $0x802a82
  800ea0:	e8 69 14 00 00       	call   80230e <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ea5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800eab:	83 ec 04             	sub    $0x4,%esp
  800eae:	68 00 10 00 00       	push   $0x1000
  800eb3:	53                   	push   %ebx
  800eb4:	68 00 f0 7f 00       	push   $0x7ff000
  800eb9:	e8 31 fb ff ff       	call   8009ef <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800ebe:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ec5:	53                   	push   %ebx
  800ec6:	6a 00                	push   $0x0
  800ec8:	68 00 f0 7f 00       	push   $0x7ff000
  800ecd:	6a 00                	push   $0x0
  800ecf:	e8 67 fd ff ff       	call   800c3b <sys_page_map>
  800ed4:	83 c4 20             	add    $0x20,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	79 12                	jns    800eed <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800edb:	50                   	push   %eax
  800edc:	68 a1 2a 80 00       	push   $0x802aa1
  800ee1:	6a 2e                	push   $0x2e
  800ee3:	68 82 2a 80 00       	push   $0x802a82
  800ee8:	e8 21 14 00 00       	call   80230e <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800eed:	83 ec 08             	sub    $0x8,%esp
  800ef0:	68 00 f0 7f 00       	push   $0x7ff000
  800ef5:	6a 00                	push   $0x0
  800ef7:	e8 81 fd ff ff       	call   800c7d <sys_page_unmap>
  800efc:	83 c4 10             	add    $0x10,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	79 12                	jns    800f15 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800f03:	50                   	push   %eax
  800f04:	68 b3 2a 80 00       	push   $0x802ab3
  800f09:	6a 30                	push   $0x30
  800f0b:	68 82 2a 80 00       	push   $0x802a82
  800f10:	e8 f9 13 00 00       	call   80230e <_panic>
	//panic("pgfault not implemented");
}
  800f15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800f23:	68 28 0e 80 00       	push   $0x800e28
  800f28:	e8 27 14 00 00       	call   802354 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f2d:	b8 07 00 00 00       	mov    $0x7,%eax
  800f32:	cd 30                	int    $0x30
  800f34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	79 14                	jns    800f52 <fork+0x38>
		panic("sys_exofork failed");
  800f3e:	83 ec 04             	sub    $0x4,%esp
  800f41:	68 c7 2a 80 00       	push   $0x802ac7
  800f46:	6a 6f                	push   $0x6f
  800f48:	68 82 2a 80 00       	push   $0x802a82
  800f4d:	e8 bc 13 00 00       	call   80230e <_panic>
  800f52:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800f54:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f58:	0f 8e 2b 01 00 00    	jle    801089 <fork+0x16f>
  800f5e:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800f63:	89 d8                	mov    %ebx,%eax
  800f65:	c1 e8 0a             	shr    $0xa,%eax
  800f68:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6f:	a8 01                	test   $0x1,%al
  800f71:	0f 84 bf 00 00 00    	je     801036 <fork+0x11c>
  800f77:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f7e:	a8 01                	test   $0x1,%al
  800f80:	0f 84 b0 00 00 00    	je     801036 <fork+0x11c>
  800f86:	89 de                	mov    %ebx,%esi
  800f88:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  800f8b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f92:	f6 c4 04             	test   $0x4,%ah
  800f95:	74 29                	je     800fc0 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  800f97:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f9e:	83 ec 0c             	sub    $0xc,%esp
  800fa1:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa6:	50                   	push   %eax
  800fa7:	56                   	push   %esi
  800fa8:	57                   	push   %edi
  800fa9:	56                   	push   %esi
  800faa:	6a 00                	push   $0x0
  800fac:	e8 8a fc ff ff       	call   800c3b <sys_page_map>
  800fb1:	83 c4 20             	add    $0x20,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbb:	0f 4f c2             	cmovg  %edx,%eax
  800fbe:	eb 72                	jmp    801032 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800fc0:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fc7:	a8 02                	test   $0x2,%al
  800fc9:	75 0c                	jne    800fd7 <fork+0xbd>
  800fcb:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fd2:	f6 c4 08             	test   $0x8,%ah
  800fd5:	74 3f                	je     801016 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	68 05 08 00 00       	push   $0x805
  800fdf:	56                   	push   %esi
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 52 fc ff ff       	call   800c3b <sys_page_map>
  800fe9:	83 c4 20             	add    $0x20,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	0f 88 b1 00 00 00    	js     8010a5 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	68 05 08 00 00       	push   $0x805
  800ffc:	56                   	push   %esi
  800ffd:	6a 00                	push   $0x0
  800fff:	56                   	push   %esi
  801000:	6a 00                	push   $0x0
  801002:	e8 34 fc ff ff       	call   800c3b <sys_page_map>
  801007:	83 c4 20             	add    $0x20,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801011:	0f 4f c1             	cmovg  %ecx,%eax
  801014:	eb 1c                	jmp    801032 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	6a 05                	push   $0x5
  80101b:	56                   	push   %esi
  80101c:	57                   	push   %edi
  80101d:	56                   	push   %esi
  80101e:	6a 00                	push   $0x0
  801020:	e8 16 fc ff ff       	call   800c3b <sys_page_map>
  801025:	83 c4 20             	add    $0x20,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80102f:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  801032:	85 c0                	test   %eax,%eax
  801034:	78 6f                	js     8010a5 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801036:	83 c3 01             	add    $0x1,%ebx
  801039:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80103f:	0f 85 1e ff ff ff    	jne    800f63 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  801045:	83 ec 04             	sub    $0x4,%esp
  801048:	6a 07                	push   $0x7
  80104a:	68 00 f0 bf ee       	push   $0xeebff000
  80104f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801052:	57                   	push   %edi
  801053:	e8 a0 fb ff ff       	call   800bf8 <sys_page_alloc>
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 46                	js     8010a5 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  80105f:	83 ec 08             	sub    $0x8,%esp
  801062:	68 b7 23 80 00       	push   $0x8023b7
  801067:	57                   	push   %edi
  801068:	e8 d6 fc ff ff       	call   800d43 <sys_env_set_pgfault_upcall>
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	78 31                	js     8010a5 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  801074:	83 ec 08             	sub    $0x8,%esp
  801077:	6a 02                	push   $0x2
  801079:	57                   	push   %edi
  80107a:	e8 40 fc ff ff       	call   800cbf <sys_env_set_status>
  80107f:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  801082:	85 c0                	test   %eax,%eax
  801084:	0f 49 c7             	cmovns %edi,%eax
  801087:	eb 1c                	jmp    8010a5 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  801089:	e8 2c fb ff ff       	call   800bba <sys_getenvid>
  80108e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801093:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801096:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109b:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  8010a0:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  8010a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a8:	5b                   	pop    %ebx
  8010a9:	5e                   	pop    %esi
  8010aa:	5f                   	pop    %edi
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    

008010ad <sfork>:

// Challenge!
int
sfork(void)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010b3:	68 da 2a 80 00       	push   $0x802ada
  8010b8:	68 8d 00 00 00       	push   $0x8d
  8010bd:	68 82 2a 80 00       	push   $0x802a82
  8010c2:	e8 47 12 00 00       	call   80230e <_panic>

008010c7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	56                   	push   %esi
  8010cb:	53                   	push   %ebx
  8010cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8010cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010dc:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8010df:	83 ec 0c             	sub    $0xc,%esp
  8010e2:	50                   	push   %eax
  8010e3:	e8 c0 fc ff ff       	call   800da8 <sys_ipc_recv>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	79 16                	jns    801105 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8010ef:	85 f6                	test   %esi,%esi
  8010f1:	74 06                	je     8010f9 <ipc_recv+0x32>
            *from_env_store = 0;
  8010f3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  8010f9:	85 db                	test   %ebx,%ebx
  8010fb:	74 2c                	je     801129 <ipc_recv+0x62>
            *perm_store = 0;
  8010fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801103:	eb 24                	jmp    801129 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801105:	85 f6                	test   %esi,%esi
  801107:	74 0a                	je     801113 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801109:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80110e:	8b 40 74             	mov    0x74(%eax),%eax
  801111:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801113:	85 db                	test   %ebx,%ebx
  801115:	74 0a                	je     801121 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801117:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80111c:	8b 40 78             	mov    0x78(%eax),%eax
  80111f:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801121:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801126:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801129:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	57                   	push   %edi
  801134:	56                   	push   %esi
  801135:	53                   	push   %ebx
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	8b 7d 08             	mov    0x8(%ebp),%edi
  80113c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80113f:	8b 45 10             	mov    0x10(%ebp),%eax
  801142:	85 c0                	test   %eax,%eax
  801144:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801149:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80114c:	eb 1c                	jmp    80116a <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80114e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801151:	74 12                	je     801165 <ipc_send+0x35>
  801153:	50                   	push   %eax
  801154:	68 f0 2a 80 00       	push   $0x802af0
  801159:	6a 3b                	push   $0x3b
  80115b:	68 06 2b 80 00       	push   $0x802b06
  801160:	e8 a9 11 00 00       	call   80230e <_panic>
		sys_yield();
  801165:	e8 6f fa ff ff       	call   800bd9 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80116a:	ff 75 14             	pushl  0x14(%ebp)
  80116d:	53                   	push   %ebx
  80116e:	56                   	push   %esi
  80116f:	57                   	push   %edi
  801170:	e8 10 fc ff ff       	call   800d85 <sys_ipc_try_send>
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	85 c0                	test   %eax,%eax
  80117a:	78 d2                	js     80114e <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80118a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80118f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801192:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801198:	8b 52 50             	mov    0x50(%edx),%edx
  80119b:	39 ca                	cmp    %ecx,%edx
  80119d:	75 0d                	jne    8011ac <ipc_find_env+0x28>
			return envs[i].env_id;
  80119f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a7:	8b 40 48             	mov    0x48(%eax),%eax
  8011aa:	eb 0f                	jmp    8011bb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011ac:	83 c0 01             	add    $0x1,%eax
  8011af:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011b4:	75 d9                	jne    80118f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c8:	c1 e8 0c             	shr    $0xc,%eax
}
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011dd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ea:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	c1 ea 16             	shr    $0x16,%edx
  8011f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fb:	f6 c2 01             	test   $0x1,%dl
  8011fe:	74 11                	je     801211 <fd_alloc+0x2d>
  801200:	89 c2                	mov    %eax,%edx
  801202:	c1 ea 0c             	shr    $0xc,%edx
  801205:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120c:	f6 c2 01             	test   $0x1,%dl
  80120f:	75 09                	jne    80121a <fd_alloc+0x36>
			*fd_store = fd;
  801211:	89 01                	mov    %eax,(%ecx)
			return 0;
  801213:	b8 00 00 00 00       	mov    $0x0,%eax
  801218:	eb 17                	jmp    801231 <fd_alloc+0x4d>
  80121a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80121f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801224:	75 c9                	jne    8011ef <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801226:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80122c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801239:	83 f8 1f             	cmp    $0x1f,%eax
  80123c:	77 36                	ja     801274 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80123e:	c1 e0 0c             	shl    $0xc,%eax
  801241:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801246:	89 c2                	mov    %eax,%edx
  801248:	c1 ea 16             	shr    $0x16,%edx
  80124b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801252:	f6 c2 01             	test   $0x1,%dl
  801255:	74 24                	je     80127b <fd_lookup+0x48>
  801257:	89 c2                	mov    %eax,%edx
  801259:	c1 ea 0c             	shr    $0xc,%edx
  80125c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801263:	f6 c2 01             	test   $0x1,%dl
  801266:	74 1a                	je     801282 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801268:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126b:	89 02                	mov    %eax,(%edx)
	return 0;
  80126d:	b8 00 00 00 00       	mov    $0x0,%eax
  801272:	eb 13                	jmp    801287 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801274:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801279:	eb 0c                	jmp    801287 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801280:	eb 05                	jmp    801287 <fd_lookup+0x54>
  801282:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 08             	sub    $0x8,%esp
  80128f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801292:	ba 8c 2b 80 00       	mov    $0x802b8c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801297:	eb 13                	jmp    8012ac <dev_lookup+0x23>
  801299:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80129c:	39 08                	cmp    %ecx,(%eax)
  80129e:	75 0c                	jne    8012ac <dev_lookup+0x23>
			*dev = devtab[i];
  8012a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012aa:	eb 2e                	jmp    8012da <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ac:	8b 02                	mov    (%edx),%eax
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	75 e7                	jne    801299 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b2:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012b7:	8b 40 48             	mov    0x48(%eax),%eax
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	51                   	push   %ecx
  8012be:	50                   	push   %eax
  8012bf:	68 10 2b 80 00       	push   $0x802b10
  8012c4:	e8 28 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  8012c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012da:	c9                   	leave  
  8012db:	c3                   	ret    

008012dc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	56                   	push   %esi
  8012e0:	53                   	push   %ebx
  8012e1:	83 ec 10             	sub    $0x10,%esp
  8012e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012f4:	c1 e8 0c             	shr    $0xc,%eax
  8012f7:	50                   	push   %eax
  8012f8:	e8 36 ff ff ff       	call   801233 <fd_lookup>
  8012fd:	83 c4 08             	add    $0x8,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 05                	js     801309 <fd_close+0x2d>
	    || fd != fd2)
  801304:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801307:	74 0c                	je     801315 <fd_close+0x39>
		return (must_exist ? r : 0);
  801309:	84 db                	test   %bl,%bl
  80130b:	ba 00 00 00 00       	mov    $0x0,%edx
  801310:	0f 44 c2             	cmove  %edx,%eax
  801313:	eb 41                	jmp    801356 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	ff 36                	pushl  (%esi)
  80131e:	e8 66 ff ff ff       	call   801289 <dev_lookup>
  801323:	89 c3                	mov    %eax,%ebx
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 1a                	js     801346 <fd_close+0x6a>
		if (dev->dev_close)
  80132c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801332:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801337:	85 c0                	test   %eax,%eax
  801339:	74 0b                	je     801346 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	56                   	push   %esi
  80133f:	ff d0                	call   *%eax
  801341:	89 c3                	mov    %eax,%ebx
  801343:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	56                   	push   %esi
  80134a:	6a 00                	push   $0x0
  80134c:	e8 2c f9 ff ff       	call   800c7d <sys_page_unmap>
	return r;
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	89 d8                	mov    %ebx,%eax
}
  801356:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801359:	5b                   	pop    %ebx
  80135a:	5e                   	pop    %esi
  80135b:	5d                   	pop    %ebp
  80135c:	c3                   	ret    

0080135d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801363:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801366:	50                   	push   %eax
  801367:	ff 75 08             	pushl  0x8(%ebp)
  80136a:	e8 c4 fe ff ff       	call   801233 <fd_lookup>
  80136f:	83 c4 08             	add    $0x8,%esp
  801372:	85 c0                	test   %eax,%eax
  801374:	78 10                	js     801386 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	6a 01                	push   $0x1
  80137b:	ff 75 f4             	pushl  -0xc(%ebp)
  80137e:	e8 59 ff ff ff       	call   8012dc <fd_close>
  801383:	83 c4 10             	add    $0x10,%esp
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <close_all>:

void
close_all(void)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	53                   	push   %ebx
  80138c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80138f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801394:	83 ec 0c             	sub    $0xc,%esp
  801397:	53                   	push   %ebx
  801398:	e8 c0 ff ff ff       	call   80135d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80139d:	83 c3 01             	add    $0x1,%ebx
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	83 fb 20             	cmp    $0x20,%ebx
  8013a6:	75 ec                	jne    801394 <close_all+0xc>
		close(i);
}
  8013a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ab:	c9                   	leave  
  8013ac:	c3                   	ret    

008013ad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	57                   	push   %edi
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 2c             	sub    $0x2c,%esp
  8013b6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	ff 75 08             	pushl  0x8(%ebp)
  8013c0:	e8 6e fe ff ff       	call   801233 <fd_lookup>
  8013c5:	83 c4 08             	add    $0x8,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	0f 88 c1 00 00 00    	js     801491 <dup+0xe4>
		return r;
	close(newfdnum);
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	56                   	push   %esi
  8013d4:	e8 84 ff ff ff       	call   80135d <close>

	newfd = INDEX2FD(newfdnum);
  8013d9:	89 f3                	mov    %esi,%ebx
  8013db:	c1 e3 0c             	shl    $0xc,%ebx
  8013de:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013e4:	83 c4 04             	add    $0x4,%esp
  8013e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ea:	e8 de fd ff ff       	call   8011cd <fd2data>
  8013ef:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013f1:	89 1c 24             	mov    %ebx,(%esp)
  8013f4:	e8 d4 fd ff ff       	call   8011cd <fd2data>
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013ff:	89 f8                	mov    %edi,%eax
  801401:	c1 e8 16             	shr    $0x16,%eax
  801404:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80140b:	a8 01                	test   $0x1,%al
  80140d:	74 37                	je     801446 <dup+0x99>
  80140f:	89 f8                	mov    %edi,%eax
  801411:	c1 e8 0c             	shr    $0xc,%eax
  801414:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80141b:	f6 c2 01             	test   $0x1,%dl
  80141e:	74 26                	je     801446 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801420:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	25 07 0e 00 00       	and    $0xe07,%eax
  80142f:	50                   	push   %eax
  801430:	ff 75 d4             	pushl  -0x2c(%ebp)
  801433:	6a 00                	push   $0x0
  801435:	57                   	push   %edi
  801436:	6a 00                	push   $0x0
  801438:	e8 fe f7 ff ff       	call   800c3b <sys_page_map>
  80143d:	89 c7                	mov    %eax,%edi
  80143f:	83 c4 20             	add    $0x20,%esp
  801442:	85 c0                	test   %eax,%eax
  801444:	78 2e                	js     801474 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801446:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801449:	89 d0                	mov    %edx,%eax
  80144b:	c1 e8 0c             	shr    $0xc,%eax
  80144e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	25 07 0e 00 00       	and    $0xe07,%eax
  80145d:	50                   	push   %eax
  80145e:	53                   	push   %ebx
  80145f:	6a 00                	push   $0x0
  801461:	52                   	push   %edx
  801462:	6a 00                	push   $0x0
  801464:	e8 d2 f7 ff ff       	call   800c3b <sys_page_map>
  801469:	89 c7                	mov    %eax,%edi
  80146b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80146e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801470:	85 ff                	test   %edi,%edi
  801472:	79 1d                	jns    801491 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	53                   	push   %ebx
  801478:	6a 00                	push   $0x0
  80147a:	e8 fe f7 ff ff       	call   800c7d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147f:	83 c4 08             	add    $0x8,%esp
  801482:	ff 75 d4             	pushl  -0x2c(%ebp)
  801485:	6a 00                	push   $0x0
  801487:	e8 f1 f7 ff ff       	call   800c7d <sys_page_unmap>
	return r;
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	89 f8                	mov    %edi,%eax
}
  801491:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801494:	5b                   	pop    %ebx
  801495:	5e                   	pop    %esi
  801496:	5f                   	pop    %edi
  801497:	5d                   	pop    %ebp
  801498:	c3                   	ret    

00801499 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	53                   	push   %ebx
  80149d:	83 ec 14             	sub    $0x14,%esp
  8014a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a6:	50                   	push   %eax
  8014a7:	53                   	push   %ebx
  8014a8:	e8 86 fd ff ff       	call   801233 <fd_lookup>
  8014ad:	83 c4 08             	add    $0x8,%esp
  8014b0:	89 c2                	mov    %eax,%edx
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 6d                	js     801523 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c0:	ff 30                	pushl  (%eax)
  8014c2:	e8 c2 fd ff ff       	call   801289 <dev_lookup>
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 4c                	js     80151a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d1:	8b 42 08             	mov    0x8(%edx),%eax
  8014d4:	83 e0 03             	and    $0x3,%eax
  8014d7:	83 f8 01             	cmp    $0x1,%eax
  8014da:	75 21                	jne    8014fd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014dc:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014e1:	8b 40 48             	mov    0x48(%eax),%eax
  8014e4:	83 ec 04             	sub    $0x4,%esp
  8014e7:	53                   	push   %ebx
  8014e8:	50                   	push   %eax
  8014e9:	68 51 2b 80 00       	push   $0x802b51
  8014ee:	e8 fe ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fb:	eb 26                	jmp    801523 <read+0x8a>
	}
	if (!dev->dev_read)
  8014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801500:	8b 40 08             	mov    0x8(%eax),%eax
  801503:	85 c0                	test   %eax,%eax
  801505:	74 17                	je     80151e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	ff 75 10             	pushl  0x10(%ebp)
  80150d:	ff 75 0c             	pushl  0xc(%ebp)
  801510:	52                   	push   %edx
  801511:	ff d0                	call   *%eax
  801513:	89 c2                	mov    %eax,%edx
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	eb 09                	jmp    801523 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	eb 05                	jmp    801523 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80151e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801523:	89 d0                	mov    %edx,%eax
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	57                   	push   %edi
  80152e:	56                   	push   %esi
  80152f:	53                   	push   %ebx
  801530:	83 ec 0c             	sub    $0xc,%esp
  801533:	8b 7d 08             	mov    0x8(%ebp),%edi
  801536:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801539:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153e:	eb 21                	jmp    801561 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801540:	83 ec 04             	sub    $0x4,%esp
  801543:	89 f0                	mov    %esi,%eax
  801545:	29 d8                	sub    %ebx,%eax
  801547:	50                   	push   %eax
  801548:	89 d8                	mov    %ebx,%eax
  80154a:	03 45 0c             	add    0xc(%ebp),%eax
  80154d:	50                   	push   %eax
  80154e:	57                   	push   %edi
  80154f:	e8 45 ff ff ff       	call   801499 <read>
		if (m < 0)
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 10                	js     80156b <readn+0x41>
			return m;
		if (m == 0)
  80155b:	85 c0                	test   %eax,%eax
  80155d:	74 0a                	je     801569 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155f:	01 c3                	add    %eax,%ebx
  801561:	39 f3                	cmp    %esi,%ebx
  801563:	72 db                	jb     801540 <readn+0x16>
  801565:	89 d8                	mov    %ebx,%eax
  801567:	eb 02                	jmp    80156b <readn+0x41>
  801569:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80156b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    

00801573 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	53                   	push   %ebx
  801577:	83 ec 14             	sub    $0x14,%esp
  80157a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	53                   	push   %ebx
  801582:	e8 ac fc ff ff       	call   801233 <fd_lookup>
  801587:	83 c4 08             	add    $0x8,%esp
  80158a:	89 c2                	mov    %eax,%edx
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 68                	js     8015f8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801590:	83 ec 08             	sub    $0x8,%esp
  801593:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801596:	50                   	push   %eax
  801597:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159a:	ff 30                	pushl  (%eax)
  80159c:	e8 e8 fc ff ff       	call   801289 <dev_lookup>
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 47                	js     8015ef <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015af:	75 21                	jne    8015d2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8015b6:	8b 40 48             	mov    0x48(%eax),%eax
  8015b9:	83 ec 04             	sub    $0x4,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	50                   	push   %eax
  8015be:	68 6d 2b 80 00       	push   $0x802b6d
  8015c3:	e8 29 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d0:	eb 26                	jmp    8015f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d8:	85 d2                	test   %edx,%edx
  8015da:	74 17                	je     8015f3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015dc:	83 ec 04             	sub    $0x4,%esp
  8015df:	ff 75 10             	pushl  0x10(%ebp)
  8015e2:	ff 75 0c             	pushl  0xc(%ebp)
  8015e5:	50                   	push   %eax
  8015e6:	ff d2                	call   *%edx
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	eb 09                	jmp    8015f8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	eb 05                	jmp    8015f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015f8:	89 d0                	mov    %edx,%eax
  8015fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801605:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801608:	50                   	push   %eax
  801609:	ff 75 08             	pushl  0x8(%ebp)
  80160c:	e8 22 fc ff ff       	call   801233 <fd_lookup>
  801611:	83 c4 08             	add    $0x8,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	78 0e                	js     801626 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801618:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80161b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801621:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801626:	c9                   	leave  
  801627:	c3                   	ret    

00801628 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	53                   	push   %ebx
  80162c:	83 ec 14             	sub    $0x14,%esp
  80162f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801632:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	53                   	push   %ebx
  801637:	e8 f7 fb ff ff       	call   801233 <fd_lookup>
  80163c:	83 c4 08             	add    $0x8,%esp
  80163f:	89 c2                	mov    %eax,%edx
  801641:	85 c0                	test   %eax,%eax
  801643:	78 65                	js     8016aa <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164f:	ff 30                	pushl  (%eax)
  801651:	e8 33 fc ff ff       	call   801289 <dev_lookup>
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 44                	js     8016a1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801660:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801664:	75 21                	jne    801687 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801666:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80166b:	8b 40 48             	mov    0x48(%eax),%eax
  80166e:	83 ec 04             	sub    $0x4,%esp
  801671:	53                   	push   %ebx
  801672:	50                   	push   %eax
  801673:	68 30 2b 80 00       	push   $0x802b30
  801678:	e8 74 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801685:	eb 23                	jmp    8016aa <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801687:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168a:	8b 52 18             	mov    0x18(%edx),%edx
  80168d:	85 d2                	test   %edx,%edx
  80168f:	74 14                	je     8016a5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801691:	83 ec 08             	sub    $0x8,%esp
  801694:	ff 75 0c             	pushl  0xc(%ebp)
  801697:	50                   	push   %eax
  801698:	ff d2                	call   *%edx
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	eb 09                	jmp    8016aa <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a1:	89 c2                	mov    %eax,%edx
  8016a3:	eb 05                	jmp    8016aa <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016aa:	89 d0                	mov    %edx,%eax
  8016ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    

008016b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	53                   	push   %ebx
  8016b5:	83 ec 14             	sub    $0x14,%esp
  8016b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016be:	50                   	push   %eax
  8016bf:	ff 75 08             	pushl  0x8(%ebp)
  8016c2:	e8 6c fb ff ff       	call   801233 <fd_lookup>
  8016c7:	83 c4 08             	add    $0x8,%esp
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 58                	js     801728 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d0:	83 ec 08             	sub    $0x8,%esp
  8016d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d6:	50                   	push   %eax
  8016d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016da:	ff 30                	pushl  (%eax)
  8016dc:	e8 a8 fb ff ff       	call   801289 <dev_lookup>
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 37                	js     80171f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016eb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ef:	74 32                	je     801723 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016fb:	00 00 00 
	stat->st_isdir = 0;
  8016fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801705:	00 00 00 
	stat->st_dev = dev;
  801708:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80170e:	83 ec 08             	sub    $0x8,%esp
  801711:	53                   	push   %ebx
  801712:	ff 75 f0             	pushl  -0x10(%ebp)
  801715:	ff 50 14             	call   *0x14(%eax)
  801718:	89 c2                	mov    %eax,%edx
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	eb 09                	jmp    801728 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171f:	89 c2                	mov    %eax,%edx
  801721:	eb 05                	jmp    801728 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801723:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801728:	89 d0                	mov    %edx,%eax
  80172a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	56                   	push   %esi
  801733:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801734:	83 ec 08             	sub    $0x8,%esp
  801737:	6a 00                	push   $0x0
  801739:	ff 75 08             	pushl  0x8(%ebp)
  80173c:	e8 e3 01 00 00       	call   801924 <open>
  801741:	89 c3                	mov    %eax,%ebx
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	85 c0                	test   %eax,%eax
  801748:	78 1b                	js     801765 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	ff 75 0c             	pushl  0xc(%ebp)
  801750:	50                   	push   %eax
  801751:	e8 5b ff ff ff       	call   8016b1 <fstat>
  801756:	89 c6                	mov    %eax,%esi
	close(fd);
  801758:	89 1c 24             	mov    %ebx,(%esp)
  80175b:	e8 fd fb ff ff       	call   80135d <close>
	return r;
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	89 f0                	mov    %esi,%eax
}
  801765:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801768:	5b                   	pop    %ebx
  801769:	5e                   	pop    %esi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	89 c6                	mov    %eax,%esi
  801773:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801775:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80177c:	75 12                	jne    801790 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80177e:	83 ec 0c             	sub    $0xc,%esp
  801781:	6a 01                	push   $0x1
  801783:	e8 fc f9 ff ff       	call   801184 <ipc_find_env>
  801788:	a3 00 40 80 00       	mov    %eax,0x804000
  80178d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801790:	6a 07                	push   $0x7
  801792:	68 00 50 80 00       	push   $0x805000
  801797:	56                   	push   %esi
  801798:	ff 35 00 40 80 00    	pushl  0x804000
  80179e:	e8 8d f9 ff ff       	call   801130 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a3:	83 c4 0c             	add    $0xc,%esp
  8017a6:	6a 00                	push   $0x0
  8017a8:	53                   	push   %ebx
  8017a9:	6a 00                	push   $0x0
  8017ab:	e8 17 f9 ff ff       	call   8010c7 <ipc_recv>
}
  8017b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017da:	e8 8d ff ff ff       	call   80176c <fsipc>
}
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ed:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017fc:	e8 6b ff ff ff       	call   80176c <fsipc>
}
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	53                   	push   %ebx
  801807:	83 ec 04             	sub    $0x4,%esp
  80180a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	8b 40 0c             	mov    0xc(%eax),%eax
  801813:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801818:	ba 00 00 00 00       	mov    $0x0,%edx
  80181d:	b8 05 00 00 00       	mov    $0x5,%eax
  801822:	e8 45 ff ff ff       	call   80176c <fsipc>
  801827:	85 c0                	test   %eax,%eax
  801829:	78 2c                	js     801857 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	68 00 50 80 00       	push   $0x805000
  801833:	53                   	push   %ebx
  801834:	e8 bc ef ff ff       	call   8007f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801839:	a1 80 50 80 00       	mov    0x805080,%eax
  80183e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801844:	a1 84 50 80 00       	mov    0x805084,%eax
  801849:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	8b 45 10             	mov    0x10(%ebp),%eax
  801865:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80186a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80186f:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801872:	8b 55 08             	mov    0x8(%ebp),%edx
  801875:	8b 52 0c             	mov    0xc(%edx),%edx
  801878:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80187e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801883:	50                   	push   %eax
  801884:	ff 75 0c             	pushl  0xc(%ebp)
  801887:	68 08 50 80 00       	push   $0x805008
  80188c:	e8 f6 f0 ff ff       	call   800987 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801891:	ba 00 00 00 00       	mov    $0x0,%edx
  801896:	b8 04 00 00 00       	mov    $0x4,%eax
  80189b:	e8 cc fe ff ff       	call   80176c <fsipc>
	//panic("devfile_write not implemented");
}
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	56                   	push   %esi
  8018a6:	53                   	push   %ebx
  8018a7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c5:	e8 a2 fe ff ff       	call   80176c <fsipc>
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 4b                	js     80191b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018d0:	39 c6                	cmp    %eax,%esi
  8018d2:	73 16                	jae    8018ea <devfile_read+0x48>
  8018d4:	68 a0 2b 80 00       	push   $0x802ba0
  8018d9:	68 a7 2b 80 00       	push   $0x802ba7
  8018de:	6a 7c                	push   $0x7c
  8018e0:	68 bc 2b 80 00       	push   $0x802bbc
  8018e5:	e8 24 0a 00 00       	call   80230e <_panic>
	assert(r <= PGSIZE);
  8018ea:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ef:	7e 16                	jle    801907 <devfile_read+0x65>
  8018f1:	68 c7 2b 80 00       	push   $0x802bc7
  8018f6:	68 a7 2b 80 00       	push   $0x802ba7
  8018fb:	6a 7d                	push   $0x7d
  8018fd:	68 bc 2b 80 00       	push   $0x802bbc
  801902:	e8 07 0a 00 00       	call   80230e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801907:	83 ec 04             	sub    $0x4,%esp
  80190a:	50                   	push   %eax
  80190b:	68 00 50 80 00       	push   $0x805000
  801910:	ff 75 0c             	pushl  0xc(%ebp)
  801913:	e8 6f f0 ff ff       	call   800987 <memmove>
	return r;
  801918:	83 c4 10             	add    $0x10,%esp
}
  80191b:	89 d8                	mov    %ebx,%eax
  80191d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801920:	5b                   	pop    %ebx
  801921:	5e                   	pop    %esi
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    

00801924 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	53                   	push   %ebx
  801928:	83 ec 20             	sub    $0x20,%esp
  80192b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80192e:	53                   	push   %ebx
  80192f:	e8 88 ee ff ff       	call   8007bc <strlen>
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80193c:	7f 67                	jg     8019a5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80193e:	83 ec 0c             	sub    $0xc,%esp
  801941:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801944:	50                   	push   %eax
  801945:	e8 9a f8 ff ff       	call   8011e4 <fd_alloc>
  80194a:	83 c4 10             	add    $0x10,%esp
		return r;
  80194d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 57                	js     8019aa <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801953:	83 ec 08             	sub    $0x8,%esp
  801956:	53                   	push   %ebx
  801957:	68 00 50 80 00       	push   $0x805000
  80195c:	e8 94 ee ff ff       	call   8007f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801961:	8b 45 0c             	mov    0xc(%ebp),%eax
  801964:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801969:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196c:	b8 01 00 00 00       	mov    $0x1,%eax
  801971:	e8 f6 fd ff ff       	call   80176c <fsipc>
  801976:	89 c3                	mov    %eax,%ebx
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	85 c0                	test   %eax,%eax
  80197d:	79 14                	jns    801993 <open+0x6f>
		fd_close(fd, 0);
  80197f:	83 ec 08             	sub    $0x8,%esp
  801982:	6a 00                	push   $0x0
  801984:	ff 75 f4             	pushl  -0xc(%ebp)
  801987:	e8 50 f9 ff ff       	call   8012dc <fd_close>
		return r;
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	89 da                	mov    %ebx,%edx
  801991:	eb 17                	jmp    8019aa <open+0x86>
	}

	return fd2num(fd);
  801993:	83 ec 0c             	sub    $0xc,%esp
  801996:	ff 75 f4             	pushl  -0xc(%ebp)
  801999:	e8 1f f8 ff ff       	call   8011bd <fd2num>
  80199e:	89 c2                	mov    %eax,%edx
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	eb 05                	jmp    8019aa <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019a5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019aa:	89 d0                	mov    %edx,%eax
  8019ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bc:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c1:	e8 a6 fd ff ff       	call   80176c <fsipc>
}
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    

008019c8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019ce:	68 d3 2b 80 00       	push   $0x802bd3
  8019d3:	ff 75 0c             	pushl  0xc(%ebp)
  8019d6:	e8 1a ee ff ff       	call   8007f5 <strcpy>
	return 0;
}
  8019db:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e0:	c9                   	leave  
  8019e1:	c3                   	ret    

008019e2 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	53                   	push   %ebx
  8019e6:	83 ec 10             	sub    $0x10,%esp
  8019e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019ec:	53                   	push   %ebx
  8019ed:	e8 e9 09 00 00       	call   8023db <pageref>
  8019f2:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019f5:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019fa:	83 f8 01             	cmp    $0x1,%eax
  8019fd:	75 10                	jne    801a0f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019ff:	83 ec 0c             	sub    $0xc,%esp
  801a02:	ff 73 0c             	pushl  0xc(%ebx)
  801a05:	e8 c0 02 00 00       	call   801cca <nsipc_close>
  801a0a:	89 c2                	mov    %eax,%edx
  801a0c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a0f:	89 d0                	mov    %edx,%eax
  801a11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a1c:	6a 00                	push   $0x0
  801a1e:	ff 75 10             	pushl  0x10(%ebp)
  801a21:	ff 75 0c             	pushl  0xc(%ebp)
  801a24:	8b 45 08             	mov    0x8(%ebp),%eax
  801a27:	ff 70 0c             	pushl  0xc(%eax)
  801a2a:	e8 78 03 00 00       	call   801da7 <nsipc_send>
}
  801a2f:	c9                   	leave  
  801a30:	c3                   	ret    

00801a31 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a37:	6a 00                	push   $0x0
  801a39:	ff 75 10             	pushl  0x10(%ebp)
  801a3c:	ff 75 0c             	pushl  0xc(%ebp)
  801a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a42:	ff 70 0c             	pushl  0xc(%eax)
  801a45:	e8 f1 02 00 00       	call   801d3b <nsipc_recv>
}
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a52:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a55:	52                   	push   %edx
  801a56:	50                   	push   %eax
  801a57:	e8 d7 f7 ff ff       	call   801233 <fd_lookup>
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	78 17                	js     801a7a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a66:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a6c:	39 08                	cmp    %ecx,(%eax)
  801a6e:	75 05                	jne    801a75 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a70:	8b 40 0c             	mov    0xc(%eax),%eax
  801a73:	eb 05                	jmp    801a7a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a75:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a7a:	c9                   	leave  
  801a7b:	c3                   	ret    

00801a7c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	56                   	push   %esi
  801a80:	53                   	push   %ebx
  801a81:	83 ec 1c             	sub    $0x1c,%esp
  801a84:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a89:	50                   	push   %eax
  801a8a:	e8 55 f7 ff ff       	call   8011e4 <fd_alloc>
  801a8f:	89 c3                	mov    %eax,%ebx
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	85 c0                	test   %eax,%eax
  801a96:	78 1b                	js     801ab3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a98:	83 ec 04             	sub    $0x4,%esp
  801a9b:	68 07 04 00 00       	push   $0x407
  801aa0:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa3:	6a 00                	push   $0x0
  801aa5:	e8 4e f1 ff ff       	call   800bf8 <sys_page_alloc>
  801aaa:	89 c3                	mov    %eax,%ebx
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	79 10                	jns    801ac3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ab3:	83 ec 0c             	sub    $0xc,%esp
  801ab6:	56                   	push   %esi
  801ab7:	e8 0e 02 00 00       	call   801cca <nsipc_close>
		return r;
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	89 d8                	mov    %ebx,%eax
  801ac1:	eb 24                	jmp    801ae7 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ac3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ad8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801adb:	83 ec 0c             	sub    $0xc,%esp
  801ade:	50                   	push   %eax
  801adf:	e8 d9 f6 ff ff       	call   8011bd <fd2num>
  801ae4:	83 c4 10             	add    $0x10,%esp
}
  801ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af4:	8b 45 08             	mov    0x8(%ebp),%eax
  801af7:	e8 50 ff ff ff       	call   801a4c <fd2sockid>
		return r;
  801afc:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 1f                	js     801b21 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b02:	83 ec 04             	sub    $0x4,%esp
  801b05:	ff 75 10             	pushl  0x10(%ebp)
  801b08:	ff 75 0c             	pushl  0xc(%ebp)
  801b0b:	50                   	push   %eax
  801b0c:	e8 12 01 00 00       	call   801c23 <nsipc_accept>
  801b11:	83 c4 10             	add    $0x10,%esp
		return r;
  801b14:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b16:	85 c0                	test   %eax,%eax
  801b18:	78 07                	js     801b21 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b1a:	e8 5d ff ff ff       	call   801a7c <alloc_sockfd>
  801b1f:	89 c1                	mov    %eax,%ecx
}
  801b21:	89 c8                	mov    %ecx,%eax
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	e8 19 ff ff ff       	call   801a4c <fd2sockid>
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 12                	js     801b49 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b37:	83 ec 04             	sub    $0x4,%esp
  801b3a:	ff 75 10             	pushl  0x10(%ebp)
  801b3d:	ff 75 0c             	pushl  0xc(%ebp)
  801b40:	50                   	push   %eax
  801b41:	e8 2d 01 00 00       	call   801c73 <nsipc_bind>
  801b46:	83 c4 10             	add    $0x10,%esp
}
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <shutdown>:

int
shutdown(int s, int how)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b51:	8b 45 08             	mov    0x8(%ebp),%eax
  801b54:	e8 f3 fe ff ff       	call   801a4c <fd2sockid>
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	78 0f                	js     801b6c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b5d:	83 ec 08             	sub    $0x8,%esp
  801b60:	ff 75 0c             	pushl  0xc(%ebp)
  801b63:	50                   	push   %eax
  801b64:	e8 3f 01 00 00       	call   801ca8 <nsipc_shutdown>
  801b69:	83 c4 10             	add    $0x10,%esp
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b74:	8b 45 08             	mov    0x8(%ebp),%eax
  801b77:	e8 d0 fe ff ff       	call   801a4c <fd2sockid>
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	78 12                	js     801b92 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b80:	83 ec 04             	sub    $0x4,%esp
  801b83:	ff 75 10             	pushl  0x10(%ebp)
  801b86:	ff 75 0c             	pushl  0xc(%ebp)
  801b89:	50                   	push   %eax
  801b8a:	e8 55 01 00 00       	call   801ce4 <nsipc_connect>
  801b8f:	83 c4 10             	add    $0x10,%esp
}
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <listen>:

int
listen(int s, int backlog)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9d:	e8 aa fe ff ff       	call   801a4c <fd2sockid>
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	78 0f                	js     801bb5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ba6:	83 ec 08             	sub    $0x8,%esp
  801ba9:	ff 75 0c             	pushl  0xc(%ebp)
  801bac:	50                   	push   %eax
  801bad:	e8 67 01 00 00       	call   801d19 <nsipc_listen>
  801bb2:	83 c4 10             	add    $0x10,%esp
}
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bbd:	ff 75 10             	pushl  0x10(%ebp)
  801bc0:	ff 75 0c             	pushl  0xc(%ebp)
  801bc3:	ff 75 08             	pushl  0x8(%ebp)
  801bc6:	e8 3a 02 00 00       	call   801e05 <nsipc_socket>
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	78 05                	js     801bd7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bd2:	e8 a5 fe ff ff       	call   801a7c <alloc_sockfd>
}
  801bd7:	c9                   	leave  
  801bd8:	c3                   	ret    

00801bd9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	53                   	push   %ebx
  801bdd:	83 ec 04             	sub    $0x4,%esp
  801be0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801be2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801be9:	75 12                	jne    801bfd <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	6a 02                	push   $0x2
  801bf0:	e8 8f f5 ff ff       	call   801184 <ipc_find_env>
  801bf5:	a3 04 40 80 00       	mov    %eax,0x804004
  801bfa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bfd:	6a 07                	push   $0x7
  801bff:	68 00 60 80 00       	push   $0x806000
  801c04:	53                   	push   %ebx
  801c05:	ff 35 04 40 80 00    	pushl  0x804004
  801c0b:	e8 20 f5 ff ff       	call   801130 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c10:	83 c4 0c             	add    $0xc,%esp
  801c13:	6a 00                	push   $0x0
  801c15:	6a 00                	push   $0x0
  801c17:	6a 00                	push   $0x0
  801c19:	e8 a9 f4 ff ff       	call   8010c7 <ipc_recv>
}
  801c1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c21:	c9                   	leave  
  801c22:	c3                   	ret    

00801c23 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	56                   	push   %esi
  801c27:	53                   	push   %ebx
  801c28:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c33:	8b 06                	mov    (%esi),%eax
  801c35:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c3a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3f:	e8 95 ff ff ff       	call   801bd9 <nsipc>
  801c44:	89 c3                	mov    %eax,%ebx
  801c46:	85 c0                	test   %eax,%eax
  801c48:	78 20                	js     801c6a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c4a:	83 ec 04             	sub    $0x4,%esp
  801c4d:	ff 35 10 60 80 00    	pushl  0x806010
  801c53:	68 00 60 80 00       	push   $0x806000
  801c58:	ff 75 0c             	pushl  0xc(%ebp)
  801c5b:	e8 27 ed ff ff       	call   800987 <memmove>
		*addrlen = ret->ret_addrlen;
  801c60:	a1 10 60 80 00       	mov    0x806010,%eax
  801c65:	89 06                	mov    %eax,(%esi)
  801c67:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c6a:	89 d8                	mov    %ebx,%eax
  801c6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6f:	5b                   	pop    %ebx
  801c70:	5e                   	pop    %esi
  801c71:	5d                   	pop    %ebp
  801c72:	c3                   	ret    

00801c73 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	53                   	push   %ebx
  801c77:	83 ec 08             	sub    $0x8,%esp
  801c7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c85:	53                   	push   %ebx
  801c86:	ff 75 0c             	pushl  0xc(%ebp)
  801c89:	68 04 60 80 00       	push   $0x806004
  801c8e:	e8 f4 ec ff ff       	call   800987 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c93:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c99:	b8 02 00 00 00       	mov    $0x2,%eax
  801c9e:	e8 36 ff ff ff       	call   801bd9 <nsipc>
}
  801ca3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cae:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cbe:	b8 03 00 00 00       	mov    $0x3,%eax
  801cc3:	e8 11 ff ff ff       	call   801bd9 <nsipc>
}
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <nsipc_close>:

int
nsipc_close(int s)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cd8:	b8 04 00 00 00       	mov    $0x4,%eax
  801cdd:	e8 f7 fe ff ff       	call   801bd9 <nsipc>
}
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    

00801ce4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 08             	sub    $0x8,%esp
  801ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cee:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cf6:	53                   	push   %ebx
  801cf7:	ff 75 0c             	pushl  0xc(%ebp)
  801cfa:	68 04 60 80 00       	push   $0x806004
  801cff:	e8 83 ec ff ff       	call   800987 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d04:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d0a:	b8 05 00 00 00       	mov    $0x5,%eax
  801d0f:	e8 c5 fe ff ff       	call   801bd9 <nsipc>
}
  801d14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d22:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d2f:	b8 06 00 00 00       	mov    $0x6,%eax
  801d34:	e8 a0 fe ff ff       	call   801bd9 <nsipc>
}
  801d39:	c9                   	leave  
  801d3a:	c3                   	ret    

00801d3b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	56                   	push   %esi
  801d3f:	53                   	push   %ebx
  801d40:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d43:	8b 45 08             	mov    0x8(%ebp),%eax
  801d46:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d4b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d51:	8b 45 14             	mov    0x14(%ebp),%eax
  801d54:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d59:	b8 07 00 00 00       	mov    $0x7,%eax
  801d5e:	e8 76 fe ff ff       	call   801bd9 <nsipc>
  801d63:	89 c3                	mov    %eax,%ebx
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 35                	js     801d9e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d69:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d6e:	7f 04                	jg     801d74 <nsipc_recv+0x39>
  801d70:	39 c6                	cmp    %eax,%esi
  801d72:	7d 16                	jge    801d8a <nsipc_recv+0x4f>
  801d74:	68 df 2b 80 00       	push   $0x802bdf
  801d79:	68 a7 2b 80 00       	push   $0x802ba7
  801d7e:	6a 62                	push   $0x62
  801d80:	68 f4 2b 80 00       	push   $0x802bf4
  801d85:	e8 84 05 00 00       	call   80230e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d8a:	83 ec 04             	sub    $0x4,%esp
  801d8d:	50                   	push   %eax
  801d8e:	68 00 60 80 00       	push   $0x806000
  801d93:	ff 75 0c             	pushl  0xc(%ebp)
  801d96:	e8 ec eb ff ff       	call   800987 <memmove>
  801d9b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d9e:	89 d8                	mov    %ebx,%eax
  801da0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	53                   	push   %ebx
  801dab:	83 ec 04             	sub    $0x4,%esp
  801dae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801db1:	8b 45 08             	mov    0x8(%ebp),%eax
  801db4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801db9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dbf:	7e 16                	jle    801dd7 <nsipc_send+0x30>
  801dc1:	68 00 2c 80 00       	push   $0x802c00
  801dc6:	68 a7 2b 80 00       	push   $0x802ba7
  801dcb:	6a 6d                	push   $0x6d
  801dcd:	68 f4 2b 80 00       	push   $0x802bf4
  801dd2:	e8 37 05 00 00       	call   80230e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dd7:	83 ec 04             	sub    $0x4,%esp
  801dda:	53                   	push   %ebx
  801ddb:	ff 75 0c             	pushl  0xc(%ebp)
  801dde:	68 0c 60 80 00       	push   $0x80600c
  801de3:	e8 9f eb ff ff       	call   800987 <memmove>
	nsipcbuf.send.req_size = size;
  801de8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801dee:	8b 45 14             	mov    0x14(%ebp),%eax
  801df1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801df6:	b8 08 00 00 00       	mov    $0x8,%eax
  801dfb:	e8 d9 fd ff ff       	call   801bd9 <nsipc>
}
  801e00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e03:	c9                   	leave  
  801e04:	c3                   	ret    

00801e05 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e16:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e1b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e1e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e23:	b8 09 00 00 00       	mov    $0x9,%eax
  801e28:	e8 ac fd ff ff       	call   801bd9 <nsipc>
}
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e37:	83 ec 0c             	sub    $0xc,%esp
  801e3a:	ff 75 08             	pushl  0x8(%ebp)
  801e3d:	e8 8b f3 ff ff       	call   8011cd <fd2data>
  801e42:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e44:	83 c4 08             	add    $0x8,%esp
  801e47:	68 0c 2c 80 00       	push   $0x802c0c
  801e4c:	53                   	push   %ebx
  801e4d:	e8 a3 e9 ff ff       	call   8007f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e52:	8b 46 04             	mov    0x4(%esi),%eax
  801e55:	2b 06                	sub    (%esi),%eax
  801e57:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e5d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e64:	00 00 00 
	stat->st_dev = &devpipe;
  801e67:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e6e:	30 80 00 
	return 0;
}
  801e71:	b8 00 00 00 00       	mov    $0x0,%eax
  801e76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e79:	5b                   	pop    %ebx
  801e7a:	5e                   	pop    %esi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    

00801e7d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	53                   	push   %ebx
  801e81:	83 ec 0c             	sub    $0xc,%esp
  801e84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e87:	53                   	push   %ebx
  801e88:	6a 00                	push   $0x0
  801e8a:	e8 ee ed ff ff       	call   800c7d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e8f:	89 1c 24             	mov    %ebx,(%esp)
  801e92:	e8 36 f3 ff ff       	call   8011cd <fd2data>
  801e97:	83 c4 08             	add    $0x8,%esp
  801e9a:	50                   	push   %eax
  801e9b:	6a 00                	push   $0x0
  801e9d:	e8 db ed ff ff       	call   800c7d <sys_page_unmap>
}
  801ea2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea5:	c9                   	leave  
  801ea6:	c3                   	ret    

00801ea7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	57                   	push   %edi
  801eab:	56                   	push   %esi
  801eac:	53                   	push   %ebx
  801ead:	83 ec 1c             	sub    $0x1c,%esp
  801eb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801eb3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801eb5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801eba:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ebd:	83 ec 0c             	sub    $0xc,%esp
  801ec0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ec3:	e8 13 05 00 00       	call   8023db <pageref>
  801ec8:	89 c3                	mov    %eax,%ebx
  801eca:	89 3c 24             	mov    %edi,(%esp)
  801ecd:	e8 09 05 00 00       	call   8023db <pageref>
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	39 c3                	cmp    %eax,%ebx
  801ed7:	0f 94 c1             	sete   %cl
  801eda:	0f b6 c9             	movzbl %cl,%ecx
  801edd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ee0:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801ee6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ee9:	39 ce                	cmp    %ecx,%esi
  801eeb:	74 1b                	je     801f08 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801eed:	39 c3                	cmp    %eax,%ebx
  801eef:	75 c4                	jne    801eb5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ef1:	8b 42 58             	mov    0x58(%edx),%eax
  801ef4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ef7:	50                   	push   %eax
  801ef8:	56                   	push   %esi
  801ef9:	68 13 2c 80 00       	push   $0x802c13
  801efe:	e8 ee e2 ff ff       	call   8001f1 <cprintf>
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	eb ad                	jmp    801eb5 <_pipeisclosed+0xe>
	}
}
  801f08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5e                   	pop    %esi
  801f10:	5f                   	pop    %edi
  801f11:	5d                   	pop    %ebp
  801f12:	c3                   	ret    

00801f13 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	57                   	push   %edi
  801f17:	56                   	push   %esi
  801f18:	53                   	push   %ebx
  801f19:	83 ec 28             	sub    $0x28,%esp
  801f1c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f1f:	56                   	push   %esi
  801f20:	e8 a8 f2 ff ff       	call   8011cd <fd2data>
  801f25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f27:	83 c4 10             	add    $0x10,%esp
  801f2a:	bf 00 00 00 00       	mov    $0x0,%edi
  801f2f:	eb 4b                	jmp    801f7c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f31:	89 da                	mov    %ebx,%edx
  801f33:	89 f0                	mov    %esi,%eax
  801f35:	e8 6d ff ff ff       	call   801ea7 <_pipeisclosed>
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	75 48                	jne    801f86 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f3e:	e8 96 ec ff ff       	call   800bd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f43:	8b 43 04             	mov    0x4(%ebx),%eax
  801f46:	8b 0b                	mov    (%ebx),%ecx
  801f48:	8d 51 20             	lea    0x20(%ecx),%edx
  801f4b:	39 d0                	cmp    %edx,%eax
  801f4d:	73 e2                	jae    801f31 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f52:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f56:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f59:	89 c2                	mov    %eax,%edx
  801f5b:	c1 fa 1f             	sar    $0x1f,%edx
  801f5e:	89 d1                	mov    %edx,%ecx
  801f60:	c1 e9 1b             	shr    $0x1b,%ecx
  801f63:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f66:	83 e2 1f             	and    $0x1f,%edx
  801f69:	29 ca                	sub    %ecx,%edx
  801f6b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f73:	83 c0 01             	add    $0x1,%eax
  801f76:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f79:	83 c7 01             	add    $0x1,%edi
  801f7c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f7f:	75 c2                	jne    801f43 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f81:	8b 45 10             	mov    0x10(%ebp),%eax
  801f84:	eb 05                	jmp    801f8b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8e:	5b                   	pop    %ebx
  801f8f:	5e                   	pop    %esi
  801f90:	5f                   	pop    %edi
  801f91:	5d                   	pop    %ebp
  801f92:	c3                   	ret    

00801f93 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	57                   	push   %edi
  801f97:	56                   	push   %esi
  801f98:	53                   	push   %ebx
  801f99:	83 ec 18             	sub    $0x18,%esp
  801f9c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f9f:	57                   	push   %edi
  801fa0:	e8 28 f2 ff ff       	call   8011cd <fd2data>
  801fa5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801faf:	eb 3d                	jmp    801fee <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fb1:	85 db                	test   %ebx,%ebx
  801fb3:	74 04                	je     801fb9 <devpipe_read+0x26>
				return i;
  801fb5:	89 d8                	mov    %ebx,%eax
  801fb7:	eb 44                	jmp    801ffd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fb9:	89 f2                	mov    %esi,%edx
  801fbb:	89 f8                	mov    %edi,%eax
  801fbd:	e8 e5 fe ff ff       	call   801ea7 <_pipeisclosed>
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	75 32                	jne    801ff8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fc6:	e8 0e ec ff ff       	call   800bd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fcb:	8b 06                	mov    (%esi),%eax
  801fcd:	3b 46 04             	cmp    0x4(%esi),%eax
  801fd0:	74 df                	je     801fb1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fd2:	99                   	cltd   
  801fd3:	c1 ea 1b             	shr    $0x1b,%edx
  801fd6:	01 d0                	add    %edx,%eax
  801fd8:	83 e0 1f             	and    $0x1f,%eax
  801fdb:	29 d0                	sub    %edx,%eax
  801fdd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fe5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fe8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801feb:	83 c3 01             	add    $0x1,%ebx
  801fee:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ff1:	75 d8                	jne    801fcb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ff3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff6:	eb 05                	jmp    801ffd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ff8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ffd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802000:	5b                   	pop    %ebx
  802001:	5e                   	pop    %esi
  802002:	5f                   	pop    %edi
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	56                   	push   %esi
  802009:	53                   	push   %ebx
  80200a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80200d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802010:	50                   	push   %eax
  802011:	e8 ce f1 ff ff       	call   8011e4 <fd_alloc>
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	89 c2                	mov    %eax,%edx
  80201b:	85 c0                	test   %eax,%eax
  80201d:	0f 88 2c 01 00 00    	js     80214f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802023:	83 ec 04             	sub    $0x4,%esp
  802026:	68 07 04 00 00       	push   $0x407
  80202b:	ff 75 f4             	pushl  -0xc(%ebp)
  80202e:	6a 00                	push   $0x0
  802030:	e8 c3 eb ff ff       	call   800bf8 <sys_page_alloc>
  802035:	83 c4 10             	add    $0x10,%esp
  802038:	89 c2                	mov    %eax,%edx
  80203a:	85 c0                	test   %eax,%eax
  80203c:	0f 88 0d 01 00 00    	js     80214f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802042:	83 ec 0c             	sub    $0xc,%esp
  802045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802048:	50                   	push   %eax
  802049:	e8 96 f1 ff ff       	call   8011e4 <fd_alloc>
  80204e:	89 c3                	mov    %eax,%ebx
  802050:	83 c4 10             	add    $0x10,%esp
  802053:	85 c0                	test   %eax,%eax
  802055:	0f 88 e2 00 00 00    	js     80213d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205b:	83 ec 04             	sub    $0x4,%esp
  80205e:	68 07 04 00 00       	push   $0x407
  802063:	ff 75 f0             	pushl  -0x10(%ebp)
  802066:	6a 00                	push   $0x0
  802068:	e8 8b eb ff ff       	call   800bf8 <sys_page_alloc>
  80206d:	89 c3                	mov    %eax,%ebx
  80206f:	83 c4 10             	add    $0x10,%esp
  802072:	85 c0                	test   %eax,%eax
  802074:	0f 88 c3 00 00 00    	js     80213d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80207a:	83 ec 0c             	sub    $0xc,%esp
  80207d:	ff 75 f4             	pushl  -0xc(%ebp)
  802080:	e8 48 f1 ff ff       	call   8011cd <fd2data>
  802085:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802087:	83 c4 0c             	add    $0xc,%esp
  80208a:	68 07 04 00 00       	push   $0x407
  80208f:	50                   	push   %eax
  802090:	6a 00                	push   $0x0
  802092:	e8 61 eb ff ff       	call   800bf8 <sys_page_alloc>
  802097:	89 c3                	mov    %eax,%ebx
  802099:	83 c4 10             	add    $0x10,%esp
  80209c:	85 c0                	test   %eax,%eax
  80209e:	0f 88 89 00 00 00    	js     80212d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a4:	83 ec 0c             	sub    $0xc,%esp
  8020a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8020aa:	e8 1e f1 ff ff       	call   8011cd <fd2data>
  8020af:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020b6:	50                   	push   %eax
  8020b7:	6a 00                	push   $0x0
  8020b9:	56                   	push   %esi
  8020ba:	6a 00                	push   $0x0
  8020bc:	e8 7a eb ff ff       	call   800c3b <sys_page_map>
  8020c1:	89 c3                	mov    %eax,%ebx
  8020c3:	83 c4 20             	add    $0x20,%esp
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	78 55                	js     80211f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020ca:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020df:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020e8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ed:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020f4:	83 ec 0c             	sub    $0xc,%esp
  8020f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020fa:	e8 be f0 ff ff       	call   8011bd <fd2num>
  8020ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802102:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802104:	83 c4 04             	add    $0x4,%esp
  802107:	ff 75 f0             	pushl  -0x10(%ebp)
  80210a:	e8 ae f0 ff ff       	call   8011bd <fd2num>
  80210f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802112:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802115:	83 c4 10             	add    $0x10,%esp
  802118:	ba 00 00 00 00       	mov    $0x0,%edx
  80211d:	eb 30                	jmp    80214f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80211f:	83 ec 08             	sub    $0x8,%esp
  802122:	56                   	push   %esi
  802123:	6a 00                	push   $0x0
  802125:	e8 53 eb ff ff       	call   800c7d <sys_page_unmap>
  80212a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80212d:	83 ec 08             	sub    $0x8,%esp
  802130:	ff 75 f0             	pushl  -0x10(%ebp)
  802133:	6a 00                	push   $0x0
  802135:	e8 43 eb ff ff       	call   800c7d <sys_page_unmap>
  80213a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80213d:	83 ec 08             	sub    $0x8,%esp
  802140:	ff 75 f4             	pushl  -0xc(%ebp)
  802143:	6a 00                	push   $0x0
  802145:	e8 33 eb ff ff       	call   800c7d <sys_page_unmap>
  80214a:	83 c4 10             	add    $0x10,%esp
  80214d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80214f:	89 d0                	mov    %edx,%eax
  802151:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    

00802158 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80215e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802161:	50                   	push   %eax
  802162:	ff 75 08             	pushl  0x8(%ebp)
  802165:	e8 c9 f0 ff ff       	call   801233 <fd_lookup>
  80216a:	83 c4 10             	add    $0x10,%esp
  80216d:	85 c0                	test   %eax,%eax
  80216f:	78 18                	js     802189 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802171:	83 ec 0c             	sub    $0xc,%esp
  802174:	ff 75 f4             	pushl  -0xc(%ebp)
  802177:	e8 51 f0 ff ff       	call   8011cd <fd2data>
	return _pipeisclosed(fd, p);
  80217c:	89 c2                	mov    %eax,%edx
  80217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802181:	e8 21 fd ff ff       	call   801ea7 <_pipeisclosed>
  802186:	83 c4 10             	add    $0x10,%esp
}
  802189:	c9                   	leave  
  80218a:	c3                   	ret    

0080218b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80218e:	b8 00 00 00 00       	mov    $0x0,%eax
  802193:	5d                   	pop    %ebp
  802194:	c3                   	ret    

00802195 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802195:	55                   	push   %ebp
  802196:	89 e5                	mov    %esp,%ebp
  802198:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80219b:	68 2b 2c 80 00       	push   $0x802c2b
  8021a0:	ff 75 0c             	pushl  0xc(%ebp)
  8021a3:	e8 4d e6 ff ff       	call   8007f5 <strcpy>
	return 0;
}
  8021a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ad:	c9                   	leave  
  8021ae:	c3                   	ret    

008021af <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	57                   	push   %edi
  8021b3:	56                   	push   %esi
  8021b4:	53                   	push   %ebx
  8021b5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021bb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021c0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021c6:	eb 2d                	jmp    8021f5 <devcons_write+0x46>
		m = n - tot;
  8021c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021cb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021cd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021d0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021d5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021d8:	83 ec 04             	sub    $0x4,%esp
  8021db:	53                   	push   %ebx
  8021dc:	03 45 0c             	add    0xc(%ebp),%eax
  8021df:	50                   	push   %eax
  8021e0:	57                   	push   %edi
  8021e1:	e8 a1 e7 ff ff       	call   800987 <memmove>
		sys_cputs(buf, m);
  8021e6:	83 c4 08             	add    $0x8,%esp
  8021e9:	53                   	push   %ebx
  8021ea:	57                   	push   %edi
  8021eb:	e8 4c e9 ff ff       	call   800b3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021f0:	01 de                	add    %ebx,%esi
  8021f2:	83 c4 10             	add    $0x10,%esp
  8021f5:	89 f0                	mov    %esi,%eax
  8021f7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021fa:	72 cc                	jb     8021c8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ff:	5b                   	pop    %ebx
  802200:	5e                   	pop    %esi
  802201:	5f                   	pop    %edi
  802202:	5d                   	pop    %ebp
  802203:	c3                   	ret    

00802204 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	83 ec 08             	sub    $0x8,%esp
  80220a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80220f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802213:	74 2a                	je     80223f <devcons_read+0x3b>
  802215:	eb 05                	jmp    80221c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802217:	e8 bd e9 ff ff       	call   800bd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80221c:	e8 39 e9 ff ff       	call   800b5a <sys_cgetc>
  802221:	85 c0                	test   %eax,%eax
  802223:	74 f2                	je     802217 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802225:	85 c0                	test   %eax,%eax
  802227:	78 16                	js     80223f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802229:	83 f8 04             	cmp    $0x4,%eax
  80222c:	74 0c                	je     80223a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80222e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802231:	88 02                	mov    %al,(%edx)
	return 1;
  802233:	b8 01 00 00 00       	mov    $0x1,%eax
  802238:	eb 05                	jmp    80223f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80223a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80223f:	c9                   	leave  
  802240:	c3                   	ret    

00802241 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  802241:	55                   	push   %ebp
  802242:	89 e5                	mov    %esp,%ebp
  802244:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802247:	8b 45 08             	mov    0x8(%ebp),%eax
  80224a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80224d:	6a 01                	push   $0x1
  80224f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802252:	50                   	push   %eax
  802253:	e8 e4 e8 ff ff       	call   800b3c <sys_cputs>
}
  802258:	83 c4 10             	add    $0x10,%esp
  80225b:	c9                   	leave  
  80225c:	c3                   	ret    

0080225d <getchar>:

int
getchar(void)
{
  80225d:	55                   	push   %ebp
  80225e:	89 e5                	mov    %esp,%ebp
  802260:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802263:	6a 01                	push   $0x1
  802265:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802268:	50                   	push   %eax
  802269:	6a 00                	push   $0x0
  80226b:	e8 29 f2 ff ff       	call   801499 <read>
	if (r < 0)
  802270:	83 c4 10             	add    $0x10,%esp
  802273:	85 c0                	test   %eax,%eax
  802275:	78 0f                	js     802286 <getchar+0x29>
		return r;
	if (r < 1)
  802277:	85 c0                	test   %eax,%eax
  802279:	7e 06                	jle    802281 <getchar+0x24>
		return -E_EOF;
	return c;
  80227b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80227f:	eb 05                	jmp    802286 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802281:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802286:	c9                   	leave  
  802287:	c3                   	ret    

00802288 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80228e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802291:	50                   	push   %eax
  802292:	ff 75 08             	pushl  0x8(%ebp)
  802295:	e8 99 ef ff ff       	call   801233 <fd_lookup>
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	85 c0                	test   %eax,%eax
  80229f:	78 11                	js     8022b2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022aa:	39 10                	cmp    %edx,(%eax)
  8022ac:	0f 94 c0             	sete   %al
  8022af:	0f b6 c0             	movzbl %al,%eax
}
  8022b2:	c9                   	leave  
  8022b3:	c3                   	ret    

008022b4 <opencons>:

int
opencons(void)
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022bd:	50                   	push   %eax
  8022be:	e8 21 ef ff ff       	call   8011e4 <fd_alloc>
  8022c3:	83 c4 10             	add    $0x10,%esp
		return r;
  8022c6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022c8:	85 c0                	test   %eax,%eax
  8022ca:	78 3e                	js     80230a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022cc:	83 ec 04             	sub    $0x4,%esp
  8022cf:	68 07 04 00 00       	push   $0x407
  8022d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8022d7:	6a 00                	push   $0x0
  8022d9:	e8 1a e9 ff ff       	call   800bf8 <sys_page_alloc>
  8022de:	83 c4 10             	add    $0x10,%esp
		return r;
  8022e1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022e3:	85 c0                	test   %eax,%eax
  8022e5:	78 23                	js     80230a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022e7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022fc:	83 ec 0c             	sub    $0xc,%esp
  8022ff:	50                   	push   %eax
  802300:	e8 b8 ee ff ff       	call   8011bd <fd2num>
  802305:	89 c2                	mov    %eax,%edx
  802307:	83 c4 10             	add    $0x10,%esp
}
  80230a:	89 d0                	mov    %edx,%eax
  80230c:	c9                   	leave  
  80230d:	c3                   	ret    

0080230e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80230e:	55                   	push   %ebp
  80230f:	89 e5                	mov    %esp,%ebp
  802311:	56                   	push   %esi
  802312:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802313:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802316:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80231c:	e8 99 e8 ff ff       	call   800bba <sys_getenvid>
  802321:	83 ec 0c             	sub    $0xc,%esp
  802324:	ff 75 0c             	pushl  0xc(%ebp)
  802327:	ff 75 08             	pushl  0x8(%ebp)
  80232a:	56                   	push   %esi
  80232b:	50                   	push   %eax
  80232c:	68 38 2c 80 00       	push   $0x802c38
  802331:	e8 bb de ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802336:	83 c4 18             	add    $0x18,%esp
  802339:	53                   	push   %ebx
  80233a:	ff 75 10             	pushl  0x10(%ebp)
  80233d:	e8 5e de ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  802342:	c7 04 24 24 2c 80 00 	movl   $0x802c24,(%esp)
  802349:	e8 a3 de ff ff       	call   8001f1 <cprintf>
  80234e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802351:	cc                   	int3   
  802352:	eb fd                	jmp    802351 <_panic+0x43>

00802354 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802354:	55                   	push   %ebp
  802355:	89 e5                	mov    %esp,%ebp
  802357:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80235a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802361:	75 4a                	jne    8023ad <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  802363:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802368:	8b 40 48             	mov    0x48(%eax),%eax
  80236b:	83 ec 04             	sub    $0x4,%esp
  80236e:	6a 07                	push   $0x7
  802370:	68 00 f0 bf ee       	push   $0xeebff000
  802375:	50                   	push   %eax
  802376:	e8 7d e8 ff ff       	call   800bf8 <sys_page_alloc>
  80237b:	83 c4 10             	add    $0x10,%esp
  80237e:	85 c0                	test   %eax,%eax
  802380:	79 12                	jns    802394 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  802382:	50                   	push   %eax
  802383:	68 5c 2c 80 00       	push   $0x802c5c
  802388:	6a 21                	push   $0x21
  80238a:	68 74 2c 80 00       	push   $0x802c74
  80238f:	e8 7a ff ff ff       	call   80230e <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802394:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802399:	8b 40 48             	mov    0x48(%eax),%eax
  80239c:	83 ec 08             	sub    $0x8,%esp
  80239f:	68 b7 23 80 00       	push   $0x8023b7
  8023a4:	50                   	push   %eax
  8023a5:	e8 99 e9 ff ff       	call   800d43 <sys_env_set_pgfault_upcall>
  8023aa:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b0:	a3 00 70 80 00       	mov    %eax,0x807000
  8023b5:	c9                   	leave  
  8023b6:	c3                   	ret    

008023b7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023b7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023b8:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023bd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023bf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8023c2:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  8023c5:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  8023c9:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  8023ce:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  8023d2:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8023d4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  8023d5:	83 c4 04             	add    $0x4,%esp
	popfl
  8023d8:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8023d9:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  8023da:	c3                   	ret    

008023db <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023db:	55                   	push   %ebp
  8023dc:	89 e5                	mov    %esp,%ebp
  8023de:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e1:	89 d0                	mov    %edx,%eax
  8023e3:	c1 e8 16             	shr    $0x16,%eax
  8023e6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023ed:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023f2:	f6 c1 01             	test   $0x1,%cl
  8023f5:	74 1d                	je     802414 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023f7:	c1 ea 0c             	shr    $0xc,%edx
  8023fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802401:	f6 c2 01             	test   $0x1,%dl
  802404:	74 0e                	je     802414 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802406:	c1 ea 0c             	shr    $0xc,%edx
  802409:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802410:	ef 
  802411:	0f b7 c0             	movzwl %ax,%eax
}
  802414:	5d                   	pop    %ebp
  802415:	c3                   	ret    
  802416:	66 90                	xchg   %ax,%ax
  802418:	66 90                	xchg   %ax,%ax
  80241a:	66 90                	xchg   %ax,%ax
  80241c:	66 90                	xchg   %ax,%ax
  80241e:	66 90                	xchg   %ax,%ax

00802420 <__udivdi3>:
  802420:	55                   	push   %ebp
  802421:	57                   	push   %edi
  802422:	56                   	push   %esi
  802423:	53                   	push   %ebx
  802424:	83 ec 1c             	sub    $0x1c,%esp
  802427:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80242b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80242f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802433:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802437:	85 f6                	test   %esi,%esi
  802439:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80243d:	89 ca                	mov    %ecx,%edx
  80243f:	89 f8                	mov    %edi,%eax
  802441:	75 3d                	jne    802480 <__udivdi3+0x60>
  802443:	39 cf                	cmp    %ecx,%edi
  802445:	0f 87 c5 00 00 00    	ja     802510 <__udivdi3+0xf0>
  80244b:	85 ff                	test   %edi,%edi
  80244d:	89 fd                	mov    %edi,%ebp
  80244f:	75 0b                	jne    80245c <__udivdi3+0x3c>
  802451:	b8 01 00 00 00       	mov    $0x1,%eax
  802456:	31 d2                	xor    %edx,%edx
  802458:	f7 f7                	div    %edi
  80245a:	89 c5                	mov    %eax,%ebp
  80245c:	89 c8                	mov    %ecx,%eax
  80245e:	31 d2                	xor    %edx,%edx
  802460:	f7 f5                	div    %ebp
  802462:	89 c1                	mov    %eax,%ecx
  802464:	89 d8                	mov    %ebx,%eax
  802466:	89 cf                	mov    %ecx,%edi
  802468:	f7 f5                	div    %ebp
  80246a:	89 c3                	mov    %eax,%ebx
  80246c:	89 d8                	mov    %ebx,%eax
  80246e:	89 fa                	mov    %edi,%edx
  802470:	83 c4 1c             	add    $0x1c,%esp
  802473:	5b                   	pop    %ebx
  802474:	5e                   	pop    %esi
  802475:	5f                   	pop    %edi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    
  802478:	90                   	nop
  802479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802480:	39 ce                	cmp    %ecx,%esi
  802482:	77 74                	ja     8024f8 <__udivdi3+0xd8>
  802484:	0f bd fe             	bsr    %esi,%edi
  802487:	83 f7 1f             	xor    $0x1f,%edi
  80248a:	0f 84 98 00 00 00    	je     802528 <__udivdi3+0x108>
  802490:	bb 20 00 00 00       	mov    $0x20,%ebx
  802495:	89 f9                	mov    %edi,%ecx
  802497:	89 c5                	mov    %eax,%ebp
  802499:	29 fb                	sub    %edi,%ebx
  80249b:	d3 e6                	shl    %cl,%esi
  80249d:	89 d9                	mov    %ebx,%ecx
  80249f:	d3 ed                	shr    %cl,%ebp
  8024a1:	89 f9                	mov    %edi,%ecx
  8024a3:	d3 e0                	shl    %cl,%eax
  8024a5:	09 ee                	or     %ebp,%esi
  8024a7:	89 d9                	mov    %ebx,%ecx
  8024a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ad:	89 d5                	mov    %edx,%ebp
  8024af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024b3:	d3 ed                	shr    %cl,%ebp
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	d3 e2                	shl    %cl,%edx
  8024b9:	89 d9                	mov    %ebx,%ecx
  8024bb:	d3 e8                	shr    %cl,%eax
  8024bd:	09 c2                	or     %eax,%edx
  8024bf:	89 d0                	mov    %edx,%eax
  8024c1:	89 ea                	mov    %ebp,%edx
  8024c3:	f7 f6                	div    %esi
  8024c5:	89 d5                	mov    %edx,%ebp
  8024c7:	89 c3                	mov    %eax,%ebx
  8024c9:	f7 64 24 0c          	mull   0xc(%esp)
  8024cd:	39 d5                	cmp    %edx,%ebp
  8024cf:	72 10                	jb     8024e1 <__udivdi3+0xc1>
  8024d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024d5:	89 f9                	mov    %edi,%ecx
  8024d7:	d3 e6                	shl    %cl,%esi
  8024d9:	39 c6                	cmp    %eax,%esi
  8024db:	73 07                	jae    8024e4 <__udivdi3+0xc4>
  8024dd:	39 d5                	cmp    %edx,%ebp
  8024df:	75 03                	jne    8024e4 <__udivdi3+0xc4>
  8024e1:	83 eb 01             	sub    $0x1,%ebx
  8024e4:	31 ff                	xor    %edi,%edi
  8024e6:	89 d8                	mov    %ebx,%eax
  8024e8:	89 fa                	mov    %edi,%edx
  8024ea:	83 c4 1c             	add    $0x1c,%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5f                   	pop    %edi
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	31 ff                	xor    %edi,%edi
  8024fa:	31 db                	xor    %ebx,%ebx
  8024fc:	89 d8                	mov    %ebx,%eax
  8024fe:	89 fa                	mov    %edi,%edx
  802500:	83 c4 1c             	add    $0x1c,%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    
  802508:	90                   	nop
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	89 d8                	mov    %ebx,%eax
  802512:	f7 f7                	div    %edi
  802514:	31 ff                	xor    %edi,%edi
  802516:	89 c3                	mov    %eax,%ebx
  802518:	89 d8                	mov    %ebx,%eax
  80251a:	89 fa                	mov    %edi,%edx
  80251c:	83 c4 1c             	add    $0x1c,%esp
  80251f:	5b                   	pop    %ebx
  802520:	5e                   	pop    %esi
  802521:	5f                   	pop    %edi
  802522:	5d                   	pop    %ebp
  802523:	c3                   	ret    
  802524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802528:	39 ce                	cmp    %ecx,%esi
  80252a:	72 0c                	jb     802538 <__udivdi3+0x118>
  80252c:	31 db                	xor    %ebx,%ebx
  80252e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802532:	0f 87 34 ff ff ff    	ja     80246c <__udivdi3+0x4c>
  802538:	bb 01 00 00 00       	mov    $0x1,%ebx
  80253d:	e9 2a ff ff ff       	jmp    80246c <__udivdi3+0x4c>
  802542:	66 90                	xchg   %ax,%ax
  802544:	66 90                	xchg   %ax,%ax
  802546:	66 90                	xchg   %ax,%ax
  802548:	66 90                	xchg   %ax,%ax
  80254a:	66 90                	xchg   %ax,%ax
  80254c:	66 90                	xchg   %ax,%ax
  80254e:	66 90                	xchg   %ax,%ax

00802550 <__umoddi3>:
  802550:	55                   	push   %ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	53                   	push   %ebx
  802554:	83 ec 1c             	sub    $0x1c,%esp
  802557:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80255b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80255f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802563:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802567:	85 d2                	test   %edx,%edx
  802569:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80256d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802571:	89 f3                	mov    %esi,%ebx
  802573:	89 3c 24             	mov    %edi,(%esp)
  802576:	89 74 24 04          	mov    %esi,0x4(%esp)
  80257a:	75 1c                	jne    802598 <__umoddi3+0x48>
  80257c:	39 f7                	cmp    %esi,%edi
  80257e:	76 50                	jbe    8025d0 <__umoddi3+0x80>
  802580:	89 c8                	mov    %ecx,%eax
  802582:	89 f2                	mov    %esi,%edx
  802584:	f7 f7                	div    %edi
  802586:	89 d0                	mov    %edx,%eax
  802588:	31 d2                	xor    %edx,%edx
  80258a:	83 c4 1c             	add    $0x1c,%esp
  80258d:	5b                   	pop    %ebx
  80258e:	5e                   	pop    %esi
  80258f:	5f                   	pop    %edi
  802590:	5d                   	pop    %ebp
  802591:	c3                   	ret    
  802592:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802598:	39 f2                	cmp    %esi,%edx
  80259a:	89 d0                	mov    %edx,%eax
  80259c:	77 52                	ja     8025f0 <__umoddi3+0xa0>
  80259e:	0f bd ea             	bsr    %edx,%ebp
  8025a1:	83 f5 1f             	xor    $0x1f,%ebp
  8025a4:	75 5a                	jne    802600 <__umoddi3+0xb0>
  8025a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025aa:	0f 82 e0 00 00 00    	jb     802690 <__umoddi3+0x140>
  8025b0:	39 0c 24             	cmp    %ecx,(%esp)
  8025b3:	0f 86 d7 00 00 00    	jbe    802690 <__umoddi3+0x140>
  8025b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025c1:	83 c4 1c             	add    $0x1c,%esp
  8025c4:	5b                   	pop    %ebx
  8025c5:	5e                   	pop    %esi
  8025c6:	5f                   	pop    %edi
  8025c7:	5d                   	pop    %ebp
  8025c8:	c3                   	ret    
  8025c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	85 ff                	test   %edi,%edi
  8025d2:	89 fd                	mov    %edi,%ebp
  8025d4:	75 0b                	jne    8025e1 <__umoddi3+0x91>
  8025d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025db:	31 d2                	xor    %edx,%edx
  8025dd:	f7 f7                	div    %edi
  8025df:	89 c5                	mov    %eax,%ebp
  8025e1:	89 f0                	mov    %esi,%eax
  8025e3:	31 d2                	xor    %edx,%edx
  8025e5:	f7 f5                	div    %ebp
  8025e7:	89 c8                	mov    %ecx,%eax
  8025e9:	f7 f5                	div    %ebp
  8025eb:	89 d0                	mov    %edx,%eax
  8025ed:	eb 99                	jmp    802588 <__umoddi3+0x38>
  8025ef:	90                   	nop
  8025f0:	89 c8                	mov    %ecx,%eax
  8025f2:	89 f2                	mov    %esi,%edx
  8025f4:	83 c4 1c             	add    $0x1c,%esp
  8025f7:	5b                   	pop    %ebx
  8025f8:	5e                   	pop    %esi
  8025f9:	5f                   	pop    %edi
  8025fa:	5d                   	pop    %ebp
  8025fb:	c3                   	ret    
  8025fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802600:	8b 34 24             	mov    (%esp),%esi
  802603:	bf 20 00 00 00       	mov    $0x20,%edi
  802608:	89 e9                	mov    %ebp,%ecx
  80260a:	29 ef                	sub    %ebp,%edi
  80260c:	d3 e0                	shl    %cl,%eax
  80260e:	89 f9                	mov    %edi,%ecx
  802610:	89 f2                	mov    %esi,%edx
  802612:	d3 ea                	shr    %cl,%edx
  802614:	89 e9                	mov    %ebp,%ecx
  802616:	09 c2                	or     %eax,%edx
  802618:	89 d8                	mov    %ebx,%eax
  80261a:	89 14 24             	mov    %edx,(%esp)
  80261d:	89 f2                	mov    %esi,%edx
  80261f:	d3 e2                	shl    %cl,%edx
  802621:	89 f9                	mov    %edi,%ecx
  802623:	89 54 24 04          	mov    %edx,0x4(%esp)
  802627:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80262b:	d3 e8                	shr    %cl,%eax
  80262d:	89 e9                	mov    %ebp,%ecx
  80262f:	89 c6                	mov    %eax,%esi
  802631:	d3 e3                	shl    %cl,%ebx
  802633:	89 f9                	mov    %edi,%ecx
  802635:	89 d0                	mov    %edx,%eax
  802637:	d3 e8                	shr    %cl,%eax
  802639:	89 e9                	mov    %ebp,%ecx
  80263b:	09 d8                	or     %ebx,%eax
  80263d:	89 d3                	mov    %edx,%ebx
  80263f:	89 f2                	mov    %esi,%edx
  802641:	f7 34 24             	divl   (%esp)
  802644:	89 d6                	mov    %edx,%esi
  802646:	d3 e3                	shl    %cl,%ebx
  802648:	f7 64 24 04          	mull   0x4(%esp)
  80264c:	39 d6                	cmp    %edx,%esi
  80264e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802652:	89 d1                	mov    %edx,%ecx
  802654:	89 c3                	mov    %eax,%ebx
  802656:	72 08                	jb     802660 <__umoddi3+0x110>
  802658:	75 11                	jne    80266b <__umoddi3+0x11b>
  80265a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80265e:	73 0b                	jae    80266b <__umoddi3+0x11b>
  802660:	2b 44 24 04          	sub    0x4(%esp),%eax
  802664:	1b 14 24             	sbb    (%esp),%edx
  802667:	89 d1                	mov    %edx,%ecx
  802669:	89 c3                	mov    %eax,%ebx
  80266b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80266f:	29 da                	sub    %ebx,%edx
  802671:	19 ce                	sbb    %ecx,%esi
  802673:	89 f9                	mov    %edi,%ecx
  802675:	89 f0                	mov    %esi,%eax
  802677:	d3 e0                	shl    %cl,%eax
  802679:	89 e9                	mov    %ebp,%ecx
  80267b:	d3 ea                	shr    %cl,%edx
  80267d:	89 e9                	mov    %ebp,%ecx
  80267f:	d3 ee                	shr    %cl,%esi
  802681:	09 d0                	or     %edx,%eax
  802683:	89 f2                	mov    %esi,%edx
  802685:	83 c4 1c             	add    $0x1c,%esp
  802688:	5b                   	pop    %ebx
  802689:	5e                   	pop    %esi
  80268a:	5f                   	pop    %edi
  80268b:	5d                   	pop    %ebp
  80268c:	c3                   	ret    
  80268d:	8d 76 00             	lea    0x0(%esi),%esi
  802690:	29 f9                	sub    %edi,%ecx
  802692:	19 d6                	sbb    %edx,%esi
  802694:	89 74 24 04          	mov    %esi,0x4(%esp)
  802698:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80269c:	e9 18 ff ff ff       	jmp    8025b9 <__umoddi3+0x69>
