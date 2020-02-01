
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
  800047:	68 00 22 80 00       	push   $0x802200
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
  800095:	68 11 22 80 00       	push   $0x802211
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 e0 06 00 00       	call   800785 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 11 0e 00 00       	call   800ebe <fork>
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
  8000d2:	68 10 22 80 00       	push   $0x802210
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
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80012d:	e8 04 11 00 00       	call   801236 <close_all>
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
  800237:	e8 24 1d 00 00       	call   801f60 <__udivdi3>
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
  80027a:	e8 11 1e 00 00       	call   802090 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 20 22 80 00 	movsbl 0x802220(%eax),%eax
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
  800344:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
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
  80040b:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  800412:	85 d2                	test   %edx,%edx
  800414:	75 1b                	jne    800431 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800416:	50                   	push   %eax
  800417:	68 38 22 80 00       	push   $0x802238
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
  800432:	68 95 26 80 00       	push   $0x802695
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
  80045c:	b8 31 22 80 00       	mov    $0x802231,%eax
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
  800b84:	68 1f 25 80 00       	push   $0x80251f
  800b89:	6a 23                	push   $0x23
  800b8b:	68 3c 25 80 00       	push   $0x80253c
  800b90:	e8 c0 11 00 00       	call   801d55 <_panic>

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
  800c05:	68 1f 25 80 00       	push   $0x80251f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 3c 25 80 00       	push   $0x80253c
  800c11:	e8 3f 11 00 00       	call   801d55 <_panic>

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
  800c47:	68 1f 25 80 00       	push   $0x80251f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 3c 25 80 00       	push   $0x80253c
  800c53:	e8 fd 10 00 00       	call   801d55 <_panic>

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
  800c89:	68 1f 25 80 00       	push   $0x80251f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 3c 25 80 00       	push   $0x80253c
  800c95:	e8 bb 10 00 00       	call   801d55 <_panic>

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
  800ccb:	68 1f 25 80 00       	push   $0x80251f
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 3c 25 80 00       	push   $0x80253c
  800cd7:	e8 79 10 00 00       	call   801d55 <_panic>

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
  800d0d:	68 1f 25 80 00       	push   $0x80251f
  800d12:	6a 23                	push   $0x23
  800d14:	68 3c 25 80 00       	push   $0x80253c
  800d19:	e8 37 10 00 00       	call   801d55 <_panic>

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
  800d4f:	68 1f 25 80 00       	push   $0x80251f
  800d54:	6a 23                	push   $0x23
  800d56:	68 3c 25 80 00       	push   $0x80253c
  800d5b:	e8 f5 0f 00 00       	call   801d55 <_panic>

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
  800db3:	68 1f 25 80 00       	push   $0x80251f
  800db8:	6a 23                	push   $0x23
  800dba:	68 3c 25 80 00       	push   $0x80253c
  800dbf:	e8 91 0f 00 00       	call   801d55 <_panic>

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

00800dcc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 04             	sub    $0x4,%esp
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dd6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800dd8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ddc:	74 2d                	je     800e0b <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800dde:	89 d8                	mov    %ebx,%eax
  800de0:	c1 e8 16             	shr    $0x16,%eax
  800de3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dea:	a8 01                	test   $0x1,%al
  800dec:	74 1d                	je     800e0b <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800dee:	89 d8                	mov    %ebx,%eax
  800df0:	c1 e8 0c             	shr    $0xc,%eax
  800df3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800dfa:	f6 c2 01             	test   $0x1,%dl
  800dfd:	74 0c                	je     800e0b <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800dff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e06:	f6 c4 08             	test   $0x8,%ah
  800e09:	75 14                	jne    800e1f <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	68 4c 25 80 00       	push   $0x80254c
  800e13:	6a 1f                	push   $0x1f
  800e15:	68 82 25 80 00       	push   $0x802582
  800e1a:	e8 36 0f 00 00       	call   801d55 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	6a 07                	push   $0x7
  800e24:	68 00 f0 7f 00       	push   $0x7ff000
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 ab fd ff ff       	call   800bdb <sys_page_alloc>
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	79 12                	jns    800e49 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800e37:	50                   	push   %eax
  800e38:	68 8d 25 80 00       	push   $0x80258d
  800e3d:	6a 29                	push   $0x29
  800e3f:	68 82 25 80 00       	push   $0x802582
  800e44:	e8 0c 0f 00 00       	call   801d55 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e49:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800e4f:	83 ec 04             	sub    $0x4,%esp
  800e52:	68 00 10 00 00       	push   $0x1000
  800e57:	53                   	push   %ebx
  800e58:	68 00 f0 7f 00       	push   $0x7ff000
  800e5d:	e8 70 fb ff ff       	call   8009d2 <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800e62:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e69:	53                   	push   %ebx
  800e6a:	6a 00                	push   $0x0
  800e6c:	68 00 f0 7f 00       	push   $0x7ff000
  800e71:	6a 00                	push   $0x0
  800e73:	e8 a6 fd ff ff       	call   800c1e <sys_page_map>
  800e78:	83 c4 20             	add    $0x20,%esp
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	79 12                	jns    800e91 <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800e7f:	50                   	push   %eax
  800e80:	68 a1 25 80 00       	push   $0x8025a1
  800e85:	6a 2e                	push   $0x2e
  800e87:	68 82 25 80 00       	push   $0x802582
  800e8c:	e8 c4 0e 00 00       	call   801d55 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	68 00 f0 7f 00       	push   $0x7ff000
  800e99:	6a 00                	push   $0x0
  800e9b:	e8 c0 fd ff ff       	call   800c60 <sys_page_unmap>
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	79 12                	jns    800eb9 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800ea7:	50                   	push   %eax
  800ea8:	68 b3 25 80 00       	push   $0x8025b3
  800ead:	6a 30                	push   $0x30
  800eaf:	68 82 25 80 00       	push   $0x802582
  800eb4:	e8 9c 0e 00 00       	call   801d55 <_panic>
	//panic("pgfault not implemented");
}
  800eb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800ec7:	68 cc 0d 80 00       	push   $0x800dcc
  800ecc:	e8 ca 0e 00 00       	call   801d9b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ed1:	b8 07 00 00 00       	mov    $0x7,%eax
  800ed6:	cd 30                	int    $0x30
  800ed8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800edb:	83 c4 10             	add    $0x10,%esp
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	79 14                	jns    800ef6 <fork+0x38>
		panic("sys_exofork failed");
  800ee2:	83 ec 04             	sub    $0x4,%esp
  800ee5:	68 c7 25 80 00       	push   $0x8025c7
  800eea:	6a 6f                	push   $0x6f
  800eec:	68 82 25 80 00       	push   $0x802582
  800ef1:	e8 5f 0e 00 00       	call   801d55 <_panic>
  800ef6:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800ef8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800efc:	0f 8e 2b 01 00 00    	jle    80102d <fork+0x16f>
  800f02:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800f07:	89 d8                	mov    %ebx,%eax
  800f09:	c1 e8 0a             	shr    $0xa,%eax
  800f0c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f13:	a8 01                	test   $0x1,%al
  800f15:	0f 84 bf 00 00 00    	je     800fda <fork+0x11c>
  800f1b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f22:	a8 01                	test   $0x1,%al
  800f24:	0f 84 b0 00 00 00    	je     800fda <fork+0x11c>
  800f2a:	89 de                	mov    %ebx,%esi
  800f2c:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  800f2f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f36:	f6 c4 04             	test   $0x4,%ah
  800f39:	74 29                	je     800f64 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  800f3b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f42:	83 ec 0c             	sub    $0xc,%esp
  800f45:	25 07 0e 00 00       	and    $0xe07,%eax
  800f4a:	50                   	push   %eax
  800f4b:	56                   	push   %esi
  800f4c:	57                   	push   %edi
  800f4d:	56                   	push   %esi
  800f4e:	6a 00                	push   $0x0
  800f50:	e8 c9 fc ff ff       	call   800c1e <sys_page_map>
  800f55:	83 c4 20             	add    $0x20,%esp
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5f:	0f 4f c2             	cmovg  %edx,%eax
  800f62:	eb 72                	jmp    800fd6 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800f64:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f6b:	a8 02                	test   $0x2,%al
  800f6d:	75 0c                	jne    800f7b <fork+0xbd>
  800f6f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f76:	f6 c4 08             	test   $0x8,%ah
  800f79:	74 3f                	je     800fba <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	68 05 08 00 00       	push   $0x805
  800f83:	56                   	push   %esi
  800f84:	57                   	push   %edi
  800f85:	56                   	push   %esi
  800f86:	6a 00                	push   $0x0
  800f88:	e8 91 fc ff ff       	call   800c1e <sys_page_map>
  800f8d:	83 c4 20             	add    $0x20,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	0f 88 b1 00 00 00    	js     801049 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	68 05 08 00 00       	push   $0x805
  800fa0:	56                   	push   %esi
  800fa1:	6a 00                	push   $0x0
  800fa3:	56                   	push   %esi
  800fa4:	6a 00                	push   $0x0
  800fa6:	e8 73 fc ff ff       	call   800c1e <sys_page_map>
  800fab:	83 c4 20             	add    $0x20,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb5:	0f 4f c1             	cmovg  %ecx,%eax
  800fb8:	eb 1c                	jmp    800fd6 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	6a 05                	push   $0x5
  800fbf:	56                   	push   %esi
  800fc0:	57                   	push   %edi
  800fc1:	56                   	push   %esi
  800fc2:	6a 00                	push   $0x0
  800fc4:	e8 55 fc ff ff       	call   800c1e <sys_page_map>
  800fc9:	83 c4 20             	add    $0x20,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd3:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 6f                	js     801049 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  800fda:	83 c3 01             	add    $0x1,%ebx
  800fdd:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fe3:	0f 85 1e ff ff ff    	jne    800f07 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  800fe9:	83 ec 04             	sub    $0x4,%esp
  800fec:	6a 07                	push   $0x7
  800fee:	68 00 f0 bf ee       	push   $0xeebff000
  800ff3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ff6:	57                   	push   %edi
  800ff7:	e8 df fb ff ff       	call   800bdb <sys_page_alloc>
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 46                	js     801049 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  801003:	83 ec 08             	sub    $0x8,%esp
  801006:	68 fe 1d 80 00       	push   $0x801dfe
  80100b:	57                   	push   %edi
  80100c:	e8 15 fd ff ff       	call   800d26 <sys_env_set_pgfault_upcall>
  801011:	83 c4 10             	add    $0x10,%esp
  801014:	85 c0                	test   %eax,%eax
  801016:	78 31                	js     801049 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  801018:	83 ec 08             	sub    $0x8,%esp
  80101b:	6a 02                	push   $0x2
  80101d:	57                   	push   %edi
  80101e:	e8 7f fc ff ff       	call   800ca2 <sys_env_set_status>
  801023:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  801026:	85 c0                	test   %eax,%eax
  801028:	0f 49 c7             	cmovns %edi,%eax
  80102b:	eb 1c                	jmp    801049 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  80102d:	e8 6b fb ff ff       	call   800b9d <sys_getenvid>
  801032:	25 ff 03 00 00       	and    $0x3ff,%eax
  801037:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80103a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80103f:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801044:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <sfork>:

// Challenge!
int
sfork(void)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801057:	68 da 25 80 00       	push   $0x8025da
  80105c:	68 8d 00 00 00       	push   $0x8d
  801061:	68 82 25 80 00       	push   $0x802582
  801066:	e8 ea 0c 00 00       	call   801d55 <_panic>

0080106b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80106e:	8b 45 08             	mov    0x8(%ebp),%eax
  801071:	05 00 00 00 30       	add    $0x30000000,%eax
  801076:	c1 e8 0c             	shr    $0xc,%eax
}
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80107e:	8b 45 08             	mov    0x8(%ebp),%eax
  801081:	05 00 00 00 30       	add    $0x30000000,%eax
  801086:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80108b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801098:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80109d:	89 c2                	mov    %eax,%edx
  80109f:	c1 ea 16             	shr    $0x16,%edx
  8010a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010a9:	f6 c2 01             	test   $0x1,%dl
  8010ac:	74 11                	je     8010bf <fd_alloc+0x2d>
  8010ae:	89 c2                	mov    %eax,%edx
  8010b0:	c1 ea 0c             	shr    $0xc,%edx
  8010b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ba:	f6 c2 01             	test   $0x1,%dl
  8010bd:	75 09                	jne    8010c8 <fd_alloc+0x36>
			*fd_store = fd;
  8010bf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c6:	eb 17                	jmp    8010df <fd_alloc+0x4d>
  8010c8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010cd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010d2:	75 c9                	jne    80109d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010d4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010da:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010e7:	83 f8 1f             	cmp    $0x1f,%eax
  8010ea:	77 36                	ja     801122 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010ec:	c1 e0 0c             	shl    $0xc,%eax
  8010ef:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010f4:	89 c2                	mov    %eax,%edx
  8010f6:	c1 ea 16             	shr    $0x16,%edx
  8010f9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801100:	f6 c2 01             	test   $0x1,%dl
  801103:	74 24                	je     801129 <fd_lookup+0x48>
  801105:	89 c2                	mov    %eax,%edx
  801107:	c1 ea 0c             	shr    $0xc,%edx
  80110a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801111:	f6 c2 01             	test   $0x1,%dl
  801114:	74 1a                	je     801130 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801116:	8b 55 0c             	mov    0xc(%ebp),%edx
  801119:	89 02                	mov    %eax,(%edx)
	return 0;
  80111b:	b8 00 00 00 00       	mov    $0x0,%eax
  801120:	eb 13                	jmp    801135 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801122:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801127:	eb 0c                	jmp    801135 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801129:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112e:	eb 05                	jmp    801135 <fd_lookup+0x54>
  801130:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	83 ec 08             	sub    $0x8,%esp
  80113d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801140:	ba 6c 26 80 00       	mov    $0x80266c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801145:	eb 13                	jmp    80115a <dev_lookup+0x23>
  801147:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80114a:	39 08                	cmp    %ecx,(%eax)
  80114c:	75 0c                	jne    80115a <dev_lookup+0x23>
			*dev = devtab[i];
  80114e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801151:	89 01                	mov    %eax,(%ecx)
			return 0;
  801153:	b8 00 00 00 00       	mov    $0x0,%eax
  801158:	eb 2e                	jmp    801188 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80115a:	8b 02                	mov    (%edx),%eax
  80115c:	85 c0                	test   %eax,%eax
  80115e:	75 e7                	jne    801147 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801160:	a1 04 40 80 00       	mov    0x804004,%eax
  801165:	8b 40 48             	mov    0x48(%eax),%eax
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	51                   	push   %ecx
  80116c:	50                   	push   %eax
  80116d:	68 f0 25 80 00       	push   $0x8025f0
  801172:	e8 5d f0 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  801177:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801188:	c9                   	leave  
  801189:	c3                   	ret    

0080118a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	56                   	push   %esi
  80118e:	53                   	push   %ebx
  80118f:	83 ec 10             	sub    $0x10,%esp
  801192:	8b 75 08             	mov    0x8(%ebp),%esi
  801195:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801198:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119b:	50                   	push   %eax
  80119c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011a2:	c1 e8 0c             	shr    $0xc,%eax
  8011a5:	50                   	push   %eax
  8011a6:	e8 36 ff ff ff       	call   8010e1 <fd_lookup>
  8011ab:	83 c4 08             	add    $0x8,%esp
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	78 05                	js     8011b7 <fd_close+0x2d>
	    || fd != fd2)
  8011b2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011b5:	74 0c                	je     8011c3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011b7:	84 db                	test   %bl,%bl
  8011b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011be:	0f 44 c2             	cmove  %edx,%eax
  8011c1:	eb 41                	jmp    801204 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	ff 36                	pushl  (%esi)
  8011cc:	e8 66 ff ff ff       	call   801137 <dev_lookup>
  8011d1:	89 c3                	mov    %eax,%ebx
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 1a                	js     8011f4 <fd_close+0x6a>
		if (dev->dev_close)
  8011da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	74 0b                	je     8011f4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	56                   	push   %esi
  8011ed:	ff d0                	call   *%eax
  8011ef:	89 c3                	mov    %eax,%ebx
  8011f1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011f4:	83 ec 08             	sub    $0x8,%esp
  8011f7:	56                   	push   %esi
  8011f8:	6a 00                	push   $0x0
  8011fa:	e8 61 fa ff ff       	call   800c60 <sys_page_unmap>
	return r;
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	89 d8                	mov    %ebx,%eax
}
  801204:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801207:	5b                   	pop    %ebx
  801208:	5e                   	pop    %esi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	ff 75 08             	pushl  0x8(%ebp)
  801218:	e8 c4 fe ff ff       	call   8010e1 <fd_lookup>
  80121d:	83 c4 08             	add    $0x8,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	78 10                	js     801234 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	6a 01                	push   $0x1
  801229:	ff 75 f4             	pushl  -0xc(%ebp)
  80122c:	e8 59 ff ff ff       	call   80118a <fd_close>
  801231:	83 c4 10             	add    $0x10,%esp
}
  801234:	c9                   	leave  
  801235:	c3                   	ret    

00801236 <close_all>:

void
close_all(void)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	53                   	push   %ebx
  80123a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801242:	83 ec 0c             	sub    $0xc,%esp
  801245:	53                   	push   %ebx
  801246:	e8 c0 ff ff ff       	call   80120b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80124b:	83 c3 01             	add    $0x1,%ebx
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	83 fb 20             	cmp    $0x20,%ebx
  801254:	75 ec                	jne    801242 <close_all+0xc>
		close(i);
}
  801256:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	57                   	push   %edi
  80125f:	56                   	push   %esi
  801260:	53                   	push   %ebx
  801261:	83 ec 2c             	sub    $0x2c,%esp
  801264:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801267:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	ff 75 08             	pushl  0x8(%ebp)
  80126e:	e8 6e fe ff ff       	call   8010e1 <fd_lookup>
  801273:	83 c4 08             	add    $0x8,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	0f 88 c1 00 00 00    	js     80133f <dup+0xe4>
		return r;
	close(newfdnum);
  80127e:	83 ec 0c             	sub    $0xc,%esp
  801281:	56                   	push   %esi
  801282:	e8 84 ff ff ff       	call   80120b <close>

	newfd = INDEX2FD(newfdnum);
  801287:	89 f3                	mov    %esi,%ebx
  801289:	c1 e3 0c             	shl    $0xc,%ebx
  80128c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801292:	83 c4 04             	add    $0x4,%esp
  801295:	ff 75 e4             	pushl  -0x1c(%ebp)
  801298:	e8 de fd ff ff       	call   80107b <fd2data>
  80129d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80129f:	89 1c 24             	mov    %ebx,(%esp)
  8012a2:	e8 d4 fd ff ff       	call   80107b <fd2data>
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012ad:	89 f8                	mov    %edi,%eax
  8012af:	c1 e8 16             	shr    $0x16,%eax
  8012b2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b9:	a8 01                	test   $0x1,%al
  8012bb:	74 37                	je     8012f4 <dup+0x99>
  8012bd:	89 f8                	mov    %edi,%eax
  8012bf:	c1 e8 0c             	shr    $0xc,%eax
  8012c2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012c9:	f6 c2 01             	test   $0x1,%dl
  8012cc:	74 26                	je     8012f4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d5:	83 ec 0c             	sub    $0xc,%esp
  8012d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012dd:	50                   	push   %eax
  8012de:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012e1:	6a 00                	push   $0x0
  8012e3:	57                   	push   %edi
  8012e4:	6a 00                	push   $0x0
  8012e6:	e8 33 f9 ff ff       	call   800c1e <sys_page_map>
  8012eb:	89 c7                	mov    %eax,%edi
  8012ed:	83 c4 20             	add    $0x20,%esp
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	78 2e                	js     801322 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012f7:	89 d0                	mov    %edx,%eax
  8012f9:	c1 e8 0c             	shr    $0xc,%eax
  8012fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801303:	83 ec 0c             	sub    $0xc,%esp
  801306:	25 07 0e 00 00       	and    $0xe07,%eax
  80130b:	50                   	push   %eax
  80130c:	53                   	push   %ebx
  80130d:	6a 00                	push   $0x0
  80130f:	52                   	push   %edx
  801310:	6a 00                	push   $0x0
  801312:	e8 07 f9 ff ff       	call   800c1e <sys_page_map>
  801317:	89 c7                	mov    %eax,%edi
  801319:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80131c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80131e:	85 ff                	test   %edi,%edi
  801320:	79 1d                	jns    80133f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801322:	83 ec 08             	sub    $0x8,%esp
  801325:	53                   	push   %ebx
  801326:	6a 00                	push   $0x0
  801328:	e8 33 f9 ff ff       	call   800c60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80132d:	83 c4 08             	add    $0x8,%esp
  801330:	ff 75 d4             	pushl  -0x2c(%ebp)
  801333:	6a 00                	push   $0x0
  801335:	e8 26 f9 ff ff       	call   800c60 <sys_page_unmap>
	return r;
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	89 f8                	mov    %edi,%eax
}
  80133f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801342:	5b                   	pop    %ebx
  801343:	5e                   	pop    %esi
  801344:	5f                   	pop    %edi
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	53                   	push   %ebx
  80134b:	83 ec 14             	sub    $0x14,%esp
  80134e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801351:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	53                   	push   %ebx
  801356:	e8 86 fd ff ff       	call   8010e1 <fd_lookup>
  80135b:	83 c4 08             	add    $0x8,%esp
  80135e:	89 c2                	mov    %eax,%edx
  801360:	85 c0                	test   %eax,%eax
  801362:	78 6d                	js     8013d1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136a:	50                   	push   %eax
  80136b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136e:	ff 30                	pushl  (%eax)
  801370:	e8 c2 fd ff ff       	call   801137 <dev_lookup>
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 4c                	js     8013c8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80137c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80137f:	8b 42 08             	mov    0x8(%edx),%eax
  801382:	83 e0 03             	and    $0x3,%eax
  801385:	83 f8 01             	cmp    $0x1,%eax
  801388:	75 21                	jne    8013ab <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80138a:	a1 04 40 80 00       	mov    0x804004,%eax
  80138f:	8b 40 48             	mov    0x48(%eax),%eax
  801392:	83 ec 04             	sub    $0x4,%esp
  801395:	53                   	push   %ebx
  801396:	50                   	push   %eax
  801397:	68 31 26 80 00       	push   $0x802631
  80139c:	e8 33 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013a9:	eb 26                	jmp    8013d1 <read+0x8a>
	}
	if (!dev->dev_read)
  8013ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ae:	8b 40 08             	mov    0x8(%eax),%eax
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	74 17                	je     8013cc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013b5:	83 ec 04             	sub    $0x4,%esp
  8013b8:	ff 75 10             	pushl  0x10(%ebp)
  8013bb:	ff 75 0c             	pushl  0xc(%ebp)
  8013be:	52                   	push   %edx
  8013bf:	ff d0                	call   *%eax
  8013c1:	89 c2                	mov    %eax,%edx
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	eb 09                	jmp    8013d1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c8:	89 c2                	mov    %eax,%edx
  8013ca:	eb 05                	jmp    8013d1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013d1:	89 d0                	mov    %edx,%eax
  8013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	57                   	push   %edi
  8013dc:	56                   	push   %esi
  8013dd:	53                   	push   %ebx
  8013de:	83 ec 0c             	sub    $0xc,%esp
  8013e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ec:	eb 21                	jmp    80140f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013ee:	83 ec 04             	sub    $0x4,%esp
  8013f1:	89 f0                	mov    %esi,%eax
  8013f3:	29 d8                	sub    %ebx,%eax
  8013f5:	50                   	push   %eax
  8013f6:	89 d8                	mov    %ebx,%eax
  8013f8:	03 45 0c             	add    0xc(%ebp),%eax
  8013fb:	50                   	push   %eax
  8013fc:	57                   	push   %edi
  8013fd:	e8 45 ff ff ff       	call   801347 <read>
		if (m < 0)
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	78 10                	js     801419 <readn+0x41>
			return m;
		if (m == 0)
  801409:	85 c0                	test   %eax,%eax
  80140b:	74 0a                	je     801417 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80140d:	01 c3                	add    %eax,%ebx
  80140f:	39 f3                	cmp    %esi,%ebx
  801411:	72 db                	jb     8013ee <readn+0x16>
  801413:	89 d8                	mov    %ebx,%eax
  801415:	eb 02                	jmp    801419 <readn+0x41>
  801417:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801419:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141c:	5b                   	pop    %ebx
  80141d:	5e                   	pop    %esi
  80141e:	5f                   	pop    %edi
  80141f:	5d                   	pop    %ebp
  801420:	c3                   	ret    

00801421 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	53                   	push   %ebx
  801425:	83 ec 14             	sub    $0x14,%esp
  801428:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	53                   	push   %ebx
  801430:	e8 ac fc ff ff       	call   8010e1 <fd_lookup>
  801435:	83 c4 08             	add    $0x8,%esp
  801438:	89 c2                	mov    %eax,%edx
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 68                	js     8014a6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801448:	ff 30                	pushl  (%eax)
  80144a:	e8 e8 fc ff ff       	call   801137 <dev_lookup>
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 47                	js     80149d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801456:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801459:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80145d:	75 21                	jne    801480 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80145f:	a1 04 40 80 00       	mov    0x804004,%eax
  801464:	8b 40 48             	mov    0x48(%eax),%eax
  801467:	83 ec 04             	sub    $0x4,%esp
  80146a:	53                   	push   %ebx
  80146b:	50                   	push   %eax
  80146c:	68 4d 26 80 00       	push   $0x80264d
  801471:	e8 5e ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80147e:	eb 26                	jmp    8014a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801480:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801483:	8b 52 0c             	mov    0xc(%edx),%edx
  801486:	85 d2                	test   %edx,%edx
  801488:	74 17                	je     8014a1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80148a:	83 ec 04             	sub    $0x4,%esp
  80148d:	ff 75 10             	pushl  0x10(%ebp)
  801490:	ff 75 0c             	pushl  0xc(%ebp)
  801493:	50                   	push   %eax
  801494:	ff d2                	call   *%edx
  801496:	89 c2                	mov    %eax,%edx
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	eb 09                	jmp    8014a6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149d:	89 c2                	mov    %eax,%edx
  80149f:	eb 05                	jmp    8014a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014a6:	89 d0                	mov    %edx,%eax
  8014a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ab:	c9                   	leave  
  8014ac:	c3                   	ret    

008014ad <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014b6:	50                   	push   %eax
  8014b7:	ff 75 08             	pushl  0x8(%ebp)
  8014ba:	e8 22 fc ff ff       	call   8010e1 <fd_lookup>
  8014bf:	83 c4 08             	add    $0x8,%esp
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 0e                	js     8014d4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014cc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d4:	c9                   	leave  
  8014d5:	c3                   	ret    

