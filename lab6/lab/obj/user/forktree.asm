
obj/user/forktree.debug：     文件格式 elf32-i386


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
  80003d:	e8 5b 0b 00 00       	call   800b9d <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 a0 26 80 00       	push   $0x8026a0
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

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
  80007e:	e8 1c 07 00 00       	call   80079f <strlen>
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
  800095:	68 b1 26 80 00       	push   $0x8026b1
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 e0 06 00 00       	call   800785 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 50 0e 00 00       	call   800efd <fork>
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
  8000d2:	68 b0 26 80 00       	push   $0x8026b0
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
  8000ec:	e8 ac 0a 00 00       	call   800b9d <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
        binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

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
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 43 11 00 00       	call   801275 <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 20 0a 00 00       	call   800b5c <sys_env_destroy>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 ae 09 00 00       	call   800b1f <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 1a 01 00 00       	call   8002d1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 53 09 00 00       	call   800b1f <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020f:	39 d3                	cmp    %edx,%ebx
  800211:	72 05                	jb     800218 <printnum+0x30>
  800213:	39 45 10             	cmp    %eax,0x10(%ebp)
  800216:	77 45                	ja     80025d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	8b 45 14             	mov    0x14(%ebp),%eax
  800221:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800224:	53                   	push   %ebx
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 c4 21 00 00       	call   802400 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 18                	jmp    800267 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	eb 03                	jmp    800260 <printnum+0x78>
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	85 db                	test   %ebx,%ebx
  800265:	7f e8                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	83 ec 04             	sub    $0x4,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 b1 22 00 00       	call   802530 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 c0 26 80 00 	movsbl 0x8026c0(%eax),%eax
  800289:	50                   	push   %eax
  80028a:	ff d7                	call   *%edi
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a6:	73 0a                	jae    8002b2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	88 02                	mov    %al,(%edx)
}
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ba:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bd:	50                   	push   %eax
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	ff 75 0c             	pushl  0xc(%ebp)
  8002c4:	ff 75 08             	pushl  0x8(%ebp)
  8002c7:	e8 05 00 00 00       	call   8002d1 <vprintfmt>
	va_end(ap);
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 2c             	sub    $0x2c,%esp
  8002da:	8b 75 08             	mov    0x8(%ebp),%esi
  8002dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e3:	eb 12                	jmp    8002f7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e5:	85 c0                	test   %eax,%eax
  8002e7:	0f 84 42 04 00 00    	je     80072f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002ed:	83 ec 08             	sub    $0x8,%esp
  8002f0:	53                   	push   %ebx
  8002f1:	50                   	push   %eax
  8002f2:	ff d6                	call   *%esi
  8002f4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f7:	83 c7 01             	add    $0x1,%edi
  8002fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002fe:	83 f8 25             	cmp    $0x25,%eax
  800301:	75 e2                	jne    8002e5 <vprintfmt+0x14>
  800303:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800307:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800315:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	eb 07                	jmp    80032a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800326:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8d 47 01             	lea    0x1(%edi),%eax
  80032d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800330:	0f b6 07             	movzbl (%edi),%eax
  800333:	0f b6 d0             	movzbl %al,%edx
  800336:	83 e8 23             	sub    $0x23,%eax
  800339:	3c 55                	cmp    $0x55,%al
  80033b:	0f 87 d3 03 00 00    	ja     800714 <vprintfmt+0x443>
  800341:	0f b6 c0             	movzbl %al,%eax
  800344:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
  80034b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800352:	eb d6                	jmp    80032a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800357:	b8 00 00 00 00       	mov    $0x0,%eax
  80035c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800362:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800366:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800369:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036c:	83 f9 09             	cmp    $0x9,%ecx
  80036f:	77 3f                	ja     8003b0 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800371:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800374:	eb e9                	jmp    80035f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8d 40 04             	lea    0x4(%eax),%eax
  800384:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038a:	eb 2a                	jmp    8003b6 <vprintfmt+0xe5>
  80038c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038f:	85 c0                	test   %eax,%eax
  800391:	ba 00 00 00 00       	mov    $0x0,%edx
  800396:	0f 49 d0             	cmovns %eax,%edx
  800399:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039f:	eb 89                	jmp    80032a <vprintfmt+0x59>
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ab:	e9 7a ff ff ff       	jmp    80032a <vprintfmt+0x59>
  8003b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ba:	0f 89 6a ff ff ff    	jns    80032a <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cd:	e9 58 ff ff ff       	jmp    80032a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d2:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d8:	e9 4d ff ff ff       	jmp    80032a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 78 04             	lea    0x4(%eax),%edi
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	53                   	push   %ebx
  8003e7:	ff 30                	pushl  (%eax)
  8003e9:	ff d6                	call   *%esi
			break;
  8003eb:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f4:	e9 fe fe ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 78 04             	lea    0x4(%eax),%edi
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	99                   	cltd   
  800402:	31 d0                	xor    %edx,%eax
  800404:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800406:	83 f8 0f             	cmp    $0xf,%eax
  800409:	7f 0b                	jg     800416 <vprintfmt+0x145>
  80040b:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  800412:	85 d2                	test   %edx,%edx
  800414:	75 1b                	jne    800431 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800416:	50                   	push   %eax
  800417:	68 d8 26 80 00       	push   $0x8026d8
  80041c:	53                   	push   %ebx
  80041d:	56                   	push   %esi
  80041e:	e8 91 fe ff ff       	call   8002b4 <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800426:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042c:	e9 c6 fe ff ff       	jmp    8002f7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800431:	52                   	push   %edx
  800432:	68 39 2b 80 00       	push   $0x802b39
  800437:	53                   	push   %ebx
  800438:	56                   	push   %esi
  800439:	e8 76 fe ff ff       	call   8002b4 <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800441:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800447:	e9 ab fe ff ff       	jmp    8002f7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	83 c0 04             	add    $0x4,%eax
  800452:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045a:	85 ff                	test   %edi,%edi
  80045c:	b8 d1 26 80 00       	mov    $0x8026d1,%eax
  800461:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800464:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800468:	0f 8e 94 00 00 00    	jle    800502 <vprintfmt+0x231>
  80046e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800472:	0f 84 98 00 00 00    	je     800510 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	ff 75 d0             	pushl  -0x30(%ebp)
  80047e:	57                   	push   %edi
  80047f:	e8 33 03 00 00       	call   8007b7 <strnlen>
  800484:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800487:	29 c1                	sub    %eax,%ecx
  800489:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800493:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800496:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800499:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	eb 0f                	jmp    8004ac <vprintfmt+0x1db>
					putch(padc, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	53                   	push   %ebx
  8004a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	83 ef 01             	sub    $0x1,%edi
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	7f ed                	jg     80049d <vprintfmt+0x1cc>
  8004b0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004b6:	85 c9                	test   %ecx,%ecx
  8004b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bd:	0f 49 c1             	cmovns %ecx,%eax
  8004c0:	29 c1                	sub    %eax,%ecx
  8004c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cb:	89 cb                	mov    %ecx,%ebx
  8004cd:	eb 4d                	jmp    80051c <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004cf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d3:	74 1b                	je     8004f0 <vprintfmt+0x21f>
  8004d5:	0f be c0             	movsbl %al,%eax
  8004d8:	83 e8 20             	sub    $0x20,%eax
  8004db:	83 f8 5e             	cmp    $0x5e,%eax
  8004de:	76 10                	jbe    8004f0 <vprintfmt+0x21f>
					putch('?', putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	6a 3f                	push   $0x3f
  8004e8:	ff 55 08             	call   *0x8(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	eb 0d                	jmp    8004fd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	ff 75 0c             	pushl  0xc(%ebp)
  8004f6:	52                   	push   %edx
  8004f7:	ff 55 08             	call   *0x8(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fd:	83 eb 01             	sub    $0x1,%ebx
  800500:	eb 1a                	jmp    80051c <vprintfmt+0x24b>
  800502:	89 75 08             	mov    %esi,0x8(%ebp)
  800505:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800508:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050e:	eb 0c                	jmp    80051c <vprintfmt+0x24b>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	83 c7 01             	add    $0x1,%edi
  80051f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800523:	0f be d0             	movsbl %al,%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	74 23                	je     80054d <vprintfmt+0x27c>
  80052a:	85 f6                	test   %esi,%esi
  80052c:	78 a1                	js     8004cf <vprintfmt+0x1fe>
  80052e:	83 ee 01             	sub    $0x1,%esi
  800531:	79 9c                	jns    8004cf <vprintfmt+0x1fe>
  800533:	89 df                	mov    %ebx,%edi
  800535:	8b 75 08             	mov    0x8(%ebp),%esi
  800538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053b:	eb 18                	jmp    800555 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	6a 20                	push   $0x20
  800543:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800545:	83 ef 01             	sub    $0x1,%edi
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 08                	jmp    800555 <vprintfmt+0x284>
  80054d:	89 df                	mov    %ebx,%edi
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800555:	85 ff                	test   %edi,%edi
  800557:	7f e4                	jg     80053d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800559:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 90 fd ff ff       	jmp    8002f7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7e 19                	jle    800585 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8b 50 04             	mov    0x4(%eax),%edx
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800577:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 40 08             	lea    0x8(%eax),%eax
  800580:	89 45 14             	mov    %eax,0x14(%ebp)
  800583:	eb 38                	jmp    8005bd <vprintfmt+0x2ec>
	else if (lflag)
  800585:	85 c9                	test   %ecx,%ecx
  800587:	74 1b                	je     8005a4 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 c1                	mov    %eax,%ecx
  800593:	c1 f9 1f             	sar    $0x1f,%ecx
  800596:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 40 04             	lea    0x4(%eax),%eax
  80059f:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a2:	eb 19                	jmp    8005bd <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ac:	89 c1                	mov    %eax,%ecx
  8005ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c3:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cc:	0f 89 0e 01 00 00    	jns    8006e0 <vprintfmt+0x40f>
				putch('-', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 2d                	push   $0x2d
  8005d8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 d1 00             	adc    $0x0,%ecx
  8005e5:	f7 d9                	neg    %ecx
  8005e7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ef:	e9 ec 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f4:	83 f9 01             	cmp    $0x1,%ecx
  8005f7:	7e 18                	jle    800611 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	8b 48 04             	mov    0x4(%eax),%ecx
  800601:	8d 40 08             	lea    0x8(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	e9 cf 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800611:	85 c9                	test   %ecx,%ecx
  800613:	74 1a                	je     80062f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062a:	e9 b1 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800644:	e9 97 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 58                	push   $0x58
  80064f:	ff d6                	call   *%esi
			putch('X', putdat);
  800651:	83 c4 08             	add    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 58                	push   $0x58
  800657:	ff d6                	call   *%esi
			putch('X', putdat);
  800659:	83 c4 08             	add    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 58                	push   $0x58
  80065f:	ff d6                	call   *%esi
			break;
  800661:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800667:	e9 8b fc ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 30                	push   $0x30
  800672:	ff d6                	call   *%esi
			putch('x', putdat);
  800674:	83 c4 08             	add    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 78                	push   $0x78
  80067a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800686:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800694:	eb 4a                	jmp    8006e0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800696:	83 f9 01             	cmp    $0x1,%ecx
  800699:	7e 15                	jle    8006b0 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a3:	8d 40 08             	lea    0x8(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ae:	eb 30                	jmp    8006e0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006b0:	85 c9                	test   %ecx,%ecx
  8006b2:	74 17                	je     8006cb <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006be:	8d 40 04             	lea    0x4(%eax),%eax
  8006c1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c9:	eb 15                	jmp    8006e0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 10                	mov    (%eax),%edx
  8006d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d5:	8d 40 04             	lea    0x4(%eax),%eax
  8006d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006db:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e0:	83 ec 0c             	sub    $0xc,%esp
  8006e3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e7:	57                   	push   %edi
  8006e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006eb:	50                   	push   %eax
  8006ec:	51                   	push   %ecx
  8006ed:	52                   	push   %edx
  8006ee:	89 da                	mov    %ebx,%edx
  8006f0:	89 f0                	mov    %esi,%eax
  8006f2:	e8 f1 fa ff ff       	call   8001e8 <printnum>
			break;
  8006f7:	83 c4 20             	add    $0x20,%esp
  8006fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fd:	e9 f5 fb ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	52                   	push   %edx
  800707:	ff d6                	call   *%esi
			break;
  800709:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070f:	e9 e3 fb ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 25                	push   $0x25
  80071a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	eb 03                	jmp    800724 <vprintfmt+0x453>
  800721:	83 ef 01             	sub    $0x1,%edi
  800724:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800728:	75 f7                	jne    800721 <vprintfmt+0x450>
  80072a:	e9 c8 fb ff ff       	jmp    8002f7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80072f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800732:	5b                   	pop    %ebx
  800733:	5e                   	pop    %esi
  800734:	5f                   	pop    %edi
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	83 ec 18             	sub    $0x18,%esp
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800743:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800746:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800754:	85 c0                	test   %eax,%eax
  800756:	74 26                	je     80077e <vsnprintf+0x47>
  800758:	85 d2                	test   %edx,%edx
  80075a:	7e 22                	jle    80077e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075c:	ff 75 14             	pushl  0x14(%ebp)
  80075f:	ff 75 10             	pushl  0x10(%ebp)
  800762:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800765:	50                   	push   %eax
  800766:	68 97 02 80 00       	push   $0x800297
  80076b:	e8 61 fb ff ff       	call   8002d1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800770:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800773:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800776:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	eb 05                	jmp    800783 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078e:	50                   	push   %eax
  80078f:	ff 75 10             	pushl  0x10(%ebp)
  800792:	ff 75 0c             	pushl  0xc(%ebp)
  800795:	ff 75 08             	pushl  0x8(%ebp)
  800798:	e8 9a ff ff ff       	call   800737 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007aa:	eb 03                	jmp    8007af <strlen+0x10>
		n++;
  8007ac:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b3:	75 f7                	jne    8007ac <strlen+0xd>
		n++;
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c5:	eb 03                	jmp    8007ca <strnlen+0x13>
		n++;
  8007c7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 08                	je     8007d6 <strnlen+0x1f>
  8007ce:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d2:	75 f3                	jne    8007c7 <strnlen+0x10>
  8007d4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e2:	89 c2                	mov    %eax,%edx
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	83 c1 01             	add    $0x1,%ecx
  8007ea:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ee:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f1:	84 db                	test   %bl,%bl
  8007f3:	75 ef                	jne    8007e4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f5:	5b                   	pop    %ebx
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ff:	53                   	push   %ebx
  800800:	e8 9a ff ff ff       	call   80079f <strlen>
  800805:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800808:	ff 75 0c             	pushl  0xc(%ebp)
  80080b:	01 d8                	add    %ebx,%eax
  80080d:	50                   	push   %eax
  80080e:	e8 c5 ff ff ff       	call   8007d8 <strcpy>
	return dst;
}
  800813:	89 d8                	mov    %ebx,%eax
  800815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	89 f3                	mov    %esi,%ebx
  800827:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082a:	89 f2                	mov    %esi,%edx
  80082c:	eb 0f                	jmp    80083d <strncpy+0x23>
		*dst++ = *src;
  80082e:	83 c2 01             	add    $0x1,%edx
  800831:	0f b6 01             	movzbl (%ecx),%eax
  800834:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800837:	80 39 01             	cmpb   $0x1,(%ecx)
  80083a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083d:	39 da                	cmp    %ebx,%edx
  80083f:	75 ed                	jne    80082e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800841:	89 f0                	mov    %esi,%eax
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	8b 75 08             	mov    0x8(%ebp),%esi
  80084f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800852:	8b 55 10             	mov    0x10(%ebp),%edx
  800855:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800857:	85 d2                	test   %edx,%edx
  800859:	74 21                	je     80087c <strlcpy+0x35>
  80085b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085f:	89 f2                	mov    %esi,%edx
  800861:	eb 09                	jmp    80086c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800863:	83 c2 01             	add    $0x1,%edx
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086c:	39 c2                	cmp    %eax,%edx
  80086e:	74 09                	je     800879 <strlcpy+0x32>
  800870:	0f b6 19             	movzbl (%ecx),%ebx
  800873:	84 db                	test   %bl,%bl
  800875:	75 ec                	jne    800863 <strlcpy+0x1c>
  800877:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800879:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087c:	29 f0                	sub    %esi,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strcmp+0x11>
		p++, q++;
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800893:	0f b6 01             	movzbl (%ecx),%eax
  800896:	84 c0                	test   %al,%al
  800898:	74 04                	je     80089e <strcmp+0x1c>
  80089a:	3a 02                	cmp    (%edx),%al
  80089c:	74 ef                	je     80088d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089e:	0f b6 c0             	movzbl %al,%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 c3                	mov    %eax,%ebx
  8008b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b7:	eb 06                	jmp    8008bf <strncmp+0x17>
		n--, p++, q++;
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bf:	39 d8                	cmp    %ebx,%eax
  8008c1:	74 15                	je     8008d8 <strncmp+0x30>
  8008c3:	0f b6 08             	movzbl (%eax),%ecx
  8008c6:	84 c9                	test   %cl,%cl
  8008c8:	74 04                	je     8008ce <strncmp+0x26>
  8008ca:	3a 0a                	cmp    (%edx),%cl
  8008cc:	74 eb                	je     8008b9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ce:	0f b6 00             	movzbl (%eax),%eax
  8008d1:	0f b6 12             	movzbl (%edx),%edx
  8008d4:	29 d0                	sub    %edx,%eax
  8008d6:	eb 05                	jmp    8008dd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ea:	eb 07                	jmp    8008f3 <strchr+0x13>
		if (*s == c)
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	74 0f                	je     8008ff <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	0f b6 10             	movzbl (%eax),%edx
  8008f6:	84 d2                	test   %dl,%dl
  8008f8:	75 f2                	jne    8008ec <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090b:	eb 03                	jmp    800910 <strfind+0xf>
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800913:	38 ca                	cmp    %cl,%dl
  800915:	74 04                	je     80091b <strfind+0x1a>
  800917:	84 d2                	test   %dl,%dl
  800919:	75 f2                	jne    80090d <strfind+0xc>
			break;
	return (char *) s;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 7d 08             	mov    0x8(%ebp),%edi
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800929:	85 c9                	test   %ecx,%ecx
  80092b:	74 36                	je     800963 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800933:	75 28                	jne    80095d <memset+0x40>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 23                	jne    80095d <memset+0x40>
		c &= 0xFF;
  80093a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093e:	89 d3                	mov    %edx,%ebx
  800940:	c1 e3 08             	shl    $0x8,%ebx
  800943:	89 d6                	mov    %edx,%esi
  800945:	c1 e6 18             	shl    $0x18,%esi
  800948:	89 d0                	mov    %edx,%eax
  80094a:	c1 e0 10             	shl    $0x10,%eax
  80094d:	09 f0                	or     %esi,%eax
  80094f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800951:	89 d8                	mov    %ebx,%eax
  800953:	09 d0                	or     %edx,%eax
  800955:	c1 e9 02             	shr    $0x2,%ecx
  800958:	fc                   	cld    
  800959:	f3 ab                	rep stos %eax,%es:(%edi)
  80095b:	eb 06                	jmp    800963 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800960:	fc                   	cld    
  800961:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800963:	89 f8                	mov    %edi,%eax
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	57                   	push   %edi
  80096e:	56                   	push   %esi
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 75 0c             	mov    0xc(%ebp),%esi
  800975:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800978:	39 c6                	cmp    %eax,%esi
  80097a:	73 35                	jae    8009b1 <memmove+0x47>
  80097c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097f:	39 d0                	cmp    %edx,%eax
  800981:	73 2e                	jae    8009b1 <memmove+0x47>
		s += n;
		d += n;
  800983:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800986:	89 d6                	mov    %edx,%esi
  800988:	09 fe                	or     %edi,%esi
  80098a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800990:	75 13                	jne    8009a5 <memmove+0x3b>
  800992:	f6 c1 03             	test   $0x3,%cl
  800995:	75 0e                	jne    8009a5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800997:	83 ef 04             	sub    $0x4,%edi
  80099a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099d:	c1 e9 02             	shr    $0x2,%ecx
  8009a0:	fd                   	std    
  8009a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a3:	eb 09                	jmp    8009ae <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a5:	83 ef 01             	sub    $0x1,%edi
  8009a8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ab:	fd                   	std    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ae:	fc                   	cld    
  8009af:	eb 1d                	jmp    8009ce <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	89 f2                	mov    %esi,%edx
  8009b3:	09 c2                	or     %eax,%edx
  8009b5:	f6 c2 03             	test   $0x3,%dl
  8009b8:	75 0f                	jne    8009c9 <memmove+0x5f>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 0a                	jne    8009c9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 05                	jmp    8009ce <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d5:	ff 75 10             	pushl  0x10(%ebp)
  8009d8:	ff 75 0c             	pushl  0xc(%ebp)
  8009db:	ff 75 08             	pushl  0x8(%ebp)
  8009de:	e8 87 ff ff ff       	call   80096a <memmove>
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f0:	89 c6                	mov    %eax,%esi
  8009f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f5:	eb 1a                	jmp    800a11 <memcmp+0x2c>
		if (*s1 != *s2)
  8009f7:	0f b6 08             	movzbl (%eax),%ecx
  8009fa:	0f b6 1a             	movzbl (%edx),%ebx
  8009fd:	38 d9                	cmp    %bl,%cl
  8009ff:	74 0a                	je     800a0b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a01:	0f b6 c1             	movzbl %cl,%eax
  800a04:	0f b6 db             	movzbl %bl,%ebx
  800a07:	29 d8                	sub    %ebx,%eax
  800a09:	eb 0f                	jmp    800a1a <memcmp+0x35>
		s1++, s2++;
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a11:	39 f0                	cmp    %esi,%eax
  800a13:	75 e2                	jne    8009f7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	53                   	push   %ebx
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a25:	89 c1                	mov    %eax,%ecx
  800a27:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2e:	eb 0a                	jmp    800a3a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a30:	0f b6 10             	movzbl (%eax),%edx
  800a33:	39 da                	cmp    %ebx,%edx
  800a35:	74 07                	je     800a3e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	39 c8                	cmp    %ecx,%eax
  800a3c:	72 f2                	jb     800a30 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4d:	eb 03                	jmp    800a52 <strtol+0x11>
		s++;
  800a4f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	0f b6 01             	movzbl (%ecx),%eax
  800a55:	3c 20                	cmp    $0x20,%al
  800a57:	74 f6                	je     800a4f <strtol+0xe>
  800a59:	3c 09                	cmp    $0x9,%al
  800a5b:	74 f2                	je     800a4f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5d:	3c 2b                	cmp    $0x2b,%al
  800a5f:	75 0a                	jne    800a6b <strtol+0x2a>
		s++;
  800a61:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a64:	bf 00 00 00 00       	mov    $0x0,%edi
  800a69:	eb 11                	jmp    800a7c <strtol+0x3b>
  800a6b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a70:	3c 2d                	cmp    $0x2d,%al
  800a72:	75 08                	jne    800a7c <strtol+0x3b>
		s++, neg = 1;
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a82:	75 15                	jne    800a99 <strtol+0x58>
  800a84:	80 39 30             	cmpb   $0x30,(%ecx)
  800a87:	75 10                	jne    800a99 <strtol+0x58>
  800a89:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8d:	75 7c                	jne    800b0b <strtol+0xca>
		s += 2, base = 16;
  800a8f:	83 c1 02             	add    $0x2,%ecx
  800a92:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a97:	eb 16                	jmp    800aaf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a99:	85 db                	test   %ebx,%ebx
  800a9b:	75 12                	jne    800aaf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa2:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa5:	75 08                	jne    800aaf <strtol+0x6e>
		s++, base = 8;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab7:	0f b6 11             	movzbl (%ecx),%edx
  800aba:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abd:	89 f3                	mov    %esi,%ebx
  800abf:	80 fb 09             	cmp    $0x9,%bl
  800ac2:	77 08                	ja     800acc <strtol+0x8b>
			dig = *s - '0';
  800ac4:	0f be d2             	movsbl %dl,%edx
  800ac7:	83 ea 30             	sub    $0x30,%edx
  800aca:	eb 22                	jmp    800aee <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800acc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800acf:	89 f3                	mov    %esi,%ebx
  800ad1:	80 fb 19             	cmp    $0x19,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad6:	0f be d2             	movsbl %dl,%edx
  800ad9:	83 ea 57             	sub    $0x57,%edx
  800adc:	eb 10                	jmp    800aee <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ade:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 16                	ja     800afe <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aee:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af1:	7d 0b                	jge    800afe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af3:	83 c1 01             	add    $0x1,%ecx
  800af6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afa:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800afc:	eb b9                	jmp    800ab7 <strtol+0x76>

	if (endptr)
  800afe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b02:	74 0d                	je     800b11 <strtol+0xd0>
		*endptr = (char *) s;
  800b04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b07:	89 0e                	mov    %ecx,(%esi)
  800b09:	eb 06                	jmp    800b11 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0b:	85 db                	test   %ebx,%ebx
  800b0d:	74 98                	je     800aa7 <strtol+0x66>
  800b0f:	eb 9e                	jmp    800aaf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b11:	89 c2                	mov    %eax,%edx
  800b13:	f7 da                	neg    %edx
  800b15:	85 ff                	test   %edi,%edi
  800b17:	0f 45 c2             	cmovne %edx,%eax
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	89 c7                	mov    %eax,%edi
  800b34:	89 c6                	mov    %eax,%esi
  800b36:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	89 cb                	mov    %ecx,%ebx
  800b74:	89 cf                	mov    %ecx,%edi
  800b76:	89 ce                	mov    %ecx,%esi
  800b78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7e 17                	jle    800b95 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	50                   	push   %eax
  800b82:	6a 03                	push   $0x3
  800b84:	68 bf 29 80 00       	push   $0x8029bf
  800b89:	6a 23                	push   $0x23
  800b8b:	68 dc 29 80 00       	push   $0x8029dc
  800b90:	e8 66 16 00 00       	call   8021fb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_yield>:

void
sys_yield(void)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcc:	89 d1                	mov    %edx,%ecx
  800bce:	89 d3                	mov    %edx,%ebx
  800bd0:	89 d7                	mov    %edx,%edi
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	be 00 00 00 00       	mov    $0x0,%esi
  800be9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	89 f7                	mov    %esi,%edi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 04                	push   $0x4
  800c05:	68 bf 29 80 00       	push   $0x8029bf
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 dc 29 80 00       	push   $0x8029dc
  800c11:	e8 e5 15 00 00       	call   8021fb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c38:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 05                	push   $0x5
  800c47:	68 bf 29 80 00       	push   $0x8029bf
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 dc 29 80 00       	push   $0x8029dc
  800c53:	e8 a3 15 00 00       	call   8021fb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 06                	push   $0x6
  800c89:	68 bf 29 80 00       	push   $0x8029bf
  800c8e:	6a 23                	push   $0x23
  800c90:	68 dc 29 80 00       	push   $0x8029dc
  800c95:	e8 61 15 00 00       	call   8021fb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 08                	push   $0x8
  800ccb:	68 bf 29 80 00       	push   $0x8029bf
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 dc 29 80 00       	push   $0x8029dc
  800cd7:	e8 1f 15 00 00       	call   8021fb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 09                	push   $0x9
  800d0d:	68 bf 29 80 00       	push   $0x8029bf
  800d12:	6a 23                	push   $0x23
  800d14:	68 dc 29 80 00       	push   $0x8029dc
  800d19:	e8 dd 14 00 00       	call   8021fb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 17                	jle    800d60 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 0a                	push   $0xa
  800d4f:	68 bf 29 80 00       	push   $0x8029bf
  800d54:	6a 23                	push   $0x23
  800d56:	68 dc 29 80 00       	push   $0x8029dc
  800d5b:	e8 9b 14 00 00       	call   8021fb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	be 00 00 00 00       	mov    $0x0,%esi
  800d73:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d81:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d84:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d99:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 cb                	mov    %ecx,%ebx
  800da3:	89 cf                	mov    %ecx,%edi
  800da5:	89 ce                	mov    %ecx,%esi
  800da7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 17                	jle    800dc4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	50                   	push   %eax
  800db1:	6a 0d                	push   $0xd
  800db3:	68 bf 29 80 00       	push   $0x8029bf
  800db8:	6a 23                	push   $0x23
  800dba:	68 dc 29 80 00       	push   $0x8029dc
  800dbf:	e8 37 14 00 00       	call   8021fb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ddc:	89 d1                	mov    %edx,%ecx
  800dde:	89 d3                	mov    %edx,%ebx
  800de0:	89 d7                	mov    %edx,%edi
  800de2:	89 d6                	mov    %edx,%esi
  800de4:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df6:	b8 10 00 00 00       	mov    $0x10,%eax
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	89 cb                	mov    %ecx,%ebx
  800e00:	89 cf                	mov    %ecx,%edi
  800e02:	89 ce                	mov    %ecx,%esi
  800e04:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	53                   	push   %ebx
  800e0f:	83 ec 04             	sub    $0x4,%esp
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e15:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e17:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e1b:	74 2d                	je     800e4a <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e1d:	89 d8                	mov    %ebx,%eax
  800e1f:	c1 e8 16             	shr    $0x16,%eax
  800e22:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e29:	a8 01                	test   $0x1,%al
  800e2b:	74 1d                	je     800e4a <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e2d:	89 d8                	mov    %ebx,%eax
  800e2f:	c1 e8 0c             	shr    $0xc,%eax
  800e32:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e39:	f6 c2 01             	test   $0x1,%dl
  800e3c:	74 0c                	je     800e4a <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e3e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e45:	f6 c4 08             	test   $0x8,%ah
  800e48:	75 14                	jne    800e5e <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	68 ec 29 80 00       	push   $0x8029ec
  800e52:	6a 1f                	push   $0x1f
  800e54:	68 22 2a 80 00       	push   $0x802a22
  800e59:	e8 9d 13 00 00       	call   8021fb <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800e5e:	83 ec 04             	sub    $0x4,%esp
  800e61:	6a 07                	push   $0x7
  800e63:	68 00 f0 7f 00       	push   $0x7ff000
  800e68:	6a 00                	push   $0x0
  800e6a:	e8 6c fd ff ff       	call   800bdb <sys_page_alloc>
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	85 c0                	test   %eax,%eax
  800e74:	79 12                	jns    800e88 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800e76:	50                   	push   %eax
  800e77:	68 2d 2a 80 00       	push   $0x802a2d
  800e7c:	6a 29                	push   $0x29
  800e7e:	68 22 2a 80 00       	push   $0x802a22
  800e83:	e8 73 13 00 00       	call   8021fb <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e88:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800e8e:	83 ec 04             	sub    $0x4,%esp
  800e91:	68 00 10 00 00       	push   $0x1000
  800e96:	53                   	push   %ebx
  800e97:	68 00 f0 7f 00       	push   $0x7ff000
  800e9c:	e8 31 fb ff ff       	call   8009d2 <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800ea1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ea8:	53                   	push   %ebx
  800ea9:	6a 00                	push   $0x0
  800eab:	68 00 f0 7f 00       	push   $0x7ff000
  800eb0:	6a 00                	push   $0x0
  800eb2:	e8 67 fd ff ff       	call   800c1e <sys_page_map>
  800eb7:	83 c4 20             	add    $0x20,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	79 12                	jns    800ed0 <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800ebe:	50                   	push   %eax
  800ebf:	68 41 2a 80 00       	push   $0x802a41
  800ec4:	6a 2e                	push   $0x2e
  800ec6:	68 22 2a 80 00       	push   $0x802a22
  800ecb:	e8 2b 13 00 00       	call   8021fb <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800ed0:	83 ec 08             	sub    $0x8,%esp
  800ed3:	68 00 f0 7f 00       	push   $0x7ff000
  800ed8:	6a 00                	push   $0x0
  800eda:	e8 81 fd ff ff       	call   800c60 <sys_page_unmap>
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	79 12                	jns    800ef8 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800ee6:	50                   	push   %eax
  800ee7:	68 53 2a 80 00       	push   $0x802a53
  800eec:	6a 30                	push   $0x30
  800eee:	68 22 2a 80 00       	push   $0x802a22
  800ef3:	e8 03 13 00 00       	call   8021fb <_panic>
	//panic("pgfault not implemented");
}
  800ef8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    

00800efd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
  800f03:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800f06:	68 0b 0e 80 00       	push   $0x800e0b
  800f0b:	e8 31 13 00 00       	call   802241 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f10:	b8 07 00 00 00       	mov    $0x7,%eax
  800f15:	cd 30                	int    $0x30
  800f17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	79 14                	jns    800f35 <fork+0x38>
		panic("sys_exofork failed");
  800f21:	83 ec 04             	sub    $0x4,%esp
  800f24:	68 67 2a 80 00       	push   $0x802a67
  800f29:	6a 6f                	push   $0x6f
  800f2b:	68 22 2a 80 00       	push   $0x802a22
  800f30:	e8 c6 12 00 00       	call   8021fb <_panic>
  800f35:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800f37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f3b:	0f 8e 2b 01 00 00    	jle    80106c <fork+0x16f>
  800f41:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800f46:	89 d8                	mov    %ebx,%eax
  800f48:	c1 e8 0a             	shr    $0xa,%eax
  800f4b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f52:	a8 01                	test   $0x1,%al
  800f54:	0f 84 bf 00 00 00    	je     801019 <fork+0x11c>
  800f5a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f61:	a8 01                	test   $0x1,%al
  800f63:	0f 84 b0 00 00 00    	je     801019 <fork+0x11c>
  800f69:	89 de                	mov    %ebx,%esi
  800f6b:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  800f6e:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f75:	f6 c4 04             	test   $0x4,%ah
  800f78:	74 29                	je     800fa3 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  800f7a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	25 07 0e 00 00       	and    $0xe07,%eax
  800f89:	50                   	push   %eax
  800f8a:	56                   	push   %esi
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 8a fc ff ff       	call   800c1e <sys_page_map>
  800f94:	83 c4 20             	add    $0x20,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9e:	0f 4f c2             	cmovg  %edx,%eax
  800fa1:	eb 72                	jmp    801015 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800fa3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800faa:	a8 02                	test   $0x2,%al
  800fac:	75 0c                	jne    800fba <fork+0xbd>
  800fae:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fb5:	f6 c4 08             	test   $0x8,%ah
  800fb8:	74 3f                	je     800ff9 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	68 05 08 00 00       	push   $0x805
  800fc2:	56                   	push   %esi
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	6a 00                	push   $0x0
  800fc7:	e8 52 fc ff ff       	call   800c1e <sys_page_map>
  800fcc:	83 c4 20             	add    $0x20,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	0f 88 b1 00 00 00    	js     801088 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	68 05 08 00 00       	push   $0x805
  800fdf:	56                   	push   %esi
  800fe0:	6a 00                	push   $0x0
  800fe2:	56                   	push   %esi
  800fe3:	6a 00                	push   $0x0
  800fe5:	e8 34 fc ff ff       	call   800c1e <sys_page_map>
  800fea:	83 c4 20             	add    $0x20,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff4:	0f 4f c1             	cmovg  %ecx,%eax
  800ff7:	eb 1c                	jmp    801015 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	6a 05                	push   $0x5
  800ffe:	56                   	push   %esi
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	6a 00                	push   $0x0
  801003:	e8 16 fc ff ff       	call   800c1e <sys_page_map>
  801008:	83 c4 20             	add    $0x20,%esp
  80100b:	85 c0                	test   %eax,%eax
  80100d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801012:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  801015:	85 c0                	test   %eax,%eax
  801017:	78 6f                	js     801088 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801019:	83 c3 01             	add    $0x1,%ebx
  80101c:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801022:	0f 85 1e ff ff ff    	jne    800f46 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	6a 07                	push   $0x7
  80102d:	68 00 f0 bf ee       	push   $0xeebff000
  801032:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801035:	57                   	push   %edi
  801036:	e8 a0 fb ff ff       	call   800bdb <sys_page_alloc>
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	78 46                	js     801088 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  801042:	83 ec 08             	sub    $0x8,%esp
  801045:	68 a4 22 80 00       	push   $0x8022a4
  80104a:	57                   	push   %edi
  80104b:	e8 d6 fc ff ff       	call   800d26 <sys_env_set_pgfault_upcall>
  801050:	83 c4 10             	add    $0x10,%esp
  801053:	85 c0                	test   %eax,%eax
  801055:	78 31                	js     801088 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  801057:	83 ec 08             	sub    $0x8,%esp
  80105a:	6a 02                	push   $0x2
  80105c:	57                   	push   %edi
  80105d:	e8 40 fc ff ff       	call   800ca2 <sys_env_set_status>
  801062:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  801065:	85 c0                	test   %eax,%eax
  801067:	0f 49 c7             	cmovns %edi,%eax
  80106a:	eb 1c                	jmp    801088 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  80106c:	e8 2c fb ff ff       	call   800b9d <sys_getenvid>
  801071:	25 ff 03 00 00       	and    $0x3ff,%eax
  801076:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80107e:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801083:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sfork>:

// Challenge!
int
sfork(void)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801096:	68 7a 2a 80 00       	push   $0x802a7a
  80109b:	68 8d 00 00 00       	push   $0x8d
  8010a0:	68 22 2a 80 00       	push   $0x802a22
  8010a5:	e8 51 11 00 00       	call   8021fb <_panic>

008010aa <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b0:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b5:	c1 e8 0c             	shr    $0xc,%eax
}
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c0:	05 00 00 00 30       	add    $0x30000000,%eax
  8010c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010ca:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010dc:	89 c2                	mov    %eax,%edx
  8010de:	c1 ea 16             	shr    $0x16,%edx
  8010e1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e8:	f6 c2 01             	test   $0x1,%dl
  8010eb:	74 11                	je     8010fe <fd_alloc+0x2d>
  8010ed:	89 c2                	mov    %eax,%edx
  8010ef:	c1 ea 0c             	shr    $0xc,%edx
  8010f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f9:	f6 c2 01             	test   $0x1,%dl
  8010fc:	75 09                	jne    801107 <fd_alloc+0x36>
			*fd_store = fd;
  8010fe:	89 01                	mov    %eax,(%ecx)
			return 0;
  801100:	b8 00 00 00 00       	mov    $0x0,%eax
  801105:	eb 17                	jmp    80111e <fd_alloc+0x4d>
  801107:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80110c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801111:	75 c9                	jne    8010dc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801113:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801119:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801126:	83 f8 1f             	cmp    $0x1f,%eax
  801129:	77 36                	ja     801161 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80112b:	c1 e0 0c             	shl    $0xc,%eax
  80112e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801133:	89 c2                	mov    %eax,%edx
  801135:	c1 ea 16             	shr    $0x16,%edx
  801138:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80113f:	f6 c2 01             	test   $0x1,%dl
  801142:	74 24                	je     801168 <fd_lookup+0x48>
  801144:	89 c2                	mov    %eax,%edx
  801146:	c1 ea 0c             	shr    $0xc,%edx
  801149:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801150:	f6 c2 01             	test   $0x1,%dl
  801153:	74 1a                	je     80116f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801155:	8b 55 0c             	mov    0xc(%ebp),%edx
  801158:	89 02                	mov    %eax,(%edx)
	return 0;
  80115a:	b8 00 00 00 00       	mov    $0x0,%eax
  80115f:	eb 13                	jmp    801174 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801161:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801166:	eb 0c                	jmp    801174 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801168:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116d:	eb 05                	jmp    801174 <fd_lookup+0x54>
  80116f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	83 ec 08             	sub    $0x8,%esp
  80117c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117f:	ba 0c 2b 80 00       	mov    $0x802b0c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801184:	eb 13                	jmp    801199 <dev_lookup+0x23>
  801186:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801189:	39 08                	cmp    %ecx,(%eax)
  80118b:	75 0c                	jne    801199 <dev_lookup+0x23>
			*dev = devtab[i];
  80118d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801190:	89 01                	mov    %eax,(%ecx)
			return 0;
  801192:	b8 00 00 00 00       	mov    $0x0,%eax
  801197:	eb 2e                	jmp    8011c7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801199:	8b 02                	mov    (%edx),%eax
  80119b:	85 c0                	test   %eax,%eax
  80119d:	75 e7                	jne    801186 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80119f:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a4:	8b 40 48             	mov    0x48(%eax),%eax
  8011a7:	83 ec 04             	sub    $0x4,%esp
  8011aa:	51                   	push   %ecx
  8011ab:	50                   	push   %eax
  8011ac:	68 90 2a 80 00       	push   $0x802a90
  8011b1:	e8 1e f0 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  8011b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c7:	c9                   	leave  
  8011c8:	c3                   	ret    

008011c9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	56                   	push   %esi
  8011cd:	53                   	push   %ebx
  8011ce:	83 ec 10             	sub    $0x10,%esp
  8011d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011e1:	c1 e8 0c             	shr    $0xc,%eax
  8011e4:	50                   	push   %eax
  8011e5:	e8 36 ff ff ff       	call   801120 <fd_lookup>
  8011ea:	83 c4 08             	add    $0x8,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 05                	js     8011f6 <fd_close+0x2d>
	    || fd != fd2)
  8011f1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011f4:	74 0c                	je     801202 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011f6:	84 db                	test   %bl,%bl
  8011f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fd:	0f 44 c2             	cmove  %edx,%eax
  801200:	eb 41                	jmp    801243 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801208:	50                   	push   %eax
  801209:	ff 36                	pushl  (%esi)
  80120b:	e8 66 ff ff ff       	call   801176 <dev_lookup>
  801210:	89 c3                	mov    %eax,%ebx
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	85 c0                	test   %eax,%eax
  801217:	78 1a                	js     801233 <fd_close+0x6a>
		if (dev->dev_close)
  801219:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80121f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801224:	85 c0                	test   %eax,%eax
  801226:	74 0b                	je     801233 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801228:	83 ec 0c             	sub    $0xc,%esp
  80122b:	56                   	push   %esi
  80122c:	ff d0                	call   *%eax
  80122e:	89 c3                	mov    %eax,%ebx
  801230:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801233:	83 ec 08             	sub    $0x8,%esp
  801236:	56                   	push   %esi
  801237:	6a 00                	push   $0x0
  801239:	e8 22 fa ff ff       	call   800c60 <sys_page_unmap>
	return r;
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	89 d8                	mov    %ebx,%eax
}
  801243:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801246:	5b                   	pop    %ebx
  801247:	5e                   	pop    %esi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801250:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801253:	50                   	push   %eax
  801254:	ff 75 08             	pushl  0x8(%ebp)
  801257:	e8 c4 fe ff ff       	call   801120 <fd_lookup>
  80125c:	83 c4 08             	add    $0x8,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 10                	js     801273 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801263:	83 ec 08             	sub    $0x8,%esp
  801266:	6a 01                	push   $0x1
  801268:	ff 75 f4             	pushl  -0xc(%ebp)
  80126b:	e8 59 ff ff ff       	call   8011c9 <fd_close>
  801270:	83 c4 10             	add    $0x10,%esp
}
  801273:	c9                   	leave  
  801274:	c3                   	ret    

00801275 <close_all>:

void
close_all(void)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	53                   	push   %ebx
  801279:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80127c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801281:	83 ec 0c             	sub    $0xc,%esp
  801284:	53                   	push   %ebx
  801285:	e8 c0 ff ff ff       	call   80124a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80128a:	83 c3 01             	add    $0x1,%ebx
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	83 fb 20             	cmp    $0x20,%ebx
  801293:	75 ec                	jne    801281 <close_all+0xc>
		close(i);
}
  801295:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801298:	c9                   	leave  
  801299:	c3                   	ret    

