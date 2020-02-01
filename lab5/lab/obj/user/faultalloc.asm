
obj/user/faultalloc.debug：     文件格式 elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 40 1f 80 00       	push   $0x801f40
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 ac 0b 00 00       	call   800c0a <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 60 1f 80 00       	push   $0x801f60
  80006f:	6a 0e                	push   $0xe
  800071:	68 4a 1f 80 00       	push   $0x801f4a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 1f 80 00       	push   $0x801f8c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 2b 07 00 00       	call   8007b4 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 5a 0d 00 00       	call   800dfb <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 5c 1f 80 00       	push   $0x801f5c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 5c 1f 80 00       	push   $0x801f5c
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 f2 0a 00 00       	call   800bcc <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
        binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

    // exit gracefully
    exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 32 0f 00 00       	call   80104d <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 66 0a 00 00       	call   800b8b <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 8f 0a 00 00       	call   800bcc <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 b8 1f 80 00       	push   $0x801fb8
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 0b 24 80 00 	movl   $0x80240b,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 ae 09 00 00       	call   800b4e <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 1a 01 00 00       	call   800300 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 53 09 00 00       	call   800b4e <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023e:	39 d3                	cmp    %edx,%ebx
  800240:	72 05                	jb     800247 <printnum+0x30>
  800242:	39 45 10             	cmp    %eax,0x10(%ebp)
  800245:	77 45                	ja     80028c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800253:	53                   	push   %ebx
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 35 1a 00 00       	call   801ca0 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 18                	jmp    800296 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	eb 03                	jmp    80028f <printnum+0x78>
  80028c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f e8                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 22 1b 00 00       	call   801dd0 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 db 1f 80 00 	movsbl 0x801fdb(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d5:	73 0a                	jae    8002e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	88 02                	mov    %al,(%edx)
}
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ec:	50                   	push   %eax
  8002ed:	ff 75 10             	pushl  0x10(%ebp)
  8002f0:	ff 75 0c             	pushl  0xc(%ebp)
  8002f3:	ff 75 08             	pushl  0x8(%ebp)
  8002f6:	e8 05 00 00 00       	call   800300 <vprintfmt>
	va_end(ap);
}
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 2c             	sub    $0x2c,%esp
  800309:	8b 75 08             	mov    0x8(%ebp),%esi
  80030c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800312:	eb 12                	jmp    800326 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800314:	85 c0                	test   %eax,%eax
  800316:	0f 84 42 04 00 00    	je     80075e <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80031c:	83 ec 08             	sub    $0x8,%esp
  80031f:	53                   	push   %ebx
  800320:	50                   	push   %eax
  800321:	ff d6                	call   *%esi
  800323:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800326:	83 c7 01             	add    $0x1,%edi
  800329:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80032d:	83 f8 25             	cmp    $0x25,%eax
  800330:	75 e2                	jne    800314 <vprintfmt+0x14>
  800332:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800336:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800344:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800350:	eb 07                	jmp    800359 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800355:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8d 47 01             	lea    0x1(%edi),%eax
  80035c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035f:	0f b6 07             	movzbl (%edi),%eax
  800362:	0f b6 d0             	movzbl %al,%edx
  800365:	83 e8 23             	sub    $0x23,%eax
  800368:	3c 55                	cmp    $0x55,%al
  80036a:	0f 87 d3 03 00 00    	ja     800743 <vprintfmt+0x443>
  800370:	0f b6 c0             	movzbl %al,%eax
  800373:	ff 24 85 20 21 80 00 	jmp    *0x802120(,%eax,4)
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800381:	eb d6                	jmp    800359 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800386:	b8 00 00 00 00       	mov    $0x0,%eax
  80038b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800391:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800395:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800398:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039b:	83 f9 09             	cmp    $0x9,%ecx
  80039e:	77 3f                	ja     8003df <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a3:	eb e9                	jmp    80038e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 40 04             	lea    0x4(%eax),%eax
  8003b3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b9:	eb 2a                	jmp    8003e5 <vprintfmt+0xe5>
  8003bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c5:	0f 49 d0             	cmovns %eax,%edx
  8003c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ce:	eb 89                	jmp    800359 <vprintfmt+0x59>
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003da:	e9 7a ff ff ff       	jmp    800359 <vprintfmt+0x59>
  8003df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e9:	0f 89 6a ff ff ff    	jns    800359 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003fc:	e9 58 ff ff ff       	jmp    800359 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800401:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800407:	e9 4d ff ff ff       	jmp    800359 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 78 04             	lea    0x4(%eax),%edi
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	53                   	push   %ebx
  800416:	ff 30                	pushl  (%eax)
  800418:	ff d6                	call   *%esi
			break;
  80041a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800423:	e9 fe fe ff ff       	jmp    800326 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 78 04             	lea    0x4(%eax),%edi
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
  800431:	31 d0                	xor    %edx,%eax
  800433:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 0f             	cmp    $0xf,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x145>
  80043a:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	75 1b                	jne    800460 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800445:	50                   	push   %eax
  800446:	68 f3 1f 80 00       	push   $0x801ff3
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 91 fe ff ff       	call   8002e3 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800455:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045b:	e9 c6 fe ff ff       	jmp    800326 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800460:	52                   	push   %edx
  800461:	68 d9 23 80 00       	push   $0x8023d9
  800466:	53                   	push   %ebx
  800467:	56                   	push   %esi
  800468:	e8 76 fe ff ff       	call   8002e3 <printfmt>
  80046d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800470:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800476:	e9 ab fe ff ff       	jmp    800326 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	83 c0 04             	add    $0x4,%eax
  800481:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800489:	85 ff                	test   %edi,%edi
  80048b:	b8 ec 1f 80 00       	mov    $0x801fec,%eax
  800490:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800493:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800497:	0f 8e 94 00 00 00    	jle    800531 <vprintfmt+0x231>
  80049d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a1:	0f 84 98 00 00 00    	je     80053f <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ad:	57                   	push   %edi
  8004ae:	e8 33 03 00 00       	call   8007e6 <strnlen>
  8004b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	eb 0f                	jmp    8004db <vprintfmt+0x1db>
					putch(padc, putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	53                   	push   %ebx
  8004d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ef 01             	sub    $0x1,%edi
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	7f ed                	jg     8004cc <vprintfmt+0x1cc>
  8004df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	0f 49 c1             	cmovns %ecx,%eax
  8004ef:	29 c1                	sub    %eax,%ecx
  8004f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fa:	89 cb                	mov    %ecx,%ebx
  8004fc:	eb 4d                	jmp    80054b <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800502:	74 1b                	je     80051f <vprintfmt+0x21f>
  800504:	0f be c0             	movsbl %al,%eax
  800507:	83 e8 20             	sub    $0x20,%eax
  80050a:	83 f8 5e             	cmp    $0x5e,%eax
  80050d:	76 10                	jbe    80051f <vprintfmt+0x21f>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	6a 3f                	push   $0x3f
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb 0d                	jmp    80052c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	52                   	push   %edx
  800526:	ff 55 08             	call   *0x8(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	83 eb 01             	sub    $0x1,%ebx
  80052f:	eb 1a                	jmp    80054b <vprintfmt+0x24b>
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053d:	eb 0c                	jmp    80054b <vprintfmt+0x24b>
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054b:	83 c7 01             	add    $0x1,%edi
  80054e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800552:	0f be d0             	movsbl %al,%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	74 23                	je     80057c <vprintfmt+0x27c>
  800559:	85 f6                	test   %esi,%esi
  80055b:	78 a1                	js     8004fe <vprintfmt+0x1fe>
  80055d:	83 ee 01             	sub    $0x1,%esi
  800560:	79 9c                	jns    8004fe <vprintfmt+0x1fe>
  800562:	89 df                	mov    %ebx,%edi
  800564:	8b 75 08             	mov    0x8(%ebp),%esi
  800567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056a:	eb 18                	jmp    800584 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	6a 20                	push   $0x20
  800572:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800574:	83 ef 01             	sub    $0x1,%edi
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb 08                	jmp    800584 <vprintfmt+0x284>
  80057c:	89 df                	mov    %ebx,%edi
  80057e:	8b 75 08             	mov    0x8(%ebp),%esi
  800581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800584:	85 ff                	test   %edi,%edi
  800586:	7f e4                	jg     80056c <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800588:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800591:	e9 90 fd ff ff       	jmp    800326 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800596:	83 f9 01             	cmp    $0x1,%ecx
  800599:	7e 19                	jle    8005b4 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 50 04             	mov    0x4(%eax),%edx
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 40 08             	lea    0x8(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b2:	eb 38                	jmp    8005ec <vprintfmt+0x2ec>
	else if (lflag)
  8005b4:	85 c9                	test   %ecx,%ecx
  8005b6:	74 1b                	je     8005d3 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 c1                	mov    %eax,%ecx
  8005c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d1:	eb 19                	jmp    8005ec <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 c1                	mov    %eax,%ecx
  8005dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fb:	0f 89 0e 01 00 00    	jns    80070f <vprintfmt+0x40f>
				putch('-', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 2d                	push   $0x2d
  800607:	ff d6                	call   *%esi
				num = -(long long) num;
  800609:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80060c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80060f:	f7 da                	neg    %edx
  800611:	83 d1 00             	adc    $0x0,%ecx
  800614:	f7 d9                	neg    %ecx
  800616:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	e9 ec 00 00 00       	jmp    80070f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7e 18                	jle    800640 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	8b 48 04             	mov    0x4(%eax),%ecx
  800630:	8d 40 08             	lea    0x8(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063b:	e9 cf 00 00 00       	jmp    80070f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800640:	85 c9                	test   %ecx,%ecx
  800642:	74 1a                	je     80065e <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8b 10                	mov    (%eax),%edx
  800649:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064e:	8d 40 04             	lea    0x4(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800654:	b8 0a 00 00 00       	mov    $0xa,%eax
  800659:	e9 b1 00 00 00       	jmp    80070f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	b9 00 00 00 00       	mov    $0x0,%ecx
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800673:	e9 97 00 00 00       	jmp    80070f <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 58                	push   $0x58
  80067e:	ff d6                	call   *%esi
			putch('X', putdat);
  800680:	83 c4 08             	add    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 58                	push   $0x58
  800686:	ff d6                	call   *%esi
			putch('X', putdat);
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 58                	push   $0x58
  80068e:	ff d6                	call   *%esi
			break;
  800690:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800693:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800696:	e9 8b fc ff ff       	jmp    800326 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 30                	push   $0x30
  8006a1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 78                	push   $0x78
  8006a9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b5:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c3:	eb 4a                	jmp    80070f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c5:	83 f9 01             	cmp    $0x1,%ecx
  8006c8:	7e 15                	jle    8006df <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d2:	8d 40 08             	lea    0x8(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006dd:	eb 30                	jmp    80070f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006df:	85 c9                	test   %ecx,%ecx
  8006e1:	74 17                	je     8006fa <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f8:	eb 15                	jmp    80070f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800704:	8d 40 04             	lea    0x4(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80070a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070f:	83 ec 0c             	sub    $0xc,%esp
  800712:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800716:	57                   	push   %edi
  800717:	ff 75 e0             	pushl  -0x20(%ebp)
  80071a:	50                   	push   %eax
  80071b:	51                   	push   %ecx
  80071c:	52                   	push   %edx
  80071d:	89 da                	mov    %ebx,%edx
  80071f:	89 f0                	mov    %esi,%eax
  800721:	e8 f1 fa ff ff       	call   800217 <printnum>
			break;
  800726:	83 c4 20             	add    $0x20,%esp
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072c:	e9 f5 fb ff ff       	jmp    800326 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	52                   	push   %edx
  800736:	ff d6                	call   *%esi
			break;
  800738:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80073e:	e9 e3 fb ff ff       	jmp    800326 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	53                   	push   %ebx
  800747:	6a 25                	push   $0x25
  800749:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074b:	83 c4 10             	add    $0x10,%esp
  80074e:	eb 03                	jmp    800753 <vprintfmt+0x453>
  800750:	83 ef 01             	sub    $0x1,%edi
  800753:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800757:	75 f7                	jne    800750 <vprintfmt+0x450>
  800759:	e9 c8 fb ff ff       	jmp    800326 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80075e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	5f                   	pop    %edi
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 18             	sub    $0x18,%esp
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800775:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800779:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800783:	85 c0                	test   %eax,%eax
  800785:	74 26                	je     8007ad <vsnprintf+0x47>
  800787:	85 d2                	test   %edx,%edx
  800789:	7e 22                	jle    8007ad <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078b:	ff 75 14             	pushl  0x14(%ebp)
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	68 c6 02 80 00       	push   $0x8002c6
  80079a:	e8 61 fb ff ff       	call   800300 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	eb 05                	jmp    8007b2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bd:	50                   	push   %eax
  8007be:	ff 75 10             	pushl  0x10(%ebp)
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	ff 75 08             	pushl  0x8(%ebp)
  8007c7:	e8 9a ff ff ff       	call   800766 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	eb 03                	jmp    8007de <strlen+0x10>
		n++;
  8007db:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e2:	75 f7                	jne    8007db <strlen+0xd>
		n++;
	return n;
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f4:	eb 03                	jmp    8007f9 <strnlen+0x13>
		n++;
  8007f6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	39 c2                	cmp    %eax,%edx
  8007fb:	74 08                	je     800805 <strnlen+0x1f>
  8007fd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800801:	75 f3                	jne    8007f6 <strnlen+0x10>
  800803:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800811:	89 c2                	mov    %eax,%edx
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	83 c1 01             	add    $0x1,%ecx
  800819:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800820:	84 db                	test   %bl,%bl
  800822:	75 ef                	jne    800813 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800824:	5b                   	pop    %ebx
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082e:	53                   	push   %ebx
  80082f:	e8 9a ff ff ff       	call   8007ce <strlen>
  800834:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800837:	ff 75 0c             	pushl  0xc(%ebp)
  80083a:	01 d8                	add    %ebx,%eax
  80083c:	50                   	push   %eax
  80083d:	e8 c5 ff ff ff       	call   800807 <strcpy>
	return dst;
}
  800842:	89 d8                	mov    %ebx,%eax
  800844:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	56                   	push   %esi
  80084d:	53                   	push   %ebx
  80084e:	8b 75 08             	mov    0x8(%ebp),%esi
  800851:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800854:	89 f3                	mov    %esi,%ebx
  800856:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	89 f2                	mov    %esi,%edx
  80085b:	eb 0f                	jmp    80086c <strncpy+0x23>
		*dst++ = *src;
  80085d:	83 c2 01             	add    $0x1,%edx
  800860:	0f b6 01             	movzbl (%ecx),%eax
  800863:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800866:	80 39 01             	cmpb   $0x1,(%ecx)
  800869:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086c:	39 da                	cmp    %ebx,%edx
  80086e:	75 ed                	jne    80085d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800870:	89 f0                	mov    %esi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800881:	8b 55 10             	mov    0x10(%ebp),%edx
  800884:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	85 d2                	test   %edx,%edx
  800888:	74 21                	je     8008ab <strlcpy+0x35>
  80088a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088e:	89 f2                	mov    %esi,%edx
  800890:	eb 09                	jmp    80089b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800892:	83 c2 01             	add    $0x1,%edx
  800895:	83 c1 01             	add    $0x1,%ecx
  800898:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089b:	39 c2                	cmp    %eax,%edx
  80089d:	74 09                	je     8008a8 <strlcpy+0x32>
  80089f:	0f b6 19             	movzbl (%ecx),%ebx
  8008a2:	84 db                	test   %bl,%bl
  8008a4:	75 ec                	jne    800892 <strlcpy+0x1c>
  8008a6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ab:	29 f0                	sub    %esi,%eax
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ba:	eb 06                	jmp    8008c2 <strcmp+0x11>
		p++, q++;
  8008bc:	83 c1 01             	add    $0x1,%ecx
  8008bf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c2:	0f b6 01             	movzbl (%ecx),%eax
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x1c>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 ef                	je     8008bc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e1:	89 c3                	mov    %eax,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e6:	eb 06                	jmp    8008ee <strncmp+0x17>
		n--, p++, q++;
  8008e8:	83 c0 01             	add    $0x1,%eax
  8008eb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ee:	39 d8                	cmp    %ebx,%eax
  8008f0:	74 15                	je     800907 <strncmp+0x30>
  8008f2:	0f b6 08             	movzbl (%eax),%ecx
  8008f5:	84 c9                	test   %cl,%cl
  8008f7:	74 04                	je     8008fd <strncmp+0x26>
  8008f9:	3a 0a                	cmp    (%edx),%cl
  8008fb:	74 eb                	je     8008e8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fd:	0f b6 00             	movzbl (%eax),%eax
  800900:	0f b6 12             	movzbl (%edx),%edx
  800903:	29 d0                	sub    %edx,%eax
  800905:	eb 05                	jmp    80090c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090c:	5b                   	pop    %ebx
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800919:	eb 07                	jmp    800922 <strchr+0x13>
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	74 0f                	je     80092e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	0f b6 10             	movzbl (%eax),%edx
  800925:	84 d2                	test   %dl,%dl
  800927:	75 f2                	jne    80091b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800929:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093a:	eb 03                	jmp    80093f <strfind+0xf>
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800942:	38 ca                	cmp    %cl,%dl
  800944:	74 04                	je     80094a <strfind+0x1a>
  800946:	84 d2                	test   %dl,%dl
  800948:	75 f2                	jne    80093c <strfind+0xc>
			break;
	return (char *) s;
}
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	8b 7d 08             	mov    0x8(%ebp),%edi
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800958:	85 c9                	test   %ecx,%ecx
  80095a:	74 36                	je     800992 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800962:	75 28                	jne    80098c <memset+0x40>
  800964:	f6 c1 03             	test   $0x3,%cl
  800967:	75 23                	jne    80098c <memset+0x40>
		c &= 0xFF;
  800969:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096d:	89 d3                	mov    %edx,%ebx
  80096f:	c1 e3 08             	shl    $0x8,%ebx
  800972:	89 d6                	mov    %edx,%esi
  800974:	c1 e6 18             	shl    $0x18,%esi
  800977:	89 d0                	mov    %edx,%eax
  800979:	c1 e0 10             	shl    $0x10,%eax
  80097c:	09 f0                	or     %esi,%eax
  80097e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800980:	89 d8                	mov    %ebx,%eax
  800982:	09 d0                	or     %edx,%eax
  800984:	c1 e9 02             	shr    $0x2,%ecx
  800987:	fc                   	cld    
  800988:	f3 ab                	rep stos %eax,%es:(%edi)
  80098a:	eb 06                	jmp    800992 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	fc                   	cld    
  800990:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800992:	89 f8                	mov    %edi,%eax
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a7:	39 c6                	cmp    %eax,%esi
  8009a9:	73 35                	jae    8009e0 <memmove+0x47>
  8009ab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ae:	39 d0                	cmp    %edx,%eax
  8009b0:	73 2e                	jae    8009e0 <memmove+0x47>
		s += n;
		d += n;
  8009b2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b5:	89 d6                	mov    %edx,%esi
  8009b7:	09 fe                	or     %edi,%esi
  8009b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bf:	75 13                	jne    8009d4 <memmove+0x3b>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 0e                	jne    8009d4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009c6:	83 ef 04             	sub    $0x4,%edi
  8009c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
  8009cf:	fd                   	std    
  8009d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d2:	eb 09                	jmp    8009dd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d4:	83 ef 01             	sub    $0x1,%edi
  8009d7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009da:	fd                   	std    
  8009db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009dd:	fc                   	cld    
  8009de:	eb 1d                	jmp    8009fd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e0:	89 f2                	mov    %esi,%edx
  8009e2:	09 c2                	or     %eax,%edx
  8009e4:	f6 c2 03             	test   $0x3,%dl
  8009e7:	75 0f                	jne    8009f8 <memmove+0x5f>
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 0a                	jne    8009f8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ee:	c1 e9 02             	shr    $0x2,%ecx
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f6:	eb 05                	jmp    8009fd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f8:	89 c7                	mov    %eax,%edi
  8009fa:	fc                   	cld    
  8009fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a04:	ff 75 10             	pushl  0x10(%ebp)
  800a07:	ff 75 0c             	pushl  0xc(%ebp)
  800a0a:	ff 75 08             	pushl  0x8(%ebp)
  800a0d:	e8 87 ff ff ff       	call   800999 <memmove>
}
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1f:	89 c6                	mov    %eax,%esi
  800a21:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a24:	eb 1a                	jmp    800a40 <memcmp+0x2c>
		if (*s1 != *s2)
  800a26:	0f b6 08             	movzbl (%eax),%ecx
  800a29:	0f b6 1a             	movzbl (%edx),%ebx
  800a2c:	38 d9                	cmp    %bl,%cl
  800a2e:	74 0a                	je     800a3a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a30:	0f b6 c1             	movzbl %cl,%eax
  800a33:	0f b6 db             	movzbl %bl,%ebx
  800a36:	29 d8                	sub    %ebx,%eax
  800a38:	eb 0f                	jmp    800a49 <memcmp+0x35>
		s1++, s2++;
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a40:	39 f0                	cmp    %esi,%eax
  800a42:	75 e2                	jne    800a26 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	53                   	push   %ebx
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a54:	89 c1                	mov    %eax,%ecx
  800a56:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a59:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5d:	eb 0a                	jmp    800a69 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5f:	0f b6 10             	movzbl (%eax),%edx
  800a62:	39 da                	cmp    %ebx,%edx
  800a64:	74 07                	je     800a6d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a66:	83 c0 01             	add    $0x1,%eax
  800a69:	39 c8                	cmp    %ecx,%eax
  800a6b:	72 f2                	jb     800a5f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7c:	eb 03                	jmp    800a81 <strtol+0x11>
		s++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a81:	0f b6 01             	movzbl (%ecx),%eax
  800a84:	3c 20                	cmp    $0x20,%al
  800a86:	74 f6                	je     800a7e <strtol+0xe>
  800a88:	3c 09                	cmp    $0x9,%al
  800a8a:	74 f2                	je     800a7e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8c:	3c 2b                	cmp    $0x2b,%al
  800a8e:	75 0a                	jne    800a9a <strtol+0x2a>
		s++;
  800a90:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
  800a98:	eb 11                	jmp    800aab <strtol+0x3b>
  800a9a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9f:	3c 2d                	cmp    $0x2d,%al
  800aa1:	75 08                	jne    800aab <strtol+0x3b>
		s++, neg = 1;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aab:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab1:	75 15                	jne    800ac8 <strtol+0x58>
  800ab3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab6:	75 10                	jne    800ac8 <strtol+0x58>
  800ab8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abc:	75 7c                	jne    800b3a <strtol+0xca>
		s += 2, base = 16;
  800abe:	83 c1 02             	add    $0x2,%ecx
  800ac1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac6:	eb 16                	jmp    800ade <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac8:	85 db                	test   %ebx,%ebx
  800aca:	75 12                	jne    800ade <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800acc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad4:	75 08                	jne    800ade <strtol+0x6e>
		s++, base = 8;
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae6:	0f b6 11             	movzbl (%ecx),%edx
  800ae9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aec:	89 f3                	mov    %esi,%ebx
  800aee:	80 fb 09             	cmp    $0x9,%bl
  800af1:	77 08                	ja     800afb <strtol+0x8b>
			dig = *s - '0';
  800af3:	0f be d2             	movsbl %dl,%edx
  800af6:	83 ea 30             	sub    $0x30,%edx
  800af9:	eb 22                	jmp    800b1d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800afb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800afe:	89 f3                	mov    %esi,%ebx
  800b00:	80 fb 19             	cmp    $0x19,%bl
  800b03:	77 08                	ja     800b0d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b05:	0f be d2             	movsbl %dl,%edx
  800b08:	83 ea 57             	sub    $0x57,%edx
  800b0b:	eb 10                	jmp    800b1d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b10:	89 f3                	mov    %esi,%ebx
  800b12:	80 fb 19             	cmp    $0x19,%bl
  800b15:	77 16                	ja     800b2d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b17:	0f be d2             	movsbl %dl,%edx
  800b1a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b20:	7d 0b                	jge    800b2d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b22:	83 c1 01             	add    $0x1,%ecx
  800b25:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b29:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b2b:	eb b9                	jmp    800ae6 <strtol+0x76>

	if (endptr)
  800b2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b31:	74 0d                	je     800b40 <strtol+0xd0>
		*endptr = (char *) s;
  800b33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b36:	89 0e                	mov    %ecx,(%esi)
  800b38:	eb 06                	jmp    800b40 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b3a:	85 db                	test   %ebx,%ebx
  800b3c:	74 98                	je     800ad6 <strtol+0x66>
  800b3e:	eb 9e                	jmp    800ade <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b40:	89 c2                	mov    %eax,%edx
  800b42:	f7 da                	neg    %edx
  800b44:	85 ff                	test   %edi,%edi
  800b46:	0f 45 c2             	cmovne %edx,%eax
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
  800b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5f:	89 c3                	mov    %eax,%ebx
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	89 c6                	mov    %eax,%esi
  800b65:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b99:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	89 cb                	mov    %ecx,%ebx
  800ba3:	89 cf                	mov    %ecx,%edi
  800ba5:	89 ce                	mov    %ecx,%esi
  800ba7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	7e 17                	jle    800bc4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	50                   	push   %eax
  800bb1:	6a 03                	push   $0x3
  800bb3:	68 df 22 80 00       	push   $0x8022df
  800bb8:	6a 23                	push   $0x23
  800bba:	68 fc 22 80 00       	push   $0x8022fc
  800bbf:	e8 66 f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdc:	89 d1                	mov    %edx,%ecx
  800bde:	89 d3                	mov    %edx,%ebx
  800be0:	89 d7                	mov    %edx,%edi
  800be2:	89 d6                	mov    %edx,%esi
  800be4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_yield>:

void
sys_yield(void)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfb:	89 d1                	mov    %edx,%ecx
  800bfd:	89 d3                	mov    %edx,%ebx
  800bff:	89 d7                	mov    %edx,%edi
  800c01:	89 d6                	mov    %edx,%esi
  800c03:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	be 00 00 00 00       	mov    $0x0,%esi
  800c18:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c26:	89 f7                	mov    %esi,%edi
  800c28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7e 17                	jle    800c45 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 04                	push   $0x4
  800c34:	68 df 22 80 00       	push   $0x8022df
  800c39:	6a 23                	push   $0x23
  800c3b:	68 fc 22 80 00       	push   $0x8022fc
  800c40:	e8 e5 f4 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c56:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c67:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7e 17                	jle    800c87 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 05                	push   $0x5
  800c76:	68 df 22 80 00       	push   $0x8022df
  800c7b:	6a 23                	push   $0x23
  800c7d:	68 fc 22 80 00       	push   $0x8022fc
  800c82:	e8 a3 f4 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	89 df                	mov    %ebx,%edi
  800caa:	89 de                	mov    %ebx,%esi
  800cac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 17                	jle    800cc9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 06                	push   $0x6
  800cb8:	68 df 22 80 00       	push   $0x8022df
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 fc 22 80 00       	push   $0x8022fc
  800cc4:	e8 61 f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 08                	push   $0x8
  800cfa:	68 df 22 80 00       	push   $0x8022df
  800cff:	6a 23                	push   $0x23
  800d01:	68 fc 22 80 00       	push   $0x8022fc
  800d06:	e8 1f f4 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	b8 09 00 00 00       	mov    $0x9,%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 09                	push   $0x9
  800d3c:	68 df 22 80 00       	push   $0x8022df
  800d41:	6a 23                	push   $0x23
  800d43:	68 fc 22 80 00       	push   $0x8022fc
  800d48:	e8 dd f3 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	89 df                	mov    %ebx,%edi
  800d70:	89 de                	mov    %ebx,%esi
  800d72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7e 17                	jle    800d8f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 0a                	push   $0xa
  800d7e:	68 df 22 80 00       	push   $0x8022df
  800d83:	6a 23                	push   $0x23
  800d85:	68 fc 22 80 00       	push   $0x8022fc
  800d8a:	e8 9b f3 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9d:	be 00 00 00 00       	mov    $0x0,%esi
  800da2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	89 cb                	mov    %ecx,%ebx
  800dd2:	89 cf                	mov    %ecx,%edi
  800dd4:	89 ce                	mov    %ecx,%esi
  800dd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	7e 17                	jle    800df3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	50                   	push   %eax
  800de0:	6a 0d                	push   $0xd
  800de2:	68 df 22 80 00       	push   $0x8022df
  800de7:	6a 23                	push   $0x23
  800de9:	68 fc 22 80 00       	push   $0x8022fc
  800dee:	e8 37 f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e01:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e08:	75 4a                	jne    800e54 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  800e0a:	a1 04 40 80 00       	mov    0x804004,%eax
  800e0f:	8b 40 48             	mov    0x48(%eax),%eax
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	6a 07                	push   $0x7
  800e17:	68 00 f0 bf ee       	push   $0xeebff000
  800e1c:	50                   	push   %eax
  800e1d:	e8 e8 fd ff ff       	call   800c0a <sys_page_alloc>
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	85 c0                	test   %eax,%eax
  800e27:	79 12                	jns    800e3b <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  800e29:	50                   	push   %eax
  800e2a:	68 0a 23 80 00       	push   $0x80230a
  800e2f:	6a 21                	push   $0x21
  800e31:	68 22 23 80 00       	push   $0x802322
  800e36:	e8 ef f2 ff ff       	call   80012a <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800e3b:	a1 04 40 80 00       	mov    0x804004,%eax
  800e40:	8b 40 48             	mov    0x48(%eax),%eax
  800e43:	83 ec 08             	sub    $0x8,%esp
  800e46:	68 5e 0e 80 00       	push   $0x800e5e
  800e4b:	50                   	push   %eax
  800e4c:	e8 04 ff ff ff       	call   800d55 <sys_env_set_pgfault_upcall>
  800e51:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	a3 08 40 80 00       	mov    %eax,0x804008
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    

00800e5e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e5e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e5f:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e64:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e66:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  800e69:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  800e6c:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  800e70:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  800e75:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  800e79:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800e7b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  800e7c:	83 c4 04             	add    $0x4,%esp
	popfl
  800e7f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e80:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  800e81:	c3                   	ret    

00800e82 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	05 00 00 00 30       	add    $0x30000000,%eax
  800e8d:	c1 e8 0c             	shr    $0xc,%eax
}
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	05 00 00 00 30       	add    $0x30000000,%eax
  800e9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ea2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaf:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eb4:	89 c2                	mov    %eax,%edx
  800eb6:	c1 ea 16             	shr    $0x16,%edx
  800eb9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec0:	f6 c2 01             	test   $0x1,%dl
  800ec3:	74 11                	je     800ed6 <fd_alloc+0x2d>
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	c1 ea 0c             	shr    $0xc,%edx
  800eca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed1:	f6 c2 01             	test   $0x1,%dl
  800ed4:	75 09                	jne    800edf <fd_alloc+0x36>
			*fd_store = fd;
  800ed6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	eb 17                	jmp    800ef6 <fd_alloc+0x4d>
  800edf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ee4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ee9:	75 c9                	jne    800eb4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eeb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ef1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800efe:	83 f8 1f             	cmp    $0x1f,%eax
  800f01:	77 36                	ja     800f39 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f03:	c1 e0 0c             	shl    $0xc,%eax
  800f06:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f0b:	89 c2                	mov    %eax,%edx
  800f0d:	c1 ea 16             	shr    $0x16,%edx
  800f10:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f17:	f6 c2 01             	test   $0x1,%dl
  800f1a:	74 24                	je     800f40 <fd_lookup+0x48>
  800f1c:	89 c2                	mov    %eax,%edx
  800f1e:	c1 ea 0c             	shr    $0xc,%edx
  800f21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f28:	f6 c2 01             	test   $0x1,%dl
  800f2b:	74 1a                	je     800f47 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f30:	89 02                	mov    %eax,(%edx)
	return 0;
  800f32:	b8 00 00 00 00       	mov    $0x0,%eax
  800f37:	eb 13                	jmp    800f4c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3e:	eb 0c                	jmp    800f4c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f40:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f45:	eb 05                	jmp    800f4c <fd_lookup+0x54>
  800f47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 08             	sub    $0x8,%esp
  800f54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f57:	ba b0 23 80 00       	mov    $0x8023b0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f5c:	eb 13                	jmp    800f71 <dev_lookup+0x23>
  800f5e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f61:	39 08                	cmp    %ecx,(%eax)
  800f63:	75 0c                	jne    800f71 <dev_lookup+0x23>
			*dev = devtab[i];
  800f65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f68:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6f:	eb 2e                	jmp    800f9f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f71:	8b 02                	mov    (%edx),%eax
  800f73:	85 c0                	test   %eax,%eax
  800f75:	75 e7                	jne    800f5e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f77:	a1 04 40 80 00       	mov    0x804004,%eax
  800f7c:	8b 40 48             	mov    0x48(%eax),%eax
  800f7f:	83 ec 04             	sub    $0x4,%esp
  800f82:	51                   	push   %ecx
  800f83:	50                   	push   %eax
  800f84:	68 30 23 80 00       	push   $0x802330
  800f89:	e8 75 f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f91:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	56                   	push   %esi
  800fa5:	53                   	push   %ebx
  800fa6:	83 ec 10             	sub    $0x10,%esp
  800fa9:	8b 75 08             	mov    0x8(%ebp),%esi
  800fac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800faf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb2:	50                   	push   %eax
  800fb3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fb9:	c1 e8 0c             	shr    $0xc,%eax
  800fbc:	50                   	push   %eax
  800fbd:	e8 36 ff ff ff       	call   800ef8 <fd_lookup>
  800fc2:	83 c4 08             	add    $0x8,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	78 05                	js     800fce <fd_close+0x2d>
	    || fd != fd2)
  800fc9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fcc:	74 0c                	je     800fda <fd_close+0x39>
		return (must_exist ? r : 0);
  800fce:	84 db                	test   %bl,%bl
  800fd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd5:	0f 44 c2             	cmove  %edx,%eax
  800fd8:	eb 41                	jmp    80101b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	ff 36                	pushl  (%esi)
  800fe3:	e8 66 ff ff ff       	call   800f4e <dev_lookup>
  800fe8:	89 c3                	mov    %eax,%ebx
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 1a                	js     80100b <fd_close+0x6a>
		if (dev->dev_close)
  800ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ff4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ff7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	74 0b                	je     80100b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	56                   	push   %esi
  801004:	ff d0                	call   *%eax
  801006:	89 c3                	mov    %eax,%ebx
  801008:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	56                   	push   %esi
  80100f:	6a 00                	push   $0x0
  801011:	e8 79 fc ff ff       	call   800c8f <sys_page_unmap>
	return r;
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	89 d8                	mov    %ebx,%eax
}
  80101b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80101e:	5b                   	pop    %ebx
  80101f:	5e                   	pop    %esi
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801028:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102b:	50                   	push   %eax
  80102c:	ff 75 08             	pushl  0x8(%ebp)
  80102f:	e8 c4 fe ff ff       	call   800ef8 <fd_lookup>
  801034:	83 c4 08             	add    $0x8,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	78 10                	js     80104b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80103b:	83 ec 08             	sub    $0x8,%esp
  80103e:	6a 01                	push   $0x1
  801040:	ff 75 f4             	pushl  -0xc(%ebp)
  801043:	e8 59 ff ff ff       	call   800fa1 <fd_close>
  801048:	83 c4 10             	add    $0x10,%esp
}
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <close_all>:

void
close_all(void)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	53                   	push   %ebx
  801051:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801054:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	53                   	push   %ebx
  80105d:	e8 c0 ff ff ff       	call   801022 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801062:	83 c3 01             	add    $0x1,%ebx
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	83 fb 20             	cmp    $0x20,%ebx
  80106b:	75 ec                	jne    801059 <close_all+0xc>
		close(i);
}
  80106d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801070:	c9                   	leave  
  801071:	c3                   	ret    