008014d6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	53                   	push   %ebx
  8014da:	83 ec 14             	sub    $0x14,%esp
  8014dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	53                   	push   %ebx
  8014e5:	e8 f7 fb ff ff       	call   8010e1 <fd_lookup>
  8014ea:	83 c4 08             	add    $0x8,%esp
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 65                	js     801558 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f9:	50                   	push   %eax
  8014fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fd:	ff 30                	pushl  (%eax)
  8014ff:	e8 33 fc ff ff       	call   801137 <dev_lookup>
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 44                	js     80154f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80150b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801512:	75 21                	jne    801535 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801514:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801519:	8b 40 48             	mov    0x48(%eax),%eax
  80151c:	83 ec 04             	sub    $0x4,%esp
  80151f:	53                   	push   %ebx
  801520:	50                   	push   %eax
  801521:	68 10 26 80 00       	push   $0x802610
  801526:	e8 a9 ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801533:	eb 23                	jmp    801558 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801535:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801538:	8b 52 18             	mov    0x18(%edx),%edx
  80153b:	85 d2                	test   %edx,%edx
  80153d:	74 14                	je     801553 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80153f:	83 ec 08             	sub    $0x8,%esp
  801542:	ff 75 0c             	pushl  0xc(%ebp)
  801545:	50                   	push   %eax
  801546:	ff d2                	call   *%edx
  801548:	89 c2                	mov    %eax,%edx
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	eb 09                	jmp    801558 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154f:	89 c2                	mov    %eax,%edx
  801551:	eb 05                	jmp    801558 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801553:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801558:	89 d0                	mov    %edx,%eax
  80155a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	53                   	push   %ebx
  801563:	83 ec 14             	sub    $0x14,%esp
  801566:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801569:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156c:	50                   	push   %eax
  80156d:	ff 75 08             	pushl  0x8(%ebp)
  801570:	e8 6c fb ff ff       	call   8010e1 <fd_lookup>
  801575:	83 c4 08             	add    $0x8,%esp
  801578:	89 c2                	mov    %eax,%edx
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 58                	js     8015d6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801588:	ff 30                	pushl  (%eax)
  80158a:	e8 a8 fb ff ff       	call   801137 <dev_lookup>
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	85 c0                	test   %eax,%eax
  801594:	78 37                	js     8015cd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801596:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801599:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80159d:	74 32                	je     8015d1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80159f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015a2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015a9:	00 00 00 
	stat->st_isdir = 0;
  8015ac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b3:	00 00 00 
	stat->st_dev = dev;
  8015b6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8015c3:	ff 50 14             	call   *0x14(%eax)
  8015c6:	89 c2                	mov    %eax,%edx
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	eb 09                	jmp    8015d6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cd:	89 c2                	mov    %eax,%edx
  8015cf:	eb 05                	jmp    8015d6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015d6:	89 d0                	mov    %edx,%eax
  8015d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	56                   	push   %esi
  8015e1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	6a 00                	push   $0x0
  8015e7:	ff 75 08             	pushl  0x8(%ebp)
  8015ea:	e8 e3 01 00 00       	call   8017d2 <open>
  8015ef:	89 c3                	mov    %eax,%ebx
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 1b                	js     801613 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	ff 75 0c             	pushl  0xc(%ebp)
  8015fe:	50                   	push   %eax
  8015ff:	e8 5b ff ff ff       	call   80155f <fstat>
  801604:	89 c6                	mov    %eax,%esi
	close(fd);
  801606:	89 1c 24             	mov    %ebx,(%esp)
  801609:	e8 fd fb ff ff       	call   80120b <close>
	return r;
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	89 f0                	mov    %esi,%eax
}
  801613:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    

0080161a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	56                   	push   %esi
  80161e:	53                   	push   %ebx
  80161f:	89 c6                	mov    %eax,%esi
  801621:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801623:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80162a:	75 12                	jne    80163e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80162c:	83 ec 0c             	sub    $0xc,%esp
  80162f:	6a 01                	push   $0x1
  801631:	e8 a9 08 00 00       	call   801edf <ipc_find_env>
  801636:	a3 00 40 80 00       	mov    %eax,0x804000
  80163b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80163e:	6a 07                	push   $0x7
  801640:	68 00 50 80 00       	push   $0x805000
  801645:	56                   	push   %esi
  801646:	ff 35 00 40 80 00    	pushl  0x804000
  80164c:	e8 3a 08 00 00       	call   801e8b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801651:	83 c4 0c             	add    $0xc,%esp
  801654:	6a 00                	push   $0x0
  801656:	53                   	push   %ebx
  801657:	6a 00                	push   $0x0
  801659:	e8 c4 07 00 00       	call   801e22 <ipc_recv>
}
  80165e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    

00801665 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80166b:	8b 45 08             	mov    0x8(%ebp),%eax
  80166e:	8b 40 0c             	mov    0xc(%eax),%eax
  801671:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801676:	8b 45 0c             	mov    0xc(%ebp),%eax
  801679:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80167e:	ba 00 00 00 00       	mov    $0x0,%edx
  801683:	b8 02 00 00 00       	mov    $0x2,%eax
  801688:	e8 8d ff ff ff       	call   80161a <fsipc>
}
  80168d:	c9                   	leave  
  80168e:	c3                   	ret    

0080168f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801695:	8b 45 08             	mov    0x8(%ebp),%eax
  801698:	8b 40 0c             	mov    0xc(%eax),%eax
  80169b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8016aa:	e8 6b ff ff ff       	call   80161a <fsipc>
}
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    

008016b1 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	53                   	push   %ebx
  8016b5:	83 ec 04             	sub    $0x4,%esp
  8016b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016be:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cb:	b8 05 00 00 00       	mov    $0x5,%eax
  8016d0:	e8 45 ff ff ff       	call   80161a <fsipc>
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 2c                	js     801705 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016d9:	83 ec 08             	sub    $0x8,%esp
  8016dc:	68 00 50 80 00       	push   $0x805000
  8016e1:	53                   	push   %ebx
  8016e2:	e8 f1 f0 ff ff       	call   8007d8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016e7:	a1 80 50 80 00       	mov    0x805080,%eax
  8016ec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016f2:	a1 84 50 80 00       	mov    0x805084,%eax
  8016f7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801705:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	83 ec 0c             	sub    $0xc,%esp
  801710:	8b 45 10             	mov    0x10(%ebp),%eax
  801713:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801718:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80171d:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801720:	8b 55 08             	mov    0x8(%ebp),%edx
  801723:	8b 52 0c             	mov    0xc(%edx),%edx
  801726:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80172c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801731:	50                   	push   %eax
  801732:	ff 75 0c             	pushl  0xc(%ebp)
  801735:	68 08 50 80 00       	push   $0x805008
  80173a:	e8 2b f2 ff ff       	call   80096a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80173f:	ba 00 00 00 00       	mov    $0x0,%edx
  801744:	b8 04 00 00 00       	mov    $0x4,%eax
  801749:	e8 cc fe ff ff       	call   80161a <fsipc>
	//panic("devfile_write not implemented");
}
  80174e:	c9                   	leave  
  80174f:	c3                   	ret    

