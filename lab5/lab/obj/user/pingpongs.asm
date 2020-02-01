
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
  80003c:	e8 2d 10 00 00       	call   80106e <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 67 0b 00 00       	call   800bba <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 00 22 80 00       	push   $0x802200
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 50 0b 00 00       	call   800bba <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 1a 22 80 00       	push   $0x80221a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 6a 10 00 00       	call   8010f1 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 ee 0f 00 00       	call   801088 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 07 0b 00 00       	call   800bba <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 30 22 80 00       	push   $0x802230
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 07 10 00 00       	call   8010f1 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
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
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80014a:	e8 fa 11 00 00       	call   801349 <close_all>
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
  800254:	e8 17 1d 00 00       	call   801f70 <__udivdi3>
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
  800297:	e8 04 1e 00 00       	call   8020a0 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
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
  800361:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
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
  800428:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  80042f:	85 d2                	test   %edx,%edx
  800431:	75 1b                	jne    80044e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800433:	50                   	push   %eax
  800434:	68 78 22 80 00       	push   $0x802278
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
  80044f:	68 f5 26 80 00       	push   $0x8026f5
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
  800479:	b8 71 22 80 00       	mov    $0x802271,%eax
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
  800ba1:	68 5f 25 80 00       	push   $0x80255f
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 7c 25 80 00       	push   $0x80257c
  800bad:	e8 b6 12 00 00       	call   801e68 <_panic>

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
  800c22:	68 5f 25 80 00       	push   $0x80255f
  800c27:	6a 23                	push   $0x23
  800c29:	68 7c 25 80 00       	push   $0x80257c
  800c2e:	e8 35 12 00 00       	call   801e68 <_panic>

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
  800c64:	68 5f 25 80 00       	push   $0x80255f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 7c 25 80 00       	push   $0x80257c
  800c70:	e8 f3 11 00 00       	call   801e68 <_panic>

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
  800ca6:	68 5f 25 80 00       	push   $0x80255f
  800cab:	6a 23                	push   $0x23
  800cad:	68 7c 25 80 00       	push   $0x80257c
  800cb2:	e8 b1 11 00 00       	call   801e68 <_panic>

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
  800ce8:	68 5f 25 80 00       	push   $0x80255f
  800ced:	6a 23                	push   $0x23
  800cef:	68 7c 25 80 00       	push   $0x80257c
  800cf4:	e8 6f 11 00 00       	call   801e68 <_panic>

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
  800d2a:	68 5f 25 80 00       	push   $0x80255f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 7c 25 80 00       	push   $0x80257c
  800d36:	e8 2d 11 00 00       	call   801e68 <_panic>

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
  800d6c:	68 5f 25 80 00       	push   $0x80255f
  800d71:	6a 23                	push   $0x23
  800d73:	68 7c 25 80 00       	push   $0x80257c
  800d78:	e8 eb 10 00 00       	call   801e68 <_panic>

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
  800dd0:	68 5f 25 80 00       	push   $0x80255f
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 7c 25 80 00       	push   $0x80257c
  800ddc:	e8 87 10 00 00       	call   801e68 <_panic>

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

00800de9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	53                   	push   %ebx
  800ded:	83 ec 04             	sub    $0x4,%esp
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800df3:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800df5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800df9:	74 2d                	je     800e28 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800dfb:	89 d8                	mov    %ebx,%eax
  800dfd:	c1 e8 16             	shr    $0x16,%eax
  800e00:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e07:	a8 01                	test   $0x1,%al
  800e09:	74 1d                	je     800e28 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e0b:	89 d8                	mov    %ebx,%eax
  800e0d:	c1 e8 0c             	shr    $0xc,%eax
  800e10:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e17:	f6 c2 01             	test   $0x1,%dl
  800e1a:	74 0c                	je     800e28 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e1c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e23:	f6 c4 08             	test   $0x8,%ah
  800e26:	75 14                	jne    800e3c <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800e28:	83 ec 04             	sub    $0x4,%esp
  800e2b:	68 8c 25 80 00       	push   $0x80258c
  800e30:	6a 1f                	push   $0x1f
  800e32:	68 c2 25 80 00       	push   $0x8025c2
  800e37:	e8 2c 10 00 00       	call   801e68 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800e3c:	83 ec 04             	sub    $0x4,%esp
  800e3f:	6a 07                	push   $0x7
  800e41:	68 00 f0 7f 00       	push   $0x7ff000
  800e46:	6a 00                	push   $0x0
  800e48:	e8 ab fd ff ff       	call   800bf8 <sys_page_alloc>
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	79 12                	jns    800e66 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800e54:	50                   	push   %eax
  800e55:	68 cd 25 80 00       	push   $0x8025cd
  800e5a:	6a 29                	push   $0x29
  800e5c:	68 c2 25 80 00       	push   $0x8025c2
  800e61:	e8 02 10 00 00       	call   801e68 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e66:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	68 00 10 00 00       	push   $0x1000
  800e74:	53                   	push   %ebx
  800e75:	68 00 f0 7f 00       	push   $0x7ff000
  800e7a:	e8 70 fb ff ff       	call   8009ef <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800e7f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e86:	53                   	push   %ebx
  800e87:	6a 00                	push   $0x0
  800e89:	68 00 f0 7f 00       	push   $0x7ff000
  800e8e:	6a 00                	push   $0x0
  800e90:	e8 a6 fd ff ff       	call   800c3b <sys_page_map>
  800e95:	83 c4 20             	add    $0x20,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	79 12                	jns    800eae <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800e9c:	50                   	push   %eax
  800e9d:	68 e1 25 80 00       	push   $0x8025e1
  800ea2:	6a 2e                	push   $0x2e
  800ea4:	68 c2 25 80 00       	push   $0x8025c2
  800ea9:	e8 ba 0f 00 00       	call   801e68 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800eae:	83 ec 08             	sub    $0x8,%esp
  800eb1:	68 00 f0 7f 00       	push   $0x7ff000
  800eb6:	6a 00                	push   $0x0
  800eb8:	e8 c0 fd ff ff       	call   800c7d <sys_page_unmap>
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	79 12                	jns    800ed6 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800ec4:	50                   	push   %eax
  800ec5:	68 f3 25 80 00       	push   $0x8025f3
  800eca:	6a 30                	push   $0x30
  800ecc:	68 c2 25 80 00       	push   $0x8025c2
  800ed1:	e8 92 0f 00 00       	call   801e68 <_panic>
	//panic("pgfault not implemented");
}
  800ed6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800ee4:	68 e9 0d 80 00       	push   $0x800de9
  800ee9:	e8 c0 0f 00 00       	call   801eae <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eee:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef3:	cd 30                	int    $0x30
  800ef5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	79 14                	jns    800f13 <fork+0x38>
		panic("sys_exofork failed");
  800eff:	83 ec 04             	sub    $0x4,%esp
  800f02:	68 07 26 80 00       	push   $0x802607
  800f07:	6a 6f                	push   $0x6f
  800f09:	68 c2 25 80 00       	push   $0x8025c2
  800f0e:	e8 55 0f 00 00       	call   801e68 <_panic>
  800f13:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800f15:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f19:	0f 8e 2b 01 00 00    	jle    80104a <fork+0x16f>
  800f1f:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800f24:	89 d8                	mov    %ebx,%eax
  800f26:	c1 e8 0a             	shr    $0xa,%eax
  800f29:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f30:	a8 01                	test   $0x1,%al
  800f32:	0f 84 bf 00 00 00    	je     800ff7 <fork+0x11c>
  800f38:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f3f:	a8 01                	test   $0x1,%al
  800f41:	0f 84 b0 00 00 00    	je     800ff7 <fork+0x11c>
  800f47:	89 de                	mov    %ebx,%esi
  800f49:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  800f4c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f53:	f6 c4 04             	test   $0x4,%ah
  800f56:	74 29                	je     800f81 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  800f58:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f5f:	83 ec 0c             	sub    $0xc,%esp
  800f62:	25 07 0e 00 00       	and    $0xe07,%eax
  800f67:	50                   	push   %eax
  800f68:	56                   	push   %esi
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 c9 fc ff ff       	call   800c3b <sys_page_map>
  800f72:	83 c4 20             	add    $0x20,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7c:	0f 4f c2             	cmovg  %edx,%eax
  800f7f:	eb 72                	jmp    800ff3 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800f81:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f88:	a8 02                	test   $0x2,%al
  800f8a:	75 0c                	jne    800f98 <fork+0xbd>
  800f8c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f93:	f6 c4 08             	test   $0x8,%ah
  800f96:	74 3f                	je     800fd7 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	68 05 08 00 00       	push   $0x805
  800fa0:	56                   	push   %esi
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	6a 00                	push   $0x0
  800fa5:	e8 91 fc ff ff       	call   800c3b <sys_page_map>
  800faa:	83 c4 20             	add    $0x20,%esp
  800fad:	85 c0                	test   %eax,%eax
  800faf:	0f 88 b1 00 00 00    	js     801066 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800fb5:	83 ec 0c             	sub    $0xc,%esp
  800fb8:	68 05 08 00 00       	push   $0x805
  800fbd:	56                   	push   %esi
  800fbe:	6a 00                	push   $0x0
  800fc0:	56                   	push   %esi
  800fc1:	6a 00                	push   $0x0
  800fc3:	e8 73 fc ff ff       	call   800c3b <sys_page_map>
  800fc8:	83 c4 20             	add    $0x20,%esp
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd2:	0f 4f c1             	cmovg  %ecx,%eax
  800fd5:	eb 1c                	jmp    800ff3 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	6a 05                	push   $0x5
  800fdc:	56                   	push   %esi
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 55 fc ff ff       	call   800c3b <sys_page_map>
  800fe6:	83 c4 20             	add    $0x20,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff0:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 6f                	js     801066 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  800ff7:	83 c3 01             	add    $0x1,%ebx
  800ffa:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801000:	0f 85 1e ff ff ff    	jne    800f24 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  801006:	83 ec 04             	sub    $0x4,%esp
  801009:	6a 07                	push   $0x7
  80100b:	68 00 f0 bf ee       	push   $0xeebff000
  801010:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801013:	57                   	push   %edi
  801014:	e8 df fb ff ff       	call   800bf8 <sys_page_alloc>
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 46                	js     801066 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  801020:	83 ec 08             	sub    $0x8,%esp
  801023:	68 11 1f 80 00       	push   $0x801f11
  801028:	57                   	push   %edi
  801029:	e8 15 fd ff ff       	call   800d43 <sys_env_set_pgfault_upcall>
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	78 31                	js     801066 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  801035:	83 ec 08             	sub    $0x8,%esp
  801038:	6a 02                	push   $0x2
  80103a:	57                   	push   %edi
  80103b:	e8 7f fc ff ff       	call   800cbf <sys_env_set_status>
  801040:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  801043:	85 c0                	test   %eax,%eax
  801045:	0f 49 c7             	cmovns %edi,%eax
  801048:	eb 1c                	jmp    801066 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  80104a:	e8 6b fb ff ff       	call   800bba <sys_getenvid>
  80104f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801054:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801057:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80105c:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801061:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801066:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801069:	5b                   	pop    %ebx
  80106a:	5e                   	pop    %esi
  80106b:	5f                   	pop    %edi
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <sfork>:

// Challenge!
int
sfork(void)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801074:	68 1a 26 80 00       	push   $0x80261a
  801079:	68 8d 00 00 00       	push   $0x8d
  80107e:	68 c2 25 80 00       	push   $0x8025c2
  801083:	e8 e0 0d 00 00       	call   801e68 <_panic>

00801088 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	56                   	push   %esi
  80108c:	53                   	push   %ebx
  80108d:	8b 75 08             	mov    0x8(%ebp),%esi
  801090:	8b 45 0c             	mov    0xc(%ebp),%eax
  801093:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801096:	85 c0                	test   %eax,%eax
  801098:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80109d:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	50                   	push   %eax
  8010a4:	e8 ff fc ff ff       	call   800da8 <sys_ipc_recv>
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	79 16                	jns    8010c6 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8010b0:	85 f6                	test   %esi,%esi
  8010b2:	74 06                	je     8010ba <ipc_recv+0x32>
            *from_env_store = 0;
  8010b4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  8010ba:	85 db                	test   %ebx,%ebx
  8010bc:	74 2c                	je     8010ea <ipc_recv+0x62>
            *perm_store = 0;
  8010be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c4:	eb 24                	jmp    8010ea <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  8010c6:	85 f6                	test   %esi,%esi
  8010c8:	74 0a                	je     8010d4 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  8010ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8010cf:	8b 40 74             	mov    0x74(%eax),%eax
  8010d2:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  8010d4:	85 db                	test   %ebx,%ebx
  8010d6:	74 0a                	je     8010e2 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  8010d8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010dd:	8b 40 78             	mov    0x78(%eax),%eax
  8010e0:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  8010e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e7:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8010ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	57                   	push   %edi
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801100:	8b 45 10             	mov    0x10(%ebp),%eax
  801103:	85 c0                	test   %eax,%eax
  801105:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80110a:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80110d:	eb 1c                	jmp    80112b <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80110f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801112:	74 12                	je     801126 <ipc_send+0x35>
  801114:	50                   	push   %eax
  801115:	68 30 26 80 00       	push   $0x802630
  80111a:	6a 3a                	push   $0x3a
  80111c:	68 46 26 80 00       	push   $0x802646
  801121:	e8 42 0d 00 00       	call   801e68 <_panic>
		sys_yield();
  801126:	e8 ae fa ff ff       	call   800bd9 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80112b:	ff 75 14             	pushl  0x14(%ebp)
  80112e:	53                   	push   %ebx
  80112f:	56                   	push   %esi
  801130:	57                   	push   %edi
  801131:	e8 4f fc ff ff       	call   800d85 <sys_ipc_try_send>
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 d2                	js     80110f <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80113d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801140:	5b                   	pop    %ebx
  801141:	5e                   	pop    %esi
  801142:	5f                   	pop    %edi
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801150:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801153:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801159:	8b 52 50             	mov    0x50(%edx),%edx
  80115c:	39 ca                	cmp    %ecx,%edx
  80115e:	75 0d                	jne    80116d <ipc_find_env+0x28>
			return envs[i].env_id;
  801160:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801168:	8b 40 48             	mov    0x48(%eax),%eax
  80116b:	eb 0f                	jmp    80117c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80116d:	83 c0 01             	add    $0x1,%eax
  801170:	3d 00 04 00 00       	cmp    $0x400,%eax
  801175:	75 d9                	jne    801150 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801177:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801181:	8b 45 08             	mov    0x8(%ebp),%eax
  801184:	05 00 00 00 30       	add    $0x30000000,%eax
  801189:	c1 e8 0c             	shr    $0xc,%eax
}
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801191:	8b 45 08             	mov    0x8(%ebp),%eax
  801194:	05 00 00 00 30       	add    $0x30000000,%eax
  801199:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ab:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	c1 ea 16             	shr    $0x16,%edx
  8011b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bc:	f6 c2 01             	test   $0x1,%dl
  8011bf:	74 11                	je     8011d2 <fd_alloc+0x2d>
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	c1 ea 0c             	shr    $0xc,%edx
  8011c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cd:	f6 c2 01             	test   $0x1,%dl
  8011d0:	75 09                	jne    8011db <fd_alloc+0x36>
			*fd_store = fd;
  8011d2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d9:	eb 17                	jmp    8011f2 <fd_alloc+0x4d>
  8011db:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011e0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e5:	75 c9                	jne    8011b0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ed:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011fa:	83 f8 1f             	cmp    $0x1f,%eax
  8011fd:	77 36                	ja     801235 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ff:	c1 e0 0c             	shl    $0xc,%eax
  801202:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801207:	89 c2                	mov    %eax,%edx
  801209:	c1 ea 16             	shr    $0x16,%edx
  80120c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801213:	f6 c2 01             	test   $0x1,%dl
  801216:	74 24                	je     80123c <fd_lookup+0x48>
  801218:	89 c2                	mov    %eax,%edx
  80121a:	c1 ea 0c             	shr    $0xc,%edx
  80121d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801224:	f6 c2 01             	test   $0x1,%dl
  801227:	74 1a                	je     801243 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122c:	89 02                	mov    %eax,(%edx)
	return 0;
  80122e:	b8 00 00 00 00       	mov    $0x0,%eax
  801233:	eb 13                	jmp    801248 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801235:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123a:	eb 0c                	jmp    801248 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801241:	eb 05                	jmp    801248 <fd_lookup+0x54>
  801243:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801253:	ba cc 26 80 00       	mov    $0x8026cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801258:	eb 13                	jmp    80126d <dev_lookup+0x23>
  80125a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80125d:	39 08                	cmp    %ecx,(%eax)
  80125f:	75 0c                	jne    80126d <dev_lookup+0x23>
			*dev = devtab[i];
  801261:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801264:	89 01                	mov    %eax,(%ecx)
			return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
  80126b:	eb 2e                	jmp    80129b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126d:	8b 02                	mov    (%edx),%eax
  80126f:	85 c0                	test   %eax,%eax
  801271:	75 e7                	jne    80125a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801273:	a1 08 40 80 00       	mov    0x804008,%eax
  801278:	8b 40 48             	mov    0x48(%eax),%eax
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	51                   	push   %ecx
  80127f:	50                   	push   %eax
  801280:	68 50 26 80 00       	push   $0x802650
  801285:	e8 67 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  80128a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	56                   	push   %esi
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 10             	sub    $0x10,%esp
  8012a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b5:	c1 e8 0c             	shr    $0xc,%eax
  8012b8:	50                   	push   %eax
  8012b9:	e8 36 ff ff ff       	call   8011f4 <fd_lookup>
  8012be:	83 c4 08             	add    $0x8,%esp
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	78 05                	js     8012ca <fd_close+0x2d>
	    || fd != fd2)
  8012c5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c8:	74 0c                	je     8012d6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012ca:	84 db                	test   %bl,%bl
  8012cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d1:	0f 44 c2             	cmove  %edx,%eax
  8012d4:	eb 41                	jmp    801317 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012dc:	50                   	push   %eax
  8012dd:	ff 36                	pushl  (%esi)
  8012df:	e8 66 ff ff ff       	call   80124a <dev_lookup>
  8012e4:	89 c3                	mov    %eax,%ebx
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	78 1a                	js     801307 <fd_close+0x6a>
		if (dev->dev_close)
  8012ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	74 0b                	je     801307 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012fc:	83 ec 0c             	sub    $0xc,%esp
  8012ff:	56                   	push   %esi
  801300:	ff d0                	call   *%eax
  801302:	89 c3                	mov    %eax,%ebx
  801304:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	56                   	push   %esi
  80130b:	6a 00                	push   $0x0
  80130d:	e8 6b f9 ff ff       	call   800c7d <sys_page_unmap>
	return r;
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	89 d8                	mov    %ebx,%eax
}
  801317:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131a:	5b                   	pop    %ebx
  80131b:	5e                   	pop    %esi
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801324:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801327:	50                   	push   %eax
  801328:	ff 75 08             	pushl  0x8(%ebp)
  80132b:	e8 c4 fe ff ff       	call   8011f4 <fd_lookup>
  801330:	83 c4 08             	add    $0x8,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 10                	js     801347 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	6a 01                	push   $0x1
  80133c:	ff 75 f4             	pushl  -0xc(%ebp)
  80133f:	e8 59 ff ff ff       	call   80129d <fd_close>
  801344:	83 c4 10             	add    $0x10,%esp
}
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <close_all>:

void
close_all(void)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	53                   	push   %ebx
  80134d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801350:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801355:	83 ec 0c             	sub    $0xc,%esp
  801358:	53                   	push   %ebx
  801359:	e8 c0 ff ff ff       	call   80131e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80135e:	83 c3 01             	add    $0x1,%ebx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	83 fb 20             	cmp    $0x20,%ebx
  801367:	75 ec                	jne    801355 <close_all+0xc>
		close(i);
}
  801369:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136c:	c9                   	leave  
  80136d:	c3                   	ret    

0080136e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	57                   	push   %edi
  801372:	56                   	push   %esi
  801373:	53                   	push   %ebx
  801374:	83 ec 2c             	sub    $0x2c,%esp
  801377:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80137a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	ff 75 08             	pushl  0x8(%ebp)
  801381:	e8 6e fe ff ff       	call   8011f4 <fd_lookup>
  801386:	83 c4 08             	add    $0x8,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	0f 88 c1 00 00 00    	js     801452 <dup+0xe4>
		return r;
	close(newfdnum);
  801391:	83 ec 0c             	sub    $0xc,%esp
  801394:	56                   	push   %esi
  801395:	e8 84 ff ff ff       	call   80131e <close>

	newfd = INDEX2FD(newfdnum);
  80139a:	89 f3                	mov    %esi,%ebx
  80139c:	c1 e3 0c             	shl    $0xc,%ebx
  80139f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a5:	83 c4 04             	add    $0x4,%esp
  8013a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ab:	e8 de fd ff ff       	call   80118e <fd2data>
  8013b0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b2:	89 1c 24             	mov    %ebx,(%esp)
  8013b5:	e8 d4 fd ff ff       	call   80118e <fd2data>
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013c0:	89 f8                	mov    %edi,%eax
  8013c2:	c1 e8 16             	shr    $0x16,%eax
  8013c5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013cc:	a8 01                	test   $0x1,%al
  8013ce:	74 37                	je     801407 <dup+0x99>
  8013d0:	89 f8                	mov    %edi,%eax
  8013d2:	c1 e8 0c             	shr    $0xc,%eax
  8013d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013dc:	f6 c2 01             	test   $0x1,%dl
  8013df:	74 26                	je     801407 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e8:	83 ec 0c             	sub    $0xc,%esp
  8013eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f0:	50                   	push   %eax
  8013f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f4:	6a 00                	push   $0x0
  8013f6:	57                   	push   %edi
  8013f7:	6a 00                	push   $0x0
  8013f9:	e8 3d f8 ff ff       	call   800c3b <sys_page_map>
  8013fe:	89 c7                	mov    %eax,%edi
  801400:	83 c4 20             	add    $0x20,%esp
  801403:	85 c0                	test   %eax,%eax
  801405:	78 2e                	js     801435 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801407:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80140a:	89 d0                	mov    %edx,%eax
  80140c:	c1 e8 0c             	shr    $0xc,%eax
  80140f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801416:	83 ec 0c             	sub    $0xc,%esp
  801419:	25 07 0e 00 00       	and    $0xe07,%eax
  80141e:	50                   	push   %eax
  80141f:	53                   	push   %ebx
  801420:	6a 00                	push   $0x0
  801422:	52                   	push   %edx
  801423:	6a 00                	push   $0x0
  801425:	e8 11 f8 ff ff       	call   800c3b <sys_page_map>
  80142a:	89 c7                	mov    %eax,%edi
  80142c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80142f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801431:	85 ff                	test   %edi,%edi
  801433:	79 1d                	jns    801452 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	53                   	push   %ebx
  801439:	6a 00                	push   $0x0
  80143b:	e8 3d f8 ff ff       	call   800c7d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801440:	83 c4 08             	add    $0x8,%esp
  801443:	ff 75 d4             	pushl  -0x2c(%ebp)
  801446:	6a 00                	push   $0x0
  801448:	e8 30 f8 ff ff       	call   800c7d <sys_page_unmap>
	return r;
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	89 f8                	mov    %edi,%eax
}
  801452:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5f                   	pop    %edi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 14             	sub    $0x14,%esp
  801461:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801464:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	53                   	push   %ebx
  801469:	e8 86 fd ff ff       	call   8011f4 <fd_lookup>
  80146e:	83 c4 08             	add    $0x8,%esp
  801471:	89 c2                	mov    %eax,%edx
  801473:	85 c0                	test   %eax,%eax
  801475:	78 6d                	js     8014e4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147d:	50                   	push   %eax
  80147e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801481:	ff 30                	pushl  (%eax)
  801483:	e8 c2 fd ff ff       	call   80124a <dev_lookup>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 4c                	js     8014db <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801492:	8b 42 08             	mov    0x8(%edx),%eax
  801495:	83 e0 03             	and    $0x3,%eax
  801498:	83 f8 01             	cmp    $0x1,%eax
  80149b:	75 21                	jne    8014be <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80149d:	a1 08 40 80 00       	mov    0x804008,%eax
  8014a2:	8b 40 48             	mov    0x48(%eax),%eax
  8014a5:	83 ec 04             	sub    $0x4,%esp
  8014a8:	53                   	push   %ebx
  8014a9:	50                   	push   %eax
  8014aa:	68 91 26 80 00       	push   $0x802691
  8014af:	e8 3d ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014bc:	eb 26                	jmp    8014e4 <read+0x8a>
	}
	if (!dev->dev_read)
  8014be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c1:	8b 40 08             	mov    0x8(%eax),%eax
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	74 17                	je     8014df <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c8:	83 ec 04             	sub    $0x4,%esp
  8014cb:	ff 75 10             	pushl  0x10(%ebp)
  8014ce:	ff 75 0c             	pushl  0xc(%ebp)
  8014d1:	52                   	push   %edx
  8014d2:	ff d0                	call   *%eax
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	eb 09                	jmp    8014e4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014db:	89 c2                	mov    %eax,%edx
  8014dd:	eb 05                	jmp    8014e4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014e4:	89 d0                	mov    %edx,%eax
  8014e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	57                   	push   %edi
  8014ef:	56                   	push   %esi
  8014f0:	53                   	push   %ebx
  8014f1:	83 ec 0c             	sub    $0xc,%esp
  8014f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ff:	eb 21                	jmp    801522 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	89 f0                	mov    %esi,%eax
  801506:	29 d8                	sub    %ebx,%eax
  801508:	50                   	push   %eax
  801509:	89 d8                	mov    %ebx,%eax
  80150b:	03 45 0c             	add    0xc(%ebp),%eax
  80150e:	50                   	push   %eax
  80150f:	57                   	push   %edi
  801510:	e8 45 ff ff ff       	call   80145a <read>
		if (m < 0)
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 10                	js     80152c <readn+0x41>
			return m;
		if (m == 0)
  80151c:	85 c0                	test   %eax,%eax
  80151e:	74 0a                	je     80152a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801520:	01 c3                	add    %eax,%ebx
  801522:	39 f3                	cmp    %esi,%ebx
  801524:	72 db                	jb     801501 <readn+0x16>
  801526:	89 d8                	mov    %ebx,%eax
  801528:	eb 02                	jmp    80152c <readn+0x41>
  80152a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80152c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152f:	5b                   	pop    %ebx
  801530:	5e                   	pop    %esi
  801531:	5f                   	pop    %edi
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 14             	sub    $0x14,%esp
  80153b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	53                   	push   %ebx
  801543:	e8 ac fc ff ff       	call   8011f4 <fd_lookup>
  801548:	83 c4 08             	add    $0x8,%esp
  80154b:	89 c2                	mov    %eax,%edx
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 68                	js     8015b9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	ff 30                	pushl  (%eax)
  80155d:	e8 e8 fc ff ff       	call   80124a <dev_lookup>
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	85 c0                	test   %eax,%eax
  801567:	78 47                	js     8015b0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801570:	75 21                	jne    801593 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801572:	a1 08 40 80 00       	mov    0x804008,%eax
  801577:	8b 40 48             	mov    0x48(%eax),%eax
  80157a:	83 ec 04             	sub    $0x4,%esp
  80157d:	53                   	push   %ebx
  80157e:	50                   	push   %eax
  80157f:	68 ad 26 80 00       	push   $0x8026ad
  801584:	e8 68 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801591:	eb 26                	jmp    8015b9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801593:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801596:	8b 52 0c             	mov    0xc(%edx),%edx
  801599:	85 d2                	test   %edx,%edx
  80159b:	74 17                	je     8015b4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	ff 75 10             	pushl  0x10(%ebp)
  8015a3:	ff 75 0c             	pushl  0xc(%ebp)
  8015a6:	50                   	push   %eax
  8015a7:	ff d2                	call   *%edx
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	eb 09                	jmp    8015b9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	eb 05                	jmp    8015b9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b9:	89 d0                	mov    %edx,%eax
  8015bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	ff 75 08             	pushl  0x8(%ebp)
  8015cd:	e8 22 fc ff ff       	call   8011f4 <fd_lookup>
  8015d2:	83 c4 08             	add    $0x8,%esp
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 0e                	js     8015e7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015df:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    