00801072 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	57                   	push   %edi
  801076:	56                   	push   %esi
  801077:	53                   	push   %ebx
  801078:	83 ec 2c             	sub    $0x2c,%esp
  80107b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80107e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801081:	50                   	push   %eax
  801082:	ff 75 08             	pushl  0x8(%ebp)
  801085:	e8 6e fe ff ff       	call   800ef8 <fd_lookup>
  80108a:	83 c4 08             	add    $0x8,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	0f 88 c1 00 00 00    	js     801156 <dup+0xe4>
		return r;
	close(newfdnum);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	56                   	push   %esi
  801099:	e8 84 ff ff ff       	call   801022 <close>

	newfd = INDEX2FD(newfdnum);
  80109e:	89 f3                	mov    %esi,%ebx
  8010a0:	c1 e3 0c             	shl    $0xc,%ebx
  8010a3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010a9:	83 c4 04             	add    $0x4,%esp
  8010ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010af:	e8 de fd ff ff       	call   800e92 <fd2data>
  8010b4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010b6:	89 1c 24             	mov    %ebx,(%esp)
  8010b9:	e8 d4 fd ff ff       	call   800e92 <fd2data>
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010c4:	89 f8                	mov    %edi,%eax
  8010c6:	c1 e8 16             	shr    $0x16,%eax
  8010c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d0:	a8 01                	test   $0x1,%al
  8010d2:	74 37                	je     80110b <dup+0x99>
  8010d4:	89 f8                	mov    %edi,%eax
  8010d6:	c1 e8 0c             	shr    $0xc,%eax
  8010d9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e0:	f6 c2 01             	test   $0x1,%dl
  8010e3:	74 26                	je     80110b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f4:	50                   	push   %eax
  8010f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f8:	6a 00                	push   $0x0
  8010fa:	57                   	push   %edi
  8010fb:	6a 00                	push   $0x0
  8010fd:	e8 4b fb ff ff       	call   800c4d <sys_page_map>
  801102:	89 c7                	mov    %eax,%edi
  801104:	83 c4 20             	add    $0x20,%esp
  801107:	85 c0                	test   %eax,%eax
  801109:	78 2e                	js     801139 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80110b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80110e:	89 d0                	mov    %edx,%eax
  801110:	c1 e8 0c             	shr    $0xc,%eax
  801113:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80111a:	83 ec 0c             	sub    $0xc,%esp
  80111d:	25 07 0e 00 00       	and    $0xe07,%eax
  801122:	50                   	push   %eax
  801123:	53                   	push   %ebx
  801124:	6a 00                	push   $0x0
  801126:	52                   	push   %edx
  801127:	6a 00                	push   $0x0
  801129:	e8 1f fb ff ff       	call   800c4d <sys_page_map>
  80112e:	89 c7                	mov    %eax,%edi
  801130:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801133:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801135:	85 ff                	test   %edi,%edi
  801137:	79 1d                	jns    801156 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801139:	83 ec 08             	sub    $0x8,%esp
  80113c:	53                   	push   %ebx
  80113d:	6a 00                	push   $0x0
  80113f:	e8 4b fb ff ff       	call   800c8f <sys_page_unmap>
	sys_page_unmap(0, nva);
  801144:	83 c4 08             	add    $0x8,%esp
  801147:	ff 75 d4             	pushl  -0x2c(%ebp)
  80114a:	6a 00                	push   $0x0
  80114c:	e8 3e fb ff ff       	call   800c8f <sys_page_unmap>
	return r;
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	89 f8                	mov    %edi,%eax
}
  801156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5e                   	pop    %esi
  80115b:	5f                   	pop    %edi
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	53                   	push   %ebx
  801162:	83 ec 14             	sub    $0x14,%esp
  801165:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801168:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116b:	50                   	push   %eax
  80116c:	53                   	push   %ebx
  80116d:	e8 86 fd ff ff       	call   800ef8 <fd_lookup>
  801172:	83 c4 08             	add    $0x8,%esp
  801175:	89 c2                	mov    %eax,%edx
  801177:	85 c0                	test   %eax,%eax
  801179:	78 6d                	js     8011e8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801185:	ff 30                	pushl  (%eax)
  801187:	e8 c2 fd ff ff       	call   800f4e <dev_lookup>
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	85 c0                	test   %eax,%eax
  801191:	78 4c                	js     8011df <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801193:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801196:	8b 42 08             	mov    0x8(%edx),%eax
  801199:	83 e0 03             	and    $0x3,%eax
  80119c:	83 f8 01             	cmp    $0x1,%eax
  80119f:	75 21                	jne    8011c2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a6:	8b 40 48             	mov    0x48(%eax),%eax
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	53                   	push   %ebx
  8011ad:	50                   	push   %eax
  8011ae:	68 74 23 80 00       	push   $0x802374
  8011b3:	e8 4b f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c0:	eb 26                	jmp    8011e8 <read+0x8a>
	}
	if (!dev->dev_read)
  8011c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c5:	8b 40 08             	mov    0x8(%eax),%eax
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	74 17                	je     8011e3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011cc:	83 ec 04             	sub    $0x4,%esp
  8011cf:	ff 75 10             	pushl  0x10(%ebp)
  8011d2:	ff 75 0c             	pushl  0xc(%ebp)
  8011d5:	52                   	push   %edx
  8011d6:	ff d0                	call   *%eax
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	eb 09                	jmp    8011e8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	eb 05                	jmp    8011e8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011e8:	89 d0                	mov    %edx,%eax
  8011ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	57                   	push   %edi
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 0c             	sub    $0xc,%esp
  8011f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801203:	eb 21                	jmp    801226 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	89 f0                	mov    %esi,%eax
  80120a:	29 d8                	sub    %ebx,%eax
  80120c:	50                   	push   %eax
  80120d:	89 d8                	mov    %ebx,%eax
  80120f:	03 45 0c             	add    0xc(%ebp),%eax
  801212:	50                   	push   %eax
  801213:	57                   	push   %edi
  801214:	e8 45 ff ff ff       	call   80115e <read>
		if (m < 0)
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 10                	js     801230 <readn+0x41>
			return m;
		if (m == 0)
  801220:	85 c0                	test   %eax,%eax
  801222:	74 0a                	je     80122e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801224:	01 c3                	add    %eax,%ebx
  801226:	39 f3                	cmp    %esi,%ebx
  801228:	72 db                	jb     801205 <readn+0x16>
  80122a:	89 d8                	mov    %ebx,%eax
  80122c:	eb 02                	jmp    801230 <readn+0x41>
  80122e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801230:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801233:	5b                   	pop    %ebx
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	53                   	push   %ebx
  80123c:	83 ec 14             	sub    $0x14,%esp
  80123f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801242:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801245:	50                   	push   %eax
  801246:	53                   	push   %ebx
  801247:	e8 ac fc ff ff       	call   800ef8 <fd_lookup>
  80124c:	83 c4 08             	add    $0x8,%esp
  80124f:	89 c2                	mov    %eax,%edx
  801251:	85 c0                	test   %eax,%eax
  801253:	78 68                	js     8012bd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125f:	ff 30                	pushl  (%eax)
  801261:	e8 e8 fc ff ff       	call   800f4e <dev_lookup>
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 47                	js     8012b4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801270:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801274:	75 21                	jne    801297 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801276:	a1 04 40 80 00       	mov    0x804004,%eax
  80127b:	8b 40 48             	mov    0x48(%eax),%eax
  80127e:	83 ec 04             	sub    $0x4,%esp
  801281:	53                   	push   %ebx
  801282:	50                   	push   %eax
  801283:	68 90 23 80 00       	push   $0x802390
  801288:	e8 76 ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801295:	eb 26                	jmp    8012bd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801297:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80129a:	8b 52 0c             	mov    0xc(%edx),%edx
  80129d:	85 d2                	test   %edx,%edx
  80129f:	74 17                	je     8012b8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012a1:	83 ec 04             	sub    $0x4,%esp
  8012a4:	ff 75 10             	pushl  0x10(%ebp)
  8012a7:	ff 75 0c             	pushl  0xc(%ebp)
  8012aa:	50                   	push   %eax
  8012ab:	ff d2                	call   *%edx
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	eb 09                	jmp    8012bd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	eb 05                	jmp    8012bd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012bd:	89 d0                	mov    %edx,%eax
  8012bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ca:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012cd:	50                   	push   %eax
  8012ce:	ff 75 08             	pushl  0x8(%ebp)
  8012d1:	e8 22 fc ff ff       	call   800ef8 <fd_lookup>
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 0e                	js     8012eb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012eb:	c9                   	leave  
  8012ec:	c3                   	ret    