0080129a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	57                   	push   %edi
  80129e:	56                   	push   %esi
  80129f:	53                   	push   %ebx
  8012a0:	83 ec 2c             	sub    $0x2c,%esp
  8012a3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012a9:	50                   	push   %eax
  8012aa:	ff 75 08             	pushl  0x8(%ebp)
  8012ad:	e8 6e fe ff ff       	call   801120 <fd_lookup>
  8012b2:	83 c4 08             	add    $0x8,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	0f 88 c1 00 00 00    	js     80137e <dup+0xe4>
		return r;
	close(newfdnum);
  8012bd:	83 ec 0c             	sub    $0xc,%esp
  8012c0:	56                   	push   %esi
  8012c1:	e8 84 ff ff ff       	call   80124a <close>

	newfd = INDEX2FD(newfdnum);
  8012c6:	89 f3                	mov    %esi,%ebx
  8012c8:	c1 e3 0c             	shl    $0xc,%ebx
  8012cb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012d1:	83 c4 04             	add    $0x4,%esp
  8012d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012d7:	e8 de fd ff ff       	call   8010ba <fd2data>
  8012dc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012de:	89 1c 24             	mov    %ebx,(%esp)
  8012e1:	e8 d4 fd ff ff       	call   8010ba <fd2data>
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012ec:	89 f8                	mov    %edi,%eax
  8012ee:	c1 e8 16             	shr    $0x16,%eax
  8012f1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012f8:	a8 01                	test   $0x1,%al
  8012fa:	74 37                	je     801333 <dup+0x99>
  8012fc:	89 f8                	mov    %edi,%eax
  8012fe:	c1 e8 0c             	shr    $0xc,%eax
  801301:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801308:	f6 c2 01             	test   $0x1,%dl
  80130b:	74 26                	je     801333 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80130d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801314:	83 ec 0c             	sub    $0xc,%esp
  801317:	25 07 0e 00 00       	and    $0xe07,%eax
  80131c:	50                   	push   %eax
  80131d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801320:	6a 00                	push   $0x0
  801322:	57                   	push   %edi
  801323:	6a 00                	push   $0x0
  801325:	e8 f4 f8 ff ff       	call   800c1e <sys_page_map>
  80132a:	89 c7                	mov    %eax,%edi
  80132c:	83 c4 20             	add    $0x20,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 2e                	js     801361 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801333:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801336:	89 d0                	mov    %edx,%eax
  801338:	c1 e8 0c             	shr    $0xc,%eax
  80133b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801342:	83 ec 0c             	sub    $0xc,%esp
  801345:	25 07 0e 00 00       	and    $0xe07,%eax
  80134a:	50                   	push   %eax
  80134b:	53                   	push   %ebx
  80134c:	6a 00                	push   $0x0
  80134e:	52                   	push   %edx
  80134f:	6a 00                	push   $0x0
  801351:	e8 c8 f8 ff ff       	call   800c1e <sys_page_map>
  801356:	89 c7                	mov    %eax,%edi
  801358:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80135b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80135d:	85 ff                	test   %edi,%edi
  80135f:	79 1d                	jns    80137e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	53                   	push   %ebx
  801365:	6a 00                	push   $0x0
  801367:	e8 f4 f8 ff ff       	call   800c60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80136c:	83 c4 08             	add    $0x8,%esp
  80136f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801372:	6a 00                	push   $0x0
  801374:	e8 e7 f8 ff ff       	call   800c60 <sys_page_unmap>
	return r;
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	89 f8                	mov    %edi,%eax
}
  80137e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5f                   	pop    %edi
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	53                   	push   %ebx
  80138a:	83 ec 14             	sub    $0x14,%esp
  80138d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801390:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801393:	50                   	push   %eax
  801394:	53                   	push   %ebx
  801395:	e8 86 fd ff ff       	call   801120 <fd_lookup>
  80139a:	83 c4 08             	add    $0x8,%esp
  80139d:	89 c2                	mov    %eax,%edx
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	78 6d                	js     801410 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a9:	50                   	push   %eax
  8013aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ad:	ff 30                	pushl  (%eax)
  8013af:	e8 c2 fd ff ff       	call   801176 <dev_lookup>
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 4c                	js     801407 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013be:	8b 42 08             	mov    0x8(%edx),%eax
  8013c1:	83 e0 03             	and    $0x3,%eax
  8013c4:	83 f8 01             	cmp    $0x1,%eax
  8013c7:	75 21                	jne    8013ea <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ce:	8b 40 48             	mov    0x48(%eax),%eax
  8013d1:	83 ec 04             	sub    $0x4,%esp
  8013d4:	53                   	push   %ebx
  8013d5:	50                   	push   %eax
  8013d6:	68 d1 2a 80 00       	push   $0x802ad1
  8013db:	e8 f4 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013e8:	eb 26                	jmp    801410 <read+0x8a>
	}
	if (!dev->dev_read)
  8013ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ed:	8b 40 08             	mov    0x8(%eax),%eax
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	74 17                	je     80140b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013f4:	83 ec 04             	sub    $0x4,%esp
  8013f7:	ff 75 10             	pushl  0x10(%ebp)
  8013fa:	ff 75 0c             	pushl  0xc(%ebp)
  8013fd:	52                   	push   %edx
  8013fe:	ff d0                	call   *%eax
  801400:	89 c2                	mov    %eax,%edx
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	eb 09                	jmp    801410 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801407:	89 c2                	mov    %eax,%edx
  801409:	eb 05                	jmp    801410 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80140b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801410:	89 d0                	mov    %edx,%eax
  801412:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	57                   	push   %edi
  80141b:	56                   	push   %esi
  80141c:	53                   	push   %ebx
  80141d:	83 ec 0c             	sub    $0xc,%esp
  801420:	8b 7d 08             	mov    0x8(%ebp),%edi
  801423:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801426:	bb 00 00 00 00       	mov    $0x0,%ebx
  80142b:	eb 21                	jmp    80144e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80142d:	83 ec 04             	sub    $0x4,%esp
  801430:	89 f0                	mov    %esi,%eax
  801432:	29 d8                	sub    %ebx,%eax
  801434:	50                   	push   %eax
  801435:	89 d8                	mov    %ebx,%eax
  801437:	03 45 0c             	add    0xc(%ebp),%eax
  80143a:	50                   	push   %eax
  80143b:	57                   	push   %edi
  80143c:	e8 45 ff ff ff       	call   801386 <read>
		if (m < 0)
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	78 10                	js     801458 <readn+0x41>
			return m;
		if (m == 0)
  801448:	85 c0                	test   %eax,%eax
  80144a:	74 0a                	je     801456 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144c:	01 c3                	add    %eax,%ebx
  80144e:	39 f3                	cmp    %esi,%ebx
  801450:	72 db                	jb     80142d <readn+0x16>
  801452:	89 d8                	mov    %ebx,%eax
  801454:	eb 02                	jmp    801458 <readn+0x41>
  801456:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801458:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5f                   	pop    %edi
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	53                   	push   %ebx
  801464:	83 ec 14             	sub    $0x14,%esp
  801467:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80146a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146d:	50                   	push   %eax
  80146e:	53                   	push   %ebx
  80146f:	e8 ac fc ff ff       	call   801120 <fd_lookup>
  801474:	83 c4 08             	add    $0x8,%esp
  801477:	89 c2                	mov    %eax,%edx
  801479:	85 c0                	test   %eax,%eax
  80147b:	78 68                	js     8014e5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801483:	50                   	push   %eax
  801484:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801487:	ff 30                	pushl  (%eax)
  801489:	e8 e8 fc ff ff       	call   801176 <dev_lookup>
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	85 c0                	test   %eax,%eax
  801493:	78 47                	js     8014dc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801495:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801498:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80149c:	75 21                	jne    8014bf <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80149e:	a1 08 40 80 00       	mov    0x804008,%eax
  8014a3:	8b 40 48             	mov    0x48(%eax),%eax
  8014a6:	83 ec 04             	sub    $0x4,%esp
  8014a9:	53                   	push   %ebx
  8014aa:	50                   	push   %eax
  8014ab:	68 ed 2a 80 00       	push   $0x802aed
  8014b0:	e8 1f ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014bd:	eb 26                	jmp    8014e5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c2:	8b 52 0c             	mov    0xc(%edx),%edx
  8014c5:	85 d2                	test   %edx,%edx
  8014c7:	74 17                	je     8014e0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014c9:	83 ec 04             	sub    $0x4,%esp
  8014cc:	ff 75 10             	pushl  0x10(%ebp)
  8014cf:	ff 75 0c             	pushl  0xc(%ebp)
  8014d2:	50                   	push   %eax
  8014d3:	ff d2                	call   *%edx
  8014d5:	89 c2                	mov    %eax,%edx
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	eb 09                	jmp    8014e5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dc:	89 c2                	mov    %eax,%edx
  8014de:	eb 05                	jmp    8014e5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014e5:	89 d0                	mov    %edx,%eax
  8014e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ea:	c9                   	leave  
  8014eb:	c3                   	ret    