008015e9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 14             	sub    $0x14,%esp
  8015f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	53                   	push   %ebx
  8015f8:	e8 f7 fb ff ff       	call   8011f4 <fd_lookup>
  8015fd:	83 c4 08             	add    $0x8,%esp
  801600:	89 c2                	mov    %eax,%edx
  801602:	85 c0                	test   %eax,%eax
  801604:	78 65                	js     80166b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801610:	ff 30                	pushl  (%eax)
  801612:	e8 33 fc ff ff       	call   80124a <dev_lookup>
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 44                	js     801662 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801621:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801625:	75 21                	jne    801648 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801627:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80162c:	8b 40 48             	mov    0x48(%eax),%eax
  80162f:	83 ec 04             	sub    $0x4,%esp
  801632:	53                   	push   %ebx
  801633:	50                   	push   %eax
  801634:	68 70 26 80 00       	push   $0x802670
  801639:	e8 b3 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801646:	eb 23                	jmp    80166b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801648:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164b:	8b 52 18             	mov    0x18(%edx),%edx
  80164e:	85 d2                	test   %edx,%edx
  801650:	74 14                	je     801666 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	ff 75 0c             	pushl  0xc(%ebp)
  801658:	50                   	push   %eax
  801659:	ff d2                	call   *%edx
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	eb 09                	jmp    80166b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801662:	89 c2                	mov    %eax,%edx
  801664:	eb 05                	jmp    80166b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801666:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80166b:	89 d0                	mov    %edx,%eax
  80166d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	53                   	push   %ebx
  801676:	83 ec 14             	sub    $0x14,%esp
  801679:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167f:	50                   	push   %eax
  801680:	ff 75 08             	pushl  0x8(%ebp)
  801683:	e8 6c fb ff ff       	call   8011f4 <fd_lookup>
  801688:	83 c4 08             	add    $0x8,%esp
  80168b:	89 c2                	mov    %eax,%edx
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 58                	js     8016e9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801691:	83 ec 08             	sub    $0x8,%esp
  801694:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801697:	50                   	push   %eax
  801698:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169b:	ff 30                	pushl  (%eax)
  80169d:	e8 a8 fb ff ff       	call   80124a <dev_lookup>
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	78 37                	js     8016e0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ac:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016b0:	74 32                	je     8016e4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016bc:	00 00 00 
	stat->st_isdir = 0;
  8016bf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c6:	00 00 00 
	stat->st_dev = dev;
  8016c9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	53                   	push   %ebx
  8016d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d6:	ff 50 14             	call   *0x14(%eax)
  8016d9:	89 c2                	mov    %eax,%edx
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	eb 09                	jmp    8016e9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	eb 05                	jmp    8016e9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e9:	89 d0                	mov    %edx,%eax
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	6a 00                	push   $0x0
  8016fa:	ff 75 08             	pushl  0x8(%ebp)
  8016fd:	e8 e3 01 00 00       	call   8018e5 <open>
  801702:	89 c3                	mov    %eax,%ebx
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	78 1b                	js     801726 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80170b:	83 ec 08             	sub    $0x8,%esp
  80170e:	ff 75 0c             	pushl  0xc(%ebp)
  801711:	50                   	push   %eax
  801712:	e8 5b ff ff ff       	call   801672 <fstat>
  801717:	89 c6                	mov    %eax,%esi
	close(fd);
  801719:	89 1c 24             	mov    %ebx,(%esp)
  80171c:	e8 fd fb ff ff       	call   80131e <close>
	return r;
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	89 f0                	mov    %esi,%eax
}
  801726:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801729:	5b                   	pop    %ebx
  80172a:	5e                   	pop    %esi
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	56                   	push   %esi
  801731:	53                   	push   %ebx
  801732:	89 c6                	mov    %eax,%esi
  801734:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801736:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80173d:	75 12                	jne    801751 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80173f:	83 ec 0c             	sub    $0xc,%esp
  801742:	6a 01                	push   $0x1
  801744:	e8 fc f9 ff ff       	call   801145 <ipc_find_env>
  801749:	a3 00 40 80 00       	mov    %eax,0x804000
  80174e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801751:	6a 07                	push   $0x7
  801753:	68 00 50 80 00       	push   $0x805000
  801758:	56                   	push   %esi
  801759:	ff 35 00 40 80 00    	pushl  0x804000
  80175f:	e8 8d f9 ff ff       	call   8010f1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801764:	83 c4 0c             	add    $0xc,%esp
  801767:	6a 00                	push   $0x0
  801769:	53                   	push   %ebx
  80176a:	6a 00                	push   $0x0
  80176c:	e8 17 f9 ff ff       	call   801088 <ipc_recv>
}
  801771:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801789:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801791:	ba 00 00 00 00       	mov    $0x0,%edx
  801796:	b8 02 00 00 00       	mov    $0x2,%eax
  80179b:	e8 8d ff ff ff       	call   80172d <fsipc>
}
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    