008012ed <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 14             	sub    $0x14,%esp
  8012f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fa:	50                   	push   %eax
  8012fb:	53                   	push   %ebx
  8012fc:	e8 f7 fb ff ff       	call   800ef8 <fd_lookup>
  801301:	83 c4 08             	add    $0x8,%esp
  801304:	89 c2                	mov    %eax,%edx
  801306:	85 c0                	test   %eax,%eax
  801308:	78 65                	js     80136f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801314:	ff 30                	pushl  (%eax)
  801316:	e8 33 fc ff ff       	call   800f4e <dev_lookup>
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 44                	js     801366 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801322:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801325:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801329:	75 21                	jne    80134c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80132b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801330:	8b 40 48             	mov    0x48(%eax),%eax
  801333:	83 ec 04             	sub    $0x4,%esp
  801336:	53                   	push   %ebx
  801337:	50                   	push   %eax
  801338:	68 50 23 80 00       	push   $0x802350
  80133d:	e8 c1 ee ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80134a:	eb 23                	jmp    80136f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80134c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80134f:	8b 52 18             	mov    0x18(%edx),%edx
  801352:	85 d2                	test   %edx,%edx
  801354:	74 14                	je     80136a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	ff 75 0c             	pushl  0xc(%ebp)
  80135c:	50                   	push   %eax
  80135d:	ff d2                	call   *%edx
  80135f:	89 c2                	mov    %eax,%edx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	eb 09                	jmp    80136f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	89 c2                	mov    %eax,%edx
  801368:	eb 05                	jmp    80136f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80136a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80136f:	89 d0                	mov    %edx,%eax
  801371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	53                   	push   %ebx
  80137a:	83 ec 14             	sub    $0x14,%esp
  80137d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801380:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	ff 75 08             	pushl  0x8(%ebp)
  801387:	e8 6c fb ff ff       	call   800ef8 <fd_lookup>
  80138c:	83 c4 08             	add    $0x8,%esp
  80138f:	89 c2                	mov    %eax,%edx
  801391:	85 c0                	test   %eax,%eax
  801393:	78 58                	js     8013ed <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139b:	50                   	push   %eax
  80139c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139f:	ff 30                	pushl  (%eax)
  8013a1:	e8 a8 fb ff ff       	call   800f4e <dev_lookup>
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 37                	js     8013e4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013b4:	74 32                	je     8013e8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013c0:	00 00 00 
	stat->st_isdir = 0;
  8013c3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ca:	00 00 00 
	stat->st_dev = dev;
  8013cd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	53                   	push   %ebx
  8013d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8013da:	ff 50 14             	call   *0x14(%eax)
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	eb 09                	jmp    8013ed <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e4:	89 c2                	mov    %eax,%edx
  8013e6:	eb 05                	jmp    8013ed <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013ed:	89 d0                	mov    %edx,%eax
  8013ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	56                   	push   %esi
  8013f8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	6a 00                	push   $0x0
  8013fe:	ff 75 08             	pushl  0x8(%ebp)
  801401:	e8 e3 01 00 00       	call   8015e9 <open>
  801406:	89 c3                	mov    %eax,%ebx
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 1b                	js     80142a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	ff 75 0c             	pushl  0xc(%ebp)
  801415:	50                   	push   %eax
  801416:	e8 5b ff ff ff       	call   801376 <fstat>
  80141b:	89 c6                	mov    %eax,%esi
	close(fd);
  80141d:	89 1c 24             	mov    %ebx,(%esp)
  801420:	e8 fd fb ff ff       	call   801022 <close>
	return r;
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	89 f0                	mov    %esi,%eax
}
  80142a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142d:	5b                   	pop    %ebx
  80142e:	5e                   	pop    %esi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
  801436:	89 c6                	mov    %eax,%esi
  801438:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80143a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801441:	75 12                	jne    801455 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801443:	83 ec 0c             	sub    $0xc,%esp
  801446:	6a 01                	push   $0x1
  801448:	e8 dc 07 00 00       	call   801c29 <ipc_find_env>
  80144d:	a3 00 40 80 00       	mov    %eax,0x804000
  801452:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801455:	6a 07                	push   $0x7
  801457:	68 00 50 80 00       	push   $0x805000
  80145c:	56                   	push   %esi
  80145d:	ff 35 00 40 80 00    	pushl  0x804000
  801463:	e8 6d 07 00 00       	call   801bd5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801468:	83 c4 0c             	add    $0xc,%esp
  80146b:	6a 00                	push   $0x0
  80146d:	53                   	push   %ebx
  80146e:	6a 00                	push   $0x0
  801470:	e8 f7 06 00 00       	call   801b6c <ipc_recv>
}
  801475:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801478:	5b                   	pop    %ebx
  801479:	5e                   	pop    %esi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801482:	8b 45 08             	mov    0x8(%ebp),%eax
  801485:	8b 40 0c             	mov    0xc(%eax),%eax
  801488:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80148d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801490:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801495:	ba 00 00 00 00       	mov    $0x0,%edx
  80149a:	b8 02 00 00 00       	mov    $0x2,%eax
  80149f:	e8 8d ff ff ff       	call   801431 <fsipc>
}
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8014af:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bc:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c1:	e8 6b ff ff ff       	call   801431 <fsipc>
}
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	53                   	push   %ebx
  8014cc:	83 ec 04             	sub    $0x4,%esp
  8014cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8014e7:	e8 45 ff ff ff       	call   801431 <fsipc>
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 2c                	js     80151c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	68 00 50 80 00       	push   $0x805000
  8014f8:	53                   	push   %ebx
  8014f9:	e8 09 f3 ff ff       	call   800807 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014fe:	a1 80 50 80 00       	mov    0x805080,%eax
  801503:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801509:	a1 84 50 80 00       	mov    0x805084,%eax
  80150e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151f:	c9                   	leave  
  801520:	c3                   	ret    