008014ec <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014f5:	50                   	push   %eax
  8014f6:	ff 75 08             	pushl  0x8(%ebp)
  8014f9:	e8 22 fc ff ff       	call   801120 <fd_lookup>
  8014fe:	83 c4 08             	add    $0x8,%esp
  801501:	85 c0                	test   %eax,%eax
  801503:	78 0e                	js     801513 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801505:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801508:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80150e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	53                   	push   %ebx
  801519:	83 ec 14             	sub    $0x14,%esp
  80151c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	53                   	push   %ebx
  801524:	e8 f7 fb ff ff       	call   801120 <fd_lookup>
  801529:	83 c4 08             	add    $0x8,%esp
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 65                	js     801597 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153c:	ff 30                	pushl  (%eax)
  80153e:	e8 33 fc ff ff       	call   801176 <dev_lookup>
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	85 c0                	test   %eax,%eax
  801548:	78 44                	js     80158e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801551:	75 21                	jne    801574 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801553:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801558:	8b 40 48             	mov    0x48(%eax),%eax
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	53                   	push   %ebx
  80155f:	50                   	push   %eax
  801560:	68 b0 2a 80 00       	push   $0x802ab0
  801565:	e8 6a ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801572:	eb 23                	jmp    801597 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801574:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801577:	8b 52 18             	mov    0x18(%edx),%edx
  80157a:	85 d2                	test   %edx,%edx
  80157c:	74 14                	je     801592 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	ff 75 0c             	pushl  0xc(%ebp)
  801584:	50                   	push   %eax
  801585:	ff d2                	call   *%edx
  801587:	89 c2                	mov    %eax,%edx
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	eb 09                	jmp    801597 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158e:	89 c2                	mov    %eax,%edx
  801590:	eb 05                	jmp    801597 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801592:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801597:	89 d0                	mov    %edx,%eax
  801599:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159c:	c9                   	leave  
  80159d:	c3                   	ret    