008017a2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ae:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8017bd:	e8 6b ff ff ff       	call   80172d <fsipc>
}
  8017c2:	c9                   	leave  
  8017c3:	c3                   	ret    

008017c4 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 04             	sub    $0x4,%esp
  8017cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017de:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e3:	e8 45 ff ff ff       	call   80172d <fsipc>
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 2c                	js     801818 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	68 00 50 80 00       	push   $0x805000
  8017f4:	53                   	push   %ebx
  8017f5:	e8 fb ef ff ff       	call   8007f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017fa:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801805:	a1 84 50 80 00       	mov    0x805084,%eax
  80180a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801818:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181b:	c9                   	leave  
  80181c:	c3                   	ret    

0080181d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	8b 45 10             	mov    0x10(%ebp),%eax
  801826:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80182b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801830:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801833:	8b 55 08             	mov    0x8(%ebp),%edx
  801836:	8b 52 0c             	mov    0xc(%edx),%edx
  801839:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80183f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801844:	50                   	push   %eax
  801845:	ff 75 0c             	pushl  0xc(%ebp)
  801848:	68 08 50 80 00       	push   $0x805008
  80184d:	e8 35 f1 ff ff       	call   800987 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	b8 04 00 00 00       	mov    $0x4,%eax
  80185c:	e8 cc fe ff ff       	call   80172d <fsipc>
	//panic("devfile_write not implemented");
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	56                   	push   %esi
  801867:	53                   	push   %ebx
  801868:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	8b 40 0c             	mov    0xc(%eax),%eax
  801871:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801876:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187c:	ba 00 00 00 00       	mov    $0x0,%edx
  801881:	b8 03 00 00 00       	mov    $0x3,%eax
  801886:	e8 a2 fe ff ff       	call   80172d <fsipc>
  80188b:	89 c3                	mov    %eax,%ebx
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 4b                	js     8018dc <devfile_read+0x79>
		return r;
	assert(r <= n);
  801891:	39 c6                	cmp    %eax,%esi
  801893:	73 16                	jae    8018ab <devfile_read+0x48>
  801895:	68 dc 26 80 00       	push   $0x8026dc
  80189a:	68 e3 26 80 00       	push   $0x8026e3
  80189f:	6a 7c                	push   $0x7c
  8018a1:	68 f8 26 80 00       	push   $0x8026f8
  8018a6:	e8 bd 05 00 00       	call   801e68 <_panic>
	assert(r <= PGSIZE);
  8018ab:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b0:	7e 16                	jle    8018c8 <devfile_read+0x65>
  8018b2:	68 03 27 80 00       	push   $0x802703
  8018b7:	68 e3 26 80 00       	push   $0x8026e3
  8018bc:	6a 7d                	push   $0x7d
  8018be:	68 f8 26 80 00       	push   $0x8026f8
  8018c3:	e8 a0 05 00 00       	call   801e68 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c8:	83 ec 04             	sub    $0x4,%esp
  8018cb:	50                   	push   %eax
  8018cc:	68 00 50 80 00       	push   $0x805000
  8018d1:	ff 75 0c             	pushl  0xc(%ebp)
  8018d4:	e8 ae f0 ff ff       	call   800987 <memmove>
	return r;
  8018d9:	83 c4 10             	add    $0x10,%esp
}
  8018dc:	89 d8                	mov    %ebx,%eax
  8018de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e1:	5b                   	pop    %ebx
  8018e2:	5e                   	pop    %esi
  8018e3:	5d                   	pop    %ebp
  8018e4:	c3                   	ret    

008018e5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	53                   	push   %ebx
  8018e9:	83 ec 20             	sub    $0x20,%esp
  8018ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ef:	53                   	push   %ebx
  8018f0:	e8 c7 ee ff ff       	call   8007bc <strlen>
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018fd:	7f 67                	jg     801966 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ff:	83 ec 0c             	sub    $0xc,%esp
  801902:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801905:	50                   	push   %eax
  801906:	e8 9a f8 ff ff       	call   8011a5 <fd_alloc>
  80190b:	83 c4 10             	add    $0x10,%esp
		return r;
  80190e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801910:	85 c0                	test   %eax,%eax
  801912:	78 57                	js     80196b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801914:	83 ec 08             	sub    $0x8,%esp
  801917:	53                   	push   %ebx
  801918:	68 00 50 80 00       	push   $0x805000
  80191d:	e8 d3 ee ff ff       	call   8007f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801922:	8b 45 0c             	mov    0xc(%ebp),%eax
  801925:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80192a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192d:	b8 01 00 00 00       	mov    $0x1,%eax
  801932:	e8 f6 fd ff ff       	call   80172d <fsipc>
  801937:	89 c3                	mov    %eax,%ebx
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	85 c0                	test   %eax,%eax
  80193e:	79 14                	jns    801954 <open+0x6f>
		fd_close(fd, 0);
  801940:	83 ec 08             	sub    $0x8,%esp
  801943:	6a 00                	push   $0x0
  801945:	ff 75 f4             	pushl  -0xc(%ebp)
  801948:	e8 50 f9 ff ff       	call   80129d <fd_close>
		return r;
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	89 da                	mov    %ebx,%edx
  801952:	eb 17                	jmp    80196b <open+0x86>
	}

	return fd2num(fd);
  801954:	83 ec 0c             	sub    $0xc,%esp
  801957:	ff 75 f4             	pushl  -0xc(%ebp)
  80195a:	e8 1f f8 ff ff       	call   80117e <fd2num>
  80195f:	89 c2                	mov    %eax,%edx
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	eb 05                	jmp    80196b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801966:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80196b:	89 d0                	mov    %edx,%eax
  80196d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801978:	ba 00 00 00 00       	mov    $0x0,%edx
  80197d:	b8 08 00 00 00       	mov    $0x8,%eax
  801982:	e8 a6 fd ff ff       	call   80172d <fsipc>
}
  801987:	c9                   	leave  
  801988:	c3                   	ret    

00801989 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	56                   	push   %esi
  80198d:	53                   	push   %ebx
  80198e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	ff 75 08             	pushl  0x8(%ebp)
  801997:	e8 f2 f7 ff ff       	call   80118e <fd2data>
  80199c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80199e:	83 c4 08             	add    $0x8,%esp
  8019a1:	68 0f 27 80 00       	push   $0x80270f
  8019a6:	53                   	push   %ebx
  8019a7:	e8 49 ee ff ff       	call   8007f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ac:	8b 46 04             	mov    0x4(%esi),%eax
  8019af:	2b 06                	sub    (%esi),%eax
  8019b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019be:	00 00 00 
	stat->st_dev = &devpipe;
  8019c1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019c8:	30 80 00 
	return 0;
}
  8019cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d3:	5b                   	pop    %ebx
  8019d4:	5e                   	pop    %esi
  8019d5:	5d                   	pop    %ebp
  8019d6:	c3                   	ret    