00801521 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	83 ec 0c             	sub    $0xc,%esp
  801527:	8b 45 10             	mov    0x10(%ebp),%eax
  80152a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80152f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801534:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801537:	8b 55 08             	mov    0x8(%ebp),%edx
  80153a:	8b 52 0c             	mov    0xc(%edx),%edx
  80153d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801543:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801548:	50                   	push   %eax
  801549:	ff 75 0c             	pushl  0xc(%ebp)
  80154c:	68 08 50 80 00       	push   $0x805008
  801551:	e8 43 f4 ff ff       	call   800999 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801556:	ba 00 00 00 00       	mov    $0x0,%edx
  80155b:	b8 04 00 00 00       	mov    $0x4,%eax
  801560:	e8 cc fe ff ff       	call   801431 <fsipc>
	//panic("devfile_write not implemented");
}
  801565:	c9                   	leave  
  801566:	c3                   	ret    

00801567 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	56                   	push   %esi
  80156b:	53                   	push   %ebx
  80156c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80156f:	8b 45 08             	mov    0x8(%ebp),%eax
  801572:	8b 40 0c             	mov    0xc(%eax),%eax
  801575:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80157a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801580:	ba 00 00 00 00       	mov    $0x0,%edx
  801585:	b8 03 00 00 00       	mov    $0x3,%eax
  80158a:	e8 a2 fe ff ff       	call   801431 <fsipc>
  80158f:	89 c3                	mov    %eax,%ebx
  801591:	85 c0                	test   %eax,%eax
  801593:	78 4b                	js     8015e0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801595:	39 c6                	cmp    %eax,%esi
  801597:	73 16                	jae    8015af <devfile_read+0x48>
  801599:	68 c0 23 80 00       	push   $0x8023c0
  80159e:	68 c7 23 80 00       	push   $0x8023c7
  8015a3:	6a 7c                	push   $0x7c
  8015a5:	68 dc 23 80 00       	push   $0x8023dc
  8015aa:	e8 7b eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  8015af:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015b4:	7e 16                	jle    8015cc <devfile_read+0x65>
  8015b6:	68 e7 23 80 00       	push   $0x8023e7
  8015bb:	68 c7 23 80 00       	push   $0x8023c7
  8015c0:	6a 7d                	push   $0x7d
  8015c2:	68 dc 23 80 00       	push   $0x8023dc
  8015c7:	e8 5e eb ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	50                   	push   %eax
  8015d0:	68 00 50 80 00       	push   $0x805000
  8015d5:	ff 75 0c             	pushl  0xc(%ebp)
  8015d8:	e8 bc f3 ff ff       	call   800999 <memmove>
	return r;
  8015dd:	83 c4 10             	add    $0x10,%esp
}
  8015e0:	89 d8                	mov    %ebx,%eax
  8015e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e5:	5b                   	pop    %ebx
  8015e6:	5e                   	pop    %esi
  8015e7:	5d                   	pop    %ebp
  8015e8:	c3                   	ret    