00801750 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	56                   	push   %esi
  801754:	53                   	push   %ebx
  801755:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	8b 40 0c             	mov    0xc(%eax),%eax
  80175e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801763:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801769:	ba 00 00 00 00       	mov    $0x0,%edx
  80176e:	b8 03 00 00 00       	mov    $0x3,%eax
  801773:	e8 a2 fe ff ff       	call   80161a <fsipc>
  801778:	89 c3                	mov    %eax,%ebx
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 4b                	js     8017c9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80177e:	39 c6                	cmp    %eax,%esi
  801780:	73 16                	jae    801798 <devfile_read+0x48>
  801782:	68 7c 26 80 00       	push   $0x80267c
  801787:	68 83 26 80 00       	push   $0x802683
  80178c:	6a 7c                	push   $0x7c
  80178e:	68 98 26 80 00       	push   $0x802698
  801793:	e8 bd 05 00 00       	call   801d55 <_panic>
	assert(r <= PGSIZE);
  801798:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80179d:	7e 16                	jle    8017b5 <devfile_read+0x65>
  80179f:	68 a3 26 80 00       	push   $0x8026a3
  8017a4:	68 83 26 80 00       	push   $0x802683
  8017a9:	6a 7d                	push   $0x7d
  8017ab:	68 98 26 80 00       	push   $0x802698
  8017b0:	e8 a0 05 00 00       	call   801d55 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017b5:	83 ec 04             	sub    $0x4,%esp
  8017b8:	50                   	push   %eax
  8017b9:	68 00 50 80 00       	push   $0x805000
  8017be:	ff 75 0c             	pushl  0xc(%ebp)
  8017c1:	e8 a4 f1 ff ff       	call   80096a <memmove>
	return r;
  8017c6:	83 c4 10             	add    $0x10,%esp
}
  8017c9:	89 d8                	mov    %ebx,%eax
  8017cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ce:	5b                   	pop    %ebx
  8017cf:	5e                   	pop    %esi
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	53                   	push   %ebx
  8017d6:	83 ec 20             	sub    $0x20,%esp
  8017d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017dc:	53                   	push   %ebx
  8017dd:	e8 bd ef ff ff       	call   80079f <strlen>
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ea:	7f 67                	jg     801853 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017ec:	83 ec 0c             	sub    $0xc,%esp
  8017ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f2:	50                   	push   %eax
  8017f3:	e8 9a f8 ff ff       	call   801092 <fd_alloc>
  8017f8:	83 c4 10             	add    $0x10,%esp
		return r;
  8017fb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 57                	js     801858 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801801:	83 ec 08             	sub    $0x8,%esp
  801804:	53                   	push   %ebx
  801805:	68 00 50 80 00       	push   $0x805000
  80180a:	e8 c9 ef ff ff       	call   8007d8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80180f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801812:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801817:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80181a:	b8 01 00 00 00       	mov    $0x1,%eax
  80181f:	e8 f6 fd ff ff       	call   80161a <fsipc>
  801824:	89 c3                	mov    %eax,%ebx
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	85 c0                	test   %eax,%eax
  80182b:	79 14                	jns    801841 <open+0x6f>
		fd_close(fd, 0);
  80182d:	83 ec 08             	sub    $0x8,%esp
  801830:	6a 00                	push   $0x0
  801832:	ff 75 f4             	pushl  -0xc(%ebp)
  801835:	e8 50 f9 ff ff       	call   80118a <fd_close>
		return r;
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	89 da                	mov    %ebx,%edx
  80183f:	eb 17                	jmp    801858 <open+0x86>
	}

	return fd2num(fd);
  801841:	83 ec 0c             	sub    $0xc,%esp
  801844:	ff 75 f4             	pushl  -0xc(%ebp)
  801847:	e8 1f f8 ff ff       	call   80106b <fd2num>
  80184c:	89 c2                	mov    %eax,%edx
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	eb 05                	jmp    801858 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801853:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801858:	89 d0                	mov    %edx,%eax
  80185a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801865:	ba 00 00 00 00       	mov    $0x0,%edx
  80186a:	b8 08 00 00 00       	mov    $0x8,%eax
  80186f:	e8 a6 fd ff ff       	call   80161a <fsipc>
}
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	56                   	push   %esi
  80187a:	53                   	push   %ebx
  80187b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80187e:	83 ec 0c             	sub    $0xc,%esp
  801881:	ff 75 08             	pushl  0x8(%ebp)
  801884:	e8 f2 f7 ff ff       	call   80107b <fd2data>
  801889:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80188b:	83 c4 08             	add    $0x8,%esp
  80188e:	68 af 26 80 00       	push   $0x8026af
  801893:	53                   	push   %ebx
  801894:	e8 3f ef ff ff       	call   8007d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801899:	8b 46 04             	mov    0x4(%esi),%eax
  80189c:	2b 06                	sub    (%esi),%eax
  80189e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018a4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ab:	00 00 00 
	stat->st_dev = &devpipe;
  8018ae:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018b5:	30 80 00 
	return 0;
}
  8018b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c0:	5b                   	pop    %ebx
  8018c1:	5e                   	pop    %esi
  8018c2:	5d                   	pop    %ebp
  8018c3:	c3                   	ret    

008018c4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	53                   	push   %ebx
  8018c8:	83 ec 0c             	sub    $0xc,%esp
  8018cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018ce:	53                   	push   %ebx
  8018cf:	6a 00                	push   $0x0
  8018d1:	e8 8a f3 ff ff       	call   800c60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018d6:	89 1c 24             	mov    %ebx,(%esp)
  8018d9:	e8 9d f7 ff ff       	call   80107b <fd2data>
  8018de:	83 c4 08             	add    $0x8,%esp
  8018e1:	50                   	push   %eax
  8018e2:	6a 00                	push   $0x0
  8018e4:	e8 77 f3 ff ff       	call   800c60 <sys_page_unmap>
}
  8018e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    

008018ee <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	57                   	push   %edi
  8018f2:	56                   	push   %esi
  8018f3:	53                   	push   %ebx
  8018f4:	83 ec 1c             	sub    $0x1c,%esp
  8018f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018fa:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801901:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801904:	83 ec 0c             	sub    $0xc,%esp
  801907:	ff 75 e0             	pushl  -0x20(%ebp)
  80190a:	e8 09 06 00 00       	call   801f18 <pageref>
  80190f:	89 c3                	mov    %eax,%ebx
  801911:	89 3c 24             	mov    %edi,(%esp)
  801914:	e8 ff 05 00 00       	call   801f18 <pageref>
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	39 c3                	cmp    %eax,%ebx
  80191e:	0f 94 c1             	sete   %cl
  801921:	0f b6 c9             	movzbl %cl,%ecx
  801924:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801927:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80192d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801930:	39 ce                	cmp    %ecx,%esi
  801932:	74 1b                	je     80194f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801934:	39 c3                	cmp    %eax,%ebx
  801936:	75 c4                	jne    8018fc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801938:	8b 42 58             	mov    0x58(%edx),%eax
  80193b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80193e:	50                   	push   %eax
  80193f:	56                   	push   %esi
  801940:	68 b6 26 80 00       	push   $0x8026b6
  801945:	e8 8a e8 ff ff       	call   8001d4 <cprintf>
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	eb ad                	jmp    8018fc <_pipeisclosed+0xe>
	}
}
  80194f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801952:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801955:	5b                   	pop    %ebx
  801956:	5e                   	pop    %esi
  801957:	5f                   	pop    %edi
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	57                   	push   %edi
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	83 ec 28             	sub    $0x28,%esp
  801963:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801966:	56                   	push   %esi
  801967:	e8 0f f7 ff ff       	call   80107b <fd2data>
  80196c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	bf 00 00 00 00       	mov    $0x0,%edi
  801976:	eb 4b                	jmp    8019c3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801978:	89 da                	mov    %ebx,%edx
  80197a:	89 f0                	mov    %esi,%eax
  80197c:	e8 6d ff ff ff       	call   8018ee <_pipeisclosed>
  801981:	85 c0                	test   %eax,%eax
  801983:	75 48                	jne    8019cd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801985:	e8 32 f2 ff ff       	call   800bbc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80198a:	8b 43 04             	mov    0x4(%ebx),%eax
  80198d:	8b 0b                	mov    (%ebx),%ecx
  80198f:	8d 51 20             	lea    0x20(%ecx),%edx
  801992:	39 d0                	cmp    %edx,%eax
  801994:	73 e2                	jae    801978 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801996:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801999:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80199d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019a0:	89 c2                	mov    %eax,%edx
  8019a2:	c1 fa 1f             	sar    $0x1f,%edx
  8019a5:	89 d1                	mov    %edx,%ecx
  8019a7:	c1 e9 1b             	shr    $0x1b,%ecx
  8019aa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019ad:	83 e2 1f             	and    $0x1f,%edx
  8019b0:	29 ca                	sub    %ecx,%edx
  8019b2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019b6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019ba:	83 c0 01             	add    $0x1,%eax
  8019bd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c0:	83 c7 01             	add    $0x1,%edi
  8019c3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019c6:	75 c2                	jne    80198a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8019cb:	eb 05                	jmp    8019d2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019cd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d5:	5b                   	pop    %ebx
  8019d6:	5e                   	pop    %esi
  8019d7:	5f                   	pop    %edi
  8019d8:	5d                   	pop    %ebp
  8019d9:	c3                   	ret    