008019d7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	53                   	push   %ebx
  8019db:	83 ec 0c             	sub    $0xc,%esp
  8019de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019e1:	53                   	push   %ebx
  8019e2:	6a 00                	push   $0x0
  8019e4:	e8 94 f2 ff ff       	call   800c7d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019e9:	89 1c 24             	mov    %ebx,(%esp)
  8019ec:	e8 9d f7 ff ff       	call   80118e <fd2data>
  8019f1:	83 c4 08             	add    $0x8,%esp
  8019f4:	50                   	push   %eax
  8019f5:	6a 00                	push   $0x0
  8019f7:	e8 81 f2 ff ff       	call   800c7d <sys_page_unmap>
}
  8019fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	57                   	push   %edi
  801a05:	56                   	push   %esi
  801a06:	53                   	push   %ebx
  801a07:	83 ec 1c             	sub    $0x1c,%esp
  801a0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a0d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a0f:	a1 08 40 80 00       	mov    0x804008,%eax
  801a14:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1d:	e8 13 05 00 00       	call   801f35 <pageref>
  801a22:	89 c3                	mov    %eax,%ebx
  801a24:	89 3c 24             	mov    %edi,(%esp)
  801a27:	e8 09 05 00 00       	call   801f35 <pageref>
  801a2c:	83 c4 10             	add    $0x10,%esp
  801a2f:	39 c3                	cmp    %eax,%ebx
  801a31:	0f 94 c1             	sete   %cl
  801a34:	0f b6 c9             	movzbl %cl,%ecx
  801a37:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a3a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a40:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a43:	39 ce                	cmp    %ecx,%esi
  801a45:	74 1b                	je     801a62 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a47:	39 c3                	cmp    %eax,%ebx
  801a49:	75 c4                	jne    801a0f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a4b:	8b 42 58             	mov    0x58(%edx),%eax
  801a4e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a51:	50                   	push   %eax
  801a52:	56                   	push   %esi
  801a53:	68 16 27 80 00       	push   $0x802716
  801a58:	e8 94 e7 ff ff       	call   8001f1 <cprintf>
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	eb ad                	jmp    801a0f <_pipeisclosed+0xe>
	}
}
  801a62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5f                   	pop    %edi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	57                   	push   %edi
  801a71:	56                   	push   %esi
  801a72:	53                   	push   %ebx
  801a73:	83 ec 28             	sub    $0x28,%esp
  801a76:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a79:	56                   	push   %esi
  801a7a:	e8 0f f7 ff ff       	call   80118e <fd2data>
  801a7f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a81:	83 c4 10             	add    $0x10,%esp
  801a84:	bf 00 00 00 00       	mov    $0x0,%edi
  801a89:	eb 4b                	jmp    801ad6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a8b:	89 da                	mov    %ebx,%edx
  801a8d:	89 f0                	mov    %esi,%eax
  801a8f:	e8 6d ff ff ff       	call   801a01 <_pipeisclosed>
  801a94:	85 c0                	test   %eax,%eax
  801a96:	75 48                	jne    801ae0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a98:	e8 3c f1 ff ff       	call   800bd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a9d:	8b 43 04             	mov    0x4(%ebx),%eax
  801aa0:	8b 0b                	mov    (%ebx),%ecx
  801aa2:	8d 51 20             	lea    0x20(%ecx),%edx
  801aa5:	39 d0                	cmp    %edx,%eax
  801aa7:	73 e2                	jae    801a8b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aac:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ab0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ab3:	89 c2                	mov    %eax,%edx
  801ab5:	c1 fa 1f             	sar    $0x1f,%edx
  801ab8:	89 d1                	mov    %edx,%ecx
  801aba:	c1 e9 1b             	shr    $0x1b,%ecx
  801abd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ac0:	83 e2 1f             	and    $0x1f,%edx
  801ac3:	29 ca                	sub    %ecx,%edx
  801ac5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ac9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801acd:	83 c0 01             	add    $0x1,%eax
  801ad0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad3:	83 c7 01             	add    $0x1,%edi
  801ad6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ad9:	75 c2                	jne    801a9d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801adb:	8b 45 10             	mov    0x10(%ebp),%eax
  801ade:	eb 05                	jmp    801ae5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ae0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ae5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae8:	5b                   	pop    %ebx
  801ae9:	5e                   	pop    %esi
  801aea:	5f                   	pop    %edi
  801aeb:	5d                   	pop    %ebp
  801aec:	c3                   	ret    

00801aed <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	57                   	push   %edi
  801af1:	56                   	push   %esi
  801af2:	53                   	push   %ebx
  801af3:	83 ec 18             	sub    $0x18,%esp
  801af6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801af9:	57                   	push   %edi
  801afa:	e8 8f f6 ff ff       	call   80118e <fd2data>
  801aff:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b09:	eb 3d                	jmp    801b48 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b0b:	85 db                	test   %ebx,%ebx
  801b0d:	74 04                	je     801b13 <devpipe_read+0x26>
				return i;
  801b0f:	89 d8                	mov    %ebx,%eax
  801b11:	eb 44                	jmp    801b57 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b13:	89 f2                	mov    %esi,%edx
  801b15:	89 f8                	mov    %edi,%eax
  801b17:	e8 e5 fe ff ff       	call   801a01 <_pipeisclosed>
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	75 32                	jne    801b52 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b20:	e8 b4 f0 ff ff       	call   800bd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b25:	8b 06                	mov    (%esi),%eax
  801b27:	3b 46 04             	cmp    0x4(%esi),%eax
  801b2a:	74 df                	je     801b0b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b2c:	99                   	cltd   
  801b2d:	c1 ea 1b             	shr    $0x1b,%edx
  801b30:	01 d0                	add    %edx,%eax
  801b32:	83 e0 1f             	and    $0x1f,%eax
  801b35:	29 d0                	sub    %edx,%eax
  801b37:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b42:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b45:	83 c3 01             	add    $0x1,%ebx
  801b48:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b4b:	75 d8                	jne    801b25 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b4d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b50:	eb 05                	jmp    801b57 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b52:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5a:	5b                   	pop    %ebx
  801b5b:	5e                   	pop    %esi
  801b5c:	5f                   	pop    %edi
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6a:	50                   	push   %eax
  801b6b:	e8 35 f6 ff ff       	call   8011a5 <fd_alloc>
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	89 c2                	mov    %eax,%edx
  801b75:	85 c0                	test   %eax,%eax
  801b77:	0f 88 2c 01 00 00    	js     801ca9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7d:	83 ec 04             	sub    $0x4,%esp
  801b80:	68 07 04 00 00       	push   $0x407
  801b85:	ff 75 f4             	pushl  -0xc(%ebp)
  801b88:	6a 00                	push   $0x0
  801b8a:	e8 69 f0 ff ff       	call   800bf8 <sys_page_alloc>
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	89 c2                	mov    %eax,%edx
  801b94:	85 c0                	test   %eax,%eax
  801b96:	0f 88 0d 01 00 00    	js     801ca9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba2:	50                   	push   %eax
  801ba3:	e8 fd f5 ff ff       	call   8011a5 <fd_alloc>
  801ba8:	89 c3                	mov    %eax,%ebx
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	85 c0                	test   %eax,%eax
  801baf:	0f 88 e2 00 00 00    	js     801c97 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb5:	83 ec 04             	sub    $0x4,%esp
  801bb8:	68 07 04 00 00       	push   $0x407
  801bbd:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc0:	6a 00                	push   $0x0
  801bc2:	e8 31 f0 ff ff       	call   800bf8 <sys_page_alloc>
  801bc7:	89 c3                	mov    %eax,%ebx
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	0f 88 c3 00 00 00    	js     801c97 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bd4:	83 ec 0c             	sub    $0xc,%esp
  801bd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bda:	e8 af f5 ff ff       	call   80118e <fd2data>
  801bdf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be1:	83 c4 0c             	add    $0xc,%esp
  801be4:	68 07 04 00 00       	push   $0x407
  801be9:	50                   	push   %eax
  801bea:	6a 00                	push   $0x0
  801bec:	e8 07 f0 ff ff       	call   800bf8 <sys_page_alloc>
  801bf1:	89 c3                	mov    %eax,%ebx
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	0f 88 89 00 00 00    	js     801c87 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfe:	83 ec 0c             	sub    $0xc,%esp
  801c01:	ff 75 f0             	pushl  -0x10(%ebp)
  801c04:	e8 85 f5 ff ff       	call   80118e <fd2data>
  801c09:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c10:	50                   	push   %eax
  801c11:	6a 00                	push   $0x0
  801c13:	56                   	push   %esi
  801c14:	6a 00                	push   $0x0
  801c16:	e8 20 f0 ff ff       	call   800c3b <sys_page_map>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	83 c4 20             	add    $0x20,%esp
  801c20:	85 c0                	test   %eax,%eax
  801c22:	78 55                	js     801c79 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c24:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c32:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c39:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c42:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c47:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c4e:	83 ec 0c             	sub    $0xc,%esp
  801c51:	ff 75 f4             	pushl  -0xc(%ebp)
  801c54:	e8 25 f5 ff ff       	call   80117e <fd2num>
  801c59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c5e:	83 c4 04             	add    $0x4,%esp
  801c61:	ff 75 f0             	pushl  -0x10(%ebp)
  801c64:	e8 15 f5 ff ff       	call   80117e <fd2num>
  801c69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	ba 00 00 00 00       	mov    $0x0,%edx
  801c77:	eb 30                	jmp    801ca9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c79:	83 ec 08             	sub    $0x8,%esp
  801c7c:	56                   	push   %esi
  801c7d:	6a 00                	push   $0x0
  801c7f:	e8 f9 ef ff ff       	call   800c7d <sys_page_unmap>
  801c84:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c87:	83 ec 08             	sub    $0x8,%esp
  801c8a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8d:	6a 00                	push   $0x0
  801c8f:	e8 e9 ef ff ff       	call   800c7d <sys_page_unmap>
  801c94:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c97:	83 ec 08             	sub    $0x8,%esp
  801c9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9d:	6a 00                	push   $0x0
  801c9f:	e8 d9 ef ff ff       	call   800c7d <sys_page_unmap>
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ca9:	89 d0                	mov    %edx,%eax
  801cab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cae:	5b                   	pop    %ebx
  801caf:	5e                   	pop    %esi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    