008015e9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 20             	sub    $0x20,%esp
  8015f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015f3:	53                   	push   %ebx
  8015f4:	e8 d5 f1 ff ff       	call   8007ce <strlen>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801601:	7f 67                	jg     80166a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	e8 9a f8 ff ff       	call   800ea9 <fd_alloc>
  80160f:	83 c4 10             	add    $0x10,%esp
		return r;
  801612:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801614:	85 c0                	test   %eax,%eax
  801616:	78 57                	js     80166f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	53                   	push   %ebx
  80161c:	68 00 50 80 00       	push   $0x805000
  801621:	e8 e1 f1 ff ff       	call   800807 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801626:	8b 45 0c             	mov    0xc(%ebp),%eax
  801629:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80162e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801631:	b8 01 00 00 00       	mov    $0x1,%eax
  801636:	e8 f6 fd ff ff       	call   801431 <fsipc>
  80163b:	89 c3                	mov    %eax,%ebx
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	79 14                	jns    801658 <open+0x6f>
		fd_close(fd, 0);
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	6a 00                	push   $0x0
  801649:	ff 75 f4             	pushl  -0xc(%ebp)
  80164c:	e8 50 f9 ff ff       	call   800fa1 <fd_close>
		return r;
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	89 da                	mov    %ebx,%edx
  801656:	eb 17                	jmp    80166f <open+0x86>
	}

	return fd2num(fd);
  801658:	83 ec 0c             	sub    $0xc,%esp
  80165b:	ff 75 f4             	pushl  -0xc(%ebp)
  80165e:	e8 1f f8 ff ff       	call   800e82 <fd2num>
  801663:	89 c2                	mov    %eax,%edx
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	eb 05                	jmp    80166f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80166a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80166f:	89 d0                	mov    %edx,%eax
  801671:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801674:	c9                   	leave  
  801675:	c3                   	ret    

