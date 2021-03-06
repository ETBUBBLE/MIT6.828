
obj/user/forktree：     文件格式 elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 53 0b 00 00       	call   800b95 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 60 13 80 00       	push   $0x801360
  80004c:	e8 7b 01 00 00       	call   8001cc <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 14 07 00 00       	call   800797 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 71 13 80 00       	push   $0x801371
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 d8 06 00 00       	call   80077d <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 c7 0d 00 00       	call   800e74 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 70 13 80 00       	push   $0x801370
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 a4 0a 00 00       	call   800b95 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 20 80 00       	mov    %eax,0x802004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
        binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 20 80 00       	mov    %eax,0x802000

    // call user main routine
    umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

    // exit gracefully
    exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012d:	6a 00                	push   $0x0
  80012f:	e8 20 0a 00 00       	call   800b54 <sys_env_destroy>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	53                   	push   %ebx
  80013d:	83 ec 04             	sub    $0x4,%esp
  800140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800143:	8b 13                	mov    (%ebx),%edx
  800145:	8d 42 01             	lea    0x1(%edx),%eax
  800148:	89 03                	mov    %eax,(%ebx)
  80014a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800151:	3d ff 00 00 00       	cmp    $0xff,%eax
  800156:	75 1a                	jne    800172 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800158:	83 ec 08             	sub    $0x8,%esp
  80015b:	68 ff 00 00 00       	push   $0xff
  800160:	8d 43 08             	lea    0x8(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	e8 ae 09 00 00       	call   800b17 <sys_cputs>
		b->idx = 0;
  800169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800184:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018b:	00 00 00 
	b.cnt = 0;
  80018e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800195:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	50                   	push   %eax
  8001a5:	68 39 01 80 00       	push   $0x800139
  8001aa:	e8 1a 01 00 00       	call   8002c9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001af:	83 c4 08             	add    $0x8,%esp
  8001b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 53 09 00 00       	call   800b17 <sys_cputs>

	return b.cnt;
}
  8001c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	50                   	push   %eax
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	e8 9d ff ff ff       	call   80017b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 1c             	sub    $0x1c,%esp
  8001e9:	89 c7                	mov    %eax,%edi
  8001eb:	89 d6                	mov    %edx,%esi
  8001ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800201:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800204:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800207:	39 d3                	cmp    %edx,%ebx
  800209:	72 05                	jb     800210 <printnum+0x30>
  80020b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80020e:	77 45                	ja     800255 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	8b 45 14             	mov    0x14(%ebp),%eax
  800219:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80021c:	53                   	push   %ebx
  80021d:	ff 75 10             	pushl  0x10(%ebp)
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	ff 75 e4             	pushl  -0x1c(%ebp)
  800226:	ff 75 e0             	pushl  -0x20(%ebp)
  800229:	ff 75 dc             	pushl  -0x24(%ebp)
  80022c:	ff 75 d8             	pushl  -0x28(%ebp)
  80022f:	e8 8c 0e 00 00       	call   8010c0 <__udivdi3>
  800234:	83 c4 18             	add    $0x18,%esp
  800237:	52                   	push   %edx
  800238:	50                   	push   %eax
  800239:	89 f2                	mov    %esi,%edx
  80023b:	89 f8                	mov    %edi,%eax
  80023d:	e8 9e ff ff ff       	call   8001e0 <printnum>
  800242:	83 c4 20             	add    $0x20,%esp
  800245:	eb 18                	jmp    80025f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	ff 75 18             	pushl  0x18(%ebp)
  80024e:	ff d7                	call   *%edi
  800250:	83 c4 10             	add    $0x10,%esp
  800253:	eb 03                	jmp    800258 <printnum+0x78>
  800255:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800258:	83 eb 01             	sub    $0x1,%ebx
  80025b:	85 db                	test   %ebx,%ebx
  80025d:	7f e8                	jg     800247 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025f:	83 ec 08             	sub    $0x8,%esp
  800262:	56                   	push   %esi
  800263:	83 ec 04             	sub    $0x4,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 79 0f 00 00       	call   8011f0 <__umoddi3>
  800277:	83 c4 14             	add    $0x14,%esp
  80027a:	0f be 80 80 13 80 00 	movsbl 0x801380(%eax),%eax
  800281:	50                   	push   %eax
  800282:	ff d7                	call   *%edi
}
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800295:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	3b 50 04             	cmp    0x4(%eax),%edx
  80029e:	73 0a                	jae    8002aa <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a8:	88 02                	mov    %al,(%edx)
}
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b5:	50                   	push   %eax
  8002b6:	ff 75 10             	pushl  0x10(%ebp)
  8002b9:	ff 75 0c             	pushl  0xc(%ebp)
  8002bc:	ff 75 08             	pushl  0x8(%ebp)
  8002bf:	e8 05 00 00 00       	call   8002c9 <vprintfmt>
	va_end(ap);
}
  8002c4:	83 c4 10             	add    $0x10,%esp
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    