00801cb2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbb:	50                   	push   %eax
  801cbc:	ff 75 08             	pushl  0x8(%ebp)
  801cbf:	e8 30 f5 ff ff       	call   8011f4 <fd_lookup>
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	78 18                	js     801ce3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd1:	e8 b8 f4 ff ff       	call   80118e <fd2data>
	return _pipeisclosed(fd, p);
  801cd6:	89 c2                	mov    %eax,%edx
  801cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdb:	e8 21 fd ff ff       	call   801a01 <_pipeisclosed>
  801ce0:	83 c4 10             	add    $0x10,%esp
}
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    

00801ce5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ce8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ced:	5d                   	pop    %ebp
  801cee:	c3                   	ret    

00801cef <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cf5:	68 2e 27 80 00       	push   $0x80272e
  801cfa:	ff 75 0c             	pushl  0xc(%ebp)
  801cfd:	e8 f3 ea ff ff       	call   8007f5 <strcpy>
	return 0;
}
  801d02:	b8 00 00 00 00       	mov    $0x0,%eax
  801d07:	c9                   	leave  
  801d08:	c3                   	ret    

00801d09 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	57                   	push   %edi
  801d0d:	56                   	push   %esi
  801d0e:	53                   	push   %ebx
  801d0f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d15:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d1a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d20:	eb 2d                	jmp    801d4f <devcons_write+0x46>
		m = n - tot;
  801d22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d25:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d27:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d2a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d2f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d32:	83 ec 04             	sub    $0x4,%esp
  801d35:	53                   	push   %ebx
  801d36:	03 45 0c             	add    0xc(%ebp),%eax
  801d39:	50                   	push   %eax
  801d3a:	57                   	push   %edi
  801d3b:	e8 47 ec ff ff       	call   800987 <memmove>
		sys_cputs(buf, m);
  801d40:	83 c4 08             	add    $0x8,%esp
  801d43:	53                   	push   %ebx
  801d44:	57                   	push   %edi
  801d45:	e8 f2 ed ff ff       	call   800b3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4a:	01 de                	add    %ebx,%esi
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	89 f0                	mov    %esi,%eax
  801d51:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d54:	72 cc                	jb     801d22 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d59:	5b                   	pop    %ebx
  801d5a:	5e                   	pop    %esi
  801d5b:	5f                   	pop    %edi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 08             	sub    $0x8,%esp
  801d64:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6d:	74 2a                	je     801d99 <devcons_read+0x3b>
  801d6f:	eb 05                	jmp    801d76 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d71:	e8 63 ee ff ff       	call   800bd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d76:	e8 df ed ff ff       	call   800b5a <sys_cgetc>
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	74 f2                	je     801d71 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	78 16                	js     801d99 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d83:	83 f8 04             	cmp    $0x4,%eax
  801d86:	74 0c                	je     801d94 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d88:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8b:	88 02                	mov    %al,(%edx)
	return 1;
  801d8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d92:	eb 05                	jmp    801d99 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801da1:	8b 45 08             	mov    0x8(%ebp),%eax
  801da4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801da7:	6a 01                	push   $0x1
  801da9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dac:	50                   	push   %eax
  801dad:	e8 8a ed ff ff       	call   800b3c <sys_cputs>
}
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <getchar>:

int
getchar(void)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dbd:	6a 01                	push   $0x1
  801dbf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc2:	50                   	push   %eax
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 90 f6 ff ff       	call   80145a <read>
	if (r < 0)
  801dca:	83 c4 10             	add    $0x10,%esp
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	78 0f                	js     801de0 <getchar+0x29>
		return r;
	if (r < 1)
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	7e 06                	jle    801ddb <getchar+0x24>
		return -E_EOF;
	return c;
  801dd5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dd9:	eb 05                	jmp    801de0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ddb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801deb:	50                   	push   %eax
  801dec:	ff 75 08             	pushl  0x8(%ebp)
  801def:	e8 00 f4 ff ff       	call   8011f4 <fd_lookup>
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	85 c0                	test   %eax,%eax
  801df9:	78 11                	js     801e0c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e04:	39 10                	cmp    %edx,(%eax)
  801e06:	0f 94 c0             	sete   %al
  801e09:	0f b6 c0             	movzbl %al,%eax
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <opencons>:

int
opencons(void)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e17:	50                   	push   %eax
  801e18:	e8 88 f3 ff ff       	call   8011a5 <fd_alloc>
  801e1d:	83 c4 10             	add    $0x10,%esp
		return r;
  801e20:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 3e                	js     801e64 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e26:	83 ec 04             	sub    $0x4,%esp
  801e29:	68 07 04 00 00       	push   $0x407
  801e2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e31:	6a 00                	push   $0x0
  801e33:	e8 c0 ed ff ff       	call   800bf8 <sys_page_alloc>
  801e38:	83 c4 10             	add    $0x10,%esp
		return r;
  801e3b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	78 23                	js     801e64 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e41:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e56:	83 ec 0c             	sub    $0xc,%esp
  801e59:	50                   	push   %eax
  801e5a:	e8 1f f3 ff ff       	call   80117e <fd2num>
  801e5f:	89 c2                	mov    %eax,%edx
  801e61:	83 c4 10             	add    $0x10,%esp
}
  801e64:	89 d0                	mov    %edx,%eax
  801e66:	c9                   	leave  
  801e67:	c3                   	ret    

00801e68 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	56                   	push   %esi
  801e6c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e6d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e70:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e76:	e8 3f ed ff ff       	call   800bba <sys_getenvid>
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	ff 75 0c             	pushl  0xc(%ebp)
  801e81:	ff 75 08             	pushl  0x8(%ebp)
  801e84:	56                   	push   %esi
  801e85:	50                   	push   %eax
  801e86:	68 3c 27 80 00       	push   $0x80273c
  801e8b:	e8 61 e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e90:	83 c4 18             	add    $0x18,%esp
  801e93:	53                   	push   %ebx
  801e94:	ff 75 10             	pushl  0x10(%ebp)
  801e97:	e8 04 e3 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801e9c:	c7 04 24 27 27 80 00 	movl   $0x802727,(%esp)
  801ea3:	e8 49 e3 ff ff       	call   8001f1 <cprintf>
  801ea8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eab:	cc                   	int3   
  801eac:	eb fd                	jmp    801eab <_panic+0x43>

00801eae <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eb4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ebb:	75 4a                	jne    801f07 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801ebd:	a1 08 40 80 00       	mov    0x804008,%eax
  801ec2:	8b 40 48             	mov    0x48(%eax),%eax
  801ec5:	83 ec 04             	sub    $0x4,%esp
  801ec8:	6a 07                	push   $0x7
  801eca:	68 00 f0 bf ee       	push   $0xeebff000
  801ecf:	50                   	push   %eax
  801ed0:	e8 23 ed ff ff       	call   800bf8 <sys_page_alloc>
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	79 12                	jns    801eee <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801edc:	50                   	push   %eax
  801edd:	68 60 27 80 00       	push   $0x802760
  801ee2:	6a 21                	push   $0x21
  801ee4:	68 78 27 80 00       	push   $0x802778
  801ee9:	e8 7a ff ff ff       	call   801e68 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801eee:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef3:	8b 40 48             	mov    0x48(%eax),%eax
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	68 11 1f 80 00       	push   $0x801f11
  801efe:	50                   	push   %eax
  801eff:	e8 3f ee ff ff       	call   800d43 <sys_env_set_pgfault_upcall>
  801f04:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f07:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0a:	a3 00 60 80 00       	mov    %eax,0x806000
  801f0f:	c9                   	leave  
  801f10:	c3                   	ret    

00801f11 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f11:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f12:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f17:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f19:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  801f1c:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  801f1f:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  801f23:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  801f28:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  801f2c:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f2e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  801f2f:	83 c4 04             	add    $0x4,%esp
	popfl
  801f32:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f33:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  801f34:	c3                   	ret    