0080159e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	53                   	push   %ebx
  8015a2:	83 ec 14             	sub    $0x14,%esp
  8015a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	ff 75 08             	pushl  0x8(%ebp)
  8015af:	e8 6c fb ff ff       	call   801120 <fd_lookup>
  8015b4:	83 c4 08             	add    $0x8,%esp
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 58                	js     801615 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c7:	ff 30                	pushl  (%eax)
  8015c9:	e8 a8 fb ff ff       	call   801176 <dev_lookup>
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 37                	js     80160c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015dc:	74 32                	je     801610 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015de:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015e1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015e8:	00 00 00 
	stat->st_isdir = 0;
  8015eb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015f2:	00 00 00 
	stat->st_dev = dev;
  8015f5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	53                   	push   %ebx
  8015ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801602:	ff 50 14             	call   *0x14(%eax)
  801605:	89 c2                	mov    %eax,%edx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb 09                	jmp    801615 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	eb 05                	jmp    801615 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801610:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801615:	89 d0                	mov    %edx,%eax
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	56                   	push   %esi
  801620:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	6a 00                	push   $0x0
  801626:	ff 75 08             	pushl  0x8(%ebp)
  801629:	e8 e3 01 00 00       	call   801811 <open>
  80162e:	89 c3                	mov    %eax,%ebx
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 1b                	js     801652 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	ff 75 0c             	pushl  0xc(%ebp)
  80163d:	50                   	push   %eax
  80163e:	e8 5b ff ff ff       	call   80159e <fstat>
  801643:	89 c6                	mov    %eax,%esi
	close(fd);
  801645:	89 1c 24             	mov    %ebx,(%esp)
  801648:	e8 fd fb ff ff       	call   80124a <close>
	return r;
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	89 f0                	mov    %esi,%eax
}
  801652:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801655:	5b                   	pop    %ebx
  801656:	5e                   	pop    %esi
  801657:	5d                   	pop    %ebp
  801658:	c3                   	ret    

00801659 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	56                   	push   %esi
  80165d:	53                   	push   %ebx
  80165e:	89 c6                	mov    %eax,%esi
  801660:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801662:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801669:	75 12                	jne    80167d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80166b:	83 ec 0c             	sub    $0xc,%esp
  80166e:	6a 01                	push   $0x1
  801670:	e8 10 0d 00 00       	call   802385 <ipc_find_env>
  801675:	a3 00 40 80 00       	mov    %eax,0x804000
  80167a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80167d:	6a 07                	push   $0x7
  80167f:	68 00 50 80 00       	push   $0x805000
  801684:	56                   	push   %esi
  801685:	ff 35 00 40 80 00    	pushl  0x804000
  80168b:	e8 a1 0c 00 00       	call   802331 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801690:	83 c4 0c             	add    $0xc,%esp
  801693:	6a 00                	push   $0x0
  801695:	53                   	push   %ebx
  801696:	6a 00                	push   $0x0
  801698:	e8 2b 0c 00 00       	call   8022c8 <ipc_recv>
}
  80169d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a0:	5b                   	pop    %ebx
  8016a1:	5e                   	pop    %esi
  8016a2:	5d                   	pop    %ebp
  8016a3:	c3                   	ret    