008002c9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 2c             	sub    $0x2c,%esp
  8002d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002db:	eb 12                	jmp    8002ef <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002dd:	85 c0                	test   %eax,%eax
  8002df:	0f 84 42 04 00 00    	je     800727 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	53                   	push   %ebx
  8002e9:	50                   	push   %eax
  8002ea:	ff d6                	call   *%esi
  8002ec:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ef:	83 c7 01             	add    $0x1,%edi
  8002f2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f6:	83 f8 25             	cmp    $0x25,%eax
  8002f9:	75 e2                	jne    8002dd <vprintfmt+0x14>
  8002fb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ff:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800306:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800314:	b9 00 00 00 00       	mov    $0x0,%ecx
  800319:	eb 07                	jmp    800322 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8d 47 01             	lea    0x1(%edi),%eax
  800325:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800328:	0f b6 07             	movzbl (%edi),%eax
  80032b:	0f b6 d0             	movzbl %al,%edx
  80032e:	83 e8 23             	sub    $0x23,%eax
  800331:	3c 55                	cmp    $0x55,%al
  800333:	0f 87 d3 03 00 00    	ja     80070c <vprintfmt+0x443>
  800339:	0f b6 c0             	movzbl %al,%eax
  80033c:	ff 24 85 40 14 80 00 	jmp    *0x801440(,%eax,4)
  800343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800346:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034a:	eb d6                	jmp    800322 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034f:	b8 00 00 00 00       	mov    $0x0,%eax
  800354:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800357:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80035e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800361:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800364:	83 f9 09             	cmp    $0x9,%ecx
  800367:	77 3f                	ja     8003a8 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800369:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036c:	eb e9                	jmp    800357 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80036e:	8b 45 14             	mov    0x14(%ebp),%eax
  800371:	8b 00                	mov    (%eax),%eax
  800373:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8d 40 04             	lea    0x4(%eax),%eax
  80037c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800382:	eb 2a                	jmp    8003ae <vprintfmt+0xe5>
  800384:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800387:	85 c0                	test   %eax,%eax
  800389:	ba 00 00 00 00       	mov    $0x0,%edx
  80038e:	0f 49 d0             	cmovns %eax,%edx
  800391:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800397:	eb 89                	jmp    800322 <vprintfmt+0x59>
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a3:	e9 7a ff ff ff       	jmp    800322 <vprintfmt+0x59>
  8003a8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ab:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b2:	0f 89 6a ff ff ff    	jns    800322 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003be:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c5:	e9 58 ff ff ff       	jmp    800322 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ca:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d0:	e9 4d ff ff ff       	jmp    800322 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d8:	8d 78 04             	lea    0x4(%eax),%edi
  8003db:	83 ec 08             	sub    $0x8,%esp
  8003de:	53                   	push   %ebx
  8003df:	ff 30                	pushl  (%eax)
  8003e1:	ff d6                	call   *%esi
			break;
  8003e3:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ec:	e9 fe fe ff ff       	jmp    8002ef <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 78 04             	lea    0x4(%eax),%edi
  8003f7:	8b 00                	mov    (%eax),%eax
  8003f9:	99                   	cltd   
  8003fa:	31 d0                	xor    %edx,%eax
  8003fc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fe:	83 f8 08             	cmp    $0x8,%eax
  800401:	7f 0b                	jg     80040e <vprintfmt+0x145>
  800403:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  80040a:	85 d2                	test   %edx,%edx
  80040c:	75 1b                	jne    800429 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80040e:	50                   	push   %eax
  80040f:	68 98 13 80 00       	push   $0x801398
  800414:	53                   	push   %ebx
  800415:	56                   	push   %esi
  800416:	e8 91 fe ff ff       	call   8002ac <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800424:	e9 c6 fe ff ff       	jmp    8002ef <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800429:	52                   	push   %edx
  80042a:	68 a1 13 80 00       	push   $0x8013a1
  80042f:	53                   	push   %ebx
  800430:	56                   	push   %esi
  800431:	e8 76 fe ff ff       	call   8002ac <printfmt>
  800436:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800439:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043f:	e9 ab fe ff ff       	jmp    8002ef <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	83 c0 04             	add    $0x4,%eax
  80044a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800452:	85 ff                	test   %edi,%edi
  800454:	b8 91 13 80 00       	mov    $0x801391,%eax
  800459:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80045c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800460:	0f 8e 94 00 00 00    	jle    8004fa <vprintfmt+0x231>
  800466:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046a:	0f 84 98 00 00 00    	je     800508 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	ff 75 d0             	pushl  -0x30(%ebp)
  800476:	57                   	push   %edi
  800477:	e8 33 03 00 00       	call   8007af <strnlen>
  80047c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80047f:	29 c1                	sub    %eax,%ecx
  800481:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800484:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800487:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80048b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800491:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	eb 0f                	jmp    8004a4 <vprintfmt+0x1db>
					putch(padc, putdat);
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	53                   	push   %ebx
  800499:	ff 75 e0             	pushl  -0x20(%ebp)
  80049c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	83 ef 01             	sub    $0x1,%edi
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	85 ff                	test   %edi,%edi
  8004a6:	7f ed                	jg     800495 <vprintfmt+0x1cc>
  8004a8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ab:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004ae:	85 c9                	test   %ecx,%ecx
  8004b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b5:	0f 49 c1             	cmovns %ecx,%eax
  8004b8:	29 c1                	sub    %eax,%ecx
  8004ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c3:	89 cb                	mov    %ecx,%ebx
  8004c5:	eb 4d                	jmp    800514 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cb:	74 1b                	je     8004e8 <vprintfmt+0x21f>
  8004cd:	0f be c0             	movsbl %al,%eax
  8004d0:	83 e8 20             	sub    $0x20,%eax
  8004d3:	83 f8 5e             	cmp    $0x5e,%eax
  8004d6:	76 10                	jbe    8004e8 <vprintfmt+0x21f>
					putch('?', putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	ff 75 0c             	pushl  0xc(%ebp)
  8004de:	6a 3f                	push   $0x3f
  8004e0:	ff 55 08             	call   *0x8(%ebp)
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	eb 0d                	jmp    8004f5 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	ff 75 0c             	pushl  0xc(%ebp)
  8004ee:	52                   	push   %edx
  8004ef:	ff 55 08             	call   *0x8(%ebp)
  8004f2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f5:	83 eb 01             	sub    $0x1,%ebx
  8004f8:	eb 1a                	jmp    800514 <vprintfmt+0x24b>
  8004fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800500:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800503:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800506:	eb 0c                	jmp    800514 <vprintfmt+0x24b>
  800508:	89 75 08             	mov    %esi,0x8(%ebp)
  80050b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800511:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800514:	83 c7 01             	add    $0x1,%edi
  800517:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051b:	0f be d0             	movsbl %al,%edx
  80051e:	85 d2                	test   %edx,%edx
  800520:	74 23                	je     800545 <vprintfmt+0x27c>
  800522:	85 f6                	test   %esi,%esi
  800524:	78 a1                	js     8004c7 <vprintfmt+0x1fe>
  800526:	83 ee 01             	sub    $0x1,%esi
  800529:	79 9c                	jns    8004c7 <vprintfmt+0x1fe>
  80052b:	89 df                	mov    %ebx,%edi
  80052d:	8b 75 08             	mov    0x8(%ebp),%esi
  800530:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800533:	eb 18                	jmp    80054d <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	53                   	push   %ebx
  800539:	6a 20                	push   $0x20
  80053b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053d:	83 ef 01             	sub    $0x1,%edi
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	eb 08                	jmp    80054d <vprintfmt+0x284>
  800545:	89 df                	mov    %ebx,%edi
  800547:	8b 75 08             	mov    0x8(%ebp),%esi
  80054a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054d:	85 ff                	test   %edi,%edi
  80054f:	7f e4                	jg     800535 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800551:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800554:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055a:	e9 90 fd ff ff       	jmp    8002ef <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055f:	83 f9 01             	cmp    $0x1,%ecx
  800562:	7e 19                	jle    80057d <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 50 04             	mov    0x4(%eax),%edx
  80056a:	8b 00                	mov    (%eax),%eax
  80056c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 40 08             	lea    0x8(%eax),%eax
  800578:	89 45 14             	mov    %eax,0x14(%ebp)
  80057b:	eb 38                	jmp    8005b5 <vprintfmt+0x2ec>
	else if (lflag)
  80057d:	85 c9                	test   %ecx,%ecx
  80057f:	74 1b                	je     80059c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 c1                	mov    %eax,%ecx
  80058b:	c1 f9 1f             	sar    $0x1f,%ecx
  80058e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 40 04             	lea    0x4(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
  80059a:	eb 19                	jmp    8005b5 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 00                	mov    (%eax),%eax
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	89 c1                	mov    %eax,%ecx
  8005a6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 40 04             	lea    0x4(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bb:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c4:	0f 89 0e 01 00 00    	jns    8006d8 <vprintfmt+0x40f>
				putch('-', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 2d                	push   $0x2d
  8005d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d8:	f7 da                	neg    %edx
  8005da:	83 d1 00             	adc    $0x0,%ecx
  8005dd:	f7 d9                	neg    %ecx
  8005df:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e7:	e9 ec 00 00 00       	jmp    8006d8 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ec:	83 f9 01             	cmp    $0x1,%ecx
  8005ef:	7e 18                	jle    800609 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f9:	8d 40 08             	lea    0x8(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	e9 cf 00 00 00       	jmp    8006d8 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800609:	85 c9                	test   %ecx,%ecx
  80060b:	74 1a                	je     800627 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 10                	mov    (%eax),%edx
  800612:	b9 00 00 00 00       	mov    $0x0,%ecx
  800617:	8d 40 04             	lea    0x4(%eax),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80061d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800622:	e9 b1 00 00 00       	jmp    8006d8 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 10                	mov    (%eax),%edx
  80062c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800631:	8d 40 04             	lea    0x4(%eax),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800637:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063c:	e9 97 00 00 00       	jmp    8006d8 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 58                	push   $0x58
  800647:	ff d6                	call   *%esi
			putch('X', putdat);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 58                	push   $0x58
  80064f:	ff d6                	call   *%esi
			putch('X', putdat);
  800651:	83 c4 08             	add    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 58                	push   $0x58
  800657:	ff d6                	call   *%esi
			break;
  800659:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80065f:	e9 8b fc ff ff       	jmp    8002ef <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	6a 30                	push   $0x30
  80066a:	ff d6                	call   *%esi
			putch('x', putdat);
  80066c:	83 c4 08             	add    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 78                	push   $0x78
  800672:	ff d6                	call   *%esi
			num = (unsigned long long)
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 10                	mov    (%eax),%edx
  800679:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80067e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800681:	8d 40 04             	lea    0x4(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800687:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80068c:	eb 4a                	jmp    8006d8 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068e:	83 f9 01             	cmp    $0x1,%ecx
  800691:	7e 15                	jle    8006a8 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 10                	mov    (%eax),%edx
  800698:	8b 48 04             	mov    0x4(%eax),%ecx
  80069b:	8d 40 08             	lea    0x8(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a6:	eb 30                	jmp    8006d8 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006a8:	85 c9                	test   %ecx,%ecx
  8006aa:	74 17                	je     8006c3 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006bc:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c1:	eb 15                	jmp    8006d8 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cd:	8d 40 04             	lea    0x4(%eax),%eax
  8006d0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d8:	83 ec 0c             	sub    $0xc,%esp
  8006db:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006df:	57                   	push   %edi
  8006e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e3:	50                   	push   %eax
  8006e4:	51                   	push   %ecx
  8006e5:	52                   	push   %edx
  8006e6:	89 da                	mov    %ebx,%edx
  8006e8:	89 f0                	mov    %esi,%eax
  8006ea:	e8 f1 fa ff ff       	call   8001e0 <printnum>
			break;
  8006ef:	83 c4 20             	add    $0x20,%esp
  8006f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f5:	e9 f5 fb ff ff       	jmp    8002ef <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	52                   	push   %edx
  8006ff:	ff d6                	call   *%esi
			break;
  800701:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800704:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800707:	e9 e3 fb ff ff       	jmp    8002ef <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	53                   	push   %ebx
  800710:	6a 25                	push   $0x25
  800712:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 03                	jmp    80071c <vprintfmt+0x453>
  800719:	83 ef 01             	sub    $0x1,%edi
  80071c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800720:	75 f7                	jne    800719 <vprintfmt+0x450>
  800722:	e9 c8 fb ff ff       	jmp    8002ef <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800727:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072a:	5b                   	pop    %ebx
  80072b:	5e                   	pop    %esi
  80072c:	5f                   	pop    %edi
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	83 ec 18             	sub    $0x18,%esp
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800742:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800745:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074c:	85 c0                	test   %eax,%eax
  80074e:	74 26                	je     800776 <vsnprintf+0x47>
  800750:	85 d2                	test   %edx,%edx
  800752:	7e 22                	jle    800776 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800754:	ff 75 14             	pushl  0x14(%ebp)
  800757:	ff 75 10             	pushl  0x10(%ebp)
  80075a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	68 8f 02 80 00       	push   $0x80028f
  800763:	e8 61 fb ff ff       	call   8002c9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800768:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	eb 05                	jmp    80077b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800786:	50                   	push   %eax
  800787:	ff 75 10             	pushl  0x10(%ebp)
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	ff 75 08             	pushl  0x8(%ebp)
  800790:	e8 9a ff ff ff       	call   80072f <vsnprintf>
	va_end(ap);

	return rc;
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a2:	eb 03                	jmp    8007a7 <strlen+0x10>
		n++;
  8007a4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ab:	75 f7                	jne    8007a4 <strlen+0xd>
		n++;
	return n;
}
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bd:	eb 03                	jmp    8007c2 <strnlen+0x13>
		n++;
  8007bf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c2:	39 c2                	cmp    %eax,%edx
  8007c4:	74 08                	je     8007ce <strnlen+0x1f>
  8007c6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ca:	75 f3                	jne    8007bf <strnlen+0x10>
  8007cc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007da:	89 c2                	mov    %eax,%edx
  8007dc:	83 c2 01             	add    $0x1,%edx
  8007df:	83 c1 01             	add    $0x1,%ecx
  8007e2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e9:	84 db                	test   %bl,%bl
  8007eb:	75 ef                	jne    8007dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ed:	5b                   	pop    %ebx
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f7:	53                   	push   %ebx
  8007f8:	e8 9a ff ff ff       	call   800797 <strlen>
  8007fd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800800:	ff 75 0c             	pushl  0xc(%ebp)
  800803:	01 d8                	add    %ebx,%eax
  800805:	50                   	push   %eax
  800806:	e8 c5 ff ff ff       	call   8007d0 <strcpy>
	return dst;
}
  80080b:	89 d8                	mov    %ebx,%eax
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 75 08             	mov    0x8(%ebp),%esi
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081d:	89 f3                	mov    %esi,%ebx
  80081f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800822:	89 f2                	mov    %esi,%edx
  800824:	eb 0f                	jmp    800835 <strncpy+0x23>
		*dst++ = *src;
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	0f b6 01             	movzbl (%ecx),%eax
  80082c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082f:	80 39 01             	cmpb   $0x1,(%ecx)
  800832:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800835:	39 da                	cmp    %ebx,%edx
  800837:	75 ed                	jne    800826 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800839:	89 f0                	mov    %esi,%eax
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 75 08             	mov    0x8(%ebp),%esi
  800847:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084a:	8b 55 10             	mov    0x10(%ebp),%edx
  80084d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084f:	85 d2                	test   %edx,%edx
  800851:	74 21                	je     800874 <strlcpy+0x35>
  800853:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800857:	89 f2                	mov    %esi,%edx
  800859:	eb 09                	jmp    800864 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085b:	83 c2 01             	add    $0x1,%edx
  80085e:	83 c1 01             	add    $0x1,%ecx
  800861:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800864:	39 c2                	cmp    %eax,%edx
  800866:	74 09                	je     800871 <strlcpy+0x32>
  800868:	0f b6 19             	movzbl (%ecx),%ebx
  80086b:	84 db                	test   %bl,%bl
  80086d:	75 ec                	jne    80085b <strlcpy+0x1c>
  80086f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800871:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800874:	29 f0                	sub    %esi,%eax
}
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800883:	eb 06                	jmp    80088b <strcmp+0x11>
		p++, q++;
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088b:	0f b6 01             	movzbl (%ecx),%eax
  80088e:	84 c0                	test   %al,%al
  800890:	74 04                	je     800896 <strcmp+0x1c>
  800892:	3a 02                	cmp    (%edx),%al
  800894:	74 ef                	je     800885 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800896:	0f b6 c0             	movzbl %al,%eax
  800899:	0f b6 12             	movzbl (%edx),%edx
  80089c:	29 d0                	sub    %edx,%eax
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	89 c3                	mov    %eax,%ebx
  8008ac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008af:	eb 06                	jmp    8008b7 <strncmp+0x17>
		n--, p++, q++;
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b7:	39 d8                	cmp    %ebx,%eax
  8008b9:	74 15                	je     8008d0 <strncmp+0x30>
  8008bb:	0f b6 08             	movzbl (%eax),%ecx
  8008be:	84 c9                	test   %cl,%cl
  8008c0:	74 04                	je     8008c6 <strncmp+0x26>
  8008c2:	3a 0a                	cmp    (%edx),%cl
  8008c4:	74 eb                	je     8008b1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 00             	movzbl (%eax),%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
  8008ce:	eb 05                	jmp    8008d5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d5:	5b                   	pop    %ebx
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e2:	eb 07                	jmp    8008eb <strchr+0x13>
		if (*s == c)
  8008e4:	38 ca                	cmp    %cl,%dl
  8008e6:	74 0f                	je     8008f7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e8:	83 c0 01             	add    $0x1,%eax
  8008eb:	0f b6 10             	movzbl (%eax),%edx
  8008ee:	84 d2                	test   %dl,%dl
  8008f0:	75 f2                	jne    8008e4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800903:	eb 03                	jmp    800908 <strfind+0xf>
  800905:	83 c0 01             	add    $0x1,%eax
  800908:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090b:	38 ca                	cmp    %cl,%dl
  80090d:	74 04                	je     800913 <strfind+0x1a>
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f2                	jne    800905 <strfind+0xc>
			break;
	return (char *) s;
}
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800921:	85 c9                	test   %ecx,%ecx
  800923:	74 36                	je     80095b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800925:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092b:	75 28                	jne    800955 <memset+0x40>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 23                	jne    800955 <memset+0x40>
		c &= 0xFF;
  800932:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800936:	89 d3                	mov    %edx,%ebx
  800938:	c1 e3 08             	shl    $0x8,%ebx
  80093b:	89 d6                	mov    %edx,%esi
  80093d:	c1 e6 18             	shl    $0x18,%esi
  800940:	89 d0                	mov    %edx,%eax
  800942:	c1 e0 10             	shl    $0x10,%eax
  800945:	09 f0                	or     %esi,%eax
  800947:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800949:	89 d8                	mov    %ebx,%eax
  80094b:	09 d0                	or     %edx,%eax
  80094d:	c1 e9 02             	shr    $0x2,%ecx
  800950:	fc                   	cld    
  800951:	f3 ab                	rep stos %eax,%es:(%edi)
  800953:	eb 06                	jmp    80095b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
  800958:	fc                   	cld    
  800959:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095b:	89 f8                	mov    %edi,%eax
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5f                   	pop    %edi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	57                   	push   %edi
  800966:	56                   	push   %esi
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800970:	39 c6                	cmp    %eax,%esi
  800972:	73 35                	jae    8009a9 <memmove+0x47>
  800974:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800977:	39 d0                	cmp    %edx,%eax
  800979:	73 2e                	jae    8009a9 <memmove+0x47>
		s += n;
		d += n;
  80097b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097e:	89 d6                	mov    %edx,%esi
  800980:	09 fe                	or     %edi,%esi
  800982:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800988:	75 13                	jne    80099d <memmove+0x3b>
  80098a:	f6 c1 03             	test   $0x3,%cl
  80098d:	75 0e                	jne    80099d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80098f:	83 ef 04             	sub    $0x4,%edi
  800992:	8d 72 fc             	lea    -0x4(%edx),%esi
  800995:	c1 e9 02             	shr    $0x2,%ecx
  800998:	fd                   	std    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 09                	jmp    8009a6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099d:	83 ef 01             	sub    $0x1,%edi
  8009a0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a3:	fd                   	std    
  8009a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a6:	fc                   	cld    
  8009a7:	eb 1d                	jmp    8009c6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a9:	89 f2                	mov    %esi,%edx
  8009ab:	09 c2                	or     %eax,%edx
  8009ad:	f6 c2 03             	test   $0x3,%dl
  8009b0:	75 0f                	jne    8009c1 <memmove+0x5f>
  8009b2:	f6 c1 03             	test   $0x3,%cl
  8009b5:	75 0a                	jne    8009c1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
  8009ba:	89 c7                	mov    %eax,%edi
  8009bc:	fc                   	cld    
  8009bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bf:	eb 05                	jmp    8009c6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c1:	89 c7                	mov    %eax,%edi
  8009c3:	fc                   	cld    
  8009c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c6:	5e                   	pop    %esi
  8009c7:	5f                   	pop    %edi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009cd:	ff 75 10             	pushl  0x10(%ebp)
  8009d0:	ff 75 0c             	pushl  0xc(%ebp)
  8009d3:	ff 75 08             	pushl  0x8(%ebp)
  8009d6:	e8 87 ff ff ff       	call   800962 <memmove>
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e8:	89 c6                	mov    %eax,%esi
  8009ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ed:	eb 1a                	jmp    800a09 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ef:	0f b6 08             	movzbl (%eax),%ecx
  8009f2:	0f b6 1a             	movzbl (%edx),%ebx
  8009f5:	38 d9                	cmp    %bl,%cl
  8009f7:	74 0a                	je     800a03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f9:	0f b6 c1             	movzbl %cl,%eax
  8009fc:	0f b6 db             	movzbl %bl,%ebx
  8009ff:	29 d8                	sub    %ebx,%eax
  800a01:	eb 0f                	jmp    800a12 <memcmp+0x35>
		s1++, s2++;
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a09:	39 f0                	cmp    %esi,%eax
  800a0b:	75 e2                	jne    8009ef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	53                   	push   %ebx
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a1d:	89 c1                	mov    %eax,%ecx
  800a1f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a22:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a26:	eb 0a                	jmp    800a32 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a28:	0f b6 10             	movzbl (%eax),%edx
  800a2b:	39 da                	cmp    %ebx,%edx
  800a2d:	74 07                	je     800a36 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2f:	83 c0 01             	add    $0x1,%eax
  800a32:	39 c8                	cmp    %ecx,%eax
  800a34:	72 f2                	jb     800a28 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a36:	5b                   	pop    %ebx
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a45:	eb 03                	jmp    800a4a <strtol+0x11>
		s++;
  800a47:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4a:	0f b6 01             	movzbl (%ecx),%eax
  800a4d:	3c 20                	cmp    $0x20,%al
  800a4f:	74 f6                	je     800a47 <strtol+0xe>
  800a51:	3c 09                	cmp    $0x9,%al
  800a53:	74 f2                	je     800a47 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a55:	3c 2b                	cmp    $0x2b,%al
  800a57:	75 0a                	jne    800a63 <strtol+0x2a>
		s++;
  800a59:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a61:	eb 11                	jmp    800a74 <strtol+0x3b>
  800a63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a68:	3c 2d                	cmp    $0x2d,%al
  800a6a:	75 08                	jne    800a74 <strtol+0x3b>
		s++, neg = 1;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a74:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7a:	75 15                	jne    800a91 <strtol+0x58>
  800a7c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7f:	75 10                	jne    800a91 <strtol+0x58>
  800a81:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a85:	75 7c                	jne    800b03 <strtol+0xca>
		s += 2, base = 16;
  800a87:	83 c1 02             	add    $0x2,%ecx
  800a8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8f:	eb 16                	jmp    800aa7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a91:	85 db                	test   %ebx,%ebx
  800a93:	75 12                	jne    800aa7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a95:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9d:	75 08                	jne    800aa7 <strtol+0x6e>
		s++, base = 8;
  800a9f:	83 c1 01             	add    $0x1,%ecx
  800aa2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aac:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aaf:	0f b6 11             	movzbl (%ecx),%edx
  800ab2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab5:	89 f3                	mov    %esi,%ebx
  800ab7:	80 fb 09             	cmp    $0x9,%bl
  800aba:	77 08                	ja     800ac4 <strtol+0x8b>
			dig = *s - '0';
  800abc:	0f be d2             	movsbl %dl,%edx
  800abf:	83 ea 30             	sub    $0x30,%edx
  800ac2:	eb 22                	jmp    800ae6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ac4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac7:	89 f3                	mov    %esi,%ebx
  800ac9:	80 fb 19             	cmp    $0x19,%bl
  800acc:	77 08                	ja     800ad6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ace:	0f be d2             	movsbl %dl,%edx
  800ad1:	83 ea 57             	sub    $0x57,%edx
  800ad4:	eb 10                	jmp    800ae6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ad6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	80 fb 19             	cmp    $0x19,%bl
  800ade:	77 16                	ja     800af6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae0:	0f be d2             	movsbl %dl,%edx
  800ae3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae9:	7d 0b                	jge    800af6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af4:	eb b9                	jmp    800aaf <strtol+0x76>

	if (endptr)
  800af6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afa:	74 0d                	je     800b09 <strtol+0xd0>
		*endptr = (char *) s;
  800afc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aff:	89 0e                	mov    %ecx,(%esi)
  800b01:	eb 06                	jmp    800b09 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b03:	85 db                	test   %ebx,%ebx
  800b05:	74 98                	je     800a9f <strtol+0x66>
  800b07:	eb 9e                	jmp    800aa7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b09:	89 c2                	mov    %eax,%edx
  800b0b:	f7 da                	neg    %edx
  800b0d:	85 ff                	test   %edi,%edi
  800b0f:	0f 45 c2             	cmovne %edx,%eax
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b25:	8b 55 08             	mov    0x8(%ebp),%edx
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	89 c7                	mov    %eax,%edi
  800b2c:	89 c6                	mov    %eax,%esi
  800b2e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b40:	b8 01 00 00 00       	mov    $0x1,%eax
  800b45:	89 d1                	mov    %edx,%ecx
  800b47:	89 d3                	mov    %edx,%ebx
  800b49:	89 d7                	mov    %edx,%edi
  800b4b:	89 d6                	mov    %edx,%esi
  800b4d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b62:	b8 03 00 00 00       	mov    $0x3,%eax
  800b67:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6a:	89 cb                	mov    %ecx,%ebx
  800b6c:	89 cf                	mov    %ecx,%edi
  800b6e:	89 ce                	mov    %ecx,%esi
  800b70:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b72:	85 c0                	test   %eax,%eax
  800b74:	7e 17                	jle    800b8d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b76:	83 ec 0c             	sub    $0xc,%esp
  800b79:	50                   	push   %eax
  800b7a:	6a 03                	push   $0x3
  800b7c:	68 c4 15 80 00       	push   $0x8015c4
  800b81:	6a 23                	push   $0x23
  800b83:	68 e1 15 80 00       	push   $0x8015e1
  800b88:	e8 5b 04 00 00       	call   800fe8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba5:	89 d1                	mov    %edx,%ecx
  800ba7:	89 d3                	mov    %edx,%ebx
  800ba9:	89 d7                	mov    %edx,%edi
  800bab:	89 d6                	mov    %edx,%esi
  800bad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_yield>:

void
sys_yield(void)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bc4:	89 d1                	mov    %edx,%ecx
  800bc6:	89 d3                	mov    %edx,%ebx
  800bc8:	89 d7                	mov    %edx,%edi
  800bca:	89 d6                	mov    %edx,%esi
  800bcc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	be 00 00 00 00       	mov    $0x0,%esi
  800be1:	b8 04 00 00 00       	mov    $0x4,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bef:	89 f7                	mov    %esi,%edi
  800bf1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 17                	jle    800c0e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	50                   	push   %eax
  800bfb:	6a 04                	push   $0x4
  800bfd:	68 c4 15 80 00       	push   $0x8015c4
  800c02:	6a 23                	push   $0x23
  800c04:	68 e1 15 80 00       	push   $0x8015e1
  800c09:	e8 da 03 00 00       	call   800fe8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c27:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c30:	8b 75 18             	mov    0x18(%ebp),%esi
  800c33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c35:	85 c0                	test   %eax,%eax
  800c37:	7e 17                	jle    800c50 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c39:	83 ec 0c             	sub    $0xc,%esp
  800c3c:	50                   	push   %eax
  800c3d:	6a 05                	push   $0x5
  800c3f:	68 c4 15 80 00       	push   $0x8015c4
  800c44:	6a 23                	push   $0x23
  800c46:	68 e1 15 80 00       	push   $0x8015e1
  800c4b:	e8 98 03 00 00       	call   800fe8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c66:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	89 df                	mov    %ebx,%edi
  800c73:	89 de                	mov    %ebx,%esi
  800c75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7e 17                	jle    800c92 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	50                   	push   %eax
  800c7f:	6a 06                	push   $0x6
  800c81:	68 c4 15 80 00       	push   $0x8015c4
  800c86:	6a 23                	push   $0x23
  800c88:	68 e1 15 80 00       	push   $0x8015e1
  800c8d:	e8 56 03 00 00       	call   800fe8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 df                	mov    %ebx,%edi
  800cb5:	89 de                	mov    %ebx,%esi
  800cb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 17                	jle    800cd4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	50                   	push   %eax
  800cc1:	6a 08                	push   $0x8
  800cc3:	68 c4 15 80 00       	push   $0x8015c4
  800cc8:	6a 23                	push   $0x23
  800cca:	68 e1 15 80 00       	push   $0x8015e1
  800ccf:	e8 14 03 00 00       	call   800fe8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cea:	b8 09 00 00 00       	mov    $0x9,%eax
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 df                	mov    %ebx,%edi
  800cf7:	89 de                	mov    %ebx,%esi
  800cf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 17                	jle    800d16 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	50                   	push   %eax
  800d03:	6a 09                	push   $0x9
  800d05:	68 c4 15 80 00       	push   $0x8015c4
  800d0a:	6a 23                	push   $0x23
  800d0c:	68 e1 15 80 00       	push   $0x8015e1
  800d11:	e8 d2 02 00 00       	call   800fe8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	be 00 00 00 00       	mov    $0x0,%esi
  800d29:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d37:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	89 cb                	mov    %ecx,%ebx
  800d59:	89 cf                	mov    %ecx,%edi
  800d5b:	89 ce                	mov    %ecx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 0c                	push   $0xc
  800d69:	68 c4 15 80 00       	push   $0x8015c4
  800d6e:	6a 23                	push   $0x23
  800d70:	68 e1 15 80 00       	push   $0x8015e1
  800d75:	e8 6e 02 00 00       	call   800fe8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	53                   	push   %ebx
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d8c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800d8e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d92:	74 2d                	je     800dc1 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800d94:	89 d8                	mov    %ebx,%eax
  800d96:	c1 e8 16             	shr    $0x16,%eax
  800d99:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800da0:	a8 01                	test   $0x1,%al
  800da2:	74 1d                	je     800dc1 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800da4:	89 d8                	mov    %ebx,%eax
  800da6:	c1 e8 0c             	shr    $0xc,%eax
  800da9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800db0:	f6 c2 01             	test   $0x1,%dl
  800db3:	74 0c                	je     800dc1 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800db5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800dbc:	f6 c4 08             	test   $0x8,%ah
  800dbf:	75 14                	jne    800dd5 <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800dc1:	83 ec 04             	sub    $0x4,%esp
  800dc4:	68 f0 15 80 00       	push   $0x8015f0
  800dc9:	6a 1f                	push   $0x1f
  800dcb:	68 26 16 80 00       	push   $0x801626
  800dd0:	e8 13 02 00 00       	call   800fe8 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800dd5:	83 ec 04             	sub    $0x4,%esp
  800dd8:	6a 07                	push   $0x7
  800dda:	68 00 f0 7f 00       	push   $0x7ff000
  800ddf:	6a 00                	push   $0x0
  800de1:	e8 ed fd ff ff       	call   800bd3 <sys_page_alloc>
  800de6:	83 c4 10             	add    $0x10,%esp
  800de9:	85 c0                	test   %eax,%eax
  800deb:	79 12                	jns    800dff <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800ded:	50                   	push   %eax
  800dee:	68 31 16 80 00       	push   $0x801631
  800df3:	6a 29                	push   $0x29
  800df5:	68 26 16 80 00       	push   $0x801626
  800dfa:	e8 e9 01 00 00       	call   800fe8 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800dff:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800e05:	83 ec 04             	sub    $0x4,%esp
  800e08:	68 00 10 00 00       	push   $0x1000
  800e0d:	53                   	push   %ebx
  800e0e:	68 00 f0 7f 00       	push   $0x7ff000
  800e13:	e8 b2 fb ff ff       	call   8009ca <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800e18:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e1f:	53                   	push   %ebx
  800e20:	6a 00                	push   $0x0
  800e22:	68 00 f0 7f 00       	push   $0x7ff000
  800e27:	6a 00                	push   $0x0
  800e29:	e8 e8 fd ff ff       	call   800c16 <sys_page_map>
  800e2e:	83 c4 20             	add    $0x20,%esp
  800e31:	85 c0                	test   %eax,%eax
  800e33:	79 12                	jns    800e47 <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800e35:	50                   	push   %eax
  800e36:	68 45 16 80 00       	push   $0x801645
  800e3b:	6a 2e                	push   $0x2e
  800e3d:	68 26 16 80 00       	push   $0x801626
  800e42:	e8 a1 01 00 00       	call   800fe8 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800e47:	83 ec 08             	sub    $0x8,%esp
  800e4a:	68 00 f0 7f 00       	push   $0x7ff000
  800e4f:	6a 00                	push   $0x0
  800e51:	e8 02 fe ff ff       	call   800c58 <sys_page_unmap>
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	79 12                	jns    800e6f <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800e5d:	50                   	push   %eax
  800e5e:	68 57 16 80 00       	push   $0x801657
  800e63:	6a 30                	push   $0x30
  800e65:	68 26 16 80 00       	push   $0x801626
  800e6a:	e8 79 01 00 00       	call   800fe8 <_panic>
	//panic("pgfault not implemented");
}
  800e6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
  800e7a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800e7d:	68 82 0d 80 00       	push   $0x800d82
  800e82:	e8 a7 01 00 00       	call   80102e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e87:	b8 07 00 00 00       	mov    $0x7,%eax
  800e8c:	cd 30                	int    $0x30
  800e8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	85 c0                	test   %eax,%eax
  800e96:	79 14                	jns    800eac <fork+0x38>
		panic("sys_exofork failed");
  800e98:	83 ec 04             	sub    $0x4,%esp
  800e9b:	68 6b 16 80 00       	push   $0x80166b
  800ea0:	6a 6d                	push   $0x6d
  800ea2:	68 26 16 80 00       	push   $0x801626
  800ea7:	e8 3c 01 00 00       	call   800fe8 <_panic>
  800eac:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800eae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eb2:	0f 8e f2 00 00 00    	jle    800faa <fork+0x136>
  800eb8:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800ebd:	89 d8                	mov    %ebx,%eax
  800ebf:	c1 e8 0a             	shr    $0xa,%eax
  800ec2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ec9:	a8 01                	test   $0x1,%al
  800ecb:	0f 84 86 00 00 00    	je     800f57 <fork+0xe3>
  800ed1:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ed8:	a8 01                	test   $0x1,%al
  800eda:	74 7b                	je     800f57 <fork+0xe3>
  800edc:	89 de                	mov    %ebx,%esi
  800ede:	c1 e6 0c             	shl    $0xc,%esi
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);

	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800ee1:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ee8:	a8 02                	test   $0x2,%al
  800eea:	75 0c                	jne    800ef8 <fork+0x84>
  800eec:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ef3:	f6 c4 08             	test   $0x8,%ah
  800ef6:	74 3f                	je     800f37 <fork+0xc3>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	68 05 08 00 00       	push   $0x805
  800f00:	56                   	push   %esi
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	6a 00                	push   $0x0
  800f05:	e8 0c fd ff ff       	call   800c16 <sys_page_map>
  800f0a:	83 c4 20             	add    $0x20,%esp
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	0f 88 b1 00 00 00    	js     800fc6 <fork+0x152>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	68 05 08 00 00       	push   $0x805
  800f1d:	56                   	push   %esi
  800f1e:	6a 00                	push   $0x0
  800f20:	56                   	push   %esi
  800f21:	6a 00                	push   $0x0
  800f23:	e8 ee fc ff ff       	call   800c16 <sys_page_map>
  800f28:	83 c4 20             	add    $0x20,%esp
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f32:	0f 4f c1             	cmovg  %ecx,%eax
  800f35:	eb 1c                	jmp    800f53 <fork+0xdf>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  800f37:	83 ec 0c             	sub    $0xc,%esp
  800f3a:	6a 05                	push   $0x5
  800f3c:	56                   	push   %esi
  800f3d:	57                   	push   %edi
  800f3e:	56                   	push   %esi
  800f3f:	6a 00                	push   $0x0
  800f41:	e8 d0 fc ff ff       	call   800c16 <sys_page_map>
  800f46:	83 c4 20             	add    $0x20,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f50:	0f 4f c2             	cmovg  %edx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  800f53:	85 c0                	test   %eax,%eax
  800f55:	78 6f                	js     800fc6 <fork+0x152>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  800f57:	83 c3 01             	add    $0x1,%ebx
  800f5a:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800f60:	0f 85 57 ff ff ff    	jne    800ebd <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  800f66:	83 ec 04             	sub    $0x4,%esp
  800f69:	6a 07                	push   $0x7
  800f6b:	68 00 f0 bf ee       	push   $0xeebff000
  800f70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f73:	57                   	push   %edi
  800f74:	e8 5a fc ff ff       	call   800bd3 <sys_page_alloc>
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 46                	js     800fc6 <fork+0x152>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  800f80:	83 ec 08             	sub    $0x8,%esp
  800f83:	68 91 10 80 00       	push   $0x801091
  800f88:	57                   	push   %edi
  800f89:	e8 4e fd ff ff       	call   800cdc <sys_env_set_pgfault_upcall>
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	78 31                	js     800fc6 <fork+0x152>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  800f95:	83 ec 08             	sub    $0x8,%esp
  800f98:	6a 02                	push   $0x2
  800f9a:	57                   	push   %edi
  800f9b:	e8 fa fc ff ff       	call   800c9a <sys_env_set_status>
  800fa0:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	0f 49 c7             	cmovns %edi,%eax
  800fa8:	eb 1c                	jmp    800fc6 <fork+0x152>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  800faa:	e8 e6 fb ff ff       	call   800b95 <sys_getenvid>
  800faf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fb7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fbc:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800fc1:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  800fc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <sfork>:

// Challenge!
int
sfork(void)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fd4:	68 7e 16 80 00       	push   $0x80167e
  800fd9:	68 8b 00 00 00       	push   $0x8b
  800fde:	68 26 16 80 00       	push   $0x801626
  800fe3:	e8 00 00 00 00       	call   800fe8 <_panic>

00800fe8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ff0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ff6:	e8 9a fb ff ff       	call   800b95 <sys_getenvid>
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	ff 75 0c             	pushl  0xc(%ebp)
  801001:	ff 75 08             	pushl  0x8(%ebp)
  801004:	56                   	push   %esi
  801005:	50                   	push   %eax
  801006:	68 94 16 80 00       	push   $0x801694
  80100b:	e8 bc f1 ff ff       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801010:	83 c4 18             	add    $0x18,%esp
  801013:	53                   	push   %ebx
  801014:	ff 75 10             	pushl  0x10(%ebp)
  801017:	e8 5f f1 ff ff       	call   80017b <vcprintf>
	cprintf("\n");
  80101c:	c7 04 24 6f 13 80 00 	movl   $0x80136f,(%esp)
  801023:	e8 a4 f1 ff ff       	call   8001cc <cprintf>
  801028:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80102b:	cc                   	int3   
  80102c:	eb fd                	jmp    80102b <_panic+0x43>

0080102e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801034:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80103b:	75 4a                	jne    801087 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  80103d:	a1 04 20 80 00       	mov    0x802004,%eax
  801042:	8b 40 48             	mov    0x48(%eax),%eax
  801045:	83 ec 04             	sub    $0x4,%esp
  801048:	6a 07                	push   $0x7
  80104a:	68 00 f0 bf ee       	push   $0xeebff000
  80104f:	50                   	push   %eax
  801050:	e8 7e fb ff ff       	call   800bd3 <sys_page_alloc>
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	85 c0                	test   %eax,%eax
  80105a:	79 12                	jns    80106e <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  80105c:	50                   	push   %eax
  80105d:	68 b8 16 80 00       	push   $0x8016b8
  801062:	6a 21                	push   $0x21
  801064:	68 d0 16 80 00       	push   $0x8016d0
  801069:	e8 7a ff ff ff       	call   800fe8 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80106e:	a1 04 20 80 00       	mov    0x802004,%eax
  801073:	8b 40 48             	mov    0x48(%eax),%eax
  801076:	83 ec 08             	sub    $0x8,%esp
  801079:	68 91 10 80 00       	push   $0x801091
  80107e:	50                   	push   %eax
  80107f:	e8 58 fc ff ff       	call   800cdc <sys_env_set_pgfault_upcall>
  801084:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	a3 08 20 80 00       	mov    %eax,0x802008
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801091:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801092:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801097:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801099:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  80109c:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  80109f:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  8010a3:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  8010a8:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  8010ac:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8010ae:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  8010af:	83 c4 04             	add    $0x4,%esp
	popfl
  8010b2:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8010b3:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  8010b4:	c3                   	ret    
  8010b5:	66 90                	xchg   %ax,%ax
  8010b7:	66 90                	xchg   %ax,%ax
  8010b9:	66 90                	xchg   %ax,%ax
  8010bb:	66 90                	xchg   %ax,%ax
  8010bd:	66 90                	xchg   %ax,%ax
  8010bf:	90                   	nop

008010c0 <__udivdi3>:
  8010c0:	55                   	push   %ebp
  8010c1:	57                   	push   %edi
  8010c2:	56                   	push   %esi
  8010c3:	53                   	push   %ebx
  8010c4:	83 ec 1c             	sub    $0x1c,%esp
  8010c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8010cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8010cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8010d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8010d7:	85 f6                	test   %esi,%esi
  8010d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010dd:	89 ca                	mov    %ecx,%edx
  8010df:	89 f8                	mov    %edi,%eax
  8010e1:	75 3d                	jne    801120 <__udivdi3+0x60>
  8010e3:	39 cf                	cmp    %ecx,%edi
  8010e5:	0f 87 c5 00 00 00    	ja     8011b0 <__udivdi3+0xf0>
  8010eb:	85 ff                	test   %edi,%edi
  8010ed:	89 fd                	mov    %edi,%ebp
  8010ef:	75 0b                	jne    8010fc <__udivdi3+0x3c>
  8010f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f6:	31 d2                	xor    %edx,%edx
  8010f8:	f7 f7                	div    %edi
  8010fa:	89 c5                	mov    %eax,%ebp
  8010fc:	89 c8                	mov    %ecx,%eax
  8010fe:	31 d2                	xor    %edx,%edx
  801100:	f7 f5                	div    %ebp
  801102:	89 c1                	mov    %eax,%ecx
  801104:	89 d8                	mov    %ebx,%eax
  801106:	89 cf                	mov    %ecx,%edi
  801108:	f7 f5                	div    %ebp
  80110a:	89 c3                	mov    %eax,%ebx
  80110c:	89 d8                	mov    %ebx,%eax
  80110e:	89 fa                	mov    %edi,%edx
  801110:	83 c4 1c             	add    $0x1c,%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    
  801118:	90                   	nop
  801119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801120:	39 ce                	cmp    %ecx,%esi
  801122:	77 74                	ja     801198 <__udivdi3+0xd8>
  801124:	0f bd fe             	bsr    %esi,%edi
  801127:	83 f7 1f             	xor    $0x1f,%edi
  80112a:	0f 84 98 00 00 00    	je     8011c8 <__udivdi3+0x108>
  801130:	bb 20 00 00 00       	mov    $0x20,%ebx
  801135:	89 f9                	mov    %edi,%ecx
  801137:	89 c5                	mov    %eax,%ebp
  801139:	29 fb                	sub    %edi,%ebx
  80113b:	d3 e6                	shl    %cl,%esi
  80113d:	89 d9                	mov    %ebx,%ecx
  80113f:	d3 ed                	shr    %cl,%ebp
  801141:	89 f9                	mov    %edi,%ecx
  801143:	d3 e0                	shl    %cl,%eax
  801145:	09 ee                	or     %ebp,%esi
  801147:	89 d9                	mov    %ebx,%ecx
  801149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80114d:	89 d5                	mov    %edx,%ebp
  80114f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801153:	d3 ed                	shr    %cl,%ebp
  801155:	89 f9                	mov    %edi,%ecx
  801157:	d3 e2                	shl    %cl,%edx
  801159:	89 d9                	mov    %ebx,%ecx
  80115b:	d3 e8                	shr    %cl,%eax
  80115d:	09 c2                	or     %eax,%edx
  80115f:	89 d0                	mov    %edx,%eax
  801161:	89 ea                	mov    %ebp,%edx
  801163:	f7 f6                	div    %esi
  801165:	89 d5                	mov    %edx,%ebp
  801167:	89 c3                	mov    %eax,%ebx
  801169:	f7 64 24 0c          	mull   0xc(%esp)
  80116d:	39 d5                	cmp    %edx,%ebp
  80116f:	72 10                	jb     801181 <__udivdi3+0xc1>
  801171:	8b 74 24 08          	mov    0x8(%esp),%esi
  801175:	89 f9                	mov    %edi,%ecx
  801177:	d3 e6                	shl    %cl,%esi
  801179:	39 c6                	cmp    %eax,%esi
  80117b:	73 07                	jae    801184 <__udivdi3+0xc4>
  80117d:	39 d5                	cmp    %edx,%ebp
  80117f:	75 03                	jne    801184 <__udivdi3+0xc4>
  801181:	83 eb 01             	sub    $0x1,%ebx
  801184:	31 ff                	xor    %edi,%edi
  801186:	89 d8                	mov    %ebx,%eax
  801188:	89 fa                	mov    %edi,%edx
  80118a:	83 c4 1c             	add    $0x1c,%esp
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    
  801192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801198:	31 ff                	xor    %edi,%edi
  80119a:	31 db                	xor    %ebx,%ebx
  80119c:	89 d8                	mov    %ebx,%eax
  80119e:	89 fa                	mov    %edi,%edx
  8011a0:	83 c4 1c             	add    $0x1c,%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    
  8011a8:	90                   	nop
  8011a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	89 d8                	mov    %ebx,%eax
  8011b2:	f7 f7                	div    %edi
  8011b4:	31 ff                	xor    %edi,%edi
  8011b6:	89 c3                	mov    %eax,%ebx
  8011b8:	89 d8                	mov    %ebx,%eax
  8011ba:	89 fa                	mov    %edi,%edx
  8011bc:	83 c4 1c             	add    $0x1c,%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5f                   	pop    %edi
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    
  8011c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	39 ce                	cmp    %ecx,%esi
  8011ca:	72 0c                	jb     8011d8 <__udivdi3+0x118>
  8011cc:	31 db                	xor    %ebx,%ebx
  8011ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8011d2:	0f 87 34 ff ff ff    	ja     80110c <__udivdi3+0x4c>
  8011d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8011dd:	e9 2a ff ff ff       	jmp    80110c <__udivdi3+0x4c>
  8011e2:	66 90                	xchg   %ax,%ax
  8011e4:	66 90                	xchg   %ax,%ax
  8011e6:	66 90                	xchg   %ax,%ax
  8011e8:	66 90                	xchg   %ax,%ax
  8011ea:	66 90                	xchg   %ax,%ax
  8011ec:	66 90                	xchg   %ax,%ax
  8011ee:	66 90                	xchg   %ax,%ax

008011f0 <__umoddi3>:
  8011f0:	55                   	push   %ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 1c             	sub    $0x1c,%esp
  8011f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8011fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8011ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801207:	85 d2                	test   %edx,%edx
  801209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80120d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801211:	89 f3                	mov    %esi,%ebx
  801213:	89 3c 24             	mov    %edi,(%esp)
  801216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80121a:	75 1c                	jne    801238 <__umoddi3+0x48>
  80121c:	39 f7                	cmp    %esi,%edi
  80121e:	76 50                	jbe    801270 <__umoddi3+0x80>
  801220:	89 c8                	mov    %ecx,%eax
  801222:	89 f2                	mov    %esi,%edx
  801224:	f7 f7                	div    %edi
  801226:	89 d0                	mov    %edx,%eax
  801228:	31 d2                	xor    %edx,%edx
  80122a:	83 c4 1c             	add    $0x1c,%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5f                   	pop    %edi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    
  801232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801238:	39 f2                	cmp    %esi,%edx
  80123a:	89 d0                	mov    %edx,%eax
  80123c:	77 52                	ja     801290 <__umoddi3+0xa0>
  80123e:	0f bd ea             	bsr    %edx,%ebp
  801241:	83 f5 1f             	xor    $0x1f,%ebp
  801244:	75 5a                	jne    8012a0 <__umoddi3+0xb0>
  801246:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80124a:	0f 82 e0 00 00 00    	jb     801330 <__umoddi3+0x140>
  801250:	39 0c 24             	cmp    %ecx,(%esp)
  801253:	0f 86 d7 00 00 00    	jbe    801330 <__umoddi3+0x140>
  801259:	8b 44 24 08          	mov    0x8(%esp),%eax
  80125d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801261:	83 c4 1c             	add    $0x1c,%esp
  801264:	5b                   	pop    %ebx
  801265:	5e                   	pop    %esi
  801266:	5f                   	pop    %edi
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    
  801269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801270:	85 ff                	test   %edi,%edi
  801272:	89 fd                	mov    %edi,%ebp
  801274:	75 0b                	jne    801281 <__umoddi3+0x91>
  801276:	b8 01 00 00 00       	mov    $0x1,%eax
  80127b:	31 d2                	xor    %edx,%edx
  80127d:	f7 f7                	div    %edi
  80127f:	89 c5                	mov    %eax,%ebp
  801281:	89 f0                	mov    %esi,%eax
  801283:	31 d2                	xor    %edx,%edx
  801285:	f7 f5                	div    %ebp
  801287:	89 c8                	mov    %ecx,%eax
  801289:	f7 f5                	div    %ebp
  80128b:	89 d0                	mov    %edx,%eax
  80128d:	eb 99                	jmp    801228 <__umoddi3+0x38>
  80128f:	90                   	nop
  801290:	89 c8                	mov    %ecx,%eax
  801292:	89 f2                	mov    %esi,%edx
  801294:	83 c4 1c             	add    $0x1c,%esp
  801297:	5b                   	pop    %ebx
  801298:	5e                   	pop    %esi
  801299:	5f                   	pop    %edi
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    
  80129c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a0:	8b 34 24             	mov    (%esp),%esi
  8012a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8012a8:	89 e9                	mov    %ebp,%ecx
  8012aa:	29 ef                	sub    %ebp,%edi
  8012ac:	d3 e0                	shl    %cl,%eax
  8012ae:	89 f9                	mov    %edi,%ecx
  8012b0:	89 f2                	mov    %esi,%edx
  8012b2:	d3 ea                	shr    %cl,%edx
  8012b4:	89 e9                	mov    %ebp,%ecx
  8012b6:	09 c2                	or     %eax,%edx
  8012b8:	89 d8                	mov    %ebx,%eax
  8012ba:	89 14 24             	mov    %edx,(%esp)
  8012bd:	89 f2                	mov    %esi,%edx
  8012bf:	d3 e2                	shl    %cl,%edx
  8012c1:	89 f9                	mov    %edi,%ecx
  8012c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012cb:	d3 e8                	shr    %cl,%eax
  8012cd:	89 e9                	mov    %ebp,%ecx
  8012cf:	89 c6                	mov    %eax,%esi
  8012d1:	d3 e3                	shl    %cl,%ebx
  8012d3:	89 f9                	mov    %edi,%ecx
  8012d5:	89 d0                	mov    %edx,%eax
  8012d7:	d3 e8                	shr    %cl,%eax
  8012d9:	89 e9                	mov    %ebp,%ecx
  8012db:	09 d8                	or     %ebx,%eax
  8012dd:	89 d3                	mov    %edx,%ebx
  8012df:	89 f2                	mov    %esi,%edx
  8012e1:	f7 34 24             	divl   (%esp)
  8012e4:	89 d6                	mov    %edx,%esi
  8012e6:	d3 e3                	shl    %cl,%ebx
  8012e8:	f7 64 24 04          	mull   0x4(%esp)
  8012ec:	39 d6                	cmp    %edx,%esi
  8012ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012f2:	89 d1                	mov    %edx,%ecx
  8012f4:	89 c3                	mov    %eax,%ebx
  8012f6:	72 08                	jb     801300 <__umoddi3+0x110>
  8012f8:	75 11                	jne    80130b <__umoddi3+0x11b>
  8012fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012fe:	73 0b                	jae    80130b <__umoddi3+0x11b>
  801300:	2b 44 24 04          	sub    0x4(%esp),%eax
  801304:	1b 14 24             	sbb    (%esp),%edx
  801307:	89 d1                	mov    %edx,%ecx
  801309:	89 c3                	mov    %eax,%ebx
  80130b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80130f:	29 da                	sub    %ebx,%edx
  801311:	19 ce                	sbb    %ecx,%esi
  801313:	89 f9                	mov    %edi,%ecx
  801315:	89 f0                	mov    %esi,%eax
  801317:	d3 e0                	shl    %cl,%eax
  801319:	89 e9                	mov    %ebp,%ecx
  80131b:	d3 ea                	shr    %cl,%edx
  80131d:	89 e9                	mov    %ebp,%ecx
  80131f:	d3 ee                	shr    %cl,%esi
  801321:	09 d0                	or     %edx,%eax
  801323:	89 f2                	mov    %esi,%edx
  801325:	83 c4 1c             	add    $0x1c,%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5f                   	pop    %edi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    
  80132d:	8d 76 00             	lea    0x0(%esi),%esi
  801330:	29 f9                	sub    %edi,%ecx
  801332:	19 d6                	sbb    %edx,%esi
  801334:	89 74 24 04          	mov    %esi,0x4(%esp)
  801338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133c:	e9 18 ff ff ff       	jmp    801259 <__umoddi3+0x69>