00801f35 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3b:	89 d0                	mov    %edx,%eax
  801f3d:	c1 e8 16             	shr    $0x16,%eax
  801f40:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f47:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4c:	f6 c1 01             	test   $0x1,%cl
  801f4f:	74 1d                	je     801f6e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f51:	c1 ea 0c             	shr    $0xc,%edx
  801f54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f5b:	f6 c2 01             	test   $0x1,%dl
  801f5e:	74 0e                	je     801f6e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f60:	c1 ea 0c             	shr    $0xc,%edx
  801f63:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f6a:	ef 
  801f6b:	0f b7 c0             	movzwl %ax,%eax
}
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f87:	85 f6                	test   %esi,%esi
  801f89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8d:	89 ca                	mov    %ecx,%edx
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	75 3d                	jne    801fd0 <__udivdi3+0x60>
  801f93:	39 cf                	cmp    %ecx,%edi
  801f95:	0f 87 c5 00 00 00    	ja     802060 <__udivdi3+0xf0>
  801f9b:	85 ff                	test   %edi,%edi
  801f9d:	89 fd                	mov    %edi,%ebp
  801f9f:	75 0b                	jne    801fac <__udivdi3+0x3c>
  801fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa6:	31 d2                	xor    %edx,%edx
  801fa8:	f7 f7                	div    %edi
  801faa:	89 c5                	mov    %eax,%ebp
  801fac:	89 c8                	mov    %ecx,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f5                	div    %ebp
  801fb2:	89 c1                	mov    %eax,%ecx
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	89 cf                	mov    %ecx,%edi
  801fb8:	f7 f5                	div    %ebp
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	39 ce                	cmp    %ecx,%esi
  801fd2:	77 74                	ja     802048 <__udivdi3+0xd8>
  801fd4:	0f bd fe             	bsr    %esi,%edi
  801fd7:	83 f7 1f             	xor    $0x1f,%edi
  801fda:	0f 84 98 00 00 00    	je     802078 <__udivdi3+0x108>
  801fe0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	89 c5                	mov    %eax,%ebp
  801fe9:	29 fb                	sub    %edi,%ebx
  801feb:	d3 e6                	shl    %cl,%esi
  801fed:	89 d9                	mov    %ebx,%ecx
  801fef:	d3 ed                	shr    %cl,%ebp
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	d3 e0                	shl    %cl,%eax
  801ff5:	09 ee                	or     %ebp,%esi
  801ff7:	89 d9                	mov    %ebx,%ecx
  801ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffd:	89 d5                	mov    %edx,%ebp
  801fff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802003:	d3 ed                	shr    %cl,%ebp
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e2                	shl    %cl,%edx
  802009:	89 d9                	mov    %ebx,%ecx
  80200b:	d3 e8                	shr    %cl,%eax
  80200d:	09 c2                	or     %eax,%edx
  80200f:	89 d0                	mov    %edx,%eax
  802011:	89 ea                	mov    %ebp,%edx
  802013:	f7 f6                	div    %esi
  802015:	89 d5                	mov    %edx,%ebp
  802017:	89 c3                	mov    %eax,%ebx
  802019:	f7 64 24 0c          	mull   0xc(%esp)
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	72 10                	jb     802031 <__udivdi3+0xc1>
  802021:	8b 74 24 08          	mov    0x8(%esp),%esi
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e6                	shl    %cl,%esi
  802029:	39 c6                	cmp    %eax,%esi
  80202b:	73 07                	jae    802034 <__udivdi3+0xc4>
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	75 03                	jne    802034 <__udivdi3+0xc4>
  802031:	83 eb 01             	sub    $0x1,%ebx
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 d8                	mov    %ebx,%eax
  802038:	89 fa                	mov    %edi,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	31 ff                	xor    %edi,%edi
  80204a:	31 db                	xor    %ebx,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d8                	mov    %ebx,%eax
  802062:	f7 f7                	div    %edi
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 c3                	mov    %eax,%ebx
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	89 fa                	mov    %edi,%edx
  80206c:	83 c4 1c             	add    $0x1c,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	39 ce                	cmp    %ecx,%esi
  80207a:	72 0c                	jb     802088 <__udivdi3+0x118>
  80207c:	31 db                	xor    %ebx,%ebx
  80207e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802082:	0f 87 34 ff ff ff    	ja     801fbc <__udivdi3+0x4c>
  802088:	bb 01 00 00 00       	mov    $0x1,%ebx
  80208d:	e9 2a ff ff ff       	jmp    801fbc <__udivdi3+0x4c>
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f3                	mov    %esi,%ebx
  8020c3:	89 3c 24             	mov    %edi,(%esp)
  8020c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ca:	75 1c                	jne    8020e8 <__umoddi3+0x48>
  8020cc:	39 f7                	cmp    %esi,%edi
  8020ce:	76 50                	jbe    802120 <__umoddi3+0x80>
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	f7 f7                	div    %edi
  8020d6:	89 d0                	mov    %edx,%eax
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	77 52                	ja     802140 <__umoddi3+0xa0>
  8020ee:	0f bd ea             	bsr    %edx,%ebp
  8020f1:	83 f5 1f             	xor    $0x1f,%ebp
  8020f4:	75 5a                	jne    802150 <__umoddi3+0xb0>
  8020f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020fa:	0f 82 e0 00 00 00    	jb     8021e0 <__umoddi3+0x140>
  802100:	39 0c 24             	cmp    %ecx,(%esp)
  802103:	0f 86 d7 00 00 00    	jbe    8021e0 <__umoddi3+0x140>
  802109:	8b 44 24 08          	mov    0x8(%esp),%eax
  80210d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802111:	83 c4 1c             	add    $0x1c,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	85 ff                	test   %edi,%edi
  802122:	89 fd                	mov    %edi,%ebp
  802124:	75 0b                	jne    802131 <__umoddi3+0x91>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f7                	div    %edi
  80212f:	89 c5                	mov    %eax,%ebp
  802131:	89 f0                	mov    %esi,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f5                	div    %ebp
  802137:	89 c8                	mov    %ecx,%eax
  802139:	f7 f5                	div    %ebp
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	eb 99                	jmp    8020d8 <__umoddi3+0x38>
  80213f:	90                   	nop
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 1c             	add    $0x1c,%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	8b 34 24             	mov    (%esp),%esi
  802153:	bf 20 00 00 00       	mov    $0x20,%edi
  802158:	89 e9                	mov    %ebp,%ecx
  80215a:	29 ef                	sub    %ebp,%edi
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 f9                	mov    %edi,%ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	d3 ea                	shr    %cl,%edx
  802164:	89 e9                	mov    %ebp,%ecx
  802166:	09 c2                	or     %eax,%edx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 14 24             	mov    %edx,(%esp)
  80216d:	89 f2                	mov    %esi,%edx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	89 f9                	mov    %edi,%ecx
  802173:	89 54 24 04          	mov    %edx,0x4(%esp)
  802177:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	89 c6                	mov    %eax,%esi
  802181:	d3 e3                	shl    %cl,%ebx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 d0                	mov    %edx,%eax
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	09 d8                	or     %ebx,%eax
  80218d:	89 d3                	mov    %edx,%ebx
  80218f:	89 f2                	mov    %esi,%edx
  802191:	f7 34 24             	divl   (%esp)
  802194:	89 d6                	mov    %edx,%esi
  802196:	d3 e3                	shl    %cl,%ebx
  802198:	f7 64 24 04          	mull   0x4(%esp)
  80219c:	39 d6                	cmp    %edx,%esi
  80219e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a2:	89 d1                	mov    %edx,%ecx
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	72 08                	jb     8021b0 <__umoddi3+0x110>
  8021a8:	75 11                	jne    8021bb <__umoddi3+0x11b>
  8021aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ae:	73 0b                	jae    8021bb <__umoddi3+0x11b>
  8021b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021b4:	1b 14 24             	sbb    (%esp),%edx
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021bf:	29 da                	sub    %ebx,%edx
  8021c1:	19 ce                	sbb    %ecx,%esi
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 f0                	mov    %esi,%eax
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	d3 ea                	shr    %cl,%edx
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	d3 ee                	shr    %cl,%esi
  8021d1:	09 d0                	or     %edx,%eax
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	83 c4 1c             	add    $0x1c,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5f                   	pop    %edi
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    
  8021dd:	8d 76 00             	lea    0x0(%esi),%esi
  8021e0:	29 f9                	sub    %edi,%ecx
  8021e2:	19 d6                	sbb    %edx,%esi
  8021e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ec:	e9 18 ff ff ff       	jmp    802109 <__umoddi3+0x69>