008016a4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c2:	b8 02 00 00 00       	mov    $0x2,%eax
  8016c7:	e8 8d ff ff ff       	call   801659 <fsipc>
}
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016da:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016df:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e4:	b8 06 00 00 00       	mov    $0x6,%eax
  8016e9:	e8 6b ff ff ff       	call   801659 <fsipc>
}
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 04             	sub    $0x4,%esp
  8016f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801700:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
  80170a:	b8 05 00 00 00       	mov    $0x5,%eax
  80170f:	e8 45 ff ff ff       	call   801659 <fsipc>
  801714:	85 c0                	test   %eax,%eax
  801716:	78 2c                	js     801744 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801718:	83 ec 08             	sub    $0x8,%esp
  80171b:	68 00 50 80 00       	push   $0x805000
  801720:	53                   	push   %ebx
  801721:	e8 b2 f0 ff ff       	call   8007d8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801726:	a1 80 50 80 00       	mov    0x805080,%eax
  80172b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801731:	a1 84 50 80 00       	mov    0x805084,%eax
  801736:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801744:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801747:	c9                   	leave  
  801748:	c3                   	ret    

00801749 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	83 ec 0c             	sub    $0xc,%esp
  80174f:	8b 45 10             	mov    0x10(%ebp),%eax
  801752:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801757:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80175c:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80175f:	8b 55 08             	mov    0x8(%ebp),%edx
  801762:	8b 52 0c             	mov    0xc(%edx),%edx
  801765:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80176b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801770:	50                   	push   %eax
  801771:	ff 75 0c             	pushl  0xc(%ebp)
  801774:	68 08 50 80 00       	push   $0x805008
  801779:	e8 ec f1 ff ff       	call   80096a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80177e:	ba 00 00 00 00       	mov    $0x0,%edx
  801783:	b8 04 00 00 00       	mov    $0x4,%eax
  801788:	e8 cc fe ff ff       	call   801659 <fsipc>
	//panic("devfile_write not implemented");
}
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	56                   	push   %esi
  801793:	53                   	push   %ebx
  801794:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801797:	8b 45 08             	mov    0x8(%ebp),%eax
  80179a:	8b 40 0c             	mov    0xc(%eax),%eax
  80179d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017a2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8017b2:	e8 a2 fe ff ff       	call   801659 <fsipc>
  8017b7:	89 c3                	mov    %eax,%ebx
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 4b                	js     801808 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017bd:	39 c6                	cmp    %eax,%esi
  8017bf:	73 16                	jae    8017d7 <devfile_read+0x48>
  8017c1:	68 20 2b 80 00       	push   $0x802b20
  8017c6:	68 27 2b 80 00       	push   $0x802b27
  8017cb:	6a 7c                	push   $0x7c
  8017cd:	68 3c 2b 80 00       	push   $0x802b3c
  8017d2:	e8 24 0a 00 00       	call   8021fb <_panic>
	assert(r <= PGSIZE);
  8017d7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017dc:	7e 16                	jle    8017f4 <devfile_read+0x65>
  8017de:	68 47 2b 80 00       	push   $0x802b47
  8017e3:	68 27 2b 80 00       	push   $0x802b27
  8017e8:	6a 7d                	push   $0x7d
  8017ea:	68 3c 2b 80 00       	push   $0x802b3c
  8017ef:	e8 07 0a 00 00       	call   8021fb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017f4:	83 ec 04             	sub    $0x4,%esp
  8017f7:	50                   	push   %eax
  8017f8:	68 00 50 80 00       	push   $0x805000
  8017fd:	ff 75 0c             	pushl  0xc(%ebp)
  801800:	e8 65 f1 ff ff       	call   80096a <memmove>
	return r;
  801805:	83 c4 10             	add    $0x10,%esp
}
  801808:	89 d8                	mov    %ebx,%eax
  80180a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180d:	5b                   	pop    %ebx
  80180e:	5e                   	pop    %esi
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	53                   	push   %ebx
  801815:	83 ec 20             	sub    $0x20,%esp
  801818:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80181b:	53                   	push   %ebx
  80181c:	e8 7e ef ff ff       	call   80079f <strlen>
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801829:	7f 67                	jg     801892 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182b:	83 ec 0c             	sub    $0xc,%esp
  80182e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	e8 9a f8 ff ff       	call   8010d1 <fd_alloc>
  801837:	83 c4 10             	add    $0x10,%esp
		return r;
  80183a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 57                	js     801897 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	53                   	push   %ebx
  801844:	68 00 50 80 00       	push   $0x805000
  801849:	e8 8a ef ff ff       	call   8007d8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801851:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801856:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801859:	b8 01 00 00 00       	mov    $0x1,%eax
  80185e:	e8 f6 fd ff ff       	call   801659 <fsipc>
  801863:	89 c3                	mov    %eax,%ebx
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	79 14                	jns    801880 <open+0x6f>
		fd_close(fd, 0);
  80186c:	83 ec 08             	sub    $0x8,%esp
  80186f:	6a 00                	push   $0x0
  801871:	ff 75 f4             	pushl  -0xc(%ebp)
  801874:	e8 50 f9 ff ff       	call   8011c9 <fd_close>
		return r;
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	89 da                	mov    %ebx,%edx
  80187e:	eb 17                	jmp    801897 <open+0x86>
	}

	return fd2num(fd);
  801880:	83 ec 0c             	sub    $0xc,%esp
  801883:	ff 75 f4             	pushl  -0xc(%ebp)
  801886:	e8 1f f8 ff ff       	call   8010aa <fd2num>
  80188b:	89 c2                	mov    %eax,%edx
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	eb 05                	jmp    801897 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801892:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801897:	89 d0                	mov    %edx,%eax
  801899:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8018ae:	e8 a6 fd ff ff       	call   801659 <fsipc>
}
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8018bb:	68 53 2b 80 00       	push   $0x802b53
  8018c0:	ff 75 0c             	pushl  0xc(%ebp)
  8018c3:	e8 10 ef ff ff       	call   8007d8 <strcpy>
	return 0;
}
  8018c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	53                   	push   %ebx
  8018d3:	83 ec 10             	sub    $0x10,%esp
  8018d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018d9:	53                   	push   %ebx
  8018da:	e8 df 0a 00 00       	call   8023be <pageref>
  8018df:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018e2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018e7:	83 f8 01             	cmp    $0x1,%eax
  8018ea:	75 10                	jne    8018fc <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018ec:	83 ec 0c             	sub    $0xc,%esp
  8018ef:	ff 73 0c             	pushl  0xc(%ebx)
  8018f2:	e8 c0 02 00 00       	call   801bb7 <nsipc_close>
  8018f7:	89 c2                	mov    %eax,%edx
  8018f9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018fc:	89 d0                	mov    %edx,%eax
  8018fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801909:	6a 00                	push   $0x0
  80190b:	ff 75 10             	pushl  0x10(%ebp)
  80190e:	ff 75 0c             	pushl  0xc(%ebp)
  801911:	8b 45 08             	mov    0x8(%ebp),%eax
  801914:	ff 70 0c             	pushl  0xc(%eax)
  801917:	e8 78 03 00 00       	call   801c94 <nsipc_send>
}
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801924:	6a 00                	push   $0x0
  801926:	ff 75 10             	pushl  0x10(%ebp)
  801929:	ff 75 0c             	pushl  0xc(%ebp)
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	ff 70 0c             	pushl  0xc(%eax)
  801932:	e8 f1 02 00 00       	call   801c28 <nsipc_recv>
}
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80193f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801942:	52                   	push   %edx
  801943:	50                   	push   %eax
  801944:	e8 d7 f7 ff ff       	call   801120 <fd_lookup>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 17                	js     801967 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801953:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801959:	39 08                	cmp    %ecx,(%eax)
  80195b:	75 05                	jne    801962 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80195d:	8b 40 0c             	mov    0xc(%eax),%eax
  801960:	eb 05                	jmp    801967 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801962:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	56                   	push   %esi
  80196d:	53                   	push   %ebx
  80196e:	83 ec 1c             	sub    $0x1c,%esp
  801971:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801973:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801976:	50                   	push   %eax
  801977:	e8 55 f7 ff ff       	call   8010d1 <fd_alloc>
  80197c:	89 c3                	mov    %eax,%ebx
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	85 c0                	test   %eax,%eax
  801983:	78 1b                	js     8019a0 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801985:	83 ec 04             	sub    $0x4,%esp
  801988:	68 07 04 00 00       	push   $0x407
  80198d:	ff 75 f4             	pushl  -0xc(%ebp)
  801990:	6a 00                	push   $0x0
  801992:	e8 44 f2 ff ff       	call   800bdb <sys_page_alloc>
  801997:	89 c3                	mov    %eax,%ebx
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	79 10                	jns    8019b0 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	56                   	push   %esi
  8019a4:	e8 0e 02 00 00       	call   801bb7 <nsipc_close>
		return r;
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	89 d8                	mov    %ebx,%eax
  8019ae:	eb 24                	jmp    8019d4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019b0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019c5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019c8:	83 ec 0c             	sub    $0xc,%esp
  8019cb:	50                   	push   %eax
  8019cc:	e8 d9 f6 ff ff       	call   8010aa <fd2num>
  8019d1:	83 c4 10             	add    $0x10,%esp
}
  8019d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d7:	5b                   	pop    %ebx
  8019d8:	5e                   	pop    %esi
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    

008019db <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	e8 50 ff ff ff       	call   801939 <fd2sockid>
		return r;
  8019e9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 1f                	js     801a0e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019ef:	83 ec 04             	sub    $0x4,%esp
  8019f2:	ff 75 10             	pushl  0x10(%ebp)
  8019f5:	ff 75 0c             	pushl  0xc(%ebp)
  8019f8:	50                   	push   %eax
  8019f9:	e8 12 01 00 00       	call   801b10 <nsipc_accept>
  8019fe:	83 c4 10             	add    $0x10,%esp
		return r;
  801a01:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 07                	js     801a0e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a07:	e8 5d ff ff ff       	call   801969 <alloc_sockfd>
  801a0c:	89 c1                	mov    %eax,%ecx
}
  801a0e:	89 c8                	mov    %ecx,%eax
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	e8 19 ff ff ff       	call   801939 <fd2sockid>
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 12                	js     801a36 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801a24:	83 ec 04             	sub    $0x4,%esp
  801a27:	ff 75 10             	pushl  0x10(%ebp)
  801a2a:	ff 75 0c             	pushl  0xc(%ebp)
  801a2d:	50                   	push   %eax
  801a2e:	e8 2d 01 00 00       	call   801b60 <nsipc_bind>
  801a33:	83 c4 10             	add    $0x10,%esp
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <shutdown>:

int
shutdown(int s, int how)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	e8 f3 fe ff ff       	call   801939 <fd2sockid>
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 0f                	js     801a59 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a4a:	83 ec 08             	sub    $0x8,%esp
  801a4d:	ff 75 0c             	pushl  0xc(%ebp)
  801a50:	50                   	push   %eax
  801a51:	e8 3f 01 00 00       	call   801b95 <nsipc_shutdown>
  801a56:	83 c4 10             	add    $0x10,%esp
}
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a61:	8b 45 08             	mov    0x8(%ebp),%eax
  801a64:	e8 d0 fe ff ff       	call   801939 <fd2sockid>
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 12                	js     801a7f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a6d:	83 ec 04             	sub    $0x4,%esp
  801a70:	ff 75 10             	pushl  0x10(%ebp)
  801a73:	ff 75 0c             	pushl  0xc(%ebp)
  801a76:	50                   	push   %eax
  801a77:	e8 55 01 00 00       	call   801bd1 <nsipc_connect>
  801a7c:	83 c4 10             	add    $0x10,%esp
}
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <listen>:

int
listen(int s, int backlog)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a87:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8a:	e8 aa fe ff ff       	call   801939 <fd2sockid>
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	78 0f                	js     801aa2 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a93:	83 ec 08             	sub    $0x8,%esp
  801a96:	ff 75 0c             	pushl  0xc(%ebp)
  801a99:	50                   	push   %eax
  801a9a:	e8 67 01 00 00       	call   801c06 <nsipc_listen>
  801a9f:	83 c4 10             	add    $0x10,%esp
}
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801aaa:	ff 75 10             	pushl  0x10(%ebp)
  801aad:	ff 75 0c             	pushl  0xc(%ebp)
  801ab0:	ff 75 08             	pushl  0x8(%ebp)
  801ab3:	e8 3a 02 00 00       	call   801cf2 <nsipc_socket>
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 05                	js     801ac4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801abf:	e8 a5 fe ff ff       	call   801969 <alloc_sockfd>
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	53                   	push   %ebx
  801aca:	83 ec 04             	sub    $0x4,%esp
  801acd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801acf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ad6:	75 12                	jne    801aea <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	6a 02                	push   $0x2
  801add:	e8 a3 08 00 00       	call   802385 <ipc_find_env>
  801ae2:	a3 04 40 80 00       	mov    %eax,0x804004
  801ae7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801aea:	6a 07                	push   $0x7
  801aec:	68 00 60 80 00       	push   $0x806000
  801af1:	53                   	push   %ebx
  801af2:	ff 35 04 40 80 00    	pushl  0x804004
  801af8:	e8 34 08 00 00       	call   802331 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801afd:	83 c4 0c             	add    $0xc,%esp
  801b00:	6a 00                	push   $0x0
  801b02:	6a 00                	push   $0x0
  801b04:	6a 00                	push   $0x0
  801b06:	e8 bd 07 00 00       	call   8022c8 <ipc_recv>
}
  801b0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b18:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b20:	8b 06                	mov    (%esi),%eax
  801b22:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b27:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2c:	e8 95 ff ff ff       	call   801ac6 <nsipc>
  801b31:	89 c3                	mov    %eax,%ebx
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 20                	js     801b57 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b37:	83 ec 04             	sub    $0x4,%esp
  801b3a:	ff 35 10 60 80 00    	pushl  0x806010
  801b40:	68 00 60 80 00       	push   $0x806000
  801b45:	ff 75 0c             	pushl  0xc(%ebp)
  801b48:	e8 1d ee ff ff       	call   80096a <memmove>
		*addrlen = ret->ret_addrlen;
  801b4d:	a1 10 60 80 00       	mov    0x806010,%eax
  801b52:	89 06                	mov    %eax,(%esi)
  801b54:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b57:	89 d8                	mov    %ebx,%eax
  801b59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5c:	5b                   	pop    %ebx
  801b5d:	5e                   	pop    %esi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	53                   	push   %ebx
  801b64:	83 ec 08             	sub    $0x8,%esp
  801b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b72:	53                   	push   %ebx
  801b73:	ff 75 0c             	pushl  0xc(%ebp)
  801b76:	68 04 60 80 00       	push   $0x806004
  801b7b:	e8 ea ed ff ff       	call   80096a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b80:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b86:	b8 02 00 00 00       	mov    $0x2,%eax
  801b8b:	e8 36 ff ff ff       	call   801ac6 <nsipc>
}
  801b90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ba3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801bab:	b8 03 00 00 00       	mov    $0x3,%eax
  801bb0:	e8 11 ff ff ff       	call   801ac6 <nsipc>
}
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <nsipc_close>:

int
nsipc_close(int s)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801bc5:	b8 04 00 00 00       	mov    $0x4,%eax
  801bca:	e8 f7 fe ff ff       	call   801ac6 <nsipc>
}
  801bcf:	c9                   	leave  
  801bd0:	c3                   	ret    

00801bd1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bde:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801be3:	53                   	push   %ebx
  801be4:	ff 75 0c             	pushl  0xc(%ebp)
  801be7:	68 04 60 80 00       	push   $0x806004
  801bec:	e8 79 ed ff ff       	call   80096a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bf1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bf7:	b8 05 00 00 00       	mov    $0x5,%eax
  801bfc:	e8 c5 fe ff ff       	call   801ac6 <nsipc>
}
  801c01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c17:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c1c:	b8 06 00 00 00       	mov    $0x6,%eax
  801c21:	e8 a0 fe ff ff       	call   801ac6 <nsipc>
}
  801c26:	c9                   	leave  
  801c27:	c3                   	ret    

00801c28 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c30:	8b 45 08             	mov    0x8(%ebp),%eax
  801c33:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c38:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c3e:	8b 45 14             	mov    0x14(%ebp),%eax
  801c41:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c46:	b8 07 00 00 00       	mov    $0x7,%eax
  801c4b:	e8 76 fe ff ff       	call   801ac6 <nsipc>
  801c50:	89 c3                	mov    %eax,%ebx
  801c52:	85 c0                	test   %eax,%eax
  801c54:	78 35                	js     801c8b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c56:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c5b:	7f 04                	jg     801c61 <nsipc_recv+0x39>
  801c5d:	39 c6                	cmp    %eax,%esi
  801c5f:	7d 16                	jge    801c77 <nsipc_recv+0x4f>
  801c61:	68 5f 2b 80 00       	push   $0x802b5f
  801c66:	68 27 2b 80 00       	push   $0x802b27
  801c6b:	6a 62                	push   $0x62
  801c6d:	68 74 2b 80 00       	push   $0x802b74
  801c72:	e8 84 05 00 00       	call   8021fb <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c77:	83 ec 04             	sub    $0x4,%esp
  801c7a:	50                   	push   %eax
  801c7b:	68 00 60 80 00       	push   $0x806000
  801c80:	ff 75 0c             	pushl  0xc(%ebp)
  801c83:	e8 e2 ec ff ff       	call   80096a <memmove>
  801c88:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    

00801c94 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	53                   	push   %ebx
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ca6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cac:	7e 16                	jle    801cc4 <nsipc_send+0x30>
  801cae:	68 80 2b 80 00       	push   $0x802b80
  801cb3:	68 27 2b 80 00       	push   $0x802b27
  801cb8:	6a 6d                	push   $0x6d
  801cba:	68 74 2b 80 00       	push   $0x802b74
  801cbf:	e8 37 05 00 00       	call   8021fb <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801cc4:	83 ec 04             	sub    $0x4,%esp
  801cc7:	53                   	push   %ebx
  801cc8:	ff 75 0c             	pushl  0xc(%ebp)
  801ccb:	68 0c 60 80 00       	push   $0x80600c
  801cd0:	e8 95 ec ff ff       	call   80096a <memmove>
	nsipcbuf.send.req_size = size;
  801cd5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cdb:	8b 45 14             	mov    0x14(%ebp),%eax
  801cde:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ce3:	b8 08 00 00 00       	mov    $0x8,%eax
  801ce8:	e8 d9 fd ff ff       	call   801ac6 <nsipc>
}
  801ced:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d03:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d08:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d10:	b8 09 00 00 00       	mov    $0x9,%eax
  801d15:	e8 ac fd ff ff       	call   801ac6 <nsipc>
}
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    

00801d1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	56                   	push   %esi
  801d20:	53                   	push   %ebx
  801d21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d24:	83 ec 0c             	sub    $0xc,%esp
  801d27:	ff 75 08             	pushl  0x8(%ebp)
  801d2a:	e8 8b f3 ff ff       	call   8010ba <fd2data>
  801d2f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d31:	83 c4 08             	add    $0x8,%esp
  801d34:	68 8c 2b 80 00       	push   $0x802b8c
  801d39:	53                   	push   %ebx
  801d3a:	e8 99 ea ff ff       	call   8007d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d3f:	8b 46 04             	mov    0x4(%esi),%eax
  801d42:	2b 06                	sub    (%esi),%eax
  801d44:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d4a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d51:	00 00 00 
	stat->st_dev = &devpipe;
  801d54:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d5b:	30 80 00 
	return 0;
}
  801d5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	53                   	push   %ebx
  801d6e:	83 ec 0c             	sub    $0xc,%esp
  801d71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d74:	53                   	push   %ebx
  801d75:	6a 00                	push   $0x0
  801d77:	e8 e4 ee ff ff       	call   800c60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d7c:	89 1c 24             	mov    %ebx,(%esp)
  801d7f:	e8 36 f3 ff ff       	call   8010ba <fd2data>
  801d84:	83 c4 08             	add    $0x8,%esp
  801d87:	50                   	push   %eax
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 d1 ee ff ff       	call   800c60 <sys_page_unmap>
}
  801d8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d92:	c9                   	leave  
  801d93:	c3                   	ret    

00801d94 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	57                   	push   %edi
  801d98:	56                   	push   %esi
  801d99:	53                   	push   %ebx
  801d9a:	83 ec 1c             	sub    $0x1c,%esp
  801d9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801da0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801da2:	a1 08 40 80 00       	mov    0x804008,%eax
  801da7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	ff 75 e0             	pushl  -0x20(%ebp)
  801db0:	e8 09 06 00 00       	call   8023be <pageref>
  801db5:	89 c3                	mov    %eax,%ebx
  801db7:	89 3c 24             	mov    %edi,(%esp)
  801dba:	e8 ff 05 00 00       	call   8023be <pageref>
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	39 c3                	cmp    %eax,%ebx
  801dc4:	0f 94 c1             	sete   %cl
  801dc7:	0f b6 c9             	movzbl %cl,%ecx
  801dca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801dcd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801dd3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dd6:	39 ce                	cmp    %ecx,%esi
  801dd8:	74 1b                	je     801df5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801dda:	39 c3                	cmp    %eax,%ebx
  801ddc:	75 c4                	jne    801da2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dde:	8b 42 58             	mov    0x58(%edx),%eax
  801de1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801de4:	50                   	push   %eax
  801de5:	56                   	push   %esi
  801de6:	68 93 2b 80 00       	push   $0x802b93
  801deb:	e8 e4 e3 ff ff       	call   8001d4 <cprintf>
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	eb ad                	jmp    801da2 <_pipeisclosed+0xe>
	}
}
  801df5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfb:	5b                   	pop    %ebx
  801dfc:	5e                   	pop    %esi
  801dfd:	5f                   	pop    %edi
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	57                   	push   %edi
  801e04:	56                   	push   %esi
  801e05:	53                   	push   %ebx
  801e06:	83 ec 28             	sub    $0x28,%esp
  801e09:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e0c:	56                   	push   %esi
  801e0d:	e8 a8 f2 ff ff       	call   8010ba <fd2data>
  801e12:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	bf 00 00 00 00       	mov    $0x0,%edi
  801e1c:	eb 4b                	jmp    801e69 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e1e:	89 da                	mov    %ebx,%edx
  801e20:	89 f0                	mov    %esi,%eax
  801e22:	e8 6d ff ff ff       	call   801d94 <_pipeisclosed>
  801e27:	85 c0                	test   %eax,%eax
  801e29:	75 48                	jne    801e73 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e2b:	e8 8c ed ff ff       	call   800bbc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e30:	8b 43 04             	mov    0x4(%ebx),%eax
  801e33:	8b 0b                	mov    (%ebx),%ecx
  801e35:	8d 51 20             	lea    0x20(%ecx),%edx
  801e38:	39 d0                	cmp    %edx,%eax
  801e3a:	73 e2                	jae    801e1e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e3f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e43:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e46:	89 c2                	mov    %eax,%edx
  801e48:	c1 fa 1f             	sar    $0x1f,%edx
  801e4b:	89 d1                	mov    %edx,%ecx
  801e4d:	c1 e9 1b             	shr    $0x1b,%ecx
  801e50:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e53:	83 e2 1f             	and    $0x1f,%edx
  801e56:	29 ca                	sub    %ecx,%edx
  801e58:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e5c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e60:	83 c0 01             	add    $0x1,%eax
  801e63:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e66:	83 c7 01             	add    $0x1,%edi
  801e69:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e6c:	75 c2                	jne    801e30 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e6e:	8b 45 10             	mov    0x10(%ebp),%eax
  801e71:	eb 05                	jmp    801e78 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e73:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e7b:	5b                   	pop    %ebx
  801e7c:	5e                   	pop    %esi
  801e7d:	5f                   	pop    %edi
  801e7e:	5d                   	pop    %ebp
  801e7f:	c3                   	ret    

00801e80 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	57                   	push   %edi
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	83 ec 18             	sub    $0x18,%esp
  801e89:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e8c:	57                   	push   %edi
  801e8d:	e8 28 f2 ff ff       	call   8010ba <fd2data>
  801e92:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e9c:	eb 3d                	jmp    801edb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e9e:	85 db                	test   %ebx,%ebx
  801ea0:	74 04                	je     801ea6 <devpipe_read+0x26>
				return i;
  801ea2:	89 d8                	mov    %ebx,%eax
  801ea4:	eb 44                	jmp    801eea <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ea6:	89 f2                	mov    %esi,%edx
  801ea8:	89 f8                	mov    %edi,%eax
  801eaa:	e8 e5 fe ff ff       	call   801d94 <_pipeisclosed>
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	75 32                	jne    801ee5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801eb3:	e8 04 ed ff ff       	call   800bbc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801eb8:	8b 06                	mov    (%esi),%eax
  801eba:	3b 46 04             	cmp    0x4(%esi),%eax
  801ebd:	74 df                	je     801e9e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ebf:	99                   	cltd   
  801ec0:	c1 ea 1b             	shr    $0x1b,%edx
  801ec3:	01 d0                	add    %edx,%eax
  801ec5:	83 e0 1f             	and    $0x1f,%eax
  801ec8:	29 d0                	sub    %edx,%eax
  801eca:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ed2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ed5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ed8:	83 c3 01             	add    $0x1,%ebx
  801edb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ede:	75 d8                	jne    801eb8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ee0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ee3:	eb 05                	jmp    801eea <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801eea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eed:	5b                   	pop    %ebx
  801eee:	5e                   	pop    %esi
  801eef:	5f                   	pop    %edi
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    

00801ef2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	56                   	push   %esi
  801ef6:	53                   	push   %ebx
  801ef7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801efa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efd:	50                   	push   %eax
  801efe:	e8 ce f1 ff ff       	call   8010d1 <fd_alloc>
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	89 c2                	mov    %eax,%edx
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	0f 88 2c 01 00 00    	js     80203c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f10:	83 ec 04             	sub    $0x4,%esp
  801f13:	68 07 04 00 00       	push   $0x407
  801f18:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1b:	6a 00                	push   $0x0
  801f1d:	e8 b9 ec ff ff       	call   800bdb <sys_page_alloc>
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	89 c2                	mov    %eax,%edx
  801f27:	85 c0                	test   %eax,%eax
  801f29:	0f 88 0d 01 00 00    	js     80203c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f2f:	83 ec 0c             	sub    $0xc,%esp
  801f32:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f35:	50                   	push   %eax
  801f36:	e8 96 f1 ff ff       	call   8010d1 <fd_alloc>
  801f3b:	89 c3                	mov    %eax,%ebx
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	85 c0                	test   %eax,%eax
  801f42:	0f 88 e2 00 00 00    	js     80202a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f48:	83 ec 04             	sub    $0x4,%esp
  801f4b:	68 07 04 00 00       	push   $0x407
  801f50:	ff 75 f0             	pushl  -0x10(%ebp)
  801f53:	6a 00                	push   $0x0
  801f55:	e8 81 ec ff ff       	call   800bdb <sys_page_alloc>
  801f5a:	89 c3                	mov    %eax,%ebx
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	85 c0                	test   %eax,%eax
  801f61:	0f 88 c3 00 00 00    	js     80202a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f67:	83 ec 0c             	sub    $0xc,%esp
  801f6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6d:	e8 48 f1 ff ff       	call   8010ba <fd2data>
  801f72:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f74:	83 c4 0c             	add    $0xc,%esp
  801f77:	68 07 04 00 00       	push   $0x407
  801f7c:	50                   	push   %eax
  801f7d:	6a 00                	push   $0x0
  801f7f:	e8 57 ec ff ff       	call   800bdb <sys_page_alloc>
  801f84:	89 c3                	mov    %eax,%ebx
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	0f 88 89 00 00 00    	js     80201a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f91:	83 ec 0c             	sub    $0xc,%esp
  801f94:	ff 75 f0             	pushl  -0x10(%ebp)
  801f97:	e8 1e f1 ff ff       	call   8010ba <fd2data>
  801f9c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801fa3:	50                   	push   %eax
  801fa4:	6a 00                	push   $0x0
  801fa6:	56                   	push   %esi
  801fa7:	6a 00                	push   $0x0
  801fa9:	e8 70 ec ff ff       	call   800c1e <sys_page_map>
  801fae:	89 c3                	mov    %eax,%ebx
  801fb0:	83 c4 20             	add    $0x20,%esp
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	78 55                	js     80200c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fb7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fcc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fd5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fda:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fe1:	83 ec 0c             	sub    $0xc,%esp
  801fe4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe7:	e8 be f0 ff ff       	call   8010aa <fd2num>
  801fec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fef:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ff1:	83 c4 04             	add    $0x4,%esp
  801ff4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff7:	e8 ae f0 ff ff       	call   8010aa <fd2num>
  801ffc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fff:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	ba 00 00 00 00       	mov    $0x0,%edx
  80200a:	eb 30                	jmp    80203c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80200c:	83 ec 08             	sub    $0x8,%esp
  80200f:	56                   	push   %esi
  802010:	6a 00                	push   $0x0
  802012:	e8 49 ec ff ff       	call   800c60 <sys_page_unmap>
  802017:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80201a:	83 ec 08             	sub    $0x8,%esp
  80201d:	ff 75 f0             	pushl  -0x10(%ebp)
  802020:	6a 00                	push   $0x0
  802022:	e8 39 ec ff ff       	call   800c60 <sys_page_unmap>
  802027:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80202a:	83 ec 08             	sub    $0x8,%esp
  80202d:	ff 75 f4             	pushl  -0xc(%ebp)
  802030:	6a 00                	push   $0x0
  802032:	e8 29 ec ff ff       	call   800c60 <sys_page_unmap>
  802037:	83 c4 10             	add    $0x10,%esp
  80203a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80203c:	89 d0                	mov    %edx,%eax
  80203e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802041:	5b                   	pop    %ebx
  802042:	5e                   	pop    %esi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    