008019da <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	57                   	push   %edi
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	83 ec 18             	sub    $0x18,%esp
  8019e3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019e6:	57                   	push   %edi
  8019e7:	e8 8f f6 ff ff       	call   80107b <fd2data>
  8019ec:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019f6:	eb 3d                	jmp    801a35 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019f8:	85 db                	test   %ebx,%ebx
  8019fa:	74 04                	je     801a00 <devpipe_read+0x26>
				return i;
  8019fc:	89 d8                	mov    %ebx,%eax
  8019fe:	eb 44                	jmp    801a44 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a00:	89 f2                	mov    %esi,%edx
  801a02:	89 f8                	mov    %edi,%eax
  801a04:	e8 e5 fe ff ff       	call   8018ee <_pipeisclosed>
  801a09:	85 c0                	test   %eax,%eax
  801a0b:	75 32                	jne    801a3f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a0d:	e8 aa f1 ff ff       	call   800bbc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a12:	8b 06                	mov    (%esi),%eax
  801a14:	3b 46 04             	cmp    0x4(%esi),%eax
  801a17:	74 df                	je     8019f8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a19:	99                   	cltd   
  801a1a:	c1 ea 1b             	shr    $0x1b,%edx
  801a1d:	01 d0                	add    %edx,%eax
  801a1f:	83 e0 1f             	and    $0x1f,%eax
  801a22:	29 d0                	sub    %edx,%eax
  801a24:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a2c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a2f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a32:	83 c3 01             	add    $0x1,%ebx
  801a35:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a38:	75 d8                	jne    801a12 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a3d:	eb 05                	jmp    801a44 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a3f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a47:	5b                   	pop    %ebx
  801a48:	5e                   	pop    %esi
  801a49:	5f                   	pop    %edi
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a57:	50                   	push   %eax
  801a58:	e8 35 f6 ff ff       	call   801092 <fd_alloc>
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	89 c2                	mov    %eax,%edx
  801a62:	85 c0                	test   %eax,%eax
  801a64:	0f 88 2c 01 00 00    	js     801b96 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a6a:	83 ec 04             	sub    $0x4,%esp
  801a6d:	68 07 04 00 00       	push   $0x407
  801a72:	ff 75 f4             	pushl  -0xc(%ebp)
  801a75:	6a 00                	push   $0x0
  801a77:	e8 5f f1 ff ff       	call   800bdb <sys_page_alloc>
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	89 c2                	mov    %eax,%edx
  801a81:	85 c0                	test   %eax,%eax
  801a83:	0f 88 0d 01 00 00    	js     801b96 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a89:	83 ec 0c             	sub    $0xc,%esp
  801a8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a8f:	50                   	push   %eax
  801a90:	e8 fd f5 ff ff       	call   801092 <fd_alloc>
  801a95:	89 c3                	mov    %eax,%ebx
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	0f 88 e2 00 00 00    	js     801b84 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa2:	83 ec 04             	sub    $0x4,%esp
  801aa5:	68 07 04 00 00       	push   $0x407
  801aaa:	ff 75 f0             	pushl  -0x10(%ebp)
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 27 f1 ff ff       	call   800bdb <sys_page_alloc>
  801ab4:	89 c3                	mov    %eax,%ebx
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	0f 88 c3 00 00 00    	js     801b84 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac7:	e8 af f5 ff ff       	call   80107b <fd2data>
  801acc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ace:	83 c4 0c             	add    $0xc,%esp
  801ad1:	68 07 04 00 00       	push   $0x407
  801ad6:	50                   	push   %eax
  801ad7:	6a 00                	push   $0x0
  801ad9:	e8 fd f0 ff ff       	call   800bdb <sys_page_alloc>
  801ade:	89 c3                	mov    %eax,%ebx
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	0f 88 89 00 00 00    	js     801b74 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aeb:	83 ec 0c             	sub    $0xc,%esp
  801aee:	ff 75 f0             	pushl  -0x10(%ebp)
  801af1:	e8 85 f5 ff ff       	call   80107b <fd2data>
  801af6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801afd:	50                   	push   %eax
  801afe:	6a 00                	push   $0x0
  801b00:	56                   	push   %esi
  801b01:	6a 00                	push   $0x0
  801b03:	e8 16 f1 ff ff       	call   800c1e <sys_page_map>
  801b08:	89 c3                	mov    %eax,%ebx
  801b0a:	83 c4 20             	add    $0x20,%esp
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	78 55                	js     801b66 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b11:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b26:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b2f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b3b:	83 ec 0c             	sub    $0xc,%esp
  801b3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b41:	e8 25 f5 ff ff       	call   80106b <fd2num>
  801b46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b49:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b4b:	83 c4 04             	add    $0x4,%esp
  801b4e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b51:	e8 15 f5 ff ff       	call   80106b <fd2num>
  801b56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b59:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b64:	eb 30                	jmp    801b96 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b66:	83 ec 08             	sub    $0x8,%esp
  801b69:	56                   	push   %esi
  801b6a:	6a 00                	push   $0x0
  801b6c:	e8 ef f0 ff ff       	call   800c60 <sys_page_unmap>
  801b71:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b74:	83 ec 08             	sub    $0x8,%esp
  801b77:	ff 75 f0             	pushl  -0x10(%ebp)
  801b7a:	6a 00                	push   $0x0
  801b7c:	e8 df f0 ff ff       	call   800c60 <sys_page_unmap>
  801b81:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b84:	83 ec 08             	sub    $0x8,%esp
  801b87:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8a:	6a 00                	push   $0x0
  801b8c:	e8 cf f0 ff ff       	call   800c60 <sys_page_unmap>
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b96:	89 d0                	mov    %edx,%eax
  801b98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9b:	5b                   	pop    %ebx
  801b9c:	5e                   	pop    %esi
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    

00801b9f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ba5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba8:	50                   	push   %eax
  801ba9:	ff 75 08             	pushl  0x8(%ebp)
  801bac:	e8 30 f5 ff ff       	call   8010e1 <fd_lookup>
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	78 18                	js     801bd0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bb8:	83 ec 0c             	sub    $0xc,%esp
  801bbb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbe:	e8 b8 f4 ff ff       	call   80107b <fd2data>
	return _pipeisclosed(fd, p);
  801bc3:	89 c2                	mov    %eax,%edx
  801bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc8:	e8 21 fd ff ff       	call   8018ee <_pipeisclosed>
  801bcd:	83 c4 10             	add    $0x10,%esp
}
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    

00801bdc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801be2:	68 ce 26 80 00       	push   $0x8026ce
  801be7:	ff 75 0c             	pushl  0xc(%ebp)
  801bea:	e8 e9 eb ff ff       	call   8007d8 <strcpy>
	return 0;
}
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	57                   	push   %edi
  801bfa:	56                   	push   %esi
  801bfb:	53                   	push   %ebx
  801bfc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c02:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c07:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c0d:	eb 2d                	jmp    801c3c <devcons_write+0x46>
		m = n - tot;
  801c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c12:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c14:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c17:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c1c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c1f:	83 ec 04             	sub    $0x4,%esp
  801c22:	53                   	push   %ebx
  801c23:	03 45 0c             	add    0xc(%ebp),%eax
  801c26:	50                   	push   %eax
  801c27:	57                   	push   %edi
  801c28:	e8 3d ed ff ff       	call   80096a <memmove>
		sys_cputs(buf, m);
  801c2d:	83 c4 08             	add    $0x8,%esp
  801c30:	53                   	push   %ebx
  801c31:	57                   	push   %edi
  801c32:	e8 e8 ee ff ff       	call   800b1f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c37:	01 de                	add    %ebx,%esi
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	89 f0                	mov    %esi,%eax
  801c3e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c41:	72 cc                	jb     801c0f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c46:	5b                   	pop    %ebx
  801c47:	5e                   	pop    %esi
  801c48:	5f                   	pop    %edi
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	83 ec 08             	sub    $0x8,%esp
  801c51:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c5a:	74 2a                	je     801c86 <devcons_read+0x3b>
  801c5c:	eb 05                	jmp    801c63 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c5e:	e8 59 ef ff ff       	call   800bbc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c63:	e8 d5 ee ff ff       	call   800b3d <sys_cgetc>
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	74 f2                	je     801c5e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	78 16                	js     801c86 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c70:	83 f8 04             	cmp    $0x4,%eax
  801c73:	74 0c                	je     801c81 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c75:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c78:	88 02                	mov    %al,(%edx)
	return 1;
  801c7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c7f:	eb 05                	jmp    801c86 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c81:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c86:	c9                   	leave  
  801c87:	c3                   	ret    

00801c88 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c91:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c94:	6a 01                	push   $0x1
  801c96:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c99:	50                   	push   %eax
  801c9a:	e8 80 ee ff ff       	call   800b1f <sys_cputs>
}
  801c9f:	83 c4 10             	add    $0x10,%esp
  801ca2:	c9                   	leave  
  801ca3:	c3                   	ret    

00801ca4 <getchar>:

int
getchar(void)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801caa:	6a 01                	push   $0x1
  801cac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801caf:	50                   	push   %eax
  801cb0:	6a 00                	push   $0x0
  801cb2:	e8 90 f6 ff ff       	call   801347 <read>
	if (r < 0)
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	78 0f                	js     801ccd <getchar+0x29>
		return r;
	if (r < 1)
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	7e 06                	jle    801cc8 <getchar+0x24>
		return -E_EOF;
	return c;
  801cc2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cc6:	eb 05                	jmp    801ccd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cc8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ccd:	c9                   	leave  
  801cce:	c3                   	ret    

00801ccf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd8:	50                   	push   %eax
  801cd9:	ff 75 08             	pushl  0x8(%ebp)
  801cdc:	e8 00 f4 ff ff       	call   8010e1 <fd_lookup>
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	78 11                	js     801cf9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ceb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf1:	39 10                	cmp    %edx,(%eax)
  801cf3:	0f 94 c0             	sete   %al
  801cf6:	0f b6 c0             	movzbl %al,%eax
}
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <opencons>:

int
opencons(void)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d04:	50                   	push   %eax
  801d05:	e8 88 f3 ff ff       	call   801092 <fd_alloc>
  801d0a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d0d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	78 3e                	js     801d51 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d13:	83 ec 04             	sub    $0x4,%esp
  801d16:	68 07 04 00 00       	push   $0x407
  801d1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1e:	6a 00                	push   $0x0
  801d20:	e8 b6 ee ff ff       	call   800bdb <sys_page_alloc>
  801d25:	83 c4 10             	add    $0x10,%esp
		return r;
  801d28:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 23                	js     801d51 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d2e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d37:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	50                   	push   %eax
  801d47:	e8 1f f3 ff ff       	call   80106b <fd2num>
  801d4c:	89 c2                	mov    %eax,%edx
  801d4e:	83 c4 10             	add    $0x10,%esp
}
  801d51:	89 d0                	mov    %edx,%eax
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	56                   	push   %esi
  801d59:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d5a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d5d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d63:	e8 35 ee ff ff       	call   800b9d <sys_getenvid>
  801d68:	83 ec 0c             	sub    $0xc,%esp
  801d6b:	ff 75 0c             	pushl  0xc(%ebp)
  801d6e:	ff 75 08             	pushl  0x8(%ebp)
  801d71:	56                   	push   %esi
  801d72:	50                   	push   %eax
  801d73:	68 dc 26 80 00       	push   $0x8026dc
  801d78:	e8 57 e4 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d7d:	83 c4 18             	add    $0x18,%esp
  801d80:	53                   	push   %ebx
  801d81:	ff 75 10             	pushl  0x10(%ebp)
  801d84:	e8 fa e3 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801d89:	c7 04 24 0f 22 80 00 	movl   $0x80220f,(%esp)
  801d90:	e8 3f e4 ff ff       	call   8001d4 <cprintf>
  801d95:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d98:	cc                   	int3   
  801d99:	eb fd                	jmp    801d98 <_panic+0x43>

00801d9b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801da1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801da8:	75 4a                	jne    801df4 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801daa:	a1 04 40 80 00       	mov    0x804004,%eax
  801daf:	8b 40 48             	mov    0x48(%eax),%eax
  801db2:	83 ec 04             	sub    $0x4,%esp
  801db5:	6a 07                	push   $0x7
  801db7:	68 00 f0 bf ee       	push   $0xeebff000
  801dbc:	50                   	push   %eax
  801dbd:	e8 19 ee ff ff       	call   800bdb <sys_page_alloc>
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	79 12                	jns    801ddb <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801dc9:	50                   	push   %eax
  801dca:	68 00 27 80 00       	push   $0x802700
  801dcf:	6a 21                	push   $0x21
  801dd1:	68 18 27 80 00       	push   $0x802718
  801dd6:	e8 7a ff ff ff       	call   801d55 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801ddb:	a1 04 40 80 00       	mov    0x804004,%eax
  801de0:	8b 40 48             	mov    0x48(%eax),%eax
  801de3:	83 ec 08             	sub    $0x8,%esp
  801de6:	68 fe 1d 80 00       	push   $0x801dfe
  801deb:	50                   	push   %eax
  801dec:	e8 35 ef ff ff       	call   800d26 <sys_env_set_pgfault_upcall>
  801df1:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	a3 00 60 80 00       	mov    %eax,0x806000
  801dfc:	c9                   	leave  
  801dfd:	c3                   	ret    

00801dfe <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dfe:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dff:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e04:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e06:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  801e09:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  801e0c:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  801e10:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  801e15:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  801e19:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801e1b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  801e1c:	83 c4 04             	add    $0x4,%esp
	popfl
  801e1f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e20:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  801e21:	c3                   	ret    

00801e22 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	56                   	push   %esi
  801e26:	53                   	push   %ebx
  801e27:	8b 75 08             	mov    0x8(%ebp),%esi
  801e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801e30:	85 c0                	test   %eax,%eax
  801e32:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e37:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801e3a:	83 ec 0c             	sub    $0xc,%esp
  801e3d:	50                   	push   %eax
  801e3e:	e8 48 ef ff ff       	call   800d8b <sys_ipc_recv>
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	85 c0                	test   %eax,%eax
  801e48:	79 16                	jns    801e60 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801e4a:	85 f6                	test   %esi,%esi
  801e4c:	74 06                	je     801e54 <ipc_recv+0x32>
            *from_env_store = 0;
  801e4e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801e54:	85 db                	test   %ebx,%ebx
  801e56:	74 2c                	je     801e84 <ipc_recv+0x62>
            *perm_store = 0;
  801e58:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e5e:	eb 24                	jmp    801e84 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801e60:	85 f6                	test   %esi,%esi
  801e62:	74 0a                	je     801e6e <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801e64:	a1 04 40 80 00       	mov    0x804004,%eax
  801e69:	8b 40 74             	mov    0x74(%eax),%eax
  801e6c:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801e6e:	85 db                	test   %ebx,%ebx
  801e70:	74 0a                	je     801e7c <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801e72:	a1 04 40 80 00       	mov    0x804004,%eax
  801e77:	8b 40 78             	mov    0x78(%eax),%eax
  801e7a:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801e7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e81:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801e84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e87:	5b                   	pop    %ebx
  801e88:	5e                   	pop    %esi
  801e89:	5d                   	pop    %ebp
  801e8a:	c3                   	ret    

00801e8b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	57                   	push   %edi
  801e8f:	56                   	push   %esi
  801e90:	53                   	push   %ebx
  801e91:	83 ec 0c             	sub    $0xc,%esp
  801e94:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e97:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e9a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ea4:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801ea7:	eb 1c                	jmp    801ec5 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801ea9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eac:	74 12                	je     801ec0 <ipc_send+0x35>
  801eae:	50                   	push   %eax
  801eaf:	68 26 27 80 00       	push   $0x802726
  801eb4:	6a 3a                	push   $0x3a
  801eb6:	68 3c 27 80 00       	push   $0x80273c
  801ebb:	e8 95 fe ff ff       	call   801d55 <_panic>
		sys_yield();
  801ec0:	e8 f7 ec ff ff       	call   800bbc <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801ec5:	ff 75 14             	pushl  0x14(%ebp)
  801ec8:	53                   	push   %ebx
  801ec9:	56                   	push   %esi
  801eca:	57                   	push   %edi
  801ecb:	e8 98 ee ff ff       	call   800d68 <sys_ipc_try_send>
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	78 d2                	js     801ea9 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801ed7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eda:	5b                   	pop    %ebx
  801edb:	5e                   	pop    %esi
  801edc:	5f                   	pop    %edi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    

00801edf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eea:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801eed:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ef3:	8b 52 50             	mov    0x50(%edx),%edx
  801ef6:	39 ca                	cmp    %ecx,%edx
  801ef8:	75 0d                	jne    801f07 <ipc_find_env+0x28>
			return envs[i].env_id;
  801efa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801efd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f02:	8b 40 48             	mov    0x48(%eax),%eax
  801f05:	eb 0f                	jmp    801f16 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f07:	83 c0 01             	add    $0x1,%eax
  801f0a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f0f:	75 d9                	jne    801eea <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    

00801f18 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f1e:	89 d0                	mov    %edx,%eax
  801f20:	c1 e8 16             	shr    $0x16,%eax
  801f23:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f2a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f2f:	f6 c1 01             	test   $0x1,%cl
  801f32:	74 1d                	je     801f51 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f34:	c1 ea 0c             	shr    $0xc,%edx
  801f37:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f3e:	f6 c2 01             	test   $0x1,%dl
  801f41:	74 0e                	je     801f51 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f43:	c1 ea 0c             	shr    $0xc,%edx
  801f46:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f4d:	ef 
  801f4e:	0f b7 c0             	movzwl %ax,%eax
}
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    
  801f53:	66 90                	xchg   %ax,%ax
  801f55:	66 90                	xchg   %ax,%ax
  801f57:	66 90                	xchg   %ax,%ax
  801f59:	66 90                	xchg   %ax,%ax
  801f5b:	66 90                	xchg   %ax,%ax
  801f5d:	66 90                	xchg   %ax,%ax
  801f5f:	90                   	nop