00801676 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80167c:	ba 00 00 00 00       	mov    $0x0,%edx
  801681:	b8 08 00 00 00       	mov    $0x8,%eax
  801686:	e8 a6 fd ff ff       	call   801431 <fsipc>
}
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	56                   	push   %esi
  801691:	53                   	push   %ebx
  801692:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	ff 75 08             	pushl  0x8(%ebp)
  80169b:	e8 f2 f7 ff ff       	call   800e92 <fd2data>
  8016a0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016a2:	83 c4 08             	add    $0x8,%esp
  8016a5:	68 f3 23 80 00       	push   $0x8023f3
  8016aa:	53                   	push   %ebx
  8016ab:	e8 57 f1 ff ff       	call   800807 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016b0:	8b 46 04             	mov    0x4(%esi),%eax
  8016b3:	2b 06                	sub    (%esi),%eax
  8016b5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c2:	00 00 00 
	stat->st_dev = &devpipe;
  8016c5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016cc:	30 80 00 
	return 0;
}
  8016cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d7:	5b                   	pop    %ebx
  8016d8:	5e                   	pop    %esi
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    

008016db <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	53                   	push   %ebx
  8016df:	83 ec 0c             	sub    $0xc,%esp
  8016e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016e5:	53                   	push   %ebx
  8016e6:	6a 00                	push   $0x0
  8016e8:	e8 a2 f5 ff ff       	call   800c8f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016ed:	89 1c 24             	mov    %ebx,(%esp)
  8016f0:	e8 9d f7 ff ff       	call   800e92 <fd2data>
  8016f5:	83 c4 08             	add    $0x8,%esp
  8016f8:	50                   	push   %eax
  8016f9:	6a 00                	push   $0x0
  8016fb:	e8 8f f5 ff ff       	call   800c8f <sys_page_unmap>
}
  801700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	57                   	push   %edi
  801709:	56                   	push   %esi
  80170a:	53                   	push   %ebx
  80170b:	83 ec 1c             	sub    $0x1c,%esp
  80170e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801711:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801713:	a1 04 40 80 00       	mov    0x804004,%eax
  801718:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80171b:	83 ec 0c             	sub    $0xc,%esp
  80171e:	ff 75 e0             	pushl  -0x20(%ebp)
  801721:	e8 3c 05 00 00       	call   801c62 <pageref>
  801726:	89 c3                	mov    %eax,%ebx
  801728:	89 3c 24             	mov    %edi,(%esp)
  80172b:	e8 32 05 00 00       	call   801c62 <pageref>
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	39 c3                	cmp    %eax,%ebx
  801735:	0f 94 c1             	sete   %cl
  801738:	0f b6 c9             	movzbl %cl,%ecx
  80173b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80173e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801744:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801747:	39 ce                	cmp    %ecx,%esi
  801749:	74 1b                	je     801766 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80174b:	39 c3                	cmp    %eax,%ebx
  80174d:	75 c4                	jne    801713 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80174f:	8b 42 58             	mov    0x58(%edx),%eax
  801752:	ff 75 e4             	pushl  -0x1c(%ebp)
  801755:	50                   	push   %eax
  801756:	56                   	push   %esi
  801757:	68 fa 23 80 00       	push   $0x8023fa
  80175c:	e8 a2 ea ff ff       	call   800203 <cprintf>
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	eb ad                	jmp    801713 <_pipeisclosed+0xe>
	}
}
  801766:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801769:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176c:	5b                   	pop    %ebx
  80176d:	5e                   	pop    %esi
  80176e:	5f                   	pop    %edi
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    

00801771 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	57                   	push   %edi
  801775:	56                   	push   %esi
  801776:	53                   	push   %ebx
  801777:	83 ec 28             	sub    $0x28,%esp
  80177a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80177d:	56                   	push   %esi
  80177e:	e8 0f f7 ff ff       	call   800e92 <fd2data>
  801783:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	bf 00 00 00 00       	mov    $0x0,%edi
  80178d:	eb 4b                	jmp    8017da <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80178f:	89 da                	mov    %ebx,%edx
  801791:	89 f0                	mov    %esi,%eax
  801793:	e8 6d ff ff ff       	call   801705 <_pipeisclosed>
  801798:	85 c0                	test   %eax,%eax
  80179a:	75 48                	jne    8017e4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80179c:	e8 4a f4 ff ff       	call   800beb <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017a1:	8b 43 04             	mov    0x4(%ebx),%eax
  8017a4:	8b 0b                	mov    (%ebx),%ecx
  8017a6:	8d 51 20             	lea    0x20(%ecx),%edx
  8017a9:	39 d0                	cmp    %edx,%eax
  8017ab:	73 e2                	jae    80178f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017b4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017b7:	89 c2                	mov    %eax,%edx
  8017b9:	c1 fa 1f             	sar    $0x1f,%edx
  8017bc:	89 d1                	mov    %edx,%ecx
  8017be:	c1 e9 1b             	shr    $0x1b,%ecx
  8017c1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017c4:	83 e2 1f             	and    $0x1f,%edx
  8017c7:	29 ca                	sub    %ecx,%edx
  8017c9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017d1:	83 c0 01             	add    $0x1,%eax
  8017d4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d7:	83 c7 01             	add    $0x1,%edi
  8017da:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017dd:	75 c2                	jne    8017a1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017df:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e2:	eb 05                	jmp    8017e9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017e4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ec:	5b                   	pop    %ebx
  8017ed:	5e                   	pop    %esi
  8017ee:	5f                   	pop    %edi
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	57                   	push   %edi
  8017f5:	56                   	push   %esi
  8017f6:	53                   	push   %ebx
  8017f7:	83 ec 18             	sub    $0x18,%esp
  8017fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017fd:	57                   	push   %edi
  8017fe:	e8 8f f6 ff ff       	call   800e92 <fd2data>
  801803:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	bb 00 00 00 00       	mov    $0x0,%ebx
  80180d:	eb 3d                	jmp    80184c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80180f:	85 db                	test   %ebx,%ebx
  801811:	74 04                	je     801817 <devpipe_read+0x26>
				return i;
  801813:	89 d8                	mov    %ebx,%eax
  801815:	eb 44                	jmp    80185b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801817:	89 f2                	mov    %esi,%edx
  801819:	89 f8                	mov    %edi,%eax
  80181b:	e8 e5 fe ff ff       	call   801705 <_pipeisclosed>
  801820:	85 c0                	test   %eax,%eax
  801822:	75 32                	jne    801856 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801824:	e8 c2 f3 ff ff       	call   800beb <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801829:	8b 06                	mov    (%esi),%eax
  80182b:	3b 46 04             	cmp    0x4(%esi),%eax
  80182e:	74 df                	je     80180f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801830:	99                   	cltd   
  801831:	c1 ea 1b             	shr    $0x1b,%edx
  801834:	01 d0                	add    %edx,%eax
  801836:	83 e0 1f             	and    $0x1f,%eax
  801839:	29 d0                	sub    %edx,%eax
  80183b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801840:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801843:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801846:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801849:	83 c3 01             	add    $0x1,%ebx
  80184c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80184f:	75 d8                	jne    801829 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801851:	8b 45 10             	mov    0x10(%ebp),%eax
  801854:	eb 05                	jmp    80185b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801856:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80185b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80185e:	5b                   	pop    %ebx
  80185f:	5e                   	pop    %esi
  801860:	5f                   	pop    %edi
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	56                   	push   %esi
  801867:	53                   	push   %ebx
  801868:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80186b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186e:	50                   	push   %eax
  80186f:	e8 35 f6 ff ff       	call   800ea9 <fd_alloc>
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	89 c2                	mov    %eax,%edx
  801879:	85 c0                	test   %eax,%eax
  80187b:	0f 88 2c 01 00 00    	js     8019ad <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801881:	83 ec 04             	sub    $0x4,%esp
  801884:	68 07 04 00 00       	push   $0x407
  801889:	ff 75 f4             	pushl  -0xc(%ebp)
  80188c:	6a 00                	push   $0x0
  80188e:	e8 77 f3 ff ff       	call   800c0a <sys_page_alloc>
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	89 c2                	mov    %eax,%edx
  801898:	85 c0                	test   %eax,%eax
  80189a:	0f 88 0d 01 00 00    	js     8019ad <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018a0:	83 ec 0c             	sub    $0xc,%esp
  8018a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a6:	50                   	push   %eax
  8018a7:	e8 fd f5 ff ff       	call   800ea9 <fd_alloc>
  8018ac:	89 c3                	mov    %eax,%ebx
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	0f 88 e2 00 00 00    	js     80199b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b9:	83 ec 04             	sub    $0x4,%esp
  8018bc:	68 07 04 00 00       	push   $0x407
  8018c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c4:	6a 00                	push   $0x0
  8018c6:	e8 3f f3 ff ff       	call   800c0a <sys_page_alloc>
  8018cb:	89 c3                	mov    %eax,%ebx
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	0f 88 c3 00 00 00    	js     80199b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018d8:	83 ec 0c             	sub    $0xc,%esp
  8018db:	ff 75 f4             	pushl  -0xc(%ebp)
  8018de:	e8 af f5 ff ff       	call   800e92 <fd2data>
  8018e3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e5:	83 c4 0c             	add    $0xc,%esp
  8018e8:	68 07 04 00 00       	push   $0x407
  8018ed:	50                   	push   %eax
  8018ee:	6a 00                	push   $0x0
  8018f0:	e8 15 f3 ff ff       	call   800c0a <sys_page_alloc>
  8018f5:	89 c3                	mov    %eax,%ebx
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	0f 88 89 00 00 00    	js     80198b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801902:	83 ec 0c             	sub    $0xc,%esp
  801905:	ff 75 f0             	pushl  -0x10(%ebp)
  801908:	e8 85 f5 ff ff       	call   800e92 <fd2data>
  80190d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801914:	50                   	push   %eax
  801915:	6a 00                	push   $0x0
  801917:	56                   	push   %esi
  801918:	6a 00                	push   $0x0
  80191a:	e8 2e f3 ff ff       	call   800c4d <sys_page_map>
  80191f:	89 c3                	mov    %eax,%ebx
  801921:	83 c4 20             	add    $0x20,%esp
  801924:	85 c0                	test   %eax,%eax
  801926:	78 55                	js     80197d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801928:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80192e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801931:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801933:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801936:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80193d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801943:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801946:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801948:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801952:	83 ec 0c             	sub    $0xc,%esp
  801955:	ff 75 f4             	pushl  -0xc(%ebp)
  801958:	e8 25 f5 ff ff       	call   800e82 <fd2num>
  80195d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801960:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801962:	83 c4 04             	add    $0x4,%esp
  801965:	ff 75 f0             	pushl  -0x10(%ebp)
  801968:	e8 15 f5 ff ff       	call   800e82 <fd2num>
  80196d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801970:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	ba 00 00 00 00       	mov    $0x0,%edx
  80197b:	eb 30                	jmp    8019ad <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	56                   	push   %esi
  801981:	6a 00                	push   $0x0
  801983:	e8 07 f3 ff ff       	call   800c8f <sys_page_unmap>
  801988:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80198b:	83 ec 08             	sub    $0x8,%esp
  80198e:	ff 75 f0             	pushl  -0x10(%ebp)
  801991:	6a 00                	push   $0x0
  801993:	e8 f7 f2 ff ff       	call   800c8f <sys_page_unmap>
  801998:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80199b:	83 ec 08             	sub    $0x8,%esp
  80199e:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a1:	6a 00                	push   $0x0
  8019a3:	e8 e7 f2 ff ff       	call   800c8f <sys_page_unmap>
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019ad:	89 d0                	mov    %edx,%eax
  8019af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b2:	5b                   	pop    %ebx
  8019b3:	5e                   	pop    %esi
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bf:	50                   	push   %eax
  8019c0:	ff 75 08             	pushl  0x8(%ebp)
  8019c3:	e8 30 f5 ff ff       	call   800ef8 <fd_lookup>
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	78 18                	js     8019e7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019cf:	83 ec 0c             	sub    $0xc,%esp
  8019d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d5:	e8 b8 f4 ff ff       	call   800e92 <fd2data>
	return _pipeisclosed(fd, p);
  8019da:	89 c2                	mov    %eax,%edx
  8019dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019df:	e8 21 fd ff ff       	call   801705 <_pipeisclosed>
  8019e4:	83 c4 10             	add    $0x10,%esp
}
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    