00802045 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204e:	50                   	push   %eax
  80204f:	ff 75 08             	pushl  0x8(%ebp)
  802052:	e8 c9 f0 ff ff       	call   801120 <fd_lookup>
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	85 c0                	test   %eax,%eax
  80205c:	78 18                	js     802076 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80205e:	83 ec 0c             	sub    $0xc,%esp
  802061:	ff 75 f4             	pushl  -0xc(%ebp)
  802064:	e8 51 f0 ff ff       	call   8010ba <fd2data>
	return _pipeisclosed(fd, p);
  802069:	89 c2                	mov    %eax,%edx
  80206b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206e:	e8 21 fd ff ff       	call   801d94 <_pipeisclosed>
  802073:	83 c4 10             	add    $0x10,%esp
}
  802076:	c9                   	leave  
  802077:	c3                   	ret    

00802078 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    

00802082 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802088:	68 ab 2b 80 00       	push   $0x802bab
  80208d:	ff 75 0c             	pushl  0xc(%ebp)
  802090:	e8 43 e7 ff ff       	call   8007d8 <strcpy>
	return 0;
}
  802095:	b8 00 00 00 00       	mov    $0x0,%eax
  80209a:	c9                   	leave  
  80209b:	c3                   	ret    

0080209c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	57                   	push   %edi
  8020a0:	56                   	push   %esi
  8020a1:	53                   	push   %ebx
  8020a2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020ad:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b3:	eb 2d                	jmp    8020e2 <devcons_write+0x46>
		m = n - tot;
  8020b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020b8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020ba:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020bd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020c2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020c5:	83 ec 04             	sub    $0x4,%esp
  8020c8:	53                   	push   %ebx
  8020c9:	03 45 0c             	add    0xc(%ebp),%eax
  8020cc:	50                   	push   %eax
  8020cd:	57                   	push   %edi
  8020ce:	e8 97 e8 ff ff       	call   80096a <memmove>
		sys_cputs(buf, m);
  8020d3:	83 c4 08             	add    $0x8,%esp
  8020d6:	53                   	push   %ebx
  8020d7:	57                   	push   %edi
  8020d8:	e8 42 ea ff ff       	call   800b1f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020dd:	01 de                	add    %ebx,%esi
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	89 f0                	mov    %esi,%eax
  8020e4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020e7:	72 cc                	jb     8020b5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ec:	5b                   	pop    %ebx
  8020ed:	5e                   	pop    %esi
  8020ee:	5f                   	pop    %edi
  8020ef:	5d                   	pop    %ebp
  8020f0:	c3                   	ret    

008020f1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020f1:	55                   	push   %ebp
  8020f2:	89 e5                	mov    %esp,%ebp
  8020f4:	83 ec 08             	sub    $0x8,%esp
  8020f7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802100:	74 2a                	je     80212c <devcons_read+0x3b>
  802102:	eb 05                	jmp    802109 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802104:	e8 b3 ea ff ff       	call   800bbc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802109:	e8 2f ea ff ff       	call   800b3d <sys_cgetc>
  80210e:	85 c0                	test   %eax,%eax
  802110:	74 f2                	je     802104 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802112:	85 c0                	test   %eax,%eax
  802114:	78 16                	js     80212c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802116:	83 f8 04             	cmp    $0x4,%eax
  802119:	74 0c                	je     802127 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80211b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80211e:	88 02                	mov    %al,(%edx)
	return 1;
  802120:	b8 01 00 00 00       	mov    $0x1,%eax
  802125:	eb 05                	jmp    80212c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802127:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80212c:	c9                   	leave  
  80212d:	c3                   	ret    

0080212e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  80212e:	55                   	push   %ebp
  80212f:	89 e5                	mov    %esp,%ebp
  802131:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802134:	8b 45 08             	mov    0x8(%ebp),%eax
  802137:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80213a:	6a 01                	push   $0x1
  80213c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80213f:	50                   	push   %eax
  802140:	e8 da e9 ff ff       	call   800b1f <sys_cputs>
}
  802145:	83 c4 10             	add    $0x10,%esp
  802148:	c9                   	leave  
  802149:	c3                   	ret    

0080214a <getchar>:

int
getchar(void)
{
  80214a:	55                   	push   %ebp
  80214b:	89 e5                	mov    %esp,%ebp
  80214d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802150:	6a 01                	push   $0x1
  802152:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802155:	50                   	push   %eax
  802156:	6a 00                	push   $0x0
  802158:	e8 29 f2 ff ff       	call   801386 <read>
	if (r < 0)
  80215d:	83 c4 10             	add    $0x10,%esp
  802160:	85 c0                	test   %eax,%eax
  802162:	78 0f                	js     802173 <getchar+0x29>
		return r;
	if (r < 1)
  802164:	85 c0                	test   %eax,%eax
  802166:	7e 06                	jle    80216e <getchar+0x24>
		return -E_EOF;
	return c;
  802168:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80216c:	eb 05                	jmp    802173 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80216e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802173:	c9                   	leave  
  802174:	c3                   	ret    

00802175 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80217b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80217e:	50                   	push   %eax
  80217f:	ff 75 08             	pushl  0x8(%ebp)
  802182:	e8 99 ef ff ff       	call   801120 <fd_lookup>
  802187:	83 c4 10             	add    $0x10,%esp
  80218a:	85 c0                	test   %eax,%eax
  80218c:	78 11                	js     80219f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80218e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802191:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802197:	39 10                	cmp    %edx,(%eax)
  802199:	0f 94 c0             	sete   %al
  80219c:	0f b6 c0             	movzbl %al,%eax
}
  80219f:	c9                   	leave  
  8021a0:	c3                   	ret    

008021a1 <opencons>:

int
opencons(void)
{
  8021a1:	55                   	push   %ebp
  8021a2:	89 e5                	mov    %esp,%ebp
  8021a4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021aa:	50                   	push   %eax
  8021ab:	e8 21 ef ff ff       	call   8010d1 <fd_alloc>
  8021b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8021b3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021b5:	85 c0                	test   %eax,%eax
  8021b7:	78 3e                	js     8021f7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021b9:	83 ec 04             	sub    $0x4,%esp
  8021bc:	68 07 04 00 00       	push   $0x407
  8021c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c4:	6a 00                	push   $0x0
  8021c6:	e8 10 ea ff ff       	call   800bdb <sys_page_alloc>
  8021cb:	83 c4 10             	add    $0x10,%esp
		return r;
  8021ce:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	78 23                	js     8021f7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021d4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021dd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021e9:	83 ec 0c             	sub    $0xc,%esp
  8021ec:	50                   	push   %eax
  8021ed:	e8 b8 ee ff ff       	call   8010aa <fd2num>
  8021f2:	89 c2                	mov    %eax,%edx
  8021f4:	83 c4 10             	add    $0x10,%esp
}
  8021f7:	89 d0                	mov    %edx,%eax
  8021f9:	c9                   	leave  
  8021fa:	c3                   	ret    

008021fb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021fb:	55                   	push   %ebp
  8021fc:	89 e5                	mov    %esp,%ebp
  8021fe:	56                   	push   %esi
  8021ff:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802200:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802203:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802209:	e8 8f e9 ff ff       	call   800b9d <sys_getenvid>
  80220e:	83 ec 0c             	sub    $0xc,%esp
  802211:	ff 75 0c             	pushl  0xc(%ebp)
  802214:	ff 75 08             	pushl  0x8(%ebp)
  802217:	56                   	push   %esi
  802218:	50                   	push   %eax
  802219:	68 b8 2b 80 00       	push   $0x802bb8
  80221e:	e8 b1 df ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802223:	83 c4 18             	add    $0x18,%esp
  802226:	53                   	push   %ebx
  802227:	ff 75 10             	pushl  0x10(%ebp)
  80222a:	e8 54 df ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  80222f:	c7 04 24 af 26 80 00 	movl   $0x8026af,(%esp)
  802236:	e8 99 df ff ff       	call   8001d4 <cprintf>
  80223b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80223e:	cc                   	int3   
  80223f:	eb fd                	jmp    80223e <_panic+0x43>

00802241 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802241:	55                   	push   %ebp
  802242:	89 e5                	mov    %esp,%ebp
  802244:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802247:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80224e:	75 4a                	jne    80229a <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  802250:	a1 08 40 80 00       	mov    0x804008,%eax
  802255:	8b 40 48             	mov    0x48(%eax),%eax
  802258:	83 ec 04             	sub    $0x4,%esp
  80225b:	6a 07                	push   $0x7
  80225d:	68 00 f0 bf ee       	push   $0xeebff000
  802262:	50                   	push   %eax
  802263:	e8 73 e9 ff ff       	call   800bdb <sys_page_alloc>
  802268:	83 c4 10             	add    $0x10,%esp
  80226b:	85 c0                	test   %eax,%eax
  80226d:	79 12                	jns    802281 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  80226f:	50                   	push   %eax
  802270:	68 dc 2b 80 00       	push   $0x802bdc
  802275:	6a 21                	push   $0x21
  802277:	68 f4 2b 80 00       	push   $0x802bf4
  80227c:	e8 7a ff ff ff       	call   8021fb <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802281:	a1 08 40 80 00       	mov    0x804008,%eax
  802286:	8b 40 48             	mov    0x48(%eax),%eax
  802289:	83 ec 08             	sub    $0x8,%esp
  80228c:	68 a4 22 80 00       	push   $0x8022a4
  802291:	50                   	push   %eax
  802292:	e8 8f ea ff ff       	call   800d26 <sys_env_set_pgfault_upcall>
  802297:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80229a:	8b 45 08             	mov    0x8(%ebp),%eax
  80229d:	a3 00 70 80 00       	mov    %eax,0x807000
  8022a2:	c9                   	leave  
  8022a3:	c3                   	ret    

008022a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022a5:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022ac:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8022af:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  8022b2:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  8022b6:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  8022bb:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  8022bf:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8022c1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  8022c2:	83 c4 04             	add    $0x4,%esp
	popfl
  8022c5:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8022c6:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  8022c7:	c3                   	ret    

008022c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	56                   	push   %esi
  8022cc:	53                   	push   %ebx
  8022cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8022d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8022d6:	85 c0                	test   %eax,%eax
  8022d8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8022dd:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8022e0:	83 ec 0c             	sub    $0xc,%esp
  8022e3:	50                   	push   %eax
  8022e4:	e8 a2 ea ff ff       	call   800d8b <sys_ipc_recv>
  8022e9:	83 c4 10             	add    $0x10,%esp
  8022ec:	85 c0                	test   %eax,%eax
  8022ee:	79 16                	jns    802306 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8022f0:	85 f6                	test   %esi,%esi
  8022f2:	74 06                	je     8022fa <ipc_recv+0x32>
            *from_env_store = 0;
  8022f4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  8022fa:	85 db                	test   %ebx,%ebx
  8022fc:	74 2c                	je     80232a <ipc_recv+0x62>
            *perm_store = 0;
  8022fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802304:	eb 24                	jmp    80232a <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  802306:	85 f6                	test   %esi,%esi
  802308:	74 0a                	je     802314 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  80230a:	a1 08 40 80 00       	mov    0x804008,%eax
  80230f:	8b 40 74             	mov    0x74(%eax),%eax
  802312:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  802314:	85 db                	test   %ebx,%ebx
  802316:	74 0a                	je     802322 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  802318:	a1 08 40 80 00       	mov    0x804008,%eax
  80231d:	8b 40 78             	mov    0x78(%eax),%eax
  802320:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  802322:	a1 08 40 80 00       	mov    0x804008,%eax
  802327:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  80232a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5d                   	pop    %ebp
  802330:	c3                   	ret    

00802331 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802331:	55                   	push   %ebp
  802332:	89 e5                	mov    %esp,%ebp
  802334:	57                   	push   %edi
  802335:	56                   	push   %esi
  802336:	53                   	push   %ebx
  802337:	83 ec 0c             	sub    $0xc,%esp
  80233a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80233d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802340:	8b 45 10             	mov    0x10(%ebp),%eax
  802343:	85 c0                	test   %eax,%eax
  802345:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80234a:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80234d:	eb 1c                	jmp    80236b <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80234f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802352:	74 12                	je     802366 <ipc_send+0x35>
  802354:	50                   	push   %eax
  802355:	68 02 2c 80 00       	push   $0x802c02
  80235a:	6a 3b                	push   $0x3b
  80235c:	68 18 2c 80 00       	push   $0x802c18
  802361:	e8 95 fe ff ff       	call   8021fb <_panic>
		sys_yield();
  802366:	e8 51 e8 ff ff       	call   800bbc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80236b:	ff 75 14             	pushl  0x14(%ebp)
  80236e:	53                   	push   %ebx
  80236f:	56                   	push   %esi
  802370:	57                   	push   %edi
  802371:	e8 f2 e9 ff ff       	call   800d68 <sys_ipc_try_send>
  802376:	83 c4 10             	add    $0x10,%esp
  802379:	85 c0                	test   %eax,%eax
  80237b:	78 d2                	js     80234f <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80237d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802380:	5b                   	pop    %ebx
  802381:	5e                   	pop    %esi
  802382:	5f                   	pop    %edi
  802383:	5d                   	pop    %ebp
  802384:	c3                   	ret    

00802385 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802385:	55                   	push   %ebp
  802386:	89 e5                	mov    %esp,%ebp
  802388:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80238b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802390:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802393:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802399:	8b 52 50             	mov    0x50(%edx),%edx
  80239c:	39 ca                	cmp    %ecx,%edx
  80239e:	75 0d                	jne    8023ad <ipc_find_env+0x28>
			return envs[i].env_id;
  8023a0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023a8:	8b 40 48             	mov    0x48(%eax),%eax
  8023ab:	eb 0f                	jmp    8023bc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023ad:	83 c0 01             	add    $0x1,%eax
  8023b0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023b5:	75 d9                	jne    802390 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023bc:	5d                   	pop    %ebp
  8023bd:	c3                   	ret    