00801f60 <__udivdi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 1c             	sub    $0x1c,%esp
  801f67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f77:	85 f6                	test   %esi,%esi
  801f79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f7d:	89 ca                	mov    %ecx,%edx
  801f7f:	89 f8                	mov    %edi,%eax
  801f81:	75 3d                	jne    801fc0 <__udivdi3+0x60>
  801f83:	39 cf                	cmp    %ecx,%edi
  801f85:	0f 87 c5 00 00 00    	ja     802050 <__udivdi3+0xf0>
  801f8b:	85 ff                	test   %edi,%edi
  801f8d:	89 fd                	mov    %edi,%ebp
  801f8f:	75 0b                	jne    801f9c <__udivdi3+0x3c>
  801f91:	b8 01 00 00 00       	mov    $0x1,%eax
  801f96:	31 d2                	xor    %edx,%edx
  801f98:	f7 f7                	div    %edi
  801f9a:	89 c5                	mov    %eax,%ebp
  801f9c:	89 c8                	mov    %ecx,%eax
  801f9e:	31 d2                	xor    %edx,%edx
  801fa0:	f7 f5                	div    %ebp
  801fa2:	89 c1                	mov    %eax,%ecx
  801fa4:	89 d8                	mov    %ebx,%eax
  801fa6:	89 cf                	mov    %ecx,%edi
  801fa8:	f7 f5                	div    %ebp
  801faa:	89 c3                	mov    %eax,%ebx
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	89 fa                	mov    %edi,%edx
  801fb0:	83 c4 1c             	add    $0x1c,%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    
  801fb8:	90                   	nop
  801fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	39 ce                	cmp    %ecx,%esi
  801fc2:	77 74                	ja     802038 <__udivdi3+0xd8>
  801fc4:	0f bd fe             	bsr    %esi,%edi
  801fc7:	83 f7 1f             	xor    $0x1f,%edi
  801fca:	0f 84 98 00 00 00    	je     802068 <__udivdi3+0x108>
  801fd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	89 c5                	mov    %eax,%ebp
  801fd9:	29 fb                	sub    %edi,%ebx
  801fdb:	d3 e6                	shl    %cl,%esi
  801fdd:	89 d9                	mov    %ebx,%ecx
  801fdf:	d3 ed                	shr    %cl,%ebp
  801fe1:	89 f9                	mov    %edi,%ecx
  801fe3:	d3 e0                	shl    %cl,%eax
  801fe5:	09 ee                	or     %ebp,%esi
  801fe7:	89 d9                	mov    %ebx,%ecx
  801fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fed:	89 d5                	mov    %edx,%ebp
  801fef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ff3:	d3 ed                	shr    %cl,%ebp
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e2                	shl    %cl,%edx
  801ff9:	89 d9                	mov    %ebx,%ecx
  801ffb:	d3 e8                	shr    %cl,%eax
  801ffd:	09 c2                	or     %eax,%edx
  801fff:	89 d0                	mov    %edx,%eax
  802001:	89 ea                	mov    %ebp,%edx
  802003:	f7 f6                	div    %esi
  802005:	89 d5                	mov    %edx,%ebp
  802007:	89 c3                	mov    %eax,%ebx
  802009:	f7 64 24 0c          	mull   0xc(%esp)
  80200d:	39 d5                	cmp    %edx,%ebp
  80200f:	72 10                	jb     802021 <__udivdi3+0xc1>
  802011:	8b 74 24 08          	mov    0x8(%esp),%esi
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e6                	shl    %cl,%esi
  802019:	39 c6                	cmp    %eax,%esi
  80201b:	73 07                	jae    802024 <__udivdi3+0xc4>
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	75 03                	jne    802024 <__udivdi3+0xc4>
  802021:	83 eb 01             	sub    $0x1,%ebx
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 d8                	mov    %ebx,%eax
  802028:	89 fa                	mov    %edi,%edx
  80202a:	83 c4 1c             	add    $0x1c,%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    
  802032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802038:	31 ff                	xor    %edi,%edi
  80203a:	31 db                	xor    %ebx,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 d8                	mov    %ebx,%eax
  802052:	f7 f7                	div    %edi
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 c3                	mov    %eax,%ebx
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	89 fa                	mov    %edi,%edx
  80205c:	83 c4 1c             	add    $0x1c,%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
  802064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802068:	39 ce                	cmp    %ecx,%esi
  80206a:	72 0c                	jb     802078 <__udivdi3+0x118>
  80206c:	31 db                	xor    %ebx,%ebx
  80206e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802072:	0f 87 34 ff ff ff    	ja     801fac <__udivdi3+0x4c>
  802078:	bb 01 00 00 00       	mov    $0x1,%ebx
  80207d:	e9 2a ff ff ff       	jmp    801fac <__udivdi3+0x4c>
  802082:	66 90                	xchg   %ax,%ax
  802084:	66 90                	xchg   %ax,%ax
  802086:	66 90                	xchg   %ax,%ax
  802088:	66 90                	xchg   %ax,%ax
  80208a:	66 90                	xchg   %ax,%ax
  80208c:	66 90                	xchg   %ax,%ax
  80208e:	66 90                	xchg   %ax,%ax

00802090 <__umoddi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80209b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80209f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 d2                	test   %edx,%edx
  8020a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f3                	mov    %esi,%ebx
  8020b3:	89 3c 24             	mov    %edi,(%esp)
  8020b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ba:	75 1c                	jne    8020d8 <__umoddi3+0x48>
  8020bc:	39 f7                	cmp    %esi,%edi
  8020be:	76 50                	jbe    802110 <__umoddi3+0x80>
  8020c0:	89 c8                	mov    %ecx,%eax
  8020c2:	89 f2                	mov    %esi,%edx
  8020c4:	f7 f7                	div    %edi
  8020c6:	89 d0                	mov    %edx,%eax
  8020c8:	31 d2                	xor    %edx,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	39 f2                	cmp    %esi,%edx
  8020da:	89 d0                	mov    %edx,%eax
  8020dc:	77 52                	ja     802130 <__umoddi3+0xa0>
  8020de:	0f bd ea             	bsr    %edx,%ebp
  8020e1:	83 f5 1f             	xor    $0x1f,%ebp
  8020e4:	75 5a                	jne    802140 <__umoddi3+0xb0>
  8020e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ea:	0f 82 e0 00 00 00    	jb     8021d0 <__umoddi3+0x140>
  8020f0:	39 0c 24             	cmp    %ecx,(%esp)
  8020f3:	0f 86 d7 00 00 00    	jbe    8021d0 <__umoddi3+0x140>
  8020f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802101:	83 c4 1c             	add    $0x1c,%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	85 ff                	test   %edi,%edi
  802112:	89 fd                	mov    %edi,%ebp
  802114:	75 0b                	jne    802121 <__umoddi3+0x91>
  802116:	b8 01 00 00 00       	mov    $0x1,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	f7 f7                	div    %edi
  80211f:	89 c5                	mov    %eax,%ebp
  802121:	89 f0                	mov    %esi,%eax
  802123:	31 d2                	xor    %edx,%edx
  802125:	f7 f5                	div    %ebp
  802127:	89 c8                	mov    %ecx,%eax
  802129:	f7 f5                	div    %ebp
  80212b:	89 d0                	mov    %edx,%eax
  80212d:	eb 99                	jmp    8020c8 <__umoddi3+0x38>
  80212f:	90                   	nop
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	83 c4 1c             	add    $0x1c,%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5f                   	pop    %edi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	8b 34 24             	mov    (%esp),%esi
  802143:	bf 20 00 00 00       	mov    $0x20,%edi
  802148:	89 e9                	mov    %ebp,%ecx
  80214a:	29 ef                	sub    %ebp,%edi
  80214c:	d3 e0                	shl    %cl,%eax
  80214e:	89 f9                	mov    %edi,%ecx
  802150:	89 f2                	mov    %esi,%edx
  802152:	d3 ea                	shr    %cl,%edx
  802154:	89 e9                	mov    %ebp,%ecx
  802156:	09 c2                	or     %eax,%edx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 14 24             	mov    %edx,(%esp)
  80215d:	89 f2                	mov    %esi,%edx
  80215f:	d3 e2                	shl    %cl,%edx
  802161:	89 f9                	mov    %edi,%ecx
  802163:	89 54 24 04          	mov    %edx,0x4(%esp)
  802167:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	89 e9                	mov    %ebp,%ecx
  80216f:	89 c6                	mov    %eax,%esi
  802171:	d3 e3                	shl    %cl,%ebx
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 d0                	mov    %edx,%eax
  802177:	d3 e8                	shr    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	09 d8                	or     %ebx,%eax
  80217d:	89 d3                	mov    %edx,%ebx
  80217f:	89 f2                	mov    %esi,%edx
  802181:	f7 34 24             	divl   (%esp)
  802184:	89 d6                	mov    %edx,%esi
  802186:	d3 e3                	shl    %cl,%ebx
  802188:	f7 64 24 04          	mull   0x4(%esp)
  80218c:	39 d6                	cmp    %edx,%esi
  80218e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802192:	89 d1                	mov    %edx,%ecx
  802194:	89 c3                	mov    %eax,%ebx
  802196:	72 08                	jb     8021a0 <__umoddi3+0x110>
  802198:	75 11                	jne    8021ab <__umoddi3+0x11b>
  80219a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80219e:	73 0b                	jae    8021ab <__umoddi3+0x11b>
  8021a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021a4:	1b 14 24             	sbb    (%esp),%edx
  8021a7:	89 d1                	mov    %edx,%ecx
  8021a9:	89 c3                	mov    %eax,%ebx
  8021ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021af:	29 da                	sub    %ebx,%edx
  8021b1:	19 ce                	sbb    %ecx,%esi
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 f0                	mov    %esi,%eax
  8021b7:	d3 e0                	shl    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	d3 ea                	shr    %cl,%edx
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	d3 ee                	shr    %cl,%esi
  8021c1:	09 d0                	or     %edx,%eax
  8021c3:	89 f2                	mov    %esi,%edx
  8021c5:	83 c4 1c             	add    $0x1c,%esp
  8021c8:	5b                   	pop    %ebx
  8021c9:	5e                   	pop    %esi
  8021ca:	5f                   	pop    %edi
  8021cb:	5d                   	pop    %ebp
  8021cc:	c3                   	ret    
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi
  8021d0:	29 f9                	sub    %edi,%ecx
  8021d2:	19 d6                	sbb    %edx,%esi
  8021d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021dc:	e9 18 ff ff ff       	jmp    8020f9 <__umoddi3+0x69>