008019f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019f9:	68 12 24 80 00       	push   $0x802412
  8019fe:	ff 75 0c             	pushl  0xc(%ebp)
  801a01:	e8 01 ee ff ff       	call   800807 <strcpy>
	return 0;
}
  801a06:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	57                   	push   %edi
  801a11:	56                   	push   %esi
  801a12:	53                   	push   %ebx
  801a13:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a19:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a1e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a24:	eb 2d                	jmp    801a53 <devcons_write+0x46>
		m = n - tot;
  801a26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a29:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a2b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a2e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a33:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a36:	83 ec 04             	sub    $0x4,%esp
  801a39:	53                   	push   %ebx
  801a3a:	03 45 0c             	add    0xc(%ebp),%eax
  801a3d:	50                   	push   %eax
  801a3e:	57                   	push   %edi
  801a3f:	e8 55 ef ff ff       	call   800999 <memmove>
		sys_cputs(buf, m);
  801a44:	83 c4 08             	add    $0x8,%esp
  801a47:	53                   	push   %ebx
  801a48:	57                   	push   %edi
  801a49:	e8 00 f1 ff ff       	call   800b4e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a4e:	01 de                	add    %ebx,%esi
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	89 f0                	mov    %esi,%eax
  801a55:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a58:	72 cc                	jb     801a26 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5d:	5b                   	pop    %ebx
  801a5e:	5e                   	pop    %esi
  801a5f:	5f                   	pop    %edi
  801a60:	5d                   	pop    %ebp
  801a61:	c3                   	ret    

00801a62 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	83 ec 08             	sub    $0x8,%esp
  801a68:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a71:	74 2a                	je     801a9d <devcons_read+0x3b>
  801a73:	eb 05                	jmp    801a7a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a75:	e8 71 f1 ff ff       	call   800beb <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a7a:	e8 ed f0 ff ff       	call   800b6c <sys_cgetc>
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	74 f2                	je     801a75 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 16                	js     801a9d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a87:	83 f8 04             	cmp    $0x4,%eax
  801a8a:	74 0c                	je     801a98 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a8f:	88 02                	mov    %al,(%edx)
	return 1;
  801a91:	b8 01 00 00 00       	mov    $0x1,%eax
  801a96:	eb 05                	jmp    801a9d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a98:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a9d:	c9                   	leave  
  801a9e:	c3                   	ret    

00801a9f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801aab:	6a 01                	push   $0x1
  801aad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ab0:	50                   	push   %eax
  801ab1:	e8 98 f0 ff ff       	call   800b4e <sys_cputs>
}
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <getchar>:

int
getchar(void)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ac1:	6a 01                	push   $0x1
  801ac3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ac6:	50                   	push   %eax
  801ac7:	6a 00                	push   $0x0
  801ac9:	e8 90 f6 ff ff       	call   80115e <read>
	if (r < 0)
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 0f                	js     801ae4 <getchar+0x29>
		return r;
	if (r < 1)
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	7e 06                	jle    801adf <getchar+0x24>
		return -E_EOF;
	return c;
  801ad9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801add:	eb 05                	jmp    801ae4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801adf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aef:	50                   	push   %eax
  801af0:	ff 75 08             	pushl  0x8(%ebp)
  801af3:	e8 00 f4 ff ff       	call   800ef8 <fd_lookup>
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	85 c0                	test   %eax,%eax
  801afd:	78 11                	js     801b10 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b02:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b08:	39 10                	cmp    %edx,(%eax)
  801b0a:	0f 94 c0             	sete   %al
  801b0d:	0f b6 c0             	movzbl %al,%eax
}
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <opencons>:

int
opencons(void)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1b:	50                   	push   %eax
  801b1c:	e8 88 f3 ff ff       	call   800ea9 <fd_alloc>
  801b21:	83 c4 10             	add    $0x10,%esp
		return r;
  801b24:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b26:	85 c0                	test   %eax,%eax
  801b28:	78 3e                	js     801b68 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b2a:	83 ec 04             	sub    $0x4,%esp
  801b2d:	68 07 04 00 00       	push   $0x407
  801b32:	ff 75 f4             	pushl  -0xc(%ebp)
  801b35:	6a 00                	push   $0x0
  801b37:	e8 ce f0 ff ff       	call   800c0a <sys_page_alloc>
  801b3c:	83 c4 10             	add    $0x10,%esp
		return r;
  801b3f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 23                	js     801b68 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b45:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b53:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b5a:	83 ec 0c             	sub    $0xc,%esp
  801b5d:	50                   	push   %eax
  801b5e:	e8 1f f3 ff ff       	call   800e82 <fd2num>
  801b63:	89 c2                	mov    %eax,%edx
  801b65:	83 c4 10             	add    $0x10,%esp
}
  801b68:	89 d0                	mov    %edx,%eax
  801b6a:	c9                   	leave  
  801b6b:	c3                   	ret    

00801b6c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	56                   	push   %esi
  801b70:	53                   	push   %ebx
  801b71:	8b 75 08             	mov    0x8(%ebp),%esi
  801b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b81:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801b84:	83 ec 0c             	sub    $0xc,%esp
  801b87:	50                   	push   %eax
  801b88:	e8 2d f2 ff ff       	call   800dba <sys_ipc_recv>
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	85 c0                	test   %eax,%eax
  801b92:	79 16                	jns    801baa <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801b94:	85 f6                	test   %esi,%esi
  801b96:	74 06                	je     801b9e <ipc_recv+0x32>
            *from_env_store = 0;
  801b98:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801b9e:	85 db                	test   %ebx,%ebx
  801ba0:	74 2c                	je     801bce <ipc_recv+0x62>
            *perm_store = 0;
  801ba2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ba8:	eb 24                	jmp    801bce <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801baa:	85 f6                	test   %esi,%esi
  801bac:	74 0a                	je     801bb8 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801bae:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb3:	8b 40 74             	mov    0x74(%eax),%eax
  801bb6:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801bb8:	85 db                	test   %ebx,%ebx
  801bba:	74 0a                	je     801bc6 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801bbc:	a1 04 40 80 00       	mov    0x804004,%eax
  801bc1:	8b 40 78             	mov    0x78(%eax),%eax
  801bc4:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801bc6:	a1 04 40 80 00       	mov    0x804004,%eax
  801bcb:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	57                   	push   %edi
  801bd9:	56                   	push   %esi
  801bda:	53                   	push   %ebx
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	8b 7d 08             	mov    0x8(%ebp),%edi
  801be1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be4:	8b 45 10             	mov    0x10(%ebp),%eax
  801be7:	85 c0                	test   %eax,%eax
  801be9:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801bee:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801bf1:	eb 1c                	jmp    801c0f <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801bf3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bf6:	74 12                	je     801c0a <ipc_send+0x35>
  801bf8:	50                   	push   %eax
  801bf9:	68 1e 24 80 00       	push   $0x80241e
  801bfe:	6a 3a                	push   $0x3a
  801c00:	68 34 24 80 00       	push   $0x802434
  801c05:	e8 20 e5 ff ff       	call   80012a <_panic>
		sys_yield();
  801c0a:	e8 dc ef ff ff       	call   800beb <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801c0f:	ff 75 14             	pushl  0x14(%ebp)
  801c12:	53                   	push   %ebx
  801c13:	56                   	push   %esi
  801c14:	57                   	push   %edi
  801c15:	e8 7d f1 ff ff       	call   800d97 <sys_ipc_try_send>
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 d2                	js     801bf3 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5f                   	pop    %edi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c2f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c34:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c37:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c3d:	8b 52 50             	mov    0x50(%edx),%edx
  801c40:	39 ca                	cmp    %ecx,%edx
  801c42:	75 0d                	jne    801c51 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c44:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c4c:	8b 40 48             	mov    0x48(%eax),%eax
  801c4f:	eb 0f                	jmp    801c60 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c51:	83 c0 01             	add    $0x1,%eax
  801c54:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c59:	75 d9                	jne    801c34 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c68:	89 d0                	mov    %edx,%eax
  801c6a:	c1 e8 16             	shr    $0x16,%eax
  801c6d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c74:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c79:	f6 c1 01             	test   $0x1,%cl
  801c7c:	74 1d                	je     801c9b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c7e:	c1 ea 0c             	shr    $0xc,%edx
  801c81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c88:	f6 c2 01             	test   $0x1,%dl
  801c8b:	74 0e                	je     801c9b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c8d:	c1 ea 0c             	shr    $0xc,%edx
  801c90:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c97:	ef 
  801c98:	0f b7 c0             	movzwl %ax,%eax
}
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    
  801c9d:	66 90                	xchg   %ax,%ax
  801c9f:	90                   	nop