008023be <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023c4:	89 d0                	mov    %edx,%eax
  8023c6:	c1 e8 16             	shr    $0x16,%eax
  8023c9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023d0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023d5:	f6 c1 01             	test   $0x1,%cl
  8023d8:	74 1d                	je     8023f7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023da:	c1 ea 0c             	shr    $0xc,%edx
  8023dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023e4:	f6 c2 01             	test   $0x1,%dl
  8023e7:	74 0e                	je     8023f7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023e9:	c1 ea 0c             	shr    $0xc,%edx
  8023ec:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023f3:	ef 
  8023f4:	0f b7 c0             	movzwl %ax,%eax
}
  8023f7:	5d                   	pop    %ebp
  8023f8:	c3                   	ret    
  8023f9:	66 90                	xchg   %ax,%ax
  8023fb:	66 90                	xchg   %ax,%ax
  8023fd:	66 90                	xchg   %ax,%ax
  8023ff:	90                   	nop

00802400 <__udivdi3>:
  802400:	55                   	push   %ebp
  802401:	57                   	push   %edi
  802402:	56                   	push   %esi
  802403:	53                   	push   %ebx
  802404:	83 ec 1c             	sub    $0x1c,%esp
  802407:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80240b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80240f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802413:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802417:	85 f6                	test   %esi,%esi
  802419:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80241d:	89 ca                	mov    %ecx,%edx
  80241f:	89 f8                	mov    %edi,%eax
  802421:	75 3d                	jne    802460 <__udivdi3+0x60>
  802423:	39 cf                	cmp    %ecx,%edi
  802425:	0f 87 c5 00 00 00    	ja     8024f0 <__udivdi3+0xf0>
  80242b:	85 ff                	test   %edi,%edi
  80242d:	89 fd                	mov    %edi,%ebp
  80242f:	75 0b                	jne    80243c <__udivdi3+0x3c>
  802431:	b8 01 00 00 00       	mov    $0x1,%eax
  802436:	31 d2                	xor    %edx,%edx
  802438:	f7 f7                	div    %edi
  80243a:	89 c5                	mov    %eax,%ebp
  80243c:	89 c8                	mov    %ecx,%eax
  80243e:	31 d2                	xor    %edx,%edx
  802440:	f7 f5                	div    %ebp
  802442:	89 c1                	mov    %eax,%ecx
  802444:	89 d8                	mov    %ebx,%eax
  802446:	89 cf                	mov    %ecx,%edi
  802448:	f7 f5                	div    %ebp
  80244a:	89 c3                	mov    %eax,%ebx
  80244c:	89 d8                	mov    %ebx,%eax
  80244e:	89 fa                	mov    %edi,%edx
  802450:	83 c4 1c             	add    $0x1c,%esp
  802453:	5b                   	pop    %ebx
  802454:	5e                   	pop    %esi
  802455:	5f                   	pop    %edi
  802456:	5d                   	pop    %ebp
  802457:	c3                   	ret    
  802458:	90                   	nop
  802459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802460:	39 ce                	cmp    %ecx,%esi
  802462:	77 74                	ja     8024d8 <__udivdi3+0xd8>
  802464:	0f bd fe             	bsr    %esi,%edi
  802467:	83 f7 1f             	xor    $0x1f,%edi
  80246a:	0f 84 98 00 00 00    	je     802508 <__udivdi3+0x108>
  802470:	bb 20 00 00 00       	mov    $0x20,%ebx
  802475:	89 f9                	mov    %edi,%ecx
  802477:	89 c5                	mov    %eax,%ebp
  802479:	29 fb                	sub    %edi,%ebx
  80247b:	d3 e6                	shl    %cl,%esi
  80247d:	89 d9                	mov    %ebx,%ecx
  80247f:	d3 ed                	shr    %cl,%ebp
  802481:	89 f9                	mov    %edi,%ecx
  802483:	d3 e0                	shl    %cl,%eax
  802485:	09 ee                	or     %ebp,%esi
  802487:	89 d9                	mov    %ebx,%ecx
  802489:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80248d:	89 d5                	mov    %edx,%ebp
  80248f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802493:	d3 ed                	shr    %cl,%ebp
  802495:	89 f9                	mov    %edi,%ecx
  802497:	d3 e2                	shl    %cl,%edx
  802499:	89 d9                	mov    %ebx,%ecx
  80249b:	d3 e8                	shr    %cl,%eax
  80249d:	09 c2                	or     %eax,%edx
  80249f:	89 d0                	mov    %edx,%eax
  8024a1:	89 ea                	mov    %ebp,%edx
  8024a3:	f7 f6                	div    %esi
  8024a5:	89 d5                	mov    %edx,%ebp
  8024a7:	89 c3                	mov    %eax,%ebx
  8024a9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ad:	39 d5                	cmp    %edx,%ebp
  8024af:	72 10                	jb     8024c1 <__udivdi3+0xc1>
  8024b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	d3 e6                	shl    %cl,%esi
  8024b9:	39 c6                	cmp    %eax,%esi
  8024bb:	73 07                	jae    8024c4 <__udivdi3+0xc4>
  8024bd:	39 d5                	cmp    %edx,%ebp
  8024bf:	75 03                	jne    8024c4 <__udivdi3+0xc4>
  8024c1:	83 eb 01             	sub    $0x1,%ebx
  8024c4:	31 ff                	xor    %edi,%edi
  8024c6:	89 d8                	mov    %ebx,%eax
  8024c8:	89 fa                	mov    %edi,%edx
  8024ca:	83 c4 1c             	add    $0x1c,%esp
  8024cd:	5b                   	pop    %ebx
  8024ce:	5e                   	pop    %esi
  8024cf:	5f                   	pop    %edi
  8024d0:	5d                   	pop    %ebp
  8024d1:	c3                   	ret    
  8024d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d8:	31 ff                	xor    %edi,%edi
  8024da:	31 db                	xor    %ebx,%ebx
  8024dc:	89 d8                	mov    %ebx,%eax
  8024de:	89 fa                	mov    %edi,%edx
  8024e0:	83 c4 1c             	add    $0x1c,%esp
  8024e3:	5b                   	pop    %ebx
  8024e4:	5e                   	pop    %esi
  8024e5:	5f                   	pop    %edi
  8024e6:	5d                   	pop    %ebp
  8024e7:	c3                   	ret    
  8024e8:	90                   	nop
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	89 d8                	mov    %ebx,%eax
  8024f2:	f7 f7                	div    %edi
  8024f4:	31 ff                	xor    %edi,%edi
  8024f6:	89 c3                	mov    %eax,%ebx
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	89 fa                	mov    %edi,%edx
  8024fc:	83 c4 1c             	add    $0x1c,%esp
  8024ff:	5b                   	pop    %ebx
  802500:	5e                   	pop    %esi
  802501:	5f                   	pop    %edi
  802502:	5d                   	pop    %ebp
  802503:	c3                   	ret    
  802504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802508:	39 ce                	cmp    %ecx,%esi
  80250a:	72 0c                	jb     802518 <__udivdi3+0x118>
  80250c:	31 db                	xor    %ebx,%ebx
  80250e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802512:	0f 87 34 ff ff ff    	ja     80244c <__udivdi3+0x4c>
  802518:	bb 01 00 00 00       	mov    $0x1,%ebx
  80251d:	e9 2a ff ff ff       	jmp    80244c <__udivdi3+0x4c>
  802522:	66 90                	xchg   %ax,%ax
  802524:	66 90                	xchg   %ax,%ax
  802526:	66 90                	xchg   %ax,%ax
  802528:	66 90                	xchg   %ax,%ax
  80252a:	66 90                	xchg   %ax,%ax
  80252c:	66 90                	xchg   %ax,%ax
  80252e:	66 90                	xchg   %ax,%ax

00802530 <__umoddi3>:
  802530:	55                   	push   %ebp
  802531:	57                   	push   %edi
  802532:	56                   	push   %esi
  802533:	53                   	push   %ebx
  802534:	83 ec 1c             	sub    $0x1c,%esp
  802537:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80253b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80253f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802543:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802547:	85 d2                	test   %edx,%edx
  802549:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80254d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802551:	89 f3                	mov    %esi,%ebx
  802553:	89 3c 24             	mov    %edi,(%esp)
  802556:	89 74 24 04          	mov    %esi,0x4(%esp)
  80255a:	75 1c                	jne    802578 <__umoddi3+0x48>
  80255c:	39 f7                	cmp    %esi,%edi
  80255e:	76 50                	jbe    8025b0 <__umoddi3+0x80>
  802560:	89 c8                	mov    %ecx,%eax
  802562:	89 f2                	mov    %esi,%edx
  802564:	f7 f7                	div    %edi
  802566:	89 d0                	mov    %edx,%eax
  802568:	31 d2                	xor    %edx,%edx
  80256a:	83 c4 1c             	add    $0x1c,%esp
  80256d:	5b                   	pop    %ebx
  80256e:	5e                   	pop    %esi
  80256f:	5f                   	pop    %edi
  802570:	5d                   	pop    %ebp
  802571:	c3                   	ret    
  802572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802578:	39 f2                	cmp    %esi,%edx
  80257a:	89 d0                	mov    %edx,%eax
  80257c:	77 52                	ja     8025d0 <__umoddi3+0xa0>
  80257e:	0f bd ea             	bsr    %edx,%ebp
  802581:	83 f5 1f             	xor    $0x1f,%ebp
  802584:	75 5a                	jne    8025e0 <__umoddi3+0xb0>
  802586:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80258a:	0f 82 e0 00 00 00    	jb     802670 <__umoddi3+0x140>
  802590:	39 0c 24             	cmp    %ecx,(%esp)
  802593:	0f 86 d7 00 00 00    	jbe    802670 <__umoddi3+0x140>
  802599:	8b 44 24 08          	mov    0x8(%esp),%eax
  80259d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025a1:	83 c4 1c             	add    $0x1c,%esp
  8025a4:	5b                   	pop    %ebx
  8025a5:	5e                   	pop    %esi
  8025a6:	5f                   	pop    %edi
  8025a7:	5d                   	pop    %ebp
  8025a8:	c3                   	ret    
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	85 ff                	test   %edi,%edi
  8025b2:	89 fd                	mov    %edi,%ebp
  8025b4:	75 0b                	jne    8025c1 <__umoddi3+0x91>
  8025b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025bb:	31 d2                	xor    %edx,%edx
  8025bd:	f7 f7                	div    %edi
  8025bf:	89 c5                	mov    %eax,%ebp
  8025c1:	89 f0                	mov    %esi,%eax
  8025c3:	31 d2                	xor    %edx,%edx
  8025c5:	f7 f5                	div    %ebp
  8025c7:	89 c8                	mov    %ecx,%eax
  8025c9:	f7 f5                	div    %ebp
  8025cb:	89 d0                	mov    %edx,%eax
  8025cd:	eb 99                	jmp    802568 <__umoddi3+0x38>
  8025cf:	90                   	nop
  8025d0:	89 c8                	mov    %ecx,%eax
  8025d2:	89 f2                	mov    %esi,%edx
  8025d4:	83 c4 1c             	add    $0x1c,%esp
  8025d7:	5b                   	pop    %ebx
  8025d8:	5e                   	pop    %esi
  8025d9:	5f                   	pop    %edi
  8025da:	5d                   	pop    %ebp
  8025db:	c3                   	ret    
  8025dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	8b 34 24             	mov    (%esp),%esi
  8025e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025e8:	89 e9                	mov    %ebp,%ecx
  8025ea:	29 ef                	sub    %ebp,%edi
  8025ec:	d3 e0                	shl    %cl,%eax
  8025ee:	89 f9                	mov    %edi,%ecx
  8025f0:	89 f2                	mov    %esi,%edx
  8025f2:	d3 ea                	shr    %cl,%edx
  8025f4:	89 e9                	mov    %ebp,%ecx
  8025f6:	09 c2                	or     %eax,%edx
  8025f8:	89 d8                	mov    %ebx,%eax
  8025fa:	89 14 24             	mov    %edx,(%esp)
  8025fd:	89 f2                	mov    %esi,%edx
  8025ff:	d3 e2                	shl    %cl,%edx
  802601:	89 f9                	mov    %edi,%ecx
  802603:	89 54 24 04          	mov    %edx,0x4(%esp)
  802607:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80260b:	d3 e8                	shr    %cl,%eax
  80260d:	89 e9                	mov    %ebp,%ecx
  80260f:	89 c6                	mov    %eax,%esi
  802611:	d3 e3                	shl    %cl,%ebx
  802613:	89 f9                	mov    %edi,%ecx
  802615:	89 d0                	mov    %edx,%eax
  802617:	d3 e8                	shr    %cl,%eax
  802619:	89 e9                	mov    %ebp,%ecx
  80261b:	09 d8                	or     %ebx,%eax
  80261d:	89 d3                	mov    %edx,%ebx
  80261f:	89 f2                	mov    %esi,%edx
  802621:	f7 34 24             	divl   (%esp)
  802624:	89 d6                	mov    %edx,%esi
  802626:	d3 e3                	shl    %cl,%ebx
  802628:	f7 64 24 04          	mull   0x4(%esp)
  80262c:	39 d6                	cmp    %edx,%esi
  80262e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802632:	89 d1                	mov    %edx,%ecx
  802634:	89 c3                	mov    %eax,%ebx
  802636:	72 08                	jb     802640 <__umoddi3+0x110>
  802638:	75 11                	jne    80264b <__umoddi3+0x11b>
  80263a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80263e:	73 0b                	jae    80264b <__umoddi3+0x11b>
  802640:	2b 44 24 04          	sub    0x4(%esp),%eax
  802644:	1b 14 24             	sbb    (%esp),%edx
  802647:	89 d1                	mov    %edx,%ecx
  802649:	89 c3                	mov    %eax,%ebx
  80264b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80264f:	29 da                	sub    %ebx,%edx
  802651:	19 ce                	sbb    %ecx,%esi
  802653:	89 f9                	mov    %edi,%ecx
  802655:	89 f0                	mov    %esi,%eax
  802657:	d3 e0                	shl    %cl,%eax
  802659:	89 e9                	mov    %ebp,%ecx
  80265b:	d3 ea                	shr    %cl,%edx
  80265d:	89 e9                	mov    %ebp,%ecx
  80265f:	d3 ee                	shr    %cl,%esi
  802661:	09 d0                	or     %edx,%eax
  802663:	89 f2                	mov    %esi,%edx
  802665:	83 c4 1c             	add    $0x1c,%esp
  802668:	5b                   	pop    %ebx
  802669:	5e                   	pop    %esi
  80266a:	5f                   	pop    %edi
  80266b:	5d                   	pop    %ebp
  80266c:	c3                   	ret    
  80266d:	8d 76 00             	lea    0x0(%esi),%esi
  802670:	29 f9                	sub    %edi,%ecx
  802672:	19 d6                	sbb    %edx,%esi
  802674:	89 74 24 04          	mov    %esi,0x4(%esp)
  802678:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80267c:	e9 18 ff ff ff       	jmp    802599 <__umoddi3+0x69>