00801ca0 <__udivdi3>:
  801ca0:	55                   	push   %ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 1c             	sub    $0x1c,%esp
  801ca7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801cab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801caf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801cb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cb7:	85 f6                	test   %esi,%esi
  801cb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cbd:	89 ca                	mov    %ecx,%edx
  801cbf:	89 f8                	mov    %edi,%eax
  801cc1:	75 3d                	jne    801d00 <__udivdi3+0x60>
  801cc3:	39 cf                	cmp    %ecx,%edi
  801cc5:	0f 87 c5 00 00 00    	ja     801d90 <__udivdi3+0xf0>
  801ccb:	85 ff                	test   %edi,%edi
  801ccd:	89 fd                	mov    %edi,%ebp
  801ccf:	75 0b                	jne    801cdc <__udivdi3+0x3c>
  801cd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd6:	31 d2                	xor    %edx,%edx
  801cd8:	f7 f7                	div    %edi
  801cda:	89 c5                	mov    %eax,%ebp
  801cdc:	89 c8                	mov    %ecx,%eax
  801cde:	31 d2                	xor    %edx,%edx
  801ce0:	f7 f5                	div    %ebp
  801ce2:	89 c1                	mov    %eax,%ecx
  801ce4:	89 d8                	mov    %ebx,%eax
  801ce6:	89 cf                	mov    %ecx,%edi
  801ce8:	f7 f5                	div    %ebp
  801cea:	89 c3                	mov    %eax,%ebx
  801cec:	89 d8                	mov    %ebx,%eax
  801cee:	89 fa                	mov    %edi,%edx
  801cf0:	83 c4 1c             	add    $0x1c,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    
  801cf8:	90                   	nop
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	39 ce                	cmp    %ecx,%esi
  801d02:	77 74                	ja     801d78 <__udivdi3+0xd8>
  801d04:	0f bd fe             	bsr    %esi,%edi
  801d07:	83 f7 1f             	xor    $0x1f,%edi
  801d0a:	0f 84 98 00 00 00    	je     801da8 <__udivdi3+0x108>
  801d10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	89 c5                	mov    %eax,%ebp
  801d19:	29 fb                	sub    %edi,%ebx
  801d1b:	d3 e6                	shl    %cl,%esi
  801d1d:	89 d9                	mov    %ebx,%ecx
  801d1f:	d3 ed                	shr    %cl,%ebp
  801d21:	89 f9                	mov    %edi,%ecx
  801d23:	d3 e0                	shl    %cl,%eax
  801d25:	09 ee                	or     %ebp,%esi
  801d27:	89 d9                	mov    %ebx,%ecx
  801d29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d2d:	89 d5                	mov    %edx,%ebp
  801d2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d33:	d3 ed                	shr    %cl,%ebp
  801d35:	89 f9                	mov    %edi,%ecx
  801d37:	d3 e2                	shl    %cl,%edx
  801d39:	89 d9                	mov    %ebx,%ecx
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	09 c2                	or     %eax,%edx
  801d3f:	89 d0                	mov    %edx,%eax
  801d41:	89 ea                	mov    %ebp,%edx
  801d43:	f7 f6                	div    %esi
  801d45:	89 d5                	mov    %edx,%ebp
  801d47:	89 c3                	mov    %eax,%ebx
  801d49:	f7 64 24 0c          	mull   0xc(%esp)
  801d4d:	39 d5                	cmp    %edx,%ebp
  801d4f:	72 10                	jb     801d61 <__udivdi3+0xc1>
  801d51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	d3 e6                	shl    %cl,%esi
  801d59:	39 c6                	cmp    %eax,%esi
  801d5b:	73 07                	jae    801d64 <__udivdi3+0xc4>
  801d5d:	39 d5                	cmp    %edx,%ebp
  801d5f:	75 03                	jne    801d64 <__udivdi3+0xc4>
  801d61:	83 eb 01             	sub    $0x1,%ebx
  801d64:	31 ff                	xor    %edi,%edi
  801d66:	89 d8                	mov    %ebx,%eax
  801d68:	89 fa                	mov    %edi,%edx
  801d6a:	83 c4 1c             	add    $0x1c,%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5f                   	pop    %edi
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    
  801d72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d78:	31 ff                	xor    %edi,%edi
  801d7a:	31 db                	xor    %ebx,%ebx
  801d7c:	89 d8                	mov    %ebx,%eax
  801d7e:	89 fa                	mov    %edi,%edx
  801d80:	83 c4 1c             	add    $0x1c,%esp
  801d83:	5b                   	pop    %ebx
  801d84:	5e                   	pop    %esi
  801d85:	5f                   	pop    %edi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    
  801d88:	90                   	nop
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	89 d8                	mov    %ebx,%eax
  801d92:	f7 f7                	div    %edi
  801d94:	31 ff                	xor    %edi,%edi
  801d96:	89 c3                	mov    %eax,%ebx
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	89 fa                	mov    %edi,%edx
  801d9c:	83 c4 1c             	add    $0x1c,%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5f                   	pop    %edi
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    
  801da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da8:	39 ce                	cmp    %ecx,%esi
  801daa:	72 0c                	jb     801db8 <__udivdi3+0x118>
  801dac:	31 db                	xor    %ebx,%ebx
  801dae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801db2:	0f 87 34 ff ff ff    	ja     801cec <__udivdi3+0x4c>
  801db8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dbd:	e9 2a ff ff ff       	jmp    801cec <__udivdi3+0x4c>
  801dc2:	66 90                	xchg   %ax,%ax
  801dc4:	66 90                	xchg   %ax,%ax
  801dc6:	66 90                	xchg   %ax,%ax
  801dc8:	66 90                	xchg   %ax,%ax
  801dca:	66 90                	xchg   %ax,%ax
  801dcc:	66 90                	xchg   %ax,%ax
  801dce:	66 90                	xchg   %ax,%ax

00801dd0 <__umoddi3>:
  801dd0:	55                   	push   %ebp
  801dd1:	57                   	push   %edi
  801dd2:	56                   	push   %esi
  801dd3:	53                   	push   %ebx
  801dd4:	83 ec 1c             	sub    $0x1c,%esp
  801dd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ddb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ddf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801de3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801de7:	85 d2                	test   %edx,%edx
  801de9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ded:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801df1:	89 f3                	mov    %esi,%ebx
  801df3:	89 3c 24             	mov    %edi,(%esp)
  801df6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dfa:	75 1c                	jne    801e18 <__umoddi3+0x48>
  801dfc:	39 f7                	cmp    %esi,%edi
  801dfe:	76 50                	jbe    801e50 <__umoddi3+0x80>
  801e00:	89 c8                	mov    %ecx,%eax
  801e02:	89 f2                	mov    %esi,%edx
  801e04:	f7 f7                	div    %edi
  801e06:	89 d0                	mov    %edx,%eax
  801e08:	31 d2                	xor    %edx,%edx
  801e0a:	83 c4 1c             	add    $0x1c,%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5e                   	pop    %esi
  801e0f:	5f                   	pop    %edi
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    
  801e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e18:	39 f2                	cmp    %esi,%edx
  801e1a:	89 d0                	mov    %edx,%eax
  801e1c:	77 52                	ja     801e70 <__umoddi3+0xa0>
  801e1e:	0f bd ea             	bsr    %edx,%ebp
  801e21:	83 f5 1f             	xor    $0x1f,%ebp
  801e24:	75 5a                	jne    801e80 <__umoddi3+0xb0>
  801e26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e2a:	0f 82 e0 00 00 00    	jb     801f10 <__umoddi3+0x140>
  801e30:	39 0c 24             	cmp    %ecx,(%esp)
  801e33:	0f 86 d7 00 00 00    	jbe    801f10 <__umoddi3+0x140>
  801e39:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e41:	83 c4 1c             	add    $0x1c,%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5f                   	pop    %edi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    
  801e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e50:	85 ff                	test   %edi,%edi
  801e52:	89 fd                	mov    %edi,%ebp
  801e54:	75 0b                	jne    801e61 <__umoddi3+0x91>
  801e56:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5b:	31 d2                	xor    %edx,%edx
  801e5d:	f7 f7                	div    %edi
  801e5f:	89 c5                	mov    %eax,%ebp
  801e61:	89 f0                	mov    %esi,%eax
  801e63:	31 d2                	xor    %edx,%edx
  801e65:	f7 f5                	div    %ebp
  801e67:	89 c8                	mov    %ecx,%eax
  801e69:	f7 f5                	div    %ebp
  801e6b:	89 d0                	mov    %edx,%eax
  801e6d:	eb 99                	jmp    801e08 <__umoddi3+0x38>
  801e6f:	90                   	nop
  801e70:	89 c8                	mov    %ecx,%eax
  801e72:	89 f2                	mov    %esi,%edx
  801e74:	83 c4 1c             	add    $0x1c,%esp
  801e77:	5b                   	pop    %ebx
  801e78:	5e                   	pop    %esi
  801e79:	5f                   	pop    %edi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    
  801e7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e80:	8b 34 24             	mov    (%esp),%esi
  801e83:	bf 20 00 00 00       	mov    $0x20,%edi
  801e88:	89 e9                	mov    %ebp,%ecx
  801e8a:	29 ef                	sub    %ebp,%edi
  801e8c:	d3 e0                	shl    %cl,%eax
  801e8e:	89 f9                	mov    %edi,%ecx
  801e90:	89 f2                	mov    %esi,%edx
  801e92:	d3 ea                	shr    %cl,%edx
  801e94:	89 e9                	mov    %ebp,%ecx
  801e96:	09 c2                	or     %eax,%edx
  801e98:	89 d8                	mov    %ebx,%eax
  801e9a:	89 14 24             	mov    %edx,(%esp)
  801e9d:	89 f2                	mov    %esi,%edx
  801e9f:	d3 e2                	shl    %cl,%edx
  801ea1:	89 f9                	mov    %edi,%ecx
  801ea3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ea7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801eab:	d3 e8                	shr    %cl,%eax
  801ead:	89 e9                	mov    %ebp,%ecx
  801eaf:	89 c6                	mov    %eax,%esi
  801eb1:	d3 e3                	shl    %cl,%ebx
  801eb3:	89 f9                	mov    %edi,%ecx
  801eb5:	89 d0                	mov    %edx,%eax
  801eb7:	d3 e8                	shr    %cl,%eax
  801eb9:	89 e9                	mov    %ebp,%ecx
  801ebb:	09 d8                	or     %ebx,%eax
  801ebd:	89 d3                	mov    %edx,%ebx
  801ebf:	89 f2                	mov    %esi,%edx
  801ec1:	f7 34 24             	divl   (%esp)
  801ec4:	89 d6                	mov    %edx,%esi
  801ec6:	d3 e3                	shl    %cl,%ebx
  801ec8:	f7 64 24 04          	mull   0x4(%esp)
  801ecc:	39 d6                	cmp    %edx,%esi
  801ece:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ed2:	89 d1                	mov    %edx,%ecx
  801ed4:	89 c3                	mov    %eax,%ebx
  801ed6:	72 08                	jb     801ee0 <__umoddi3+0x110>
  801ed8:	75 11                	jne    801eeb <__umoddi3+0x11b>
  801eda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ede:	73 0b                	jae    801eeb <__umoddi3+0x11b>
  801ee0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ee4:	1b 14 24             	sbb    (%esp),%edx
  801ee7:	89 d1                	mov    %edx,%ecx
  801ee9:	89 c3                	mov    %eax,%ebx
  801eeb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801eef:	29 da                	sub    %ebx,%edx
  801ef1:	19 ce                	sbb    %ecx,%esi
  801ef3:	89 f9                	mov    %edi,%ecx
  801ef5:	89 f0                	mov    %esi,%eax
  801ef7:	d3 e0                	shl    %cl,%eax
  801ef9:	89 e9                	mov    %ebp,%ecx
  801efb:	d3 ea                	shr    %cl,%edx
  801efd:	89 e9                	mov    %ebp,%ecx
  801eff:	d3 ee                	shr    %cl,%esi
  801f01:	09 d0                	or     %edx,%eax
  801f03:	89 f2                	mov    %esi,%edx
  801f05:	83 c4 1c             	add    $0x1c,%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5f                   	pop    %edi
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    
  801f0d:	8d 76 00             	lea    0x0(%esi),%esi
  801f10:	29 f9                	sub    %edi,%ecx
  801f12:	19 d6                	sbb    %edx,%esi
  801f14:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f1c:	e9 18 ff ff ff       	jmp    801e39 <__umoddi3+0x69>
