
obj/user/faultallocbad.debug：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800040:	68 c0 23 80 00       	push   $0x8023c0
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 97 0b 00 00       	call   800bf5 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 e0 23 80 00       	push   $0x8023e0
  80006f:	6a 0f                	push   $0xf
  800071:	68 ca 23 80 00       	push   $0x8023ca
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 0c 24 80 00       	push   $0x80240c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 16 07 00 00       	call   80079f <snprintf>
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
  80009c:	e8 84 0d 00 00       	call   800e25 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 89 0a 00 00       	call   800b39 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 f2 0a 00 00       	call   800bb7 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
        binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

    // exit gracefully
    exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 71 0f 00 00       	call   801077 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 66 0a 00 00       	call   800b76 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 8f 0a 00 00       	call   800bb7 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 38 24 80 00       	push   $0x802438
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 ae 09 00 00       	call   800b39 <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 1a 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 53 09 00 00       	call   800b39 <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 da 1e 00 00       	call   802130 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 c7 1f 00 00       	call   802260 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 5b 24 80 00 	movsbl 0x80245b(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 42 04 00 00    	je     800749 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 d0             	movzbl %al,%edx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 d3 03 00 00    	ja     80072e <vprintfmt+0x443>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800383:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800386:	83 f9 09             	cmp    $0x9,%ecx
  800389:	77 3f                	ja     8003ca <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8b 00                	mov    (%eax),%eax
  800395:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 40 04             	lea    0x4(%eax),%eax
  80039e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a4:	eb 2a                	jmp    8003d0 <vprintfmt+0xe5>
  8003a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	0f 49 d0             	cmovns %eax,%edx
  8003b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b9:	eb 89                	jmp    800344 <vprintfmt+0x59>
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c5:	e9 7a ff ff ff       	jmp    800344 <vprintfmt+0x59>
  8003ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d4:	0f 89 6a ff ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003da:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e7:	e9 58 ff ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ec:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f2:	e9 4d ff ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 78 04             	lea    0x4(%eax),%edi
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	53                   	push   %ebx
  800401:	ff 30                	pushl  (%eax)
  800403:	ff d6                	call   *%esi
			break;
  800405:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040e:	e9 fe fe ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 78 04             	lea    0x4(%eax),%edi
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	99                   	cltd   
  80041c:	31 d0                	xor    %edx,%eax
  80041e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800420:	83 f8 0f             	cmp    $0xf,%eax
  800423:	7f 0b                	jg     800430 <vprintfmt+0x145>
  800425:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  80042c:	85 d2                	test   %edx,%edx
  80042e:	75 1b                	jne    80044b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800430:	50                   	push   %eax
  800431:	68 73 24 80 00       	push   $0x802473
  800436:	53                   	push   %ebx
  800437:	56                   	push   %esi
  800438:	e8 91 fe ff ff       	call   8002ce <printfmt>
  80043d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800446:	e9 c6 fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044b:	52                   	push   %edx
  80044c:	68 5d 28 80 00       	push   $0x80285d
  800451:	53                   	push   %ebx
  800452:	56                   	push   %esi
  800453:	e8 76 fe ff ff       	call   8002ce <printfmt>
  800458:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800461:	e9 ab fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	83 c0 04             	add    $0x4,%eax
  80046c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800474:	85 ff                	test   %edi,%edi
  800476:	b8 6c 24 80 00       	mov    $0x80246c,%eax
  80047b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80047e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800482:	0f 8e 94 00 00 00    	jle    80051c <vprintfmt+0x231>
  800488:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048c:	0f 84 98 00 00 00    	je     80052a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	ff 75 d0             	pushl  -0x30(%ebp)
  800498:	57                   	push   %edi
  800499:	e8 33 03 00 00       	call   8007d1 <strnlen>
  80049e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a1:	29 c1                	sub    %eax,%ecx
  8004a3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	eb 0f                	jmp    8004c6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	53                   	push   %ebx
  8004bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004be:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ef 01             	sub    $0x1,%edi
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 ff                	test   %edi,%edi
  8004c8:	7f ed                	jg     8004b7 <vprintfmt+0x1cc>
  8004ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004cd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d0:	85 c9                	test   %ecx,%ecx
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	0f 49 c1             	cmovns %ecx,%eax
  8004da:	29 c1                	sub    %eax,%ecx
  8004dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e5:	89 cb                	mov    %ecx,%ebx
  8004e7:	eb 4d                	jmp    800536 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ed:	74 1b                	je     80050a <vprintfmt+0x21f>
  8004ef:	0f be c0             	movsbl %al,%eax
  8004f2:	83 e8 20             	sub    $0x20,%eax
  8004f5:	83 f8 5e             	cmp    $0x5e,%eax
  8004f8:	76 10                	jbe    80050a <vprintfmt+0x21f>
					putch('?', putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	6a 3f                	push   $0x3f
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	eb 0d                	jmp    800517 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	52                   	push   %edx
  800511:	ff 55 08             	call   *0x8(%ebp)
  800514:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800517:	83 eb 01             	sub    $0x1,%ebx
  80051a:	eb 1a                	jmp    800536 <vprintfmt+0x24b>
  80051c:	89 75 08             	mov    %esi,0x8(%ebp)
  80051f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800522:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800525:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800528:	eb 0c                	jmp    800536 <vprintfmt+0x24b>
  80052a:	89 75 08             	mov    %esi,0x8(%ebp)
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800530:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800533:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800536:	83 c7 01             	add    $0x1,%edi
  800539:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053d:	0f be d0             	movsbl %al,%edx
  800540:	85 d2                	test   %edx,%edx
  800542:	74 23                	je     800567 <vprintfmt+0x27c>
  800544:	85 f6                	test   %esi,%esi
  800546:	78 a1                	js     8004e9 <vprintfmt+0x1fe>
  800548:	83 ee 01             	sub    $0x1,%esi
  80054b:	79 9c                	jns    8004e9 <vprintfmt+0x1fe>
  80054d:	89 df                	mov    %ebx,%edi
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800555:	eb 18                	jmp    80056f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	53                   	push   %ebx
  80055b:	6a 20                	push   $0x20
  80055d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055f:	83 ef 01             	sub    $0x1,%edi
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	eb 08                	jmp    80056f <vprintfmt+0x284>
  800567:	89 df                	mov    %ebx,%edi
  800569:	8b 75 08             	mov    0x8(%ebp),%esi
  80056c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056f:	85 ff                	test   %edi,%edi
  800571:	7f e4                	jg     800557 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800573:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057c:	e9 90 fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800581:	83 f9 01             	cmp    $0x1,%ecx
  800584:	7e 19                	jle    80059f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 50 04             	mov    0x4(%eax),%edx
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 08             	lea    0x8(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
  80059d:	eb 38                	jmp    8005d7 <vprintfmt+0x2ec>
	else if (lflag)
  80059f:	85 c9                	test   %ecx,%ecx
  8005a1:	74 1b                	je     8005be <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	89 c1                	mov    %eax,%ecx
  8005ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bc:	eb 19                	jmp    8005d7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	89 c1                	mov    %eax,%ecx
  8005c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 40 04             	lea    0x4(%eax),%eax
  8005d4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e6:	0f 89 0e 01 00 00    	jns    8006fa <vprintfmt+0x40f>
				putch('-', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 2d                	push   $0x2d
  8005f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fa:	f7 da                	neg    %edx
  8005fc:	83 d1 00             	adc    $0x0,%ecx
  8005ff:	f7 d9                	neg    %ecx
  800601:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
  800609:	e9 ec 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060e:	83 f9 01             	cmp    $0x1,%ecx
  800611:	7e 18                	jle    80062b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 10                	mov    (%eax),%edx
  800618:	8b 48 04             	mov    0x4(%eax),%ecx
  80061b:	8d 40 08             	lea    0x8(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
  800626:	e9 cf 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062b:	85 c9                	test   %ecx,%ecx
  80062d:	74 1a                	je     800649 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
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
  800644:	e9 b1 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 97 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 58                	push   $0x58
  800669:	ff d6                	call   *%esi
			putch('X', putdat);
  80066b:	83 c4 08             	add    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 58                	push   $0x58
  800671:	ff d6                	call   *%esi
			putch('X', putdat);
  800673:	83 c4 08             	add    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 58                	push   $0x58
  800679:	ff d6                	call   *%esi
			break;
  80067b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800681:	e9 8b fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 30                	push   $0x30
  80068c:	ff d6                	call   *%esi
			putch('x', putdat);
  80068e:	83 c4 08             	add    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 78                	push   $0x78
  800694:	ff d6                	call   *%esi
			num = (unsigned long long)
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8b 10                	mov    (%eax),%edx
  80069b:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a3:	8d 40 04             	lea    0x4(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ae:	eb 4a                	jmp    8006fa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b0:	83 f9 01             	cmp    $0x1,%ecx
  8006b3:	7e 15                	jle    8006ca <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 10                	mov    (%eax),%edx
  8006ba:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bd:	8d 40 08             	lea    0x8(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c8:	eb 30                	jmp    8006fa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ca:	85 c9                	test   %ecx,%ecx
  8006cc:	74 17                	je     8006e5 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d8:	8d 40 04             	lea    0x4(%eax),%eax
  8006db:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006de:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e3:	eb 15                	jmp    8006fa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 10                	mov    (%eax),%edx
  8006ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ef:	8d 40 04             	lea    0x4(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fa:	83 ec 0c             	sub    $0xc,%esp
  8006fd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800701:	57                   	push   %edi
  800702:	ff 75 e0             	pushl  -0x20(%ebp)
  800705:	50                   	push   %eax
  800706:	51                   	push   %ecx
  800707:	52                   	push   %edx
  800708:	89 da                	mov    %ebx,%edx
  80070a:	89 f0                	mov    %esi,%eax
  80070c:	e8 f1 fa ff ff       	call   800202 <printnum>
			break;
  800711:	83 c4 20             	add    $0x20,%esp
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800717:	e9 f5 fb ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	52                   	push   %edx
  800721:	ff d6                	call   *%esi
			break;
  800723:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 e3 fb ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 25                	push   $0x25
  800734:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 03                	jmp    80073e <vprintfmt+0x453>
  80073b:	83 ef 01             	sub    $0x1,%edi
  80073e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800742:	75 f7                	jne    80073b <vprintfmt+0x450>
  800744:	e9 c8 fb ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800749:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074c:	5b                   	pop    %ebx
  80074d:	5e                   	pop    %esi
  80074e:	5f                   	pop    %edi
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 18             	sub    $0x18,%esp
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800760:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800764:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800767:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076e:	85 c0                	test   %eax,%eax
  800770:	74 26                	je     800798 <vsnprintf+0x47>
  800772:	85 d2                	test   %edx,%edx
  800774:	7e 22                	jle    800798 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800776:	ff 75 14             	pushl  0x14(%ebp)
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	68 b1 02 80 00       	push   $0x8002b1
  800785:	e8 61 fb ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 05                	jmp    80079d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800798:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a8:	50                   	push   %eax
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	ff 75 08             	pushl  0x8(%ebp)
  8007b2:	e8 9a ff ff ff       	call   800751 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 03                	jmp    8007c9 <strlen+0x10>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cd:	75 f7                	jne    8007c6 <strlen+0xd>
		n++;
	return n;
}
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	ba 00 00 00 00       	mov    $0x0,%edx
  8007df:	eb 03                	jmp    8007e4 <strnlen+0x13>
		n++;
  8007e1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	39 c2                	cmp    %eax,%edx
  8007e6:	74 08                	je     8007f0 <strnlen+0x1f>
  8007e8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ec:	75 f3                	jne    8007e1 <strnlen+0x10>
  8007ee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c1 01             	add    $0x1,%ecx
  800804:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ef                	jne    8007fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800819:	53                   	push   %ebx
  80081a:	e8 9a ff ff ff       	call   8007b9 <strlen>
  80081f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	01 d8                	add    %ebx,%eax
  800827:	50                   	push   %eax
  800828:	e8 c5 ff ff ff       	call   8007f2 <strcpy>
	return dst;
}
  80082d:	89 d8                	mov    %ebx,%eax
  80082f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	56                   	push   %esi
  800838:	53                   	push   %ebx
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083f:	89 f3                	mov    %esi,%ebx
  800841:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800844:	89 f2                	mov    %esi,%edx
  800846:	eb 0f                	jmp    800857 <strncpy+0x23>
		*dst++ = *src;
  800848:	83 c2 01             	add    $0x1,%edx
  80084b:	0f b6 01             	movzbl (%ecx),%eax
  80084e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800851:	80 39 01             	cmpb   $0x1,(%ecx)
  800854:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	39 da                	cmp    %ebx,%edx
  800859:	75 ed                	jne    800848 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085b:	89 f0                	mov    %esi,%eax
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	56                   	push   %esi
  800865:	53                   	push   %ebx
  800866:	8b 75 08             	mov    0x8(%ebp),%esi
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086c:	8b 55 10             	mov    0x10(%ebp),%edx
  80086f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800871:	85 d2                	test   %edx,%edx
  800873:	74 21                	je     800896 <strlcpy+0x35>
  800875:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800879:	89 f2                	mov    %esi,%edx
  80087b:	eb 09                	jmp    800886 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087d:	83 c2 01             	add    $0x1,%edx
  800880:	83 c1 01             	add    $0x1,%ecx
  800883:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 09                	je     800893 <strlcpy+0x32>
  80088a:	0f b6 19             	movzbl (%ecx),%ebx
  80088d:	84 db                	test   %bl,%bl
  80088f:	75 ec                	jne    80087d <strlcpy+0x1c>
  800891:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800893:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800896:	29 f0                	sub    %esi,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strcmp+0x11>
		p++, q++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 04                	je     8008b8 <strcmp+0x1c>
  8008b4:	3a 02                	cmp    (%edx),%al
  8008b6:	74 ef                	je     8008a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 c0             	movzbl %al,%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d1:	eb 06                	jmp    8008d9 <strncmp+0x17>
		n--, p++, q++;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d9:	39 d8                	cmp    %ebx,%eax
  8008db:	74 15                	je     8008f2 <strncmp+0x30>
  8008dd:	0f b6 08             	movzbl (%eax),%ecx
  8008e0:	84 c9                	test   %cl,%cl
  8008e2:	74 04                	je     8008e8 <strncmp+0x26>
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 eb                	je     8008d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 00             	movzbl (%eax),%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb 05                	jmp    8008f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 07                	jmp    80090d <strchr+0x13>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0f                	je     800919 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 03                	jmp    80092a <strfind+0xf>
  800927:	83 c0 01             	add    $0x1,%eax
  80092a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092d:	38 ca                	cmp    %cl,%dl
  80092f:	74 04                	je     800935 <strfind+0x1a>
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strfind+0xc>
			break;
	return (char *) s;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 36                	je     80097d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800947:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094d:	75 28                	jne    800977 <memset+0x40>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 23                	jne    800977 <memset+0x40>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096b:	89 d8                	mov    %ebx,%eax
  80096d:	09 d0                	or     %edx,%eax
  80096f:	c1 e9 02             	shr    $0x2,%ecx
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 35                	jae    8009cb <memmove+0x47>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2e                	jae    8009cb <memmove+0x47>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	09 fe                	or     %edi,%esi
  8009a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009aa:	75 13                	jne    8009bf <memmove+0x3b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1d                	jmp    8009e8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 0f                	jne    8009e3 <memmove+0x5f>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ef:	ff 75 10             	pushl  0x10(%ebp)
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	ff 75 08             	pushl  0x8(%ebp)
  8009f8:	e8 87 ff ff ff       	call   800984 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0a:	89 c6                	mov    %eax,%esi
  800a0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	eb 1a                	jmp    800a2b <memcmp+0x2c>
		if (*s1 != *s2)
  800a11:	0f b6 08             	movzbl (%eax),%ecx
  800a14:	0f b6 1a             	movzbl (%edx),%ebx
  800a17:	38 d9                	cmp    %bl,%cl
  800a19:	74 0a                	je     800a25 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1b:	0f b6 c1             	movzbl %cl,%eax
  800a1e:	0f b6 db             	movzbl %bl,%ebx
  800a21:	29 d8                	sub    %ebx,%eax
  800a23:	eb 0f                	jmp    800a34 <memcmp+0x35>
		s1++, s2++;
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 f0                	cmp    %esi,%eax
  800a2d:	75 e2                	jne    800a11 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3f:	89 c1                	mov    %eax,%ecx
  800a41:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a44:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a48:	eb 0a                	jmp    800a54 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4a:	0f b6 10             	movzbl (%eax),%edx
  800a4d:	39 da                	cmp    %ebx,%edx
  800a4f:	74 07                	je     800a58 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	39 c8                	cmp    %ecx,%eax
  800a56:	72 f2                	jb     800a4a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a58:	5b                   	pop    %ebx
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a67:	eb 03                	jmp    800a6c <strtol+0x11>
		s++;
  800a69:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6c:	0f b6 01             	movzbl (%ecx),%eax
  800a6f:	3c 20                	cmp    $0x20,%al
  800a71:	74 f6                	je     800a69 <strtol+0xe>
  800a73:	3c 09                	cmp    $0x9,%al
  800a75:	74 f2                	je     800a69 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a77:	3c 2b                	cmp    $0x2b,%al
  800a79:	75 0a                	jne    800a85 <strtol+0x2a>
		s++;
  800a7b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a83:	eb 11                	jmp    800a96 <strtol+0x3b>
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8a:	3c 2d                	cmp    $0x2d,%al
  800a8c:	75 08                	jne    800a96 <strtol+0x3b>
		s++, neg = 1;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9c:	75 15                	jne    800ab3 <strtol+0x58>
  800a9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa1:	75 10                	jne    800ab3 <strtol+0x58>
  800aa3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa7:	75 7c                	jne    800b25 <strtol+0xca>
		s += 2, base = 16;
  800aa9:	83 c1 02             	add    $0x2,%ecx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb 16                	jmp    800ac9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	75 12                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abc:	80 39 30             	cmpb   $0x30,(%ecx)
  800abf:	75 08                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad1:	0f b6 11             	movzbl (%ecx),%edx
  800ad4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x8b>
			dig = *s - '0';
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 30             	sub    $0x30,%edx
  800ae4:	eb 22                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 08                	ja     800af8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 57             	sub    $0x57,%edx
  800af6:	eb 10                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 16                	ja     800b18 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b08:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0b:	7d 0b                	jge    800b18 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b14:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b16:	eb b9                	jmp    800ad1 <strtol+0x76>

	if (endptr)
  800b18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1c:	74 0d                	je     800b2b <strtol+0xd0>
		*endptr = (char *) s;
  800b1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b21:	89 0e                	mov    %ecx,(%esi)
  800b23:	eb 06                	jmp    800b2b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b25:	85 db                	test   %ebx,%ebx
  800b27:	74 98                	je     800ac1 <strtol+0x66>
  800b29:	eb 9e                	jmp    800ac9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	f7 da                	neg    %edx
  800b2f:	85 ff                	test   %edi,%edi
  800b31:	0f 45 c2             	cmovne %edx,%eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b47:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4a:	89 c3                	mov    %eax,%ebx
  800b4c:	89 c7                	mov    %eax,%edi
  800b4e:	89 c6                	mov    %eax,%esi
  800b50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 01 00 00 00       	mov    $0x1,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b84:	b8 03 00 00 00       	mov    $0x3,%eax
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	89 cb                	mov    %ecx,%ebx
  800b8e:	89 cf                	mov    %ecx,%edi
  800b90:	89 ce                	mov    %ecx,%esi
  800b92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7e 17                	jle    800baf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 03                	push   $0x3
  800b9e:	68 5f 27 80 00       	push   $0x80275f
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 7c 27 80 00       	push   $0x80277c
  800baa:	e8 66 f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_yield>:

void
sys_yield(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	be 00 00 00 00       	mov    $0x0,%esi
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c11:	89 f7                	mov    %esi,%edi
  800c13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 17                	jle    800c30 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 04                	push   $0x4
  800c1f:	68 5f 27 80 00       	push   $0x80275f
  800c24:	6a 23                	push   $0x23
  800c26:	68 7c 27 80 00       	push   $0x80277c
  800c2b:	e8 e5 f4 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	b8 05 00 00 00       	mov    $0x5,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c52:	8b 75 18             	mov    0x18(%ebp),%esi
  800c55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 05                	push   $0x5
  800c61:	68 5f 27 80 00       	push   $0x80275f
  800c66:	6a 23                	push   $0x23
  800c68:	68 7c 27 80 00       	push   $0x80277c
  800c6d:	e8 a3 f4 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 06                	push   $0x6
  800ca3:	68 5f 27 80 00       	push   $0x80275f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 7c 27 80 00       	push   $0x80277c
  800caf:	e8 61 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cca:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 df                	mov    %ebx,%edi
  800cd7:	89 de                	mov    %ebx,%esi
  800cd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 08                	push   $0x8
  800ce5:	68 5f 27 80 00       	push   $0x80275f
  800cea:	6a 23                	push   $0x23
  800cec:	68 7c 27 80 00       	push   $0x80277c
  800cf1:	e8 1f f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 09                	push   $0x9
  800d27:	68 5f 27 80 00       	push   $0x80275f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 7c 27 80 00       	push   $0x80277c
  800d33:	e8 dd f3 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 0a                	push   $0xa
  800d69:	68 5f 27 80 00       	push   $0x80275f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 7c 27 80 00       	push   $0x80277c
  800d75:	e8 9b f3 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	be 00 00 00 00       	mov    $0x0,%esi
  800d8d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 cb                	mov    %ecx,%ebx
  800dbd:	89 cf                	mov    %ecx,%edi
  800dbf:	89 ce                	mov    %ecx,%esi
  800dc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 17                	jle    800dde <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	50                   	push   %eax
  800dcb:	6a 0d                	push   $0xd
  800dcd:	68 5f 27 80 00       	push   $0x80275f
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 7c 27 80 00       	push   $0x80277c
  800dd9:	e8 37 f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	ba 00 00 00 00       	mov    $0x0,%edx
  800df1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df6:	89 d1                	mov    %edx,%ecx
  800df8:	89 d3                	mov    %edx,%ebx
  800dfa:	89 d7                	mov    %edx,%edi
  800dfc:	89 d6                	mov    %edx,%esi
  800dfe:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e10:	b8 10 00 00 00       	mov    $0x10,%eax
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	89 cb                	mov    %ecx,%ebx
  800e1a:	89 cf                	mov    %ecx,%edi
  800e1c:	89 ce                	mov    %ecx,%esi
  800e1e:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e2b:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e32:	75 4a                	jne    800e7e <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  800e34:	a1 08 40 80 00       	mov    0x804008,%eax
  800e39:	8b 40 48             	mov    0x48(%eax),%eax
  800e3c:	83 ec 04             	sub    $0x4,%esp
  800e3f:	6a 07                	push   $0x7
  800e41:	68 00 f0 bf ee       	push   $0xeebff000
  800e46:	50                   	push   %eax
  800e47:	e8 a9 fd ff ff       	call   800bf5 <sys_page_alloc>
  800e4c:	83 c4 10             	add    $0x10,%esp
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	79 12                	jns    800e65 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  800e53:	50                   	push   %eax
  800e54:	68 8a 27 80 00       	push   $0x80278a
  800e59:	6a 21                	push   $0x21
  800e5b:	68 a2 27 80 00       	push   $0x8027a2
  800e60:	e8 b0 f2 ff ff       	call   800115 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800e65:	a1 08 40 80 00       	mov    0x804008,%eax
  800e6a:	8b 40 48             	mov    0x48(%eax),%eax
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	68 88 0e 80 00       	push   $0x800e88
  800e75:	50                   	push   %eax
  800e76:	e8 c5 fe ff ff       	call   800d40 <sys_env_set_pgfault_upcall>
  800e7b:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e81:	a3 0c 40 80 00       	mov    %eax,0x80400c
  800e86:	c9                   	leave  
  800e87:	c3                   	ret    

00800e88 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e88:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e89:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e8e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e90:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  800e93:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  800e96:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  800e9a:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  800e9f:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  800ea3:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800ea5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  800ea6:	83 c4 04             	add    $0x4,%esp
	popfl
  800ea9:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800eaa:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  800eab:	c3                   	ret    

00800eac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	05 00 00 00 30       	add    $0x30000000,%eax
  800eb7:	c1 e8 0c             	shr    $0xc,%eax
}
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ec7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ecc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	c1 ea 16             	shr    $0x16,%edx
  800ee3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eea:	f6 c2 01             	test   $0x1,%dl
  800eed:	74 11                	je     800f00 <fd_alloc+0x2d>
  800eef:	89 c2                	mov    %eax,%edx
  800ef1:	c1 ea 0c             	shr    $0xc,%edx
  800ef4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efb:	f6 c2 01             	test   $0x1,%dl
  800efe:	75 09                	jne    800f09 <fd_alloc+0x36>
			*fd_store = fd;
  800f00:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
  800f07:	eb 17                	jmp    800f20 <fd_alloc+0x4d>
  800f09:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f0e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f13:	75 c9                	jne    800ede <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f15:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f1b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f28:	83 f8 1f             	cmp    $0x1f,%eax
  800f2b:	77 36                	ja     800f63 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f2d:	c1 e0 0c             	shl    $0xc,%eax
  800f30:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f35:	89 c2                	mov    %eax,%edx
  800f37:	c1 ea 16             	shr    $0x16,%edx
  800f3a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f41:	f6 c2 01             	test   $0x1,%dl
  800f44:	74 24                	je     800f6a <fd_lookup+0x48>
  800f46:	89 c2                	mov    %eax,%edx
  800f48:	c1 ea 0c             	shr    $0xc,%edx
  800f4b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f52:	f6 c2 01             	test   $0x1,%dl
  800f55:	74 1a                	je     800f71 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5a:	89 02                	mov    %eax,(%edx)
	return 0;
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f61:	eb 13                	jmp    800f76 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f68:	eb 0c                	jmp    800f76 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f6f:	eb 05                	jmp    800f76 <fd_lookup+0x54>
  800f71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f81:	ba 30 28 80 00       	mov    $0x802830,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f86:	eb 13                	jmp    800f9b <dev_lookup+0x23>
  800f88:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f8b:	39 08                	cmp    %ecx,(%eax)
  800f8d:	75 0c                	jne    800f9b <dev_lookup+0x23>
			*dev = devtab[i];
  800f8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f92:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f94:	b8 00 00 00 00       	mov    $0x0,%eax
  800f99:	eb 2e                	jmp    800fc9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f9b:	8b 02                	mov    (%edx),%eax
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	75 e7                	jne    800f88 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fa1:	a1 08 40 80 00       	mov    0x804008,%eax
  800fa6:	8b 40 48             	mov    0x48(%eax),%eax
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	51                   	push   %ecx
  800fad:	50                   	push   %eax
  800fae:	68 b0 27 80 00       	push   $0x8027b0
  800fb3:	e8 36 f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    

00800fcb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 10             	sub    $0x10,%esp
  800fd3:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdc:	50                   	push   %eax
  800fdd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fe3:	c1 e8 0c             	shr    $0xc,%eax
  800fe6:	50                   	push   %eax
  800fe7:	e8 36 ff ff ff       	call   800f22 <fd_lookup>
  800fec:	83 c4 08             	add    $0x8,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 05                	js     800ff8 <fd_close+0x2d>
	    || fd != fd2)
  800ff3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ff6:	74 0c                	je     801004 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ff8:	84 db                	test   %bl,%bl
  800ffa:	ba 00 00 00 00       	mov    $0x0,%edx
  800fff:	0f 44 c2             	cmove  %edx,%eax
  801002:	eb 41                	jmp    801045 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801004:	83 ec 08             	sub    $0x8,%esp
  801007:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80100a:	50                   	push   %eax
  80100b:	ff 36                	pushl  (%esi)
  80100d:	e8 66 ff ff ff       	call   800f78 <dev_lookup>
  801012:	89 c3                	mov    %eax,%ebx
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	78 1a                	js     801035 <fd_close+0x6a>
		if (dev->dev_close)
  80101b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80101e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801021:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801026:	85 c0                	test   %eax,%eax
  801028:	74 0b                	je     801035 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	56                   	push   %esi
  80102e:	ff d0                	call   *%eax
  801030:	89 c3                	mov    %eax,%ebx
  801032:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801035:	83 ec 08             	sub    $0x8,%esp
  801038:	56                   	push   %esi
  801039:	6a 00                	push   $0x0
  80103b:	e8 3a fc ff ff       	call   800c7a <sys_page_unmap>
	return r;
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	89 d8                	mov    %ebx,%eax
}
  801045:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801052:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801055:	50                   	push   %eax
  801056:	ff 75 08             	pushl  0x8(%ebp)
  801059:	e8 c4 fe ff ff       	call   800f22 <fd_lookup>
  80105e:	83 c4 08             	add    $0x8,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	78 10                	js     801075 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	6a 01                	push   $0x1
  80106a:	ff 75 f4             	pushl  -0xc(%ebp)
  80106d:	e8 59 ff ff ff       	call   800fcb <fd_close>
  801072:	83 c4 10             	add    $0x10,%esp
}
  801075:	c9                   	leave  
  801076:	c3                   	ret    

00801077 <close_all>:

void
close_all(void)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	53                   	push   %ebx
  80107b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80107e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	53                   	push   %ebx
  801087:	e8 c0 ff ff ff       	call   80104c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80108c:	83 c3 01             	add    $0x1,%ebx
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	83 fb 20             	cmp    $0x20,%ebx
  801095:	75 ec                	jne    801083 <close_all+0xc>
		close(i);
}
  801097:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	57                   	push   %edi
  8010a0:	56                   	push   %esi
  8010a1:	53                   	push   %ebx
  8010a2:	83 ec 2c             	sub    $0x2c,%esp
  8010a5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ab:	50                   	push   %eax
  8010ac:	ff 75 08             	pushl  0x8(%ebp)
  8010af:	e8 6e fe ff ff       	call   800f22 <fd_lookup>
  8010b4:	83 c4 08             	add    $0x8,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	0f 88 c1 00 00 00    	js     801180 <dup+0xe4>
		return r;
	close(newfdnum);
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	56                   	push   %esi
  8010c3:	e8 84 ff ff ff       	call   80104c <close>

	newfd = INDEX2FD(newfdnum);
  8010c8:	89 f3                	mov    %esi,%ebx
  8010ca:	c1 e3 0c             	shl    $0xc,%ebx
  8010cd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010d3:	83 c4 04             	add    $0x4,%esp
  8010d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d9:	e8 de fd ff ff       	call   800ebc <fd2data>
  8010de:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010e0:	89 1c 24             	mov    %ebx,(%esp)
  8010e3:	e8 d4 fd ff ff       	call   800ebc <fd2data>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ee:	89 f8                	mov    %edi,%eax
  8010f0:	c1 e8 16             	shr    $0x16,%eax
  8010f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fa:	a8 01                	test   $0x1,%al
  8010fc:	74 37                	je     801135 <dup+0x99>
  8010fe:	89 f8                	mov    %edi,%eax
  801100:	c1 e8 0c             	shr    $0xc,%eax
  801103:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80110a:	f6 c2 01             	test   $0x1,%dl
  80110d:	74 26                	je     801135 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80110f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	25 07 0e 00 00       	and    $0xe07,%eax
  80111e:	50                   	push   %eax
  80111f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801122:	6a 00                	push   $0x0
  801124:	57                   	push   %edi
  801125:	6a 00                	push   $0x0
  801127:	e8 0c fb ff ff       	call   800c38 <sys_page_map>
  80112c:	89 c7                	mov    %eax,%edi
  80112e:	83 c4 20             	add    $0x20,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 2e                	js     801163 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801135:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801138:	89 d0                	mov    %edx,%eax
  80113a:	c1 e8 0c             	shr    $0xc,%eax
  80113d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	25 07 0e 00 00       	and    $0xe07,%eax
  80114c:	50                   	push   %eax
  80114d:	53                   	push   %ebx
  80114e:	6a 00                	push   $0x0
  801150:	52                   	push   %edx
  801151:	6a 00                	push   $0x0
  801153:	e8 e0 fa ff ff       	call   800c38 <sys_page_map>
  801158:	89 c7                	mov    %eax,%edi
  80115a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80115d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80115f:	85 ff                	test   %edi,%edi
  801161:	79 1d                	jns    801180 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801163:	83 ec 08             	sub    $0x8,%esp
  801166:	53                   	push   %ebx
  801167:	6a 00                	push   $0x0
  801169:	e8 0c fb ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80116e:	83 c4 08             	add    $0x8,%esp
  801171:	ff 75 d4             	pushl  -0x2c(%ebp)
  801174:	6a 00                	push   $0x0
  801176:	e8 ff fa ff ff       	call   800c7a <sys_page_unmap>
	return r;
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	89 f8                	mov    %edi,%eax
}
  801180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	53                   	push   %ebx
  80118c:	83 ec 14             	sub    $0x14,%esp
  80118f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801192:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	53                   	push   %ebx
  801197:	e8 86 fd ff ff       	call   800f22 <fd_lookup>
  80119c:	83 c4 08             	add    $0x8,%esp
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	78 6d                	js     801212 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011af:	ff 30                	pushl  (%eax)
  8011b1:	e8 c2 fd ff ff       	call   800f78 <dev_lookup>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 4c                	js     801209 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011c0:	8b 42 08             	mov    0x8(%edx),%eax
  8011c3:	83 e0 03             	and    $0x3,%eax
  8011c6:	83 f8 01             	cmp    $0x1,%eax
  8011c9:	75 21                	jne    8011ec <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cb:	a1 08 40 80 00       	mov    0x804008,%eax
  8011d0:	8b 40 48             	mov    0x48(%eax),%eax
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	53                   	push   %ebx
  8011d7:	50                   	push   %eax
  8011d8:	68 f4 27 80 00       	push   $0x8027f4
  8011dd:	e8 0c f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ea:	eb 26                	jmp    801212 <read+0x8a>
	}
	if (!dev->dev_read)
  8011ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ef:	8b 40 08             	mov    0x8(%eax),%eax
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	74 17                	je     80120d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f6:	83 ec 04             	sub    $0x4,%esp
  8011f9:	ff 75 10             	pushl  0x10(%ebp)
  8011fc:	ff 75 0c             	pushl  0xc(%ebp)
  8011ff:	52                   	push   %edx
  801200:	ff d0                	call   *%eax
  801202:	89 c2                	mov    %eax,%edx
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	eb 09                	jmp    801212 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801209:	89 c2                	mov    %eax,%edx
  80120b:	eb 05                	jmp    801212 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80120d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801212:	89 d0                	mov    %edx,%eax
  801214:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801217:	c9                   	leave  
  801218:	c3                   	ret    

00801219 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	8b 7d 08             	mov    0x8(%ebp),%edi
  801225:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122d:	eb 21                	jmp    801250 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80122f:	83 ec 04             	sub    $0x4,%esp
  801232:	89 f0                	mov    %esi,%eax
  801234:	29 d8                	sub    %ebx,%eax
  801236:	50                   	push   %eax
  801237:	89 d8                	mov    %ebx,%eax
  801239:	03 45 0c             	add    0xc(%ebp),%eax
  80123c:	50                   	push   %eax
  80123d:	57                   	push   %edi
  80123e:	e8 45 ff ff ff       	call   801188 <read>
		if (m < 0)
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	78 10                	js     80125a <readn+0x41>
			return m;
		if (m == 0)
  80124a:	85 c0                	test   %eax,%eax
  80124c:	74 0a                	je     801258 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80124e:	01 c3                	add    %eax,%ebx
  801250:	39 f3                	cmp    %esi,%ebx
  801252:	72 db                	jb     80122f <readn+0x16>
  801254:	89 d8                	mov    %ebx,%eax
  801256:	eb 02                	jmp    80125a <readn+0x41>
  801258:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80125a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	53                   	push   %ebx
  801266:	83 ec 14             	sub    $0x14,%esp
  801269:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	53                   	push   %ebx
  801271:	e8 ac fc ff ff       	call   800f22 <fd_lookup>
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	89 c2                	mov    %eax,%edx
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 68                	js     8012e7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	ff 30                	pushl  (%eax)
  80128b:	e8 e8 fc ff ff       	call   800f78 <dev_lookup>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 47                	js     8012de <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80129e:	75 21                	jne    8012c1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8012a5:	8b 40 48             	mov    0x48(%eax),%eax
  8012a8:	83 ec 04             	sub    $0x4,%esp
  8012ab:	53                   	push   %ebx
  8012ac:	50                   	push   %eax
  8012ad:	68 10 28 80 00       	push   $0x802810
  8012b2:	e8 37 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012bf:	eb 26                	jmp    8012e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8012c7:	85 d2                	test   %edx,%edx
  8012c9:	74 17                	je     8012e2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012cb:	83 ec 04             	sub    $0x4,%esp
  8012ce:	ff 75 10             	pushl  0x10(%ebp)
  8012d1:	ff 75 0c             	pushl  0xc(%ebp)
  8012d4:	50                   	push   %eax
  8012d5:	ff d2                	call   *%edx
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	eb 09                	jmp    8012e7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	eb 05                	jmp    8012e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012e7:	89 d0                	mov    %edx,%eax
  8012e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    

008012ee <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	ff 75 08             	pushl  0x8(%ebp)
  8012fb:	e8 22 fc ff ff       	call   800f22 <fd_lookup>
  801300:	83 c4 08             	add    $0x8,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 0e                	js     801315 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801307:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80130a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801310:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801315:	c9                   	leave  
  801316:	c3                   	ret    

00801317 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	53                   	push   %ebx
  80131b:	83 ec 14             	sub    $0x14,%esp
  80131e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801321:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801324:	50                   	push   %eax
  801325:	53                   	push   %ebx
  801326:	e8 f7 fb ff ff       	call   800f22 <fd_lookup>
  80132b:	83 c4 08             	add    $0x8,%esp
  80132e:	89 c2                	mov    %eax,%edx
  801330:	85 c0                	test   %eax,%eax
  801332:	78 65                	js     801399 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133e:	ff 30                	pushl  (%eax)
  801340:	e8 33 fc ff ff       	call   800f78 <dev_lookup>
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 44                	js     801390 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80134c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801353:	75 21                	jne    801376 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801355:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80135a:	8b 40 48             	mov    0x48(%eax),%eax
  80135d:	83 ec 04             	sub    $0x4,%esp
  801360:	53                   	push   %ebx
  801361:	50                   	push   %eax
  801362:	68 d0 27 80 00       	push   $0x8027d0
  801367:	e8 82 ee ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801374:	eb 23                	jmp    801399 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801376:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801379:	8b 52 18             	mov    0x18(%edx),%edx
  80137c:	85 d2                	test   %edx,%edx
  80137e:	74 14                	je     801394 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	ff 75 0c             	pushl  0xc(%ebp)
  801386:	50                   	push   %eax
  801387:	ff d2                	call   *%edx
  801389:	89 c2                	mov    %eax,%edx
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	eb 09                	jmp    801399 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801390:	89 c2                	mov    %eax,%edx
  801392:	eb 05                	jmp    801399 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801394:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801399:	89 d0                	mov    %edx,%eax
  80139b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139e:	c9                   	leave  
  80139f:	c3                   	ret    

008013a0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 14             	sub    $0x14,%esp
  8013a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	ff 75 08             	pushl  0x8(%ebp)
  8013b1:	e8 6c fb ff ff       	call   800f22 <fd_lookup>
  8013b6:	83 c4 08             	add    $0x8,%esp
  8013b9:	89 c2                	mov    %eax,%edx
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 58                	js     801417 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c5:	50                   	push   %eax
  8013c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c9:	ff 30                	pushl  (%eax)
  8013cb:	e8 a8 fb ff ff       	call   800f78 <dev_lookup>
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 37                	js     80140e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013da:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013de:	74 32                	je     801412 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ea:	00 00 00 
	stat->st_isdir = 0;
  8013ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f4:	00 00 00 
	stat->st_dev = dev;
  8013f7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013fd:	83 ec 08             	sub    $0x8,%esp
  801400:	53                   	push   %ebx
  801401:	ff 75 f0             	pushl  -0x10(%ebp)
  801404:	ff 50 14             	call   *0x14(%eax)
  801407:	89 c2                	mov    %eax,%edx
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	eb 09                	jmp    801417 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140e:	89 c2                	mov    %eax,%edx
  801410:	eb 05                	jmp    801417 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801412:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801417:	89 d0                	mov    %edx,%eax
  801419:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	56                   	push   %esi
  801422:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	6a 00                	push   $0x0
  801428:	ff 75 08             	pushl  0x8(%ebp)
  80142b:	e8 e3 01 00 00       	call   801613 <open>
  801430:	89 c3                	mov    %eax,%ebx
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 1b                	js     801454 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801439:	83 ec 08             	sub    $0x8,%esp
  80143c:	ff 75 0c             	pushl  0xc(%ebp)
  80143f:	50                   	push   %eax
  801440:	e8 5b ff ff ff       	call   8013a0 <fstat>
  801445:	89 c6                	mov    %eax,%esi
	close(fd);
  801447:	89 1c 24             	mov    %ebx,(%esp)
  80144a:	e8 fd fb ff ff       	call   80104c <close>
	return r;
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	89 f0                	mov    %esi,%eax
}
  801454:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    

0080145b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
  801460:	89 c6                	mov    %eax,%esi
  801462:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801464:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80146b:	75 12                	jne    80147f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80146d:	83 ec 0c             	sub    $0xc,%esp
  801470:	6a 01                	push   $0x1
  801472:	e8 43 0c 00 00       	call   8020ba <ipc_find_env>
  801477:	a3 00 40 80 00       	mov    %eax,0x804000
  80147c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80147f:	6a 07                	push   $0x7
  801481:	68 00 50 80 00       	push   $0x805000
  801486:	56                   	push   %esi
  801487:	ff 35 00 40 80 00    	pushl  0x804000
  80148d:	e8 d4 0b 00 00       	call   802066 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801492:	83 c4 0c             	add    $0xc,%esp
  801495:	6a 00                	push   $0x0
  801497:	53                   	push   %ebx
  801498:	6a 00                	push   $0x0
  80149a:	e8 5e 0b 00 00       	call   801ffd <ipc_recv>
}
  80149f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a2:	5b                   	pop    %ebx
  8014a3:	5e                   	pop    %esi
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    

008014a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8014af:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c9:	e8 8d ff ff ff       	call   80145b <fsipc>
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8014eb:	e8 6b ff ff ff       	call   80145b <fsipc>
}
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 04             	sub    $0x4,%esp
  8014f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801502:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801507:	ba 00 00 00 00       	mov    $0x0,%edx
  80150c:	b8 05 00 00 00       	mov    $0x5,%eax
  801511:	e8 45 ff ff ff       	call   80145b <fsipc>
  801516:	85 c0                	test   %eax,%eax
  801518:	78 2c                	js     801546 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	68 00 50 80 00       	push   $0x805000
  801522:	53                   	push   %ebx
  801523:	e8 ca f2 ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801528:	a1 80 50 80 00       	mov    0x805080,%eax
  80152d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801533:	a1 84 50 80 00       	mov    0x805084,%eax
  801538:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	8b 45 10             	mov    0x10(%ebp),%eax
  801554:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801559:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80155e:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801561:	8b 55 08             	mov    0x8(%ebp),%edx
  801564:	8b 52 0c             	mov    0xc(%edx),%edx
  801567:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80156d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801572:	50                   	push   %eax
  801573:	ff 75 0c             	pushl  0xc(%ebp)
  801576:	68 08 50 80 00       	push   $0x805008
  80157b:	e8 04 f4 ff ff       	call   800984 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801580:	ba 00 00 00 00       	mov    $0x0,%edx
  801585:	b8 04 00 00 00       	mov    $0x4,%eax
  80158a:	e8 cc fe ff ff       	call   80145b <fsipc>
	//panic("devfile_write not implemented");
}
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801599:	8b 45 08             	mov    0x8(%ebp),%eax
  80159c:	8b 40 0c             	mov    0xc(%eax),%eax
  80159f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015a4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8015af:	b8 03 00 00 00       	mov    $0x3,%eax
  8015b4:	e8 a2 fe ff ff       	call   80145b <fsipc>
  8015b9:	89 c3                	mov    %eax,%ebx
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 4b                	js     80160a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015bf:	39 c6                	cmp    %eax,%esi
  8015c1:	73 16                	jae    8015d9 <devfile_read+0x48>
  8015c3:	68 44 28 80 00       	push   $0x802844
  8015c8:	68 4b 28 80 00       	push   $0x80284b
  8015cd:	6a 7c                	push   $0x7c
  8015cf:	68 60 28 80 00       	push   $0x802860
  8015d4:	e8 3c eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  8015d9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015de:	7e 16                	jle    8015f6 <devfile_read+0x65>
  8015e0:	68 6b 28 80 00       	push   $0x80286b
  8015e5:	68 4b 28 80 00       	push   $0x80284b
  8015ea:	6a 7d                	push   $0x7d
  8015ec:	68 60 28 80 00       	push   $0x802860
  8015f1:	e8 1f eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015f6:	83 ec 04             	sub    $0x4,%esp
  8015f9:	50                   	push   %eax
  8015fa:	68 00 50 80 00       	push   $0x805000
  8015ff:	ff 75 0c             	pushl  0xc(%ebp)
  801602:	e8 7d f3 ff ff       	call   800984 <memmove>
	return r;
  801607:	83 c4 10             	add    $0x10,%esp
}
  80160a:	89 d8                	mov    %ebx,%eax
  80160c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	53                   	push   %ebx
  801617:	83 ec 20             	sub    $0x20,%esp
  80161a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80161d:	53                   	push   %ebx
  80161e:	e8 96 f1 ff ff       	call   8007b9 <strlen>
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80162b:	7f 67                	jg     801694 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80162d:	83 ec 0c             	sub    $0xc,%esp
  801630:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801633:	50                   	push   %eax
  801634:	e8 9a f8 ff ff       	call   800ed3 <fd_alloc>
  801639:	83 c4 10             	add    $0x10,%esp
		return r;
  80163c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 57                	js     801699 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	53                   	push   %ebx
  801646:	68 00 50 80 00       	push   $0x805000
  80164b:	e8 a2 f1 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801650:	8b 45 0c             	mov    0xc(%ebp),%eax
  801653:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801658:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165b:	b8 01 00 00 00       	mov    $0x1,%eax
  801660:	e8 f6 fd ff ff       	call   80145b <fsipc>
  801665:	89 c3                	mov    %eax,%ebx
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	85 c0                	test   %eax,%eax
  80166c:	79 14                	jns    801682 <open+0x6f>
		fd_close(fd, 0);
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	6a 00                	push   $0x0
  801673:	ff 75 f4             	pushl  -0xc(%ebp)
  801676:	e8 50 f9 ff ff       	call   800fcb <fd_close>
		return r;
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	89 da                	mov    %ebx,%edx
  801680:	eb 17                	jmp    801699 <open+0x86>
	}

	return fd2num(fd);
  801682:	83 ec 0c             	sub    $0xc,%esp
  801685:	ff 75 f4             	pushl  -0xc(%ebp)
  801688:	e8 1f f8 ff ff       	call   800eac <fd2num>
  80168d:	89 c2                	mov    %eax,%edx
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	eb 05                	jmp    801699 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801694:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801699:	89 d0                	mov    %edx,%eax
  80169b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169e:	c9                   	leave  
  80169f:	c3                   	ret    

008016a0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8016b0:	e8 a6 fd ff ff       	call   80145b <fsipc>
}
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016bd:	68 77 28 80 00       	push   $0x802877
  8016c2:	ff 75 0c             	pushl  0xc(%ebp)
  8016c5:	e8 28 f1 ff ff       	call   8007f2 <strcpy>
	return 0;
}
  8016ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	53                   	push   %ebx
  8016d5:	83 ec 10             	sub    $0x10,%esp
  8016d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016db:	53                   	push   %ebx
  8016dc:	e8 12 0a 00 00       	call   8020f3 <pageref>
  8016e1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8016e4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8016e9:	83 f8 01             	cmp    $0x1,%eax
  8016ec:	75 10                	jne    8016fe <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8016ee:	83 ec 0c             	sub    $0xc,%esp
  8016f1:	ff 73 0c             	pushl  0xc(%ebx)
  8016f4:	e8 c0 02 00 00       	call   8019b9 <nsipc_close>
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8016fe:	89 d0                	mov    %edx,%eax
  801700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80170b:	6a 00                	push   $0x0
  80170d:	ff 75 10             	pushl  0x10(%ebp)
  801710:	ff 75 0c             	pushl  0xc(%ebp)
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	ff 70 0c             	pushl  0xc(%eax)
  801719:	e8 78 03 00 00       	call   801a96 <nsipc_send>
}
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801726:	6a 00                	push   $0x0
  801728:	ff 75 10             	pushl  0x10(%ebp)
  80172b:	ff 75 0c             	pushl  0xc(%ebp)
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
  801731:	ff 70 0c             	pushl  0xc(%eax)
  801734:	e8 f1 02 00 00       	call   801a2a <nsipc_recv>
}
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801741:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801744:	52                   	push   %edx
  801745:	50                   	push   %eax
  801746:	e8 d7 f7 ff ff       	call   800f22 <fd_lookup>
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	85 c0                	test   %eax,%eax
  801750:	78 17                	js     801769 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801752:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801755:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80175b:	39 08                	cmp    %ecx,(%eax)
  80175d:	75 05                	jne    801764 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80175f:	8b 40 0c             	mov    0xc(%eax),%eax
  801762:	eb 05                	jmp    801769 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801764:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801769:	c9                   	leave  
  80176a:	c3                   	ret    

0080176b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	56                   	push   %esi
  80176f:	53                   	push   %ebx
  801770:	83 ec 1c             	sub    $0x1c,%esp
  801773:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801775:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801778:	50                   	push   %eax
  801779:	e8 55 f7 ff ff       	call   800ed3 <fd_alloc>
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	78 1b                	js     8017a2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801787:	83 ec 04             	sub    $0x4,%esp
  80178a:	68 07 04 00 00       	push   $0x407
  80178f:	ff 75 f4             	pushl  -0xc(%ebp)
  801792:	6a 00                	push   $0x0
  801794:	e8 5c f4 ff ff       	call   800bf5 <sys_page_alloc>
  801799:	89 c3                	mov    %eax,%ebx
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	79 10                	jns    8017b2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	56                   	push   %esi
  8017a6:	e8 0e 02 00 00       	call   8019b9 <nsipc_close>
		return r;
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	89 d8                	mov    %ebx,%eax
  8017b0:	eb 24                	jmp    8017d6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8017b2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017bb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8017c7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017ca:	83 ec 0c             	sub    $0xc,%esp
  8017cd:	50                   	push   %eax
  8017ce:	e8 d9 f6 ff ff       	call   800eac <fd2num>
  8017d3:	83 c4 10             	add    $0x10,%esp
}
  8017d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d9:	5b                   	pop    %ebx
  8017da:	5e                   	pop    %esi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e6:	e8 50 ff ff ff       	call   80173b <fd2sockid>
		return r;
  8017eb:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 1f                	js     801810 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017f1:	83 ec 04             	sub    $0x4,%esp
  8017f4:	ff 75 10             	pushl  0x10(%ebp)
  8017f7:	ff 75 0c             	pushl  0xc(%ebp)
  8017fa:	50                   	push   %eax
  8017fb:	e8 12 01 00 00       	call   801912 <nsipc_accept>
  801800:	83 c4 10             	add    $0x10,%esp
		return r;
  801803:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801805:	85 c0                	test   %eax,%eax
  801807:	78 07                	js     801810 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801809:	e8 5d ff ff ff       	call   80176b <alloc_sockfd>
  80180e:	89 c1                	mov    %eax,%ecx
}
  801810:	89 c8                	mov    %ecx,%eax
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80181a:	8b 45 08             	mov    0x8(%ebp),%eax
  80181d:	e8 19 ff ff ff       	call   80173b <fd2sockid>
  801822:	85 c0                	test   %eax,%eax
  801824:	78 12                	js     801838 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801826:	83 ec 04             	sub    $0x4,%esp
  801829:	ff 75 10             	pushl  0x10(%ebp)
  80182c:	ff 75 0c             	pushl  0xc(%ebp)
  80182f:	50                   	push   %eax
  801830:	e8 2d 01 00 00       	call   801962 <nsipc_bind>
  801835:	83 c4 10             	add    $0x10,%esp
}
  801838:	c9                   	leave  
  801839:	c3                   	ret    

0080183a <shutdown>:

int
shutdown(int s, int how)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	e8 f3 fe ff ff       	call   80173b <fd2sockid>
  801848:	85 c0                	test   %eax,%eax
  80184a:	78 0f                	js     80185b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	ff 75 0c             	pushl  0xc(%ebp)
  801852:	50                   	push   %eax
  801853:	e8 3f 01 00 00       	call   801997 <nsipc_shutdown>
  801858:	83 c4 10             	add    $0x10,%esp
}
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	e8 d0 fe ff ff       	call   80173b <fd2sockid>
  80186b:	85 c0                	test   %eax,%eax
  80186d:	78 12                	js     801881 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	ff 75 10             	pushl  0x10(%ebp)
  801875:	ff 75 0c             	pushl  0xc(%ebp)
  801878:	50                   	push   %eax
  801879:	e8 55 01 00 00       	call   8019d3 <nsipc_connect>
  80187e:	83 c4 10             	add    $0x10,%esp
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <listen>:

int
listen(int s, int backlog)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	e8 aa fe ff ff       	call   80173b <fd2sockid>
  801891:	85 c0                	test   %eax,%eax
  801893:	78 0f                	js     8018a4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801895:	83 ec 08             	sub    $0x8,%esp
  801898:	ff 75 0c             	pushl  0xc(%ebp)
  80189b:	50                   	push   %eax
  80189c:	e8 67 01 00 00       	call   801a08 <nsipc_listen>
  8018a1:	83 c4 10             	add    $0x10,%esp
}
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018ac:	ff 75 10             	pushl  0x10(%ebp)
  8018af:	ff 75 0c             	pushl  0xc(%ebp)
  8018b2:	ff 75 08             	pushl  0x8(%ebp)
  8018b5:	e8 3a 02 00 00       	call   801af4 <nsipc_socket>
  8018ba:	83 c4 10             	add    $0x10,%esp
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	78 05                	js     8018c6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8018c1:	e8 a5 fe ff ff       	call   80176b <alloc_sockfd>
}
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	53                   	push   %ebx
  8018cc:	83 ec 04             	sub    $0x4,%esp
  8018cf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018d1:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018d8:	75 12                	jne    8018ec <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018da:	83 ec 0c             	sub    $0xc,%esp
  8018dd:	6a 02                	push   $0x2
  8018df:	e8 d6 07 00 00       	call   8020ba <ipc_find_env>
  8018e4:	a3 04 40 80 00       	mov    %eax,0x804004
  8018e9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018ec:	6a 07                	push   $0x7
  8018ee:	68 00 60 80 00       	push   $0x806000
  8018f3:	53                   	push   %ebx
  8018f4:	ff 35 04 40 80 00    	pushl  0x804004
  8018fa:	e8 67 07 00 00       	call   802066 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018ff:	83 c4 0c             	add    $0xc,%esp
  801902:	6a 00                	push   $0x0
  801904:	6a 00                	push   $0x0
  801906:	6a 00                	push   $0x0
  801908:	e8 f0 06 00 00       	call   801ffd <ipc_recv>
}
  80190d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801910:	c9                   	leave  
  801911:	c3                   	ret    

00801912 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801922:	8b 06                	mov    (%esi),%eax
  801924:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801929:	b8 01 00 00 00       	mov    $0x1,%eax
  80192e:	e8 95 ff ff ff       	call   8018c8 <nsipc>
  801933:	89 c3                	mov    %eax,%ebx
  801935:	85 c0                	test   %eax,%eax
  801937:	78 20                	js     801959 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801939:	83 ec 04             	sub    $0x4,%esp
  80193c:	ff 35 10 60 80 00    	pushl  0x806010
  801942:	68 00 60 80 00       	push   $0x806000
  801947:	ff 75 0c             	pushl  0xc(%ebp)
  80194a:	e8 35 f0 ff ff       	call   800984 <memmove>
		*addrlen = ret->ret_addrlen;
  80194f:	a1 10 60 80 00       	mov    0x806010,%eax
  801954:	89 06                	mov    %eax,(%esi)
  801956:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801959:	89 d8                	mov    %ebx,%eax
  80195b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5e                   	pop    %esi
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	53                   	push   %ebx
  801966:	83 ec 08             	sub    $0x8,%esp
  801969:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801974:	53                   	push   %ebx
  801975:	ff 75 0c             	pushl  0xc(%ebp)
  801978:	68 04 60 80 00       	push   $0x806004
  80197d:	e8 02 f0 ff ff       	call   800984 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801982:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801988:	b8 02 00 00 00       	mov    $0x2,%eax
  80198d:	e8 36 ff ff ff       	call   8018c8 <nsipc>
}
  801992:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801995:	c9                   	leave  
  801996:	c3                   	ret    

00801997 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b2:	e8 11 ff ff ff       	call   8018c8 <nsipc>
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <nsipc_close>:

int
nsipc_close(int s)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8019cc:	e8 f7 fe ff ff       	call   8018c8 <nsipc>
}
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    

008019d3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	53                   	push   %ebx
  8019d7:	83 ec 08             	sub    $0x8,%esp
  8019da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019e5:	53                   	push   %ebx
  8019e6:	ff 75 0c             	pushl  0xc(%ebp)
  8019e9:	68 04 60 80 00       	push   $0x806004
  8019ee:	e8 91 ef ff ff       	call   800984 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019f3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8019f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8019fe:	e8 c5 fe ff ff       	call   8018c8 <nsipc>
}
  801a03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a11:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a19:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a1e:	b8 06 00 00 00       	mov    $0x6,%eax
  801a23:	e8 a0 fe ff ff       	call   8018c8 <nsipc>
}
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	56                   	push   %esi
  801a2e:	53                   	push   %ebx
  801a2f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a32:	8b 45 08             	mov    0x8(%ebp),%eax
  801a35:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a3a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a40:	8b 45 14             	mov    0x14(%ebp),%eax
  801a43:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a48:	b8 07 00 00 00       	mov    $0x7,%eax
  801a4d:	e8 76 fe ff ff       	call   8018c8 <nsipc>
  801a52:	89 c3                	mov    %eax,%ebx
  801a54:	85 c0                	test   %eax,%eax
  801a56:	78 35                	js     801a8d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a58:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a5d:	7f 04                	jg     801a63 <nsipc_recv+0x39>
  801a5f:	39 c6                	cmp    %eax,%esi
  801a61:	7d 16                	jge    801a79 <nsipc_recv+0x4f>
  801a63:	68 83 28 80 00       	push   $0x802883
  801a68:	68 4b 28 80 00       	push   $0x80284b
  801a6d:	6a 62                	push   $0x62
  801a6f:	68 98 28 80 00       	push   $0x802898
  801a74:	e8 9c e6 ff ff       	call   800115 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a79:	83 ec 04             	sub    $0x4,%esp
  801a7c:	50                   	push   %eax
  801a7d:	68 00 60 80 00       	push   $0x806000
  801a82:	ff 75 0c             	pushl  0xc(%ebp)
  801a85:	e8 fa ee ff ff       	call   800984 <memmove>
  801a8a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a8d:	89 d8                	mov    %ebx,%eax
  801a8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5d                   	pop    %ebp
  801a95:	c3                   	ret    

00801a96 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	53                   	push   %ebx
  801a9a:	83 ec 04             	sub    $0x4,%esp
  801a9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801aa8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801aae:	7e 16                	jle    801ac6 <nsipc_send+0x30>
  801ab0:	68 a4 28 80 00       	push   $0x8028a4
  801ab5:	68 4b 28 80 00       	push   $0x80284b
  801aba:	6a 6d                	push   $0x6d
  801abc:	68 98 28 80 00       	push   $0x802898
  801ac1:	e8 4f e6 ff ff       	call   800115 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ac6:	83 ec 04             	sub    $0x4,%esp
  801ac9:	53                   	push   %ebx
  801aca:	ff 75 0c             	pushl  0xc(%ebp)
  801acd:	68 0c 60 80 00       	push   $0x80600c
  801ad2:	e8 ad ee ff ff       	call   800984 <memmove>
	nsipcbuf.send.req_size = size;
  801ad7:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801add:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ae5:	b8 08 00 00 00       	mov    $0x8,%eax
  801aea:	e8 d9 fd ff ff       	call   8018c8 <nsipc>
}
  801aef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af2:	c9                   	leave  
  801af3:	c3                   	ret    

00801af4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801afa:	8b 45 08             	mov    0x8(%ebp),%eax
  801afd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b05:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b0a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b0d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b12:	b8 09 00 00 00       	mov    $0x9,%eax
  801b17:	e8 ac fd ff ff       	call   8018c8 <nsipc>
}
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    

00801b1e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	56                   	push   %esi
  801b22:	53                   	push   %ebx
  801b23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b26:	83 ec 0c             	sub    $0xc,%esp
  801b29:	ff 75 08             	pushl  0x8(%ebp)
  801b2c:	e8 8b f3 ff ff       	call   800ebc <fd2data>
  801b31:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b33:	83 c4 08             	add    $0x8,%esp
  801b36:	68 b0 28 80 00       	push   $0x8028b0
  801b3b:	53                   	push   %ebx
  801b3c:	e8 b1 ec ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b41:	8b 46 04             	mov    0x4(%esi),%eax
  801b44:	2b 06                	sub    (%esi),%eax
  801b46:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b4c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b53:	00 00 00 
	stat->st_dev = &devpipe;
  801b56:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b5d:	30 80 00 
	return 0;
}
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
  801b65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b68:	5b                   	pop    %ebx
  801b69:	5e                   	pop    %esi
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	53                   	push   %ebx
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b76:	53                   	push   %ebx
  801b77:	6a 00                	push   $0x0
  801b79:	e8 fc f0 ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b7e:	89 1c 24             	mov    %ebx,(%esp)
  801b81:	e8 36 f3 ff ff       	call   800ebc <fd2data>
  801b86:	83 c4 08             	add    $0x8,%esp
  801b89:	50                   	push   %eax
  801b8a:	6a 00                	push   $0x0
  801b8c:	e8 e9 f0 ff ff       	call   800c7a <sys_page_unmap>
}
  801b91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	57                   	push   %edi
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 1c             	sub    $0x1c,%esp
  801b9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ba2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ba4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ba9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bac:	83 ec 0c             	sub    $0xc,%esp
  801baf:	ff 75 e0             	pushl  -0x20(%ebp)
  801bb2:	e8 3c 05 00 00       	call   8020f3 <pageref>
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	89 3c 24             	mov    %edi,(%esp)
  801bbc:	e8 32 05 00 00       	call   8020f3 <pageref>
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	39 c3                	cmp    %eax,%ebx
  801bc6:	0f 94 c1             	sete   %cl
  801bc9:	0f b6 c9             	movzbl %cl,%ecx
  801bcc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bcf:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801bd5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bd8:	39 ce                	cmp    %ecx,%esi
  801bda:	74 1b                	je     801bf7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bdc:	39 c3                	cmp    %eax,%ebx
  801bde:	75 c4                	jne    801ba4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801be0:	8b 42 58             	mov    0x58(%edx),%eax
  801be3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801be6:	50                   	push   %eax
  801be7:	56                   	push   %esi
  801be8:	68 b7 28 80 00       	push   $0x8028b7
  801bed:	e8 fc e5 ff ff       	call   8001ee <cprintf>
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	eb ad                	jmp    801ba4 <_pipeisclosed+0xe>
	}
}
  801bf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	57                   	push   %edi
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	83 ec 28             	sub    $0x28,%esp
  801c0b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c0e:	56                   	push   %esi
  801c0f:	e8 a8 f2 ff ff       	call   800ebc <fd2data>
  801c14:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	bf 00 00 00 00       	mov    $0x0,%edi
  801c1e:	eb 4b                	jmp    801c6b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c20:	89 da                	mov    %ebx,%edx
  801c22:	89 f0                	mov    %esi,%eax
  801c24:	e8 6d ff ff ff       	call   801b96 <_pipeisclosed>
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	75 48                	jne    801c75 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c2d:	e8 a4 ef ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c32:	8b 43 04             	mov    0x4(%ebx),%eax
  801c35:	8b 0b                	mov    (%ebx),%ecx
  801c37:	8d 51 20             	lea    0x20(%ecx),%edx
  801c3a:	39 d0                	cmp    %edx,%eax
  801c3c:	73 e2                	jae    801c20 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c41:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c45:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c48:	89 c2                	mov    %eax,%edx
  801c4a:	c1 fa 1f             	sar    $0x1f,%edx
  801c4d:	89 d1                	mov    %edx,%ecx
  801c4f:	c1 e9 1b             	shr    $0x1b,%ecx
  801c52:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c55:	83 e2 1f             	and    $0x1f,%edx
  801c58:	29 ca                	sub    %ecx,%edx
  801c5a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c5e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c62:	83 c0 01             	add    $0x1,%eax
  801c65:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c68:	83 c7 01             	add    $0x1,%edi
  801c6b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c6e:	75 c2                	jne    801c32 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c70:	8b 45 10             	mov    0x10(%ebp),%eax
  801c73:	eb 05                	jmp    801c7a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c75:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 18             	sub    $0x18,%esp
  801c8b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c8e:	57                   	push   %edi
  801c8f:	e8 28 f2 ff ff       	call   800ebc <fd2data>
  801c94:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c9e:	eb 3d                	jmp    801cdd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ca0:	85 db                	test   %ebx,%ebx
  801ca2:	74 04                	je     801ca8 <devpipe_read+0x26>
				return i;
  801ca4:	89 d8                	mov    %ebx,%eax
  801ca6:	eb 44                	jmp    801cec <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ca8:	89 f2                	mov    %esi,%edx
  801caa:	89 f8                	mov    %edi,%eax
  801cac:	e8 e5 fe ff ff       	call   801b96 <_pipeisclosed>
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	75 32                	jne    801ce7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cb5:	e8 1c ef ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cba:	8b 06                	mov    (%esi),%eax
  801cbc:	3b 46 04             	cmp    0x4(%esi),%eax
  801cbf:	74 df                	je     801ca0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cc1:	99                   	cltd   
  801cc2:	c1 ea 1b             	shr    $0x1b,%edx
  801cc5:	01 d0                	add    %edx,%eax
  801cc7:	83 e0 1f             	and    $0x1f,%eax
  801cca:	29 d0                	sub    %edx,%eax
  801ccc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cd7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cda:	83 c3 01             	add    $0x1,%ebx
  801cdd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ce0:	75 d8                	jne    801cba <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ce2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce5:	eb 05                	jmp    801cec <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ce7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	5f                   	pop    %edi
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    

00801cf4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	56                   	push   %esi
  801cf8:	53                   	push   %ebx
  801cf9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cff:	50                   	push   %eax
  801d00:	e8 ce f1 ff ff       	call   800ed3 <fd_alloc>
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	89 c2                	mov    %eax,%edx
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	0f 88 2c 01 00 00    	js     801e3e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d12:	83 ec 04             	sub    $0x4,%esp
  801d15:	68 07 04 00 00       	push   $0x407
  801d1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1d:	6a 00                	push   $0x0
  801d1f:	e8 d1 ee ff ff       	call   800bf5 <sys_page_alloc>
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	89 c2                	mov    %eax,%edx
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	0f 88 0d 01 00 00    	js     801e3e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d31:	83 ec 0c             	sub    $0xc,%esp
  801d34:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d37:	50                   	push   %eax
  801d38:	e8 96 f1 ff ff       	call   800ed3 <fd_alloc>
  801d3d:	89 c3                	mov    %eax,%ebx
  801d3f:	83 c4 10             	add    $0x10,%esp
  801d42:	85 c0                	test   %eax,%eax
  801d44:	0f 88 e2 00 00 00    	js     801e2c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4a:	83 ec 04             	sub    $0x4,%esp
  801d4d:	68 07 04 00 00       	push   $0x407
  801d52:	ff 75 f0             	pushl  -0x10(%ebp)
  801d55:	6a 00                	push   $0x0
  801d57:	e8 99 ee ff ff       	call   800bf5 <sys_page_alloc>
  801d5c:	89 c3                	mov    %eax,%ebx
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	85 c0                	test   %eax,%eax
  801d63:	0f 88 c3 00 00 00    	js     801e2c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d69:	83 ec 0c             	sub    $0xc,%esp
  801d6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6f:	e8 48 f1 ff ff       	call   800ebc <fd2data>
  801d74:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d76:	83 c4 0c             	add    $0xc,%esp
  801d79:	68 07 04 00 00       	push   $0x407
  801d7e:	50                   	push   %eax
  801d7f:	6a 00                	push   $0x0
  801d81:	e8 6f ee ff ff       	call   800bf5 <sys_page_alloc>
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	0f 88 89 00 00 00    	js     801e1c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d93:	83 ec 0c             	sub    $0xc,%esp
  801d96:	ff 75 f0             	pushl  -0x10(%ebp)
  801d99:	e8 1e f1 ff ff       	call   800ebc <fd2data>
  801d9e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801da5:	50                   	push   %eax
  801da6:	6a 00                	push   $0x0
  801da8:	56                   	push   %esi
  801da9:	6a 00                	push   $0x0
  801dab:	e8 88 ee ff ff       	call   800c38 <sys_page_map>
  801db0:	89 c3                	mov    %eax,%ebx
  801db2:	83 c4 20             	add    $0x20,%esp
  801db5:	85 c0                	test   %eax,%eax
  801db7:	78 55                	js     801e0e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801db9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ddc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	ff 75 f4             	pushl  -0xc(%ebp)
  801de9:	e8 be f0 ff ff       	call   800eac <fd2num>
  801dee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801df1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801df3:	83 c4 04             	add    $0x4,%esp
  801df6:	ff 75 f0             	pushl  -0x10(%ebp)
  801df9:	e8 ae f0 ff ff       	call   800eac <fd2num>
  801dfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e01:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	ba 00 00 00 00       	mov    $0x0,%edx
  801e0c:	eb 30                	jmp    801e3e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e0e:	83 ec 08             	sub    $0x8,%esp
  801e11:	56                   	push   %esi
  801e12:	6a 00                	push   $0x0
  801e14:	e8 61 ee ff ff       	call   800c7a <sys_page_unmap>
  801e19:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e1c:	83 ec 08             	sub    $0x8,%esp
  801e1f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e22:	6a 00                	push   $0x0
  801e24:	e8 51 ee ff ff       	call   800c7a <sys_page_unmap>
  801e29:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e2c:	83 ec 08             	sub    $0x8,%esp
  801e2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e32:	6a 00                	push   $0x0
  801e34:	e8 41 ee ff ff       	call   800c7a <sys_page_unmap>
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e3e:	89 d0                	mov    %edx,%eax
  801e40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e43:	5b                   	pop    %ebx
  801e44:	5e                   	pop    %esi
  801e45:	5d                   	pop    %ebp
  801e46:	c3                   	ret    

00801e47 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e50:	50                   	push   %eax
  801e51:	ff 75 08             	pushl  0x8(%ebp)
  801e54:	e8 c9 f0 ff ff       	call   800f22 <fd_lookup>
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	78 18                	js     801e78 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e60:	83 ec 0c             	sub    $0xc,%esp
  801e63:	ff 75 f4             	pushl  -0xc(%ebp)
  801e66:	e8 51 f0 ff ff       	call   800ebc <fd2data>
	return _pipeisclosed(fd, p);
  801e6b:	89 c2                	mov    %eax,%edx
  801e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e70:	e8 21 fd ff ff       	call   801b96 <_pipeisclosed>
  801e75:	83 c4 10             	add    $0x10,%esp
}
  801e78:	c9                   	leave  
  801e79:	c3                   	ret    

00801e7a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e82:	5d                   	pop    %ebp
  801e83:	c3                   	ret    

00801e84 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e8a:	68 cf 28 80 00       	push   $0x8028cf
  801e8f:	ff 75 0c             	pushl  0xc(%ebp)
  801e92:	e8 5b e9 ff ff       	call   8007f2 <strcpy>
	return 0;
}
  801e97:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9c:	c9                   	leave  
  801e9d:	c3                   	ret    

00801e9e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	57                   	push   %edi
  801ea2:	56                   	push   %esi
  801ea3:	53                   	push   %ebx
  801ea4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eaa:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eaf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb5:	eb 2d                	jmp    801ee4 <devcons_write+0x46>
		m = n - tot;
  801eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eba:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ebc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ebf:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ec4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ec7:	83 ec 04             	sub    $0x4,%esp
  801eca:	53                   	push   %ebx
  801ecb:	03 45 0c             	add    0xc(%ebp),%eax
  801ece:	50                   	push   %eax
  801ecf:	57                   	push   %edi
  801ed0:	e8 af ea ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  801ed5:	83 c4 08             	add    $0x8,%esp
  801ed8:	53                   	push   %ebx
  801ed9:	57                   	push   %edi
  801eda:	e8 5a ec ff ff       	call   800b39 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801edf:	01 de                	add    %ebx,%esi
  801ee1:	83 c4 10             	add    $0x10,%esp
  801ee4:	89 f0                	mov    %esi,%eax
  801ee6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ee9:	72 cc                	jb     801eb7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801eeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eee:	5b                   	pop    %ebx
  801eef:	5e                   	pop    %esi
  801ef0:	5f                   	pop    %edi
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    

00801ef3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801efe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f02:	74 2a                	je     801f2e <devcons_read+0x3b>
  801f04:	eb 05                	jmp    801f0b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f06:	e8 cb ec ff ff       	call   800bd6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f0b:	e8 47 ec ff ff       	call   800b57 <sys_cgetc>
  801f10:	85 c0                	test   %eax,%eax
  801f12:	74 f2                	je     801f06 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f14:	85 c0                	test   %eax,%eax
  801f16:	78 16                	js     801f2e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f18:	83 f8 04             	cmp    $0x4,%eax
  801f1b:	74 0c                	je     801f29 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f20:	88 02                	mov    %al,(%edx)
	return 1;
  801f22:	b8 01 00 00 00       	mov    $0x1,%eax
  801f27:	eb 05                	jmp    801f2e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f29:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f2e:	c9                   	leave  
  801f2f:	c3                   	ret    

00801f30 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f36:	8b 45 08             	mov    0x8(%ebp),%eax
  801f39:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f3c:	6a 01                	push   $0x1
  801f3e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f41:	50                   	push   %eax
  801f42:	e8 f2 eb ff ff       	call   800b39 <sys_cputs>
}
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	c9                   	leave  
  801f4b:	c3                   	ret    

00801f4c <getchar>:

int
getchar(void)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f52:	6a 01                	push   $0x1
  801f54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f57:	50                   	push   %eax
  801f58:	6a 00                	push   $0x0
  801f5a:	e8 29 f2 ff ff       	call   801188 <read>
	if (r < 0)
  801f5f:	83 c4 10             	add    $0x10,%esp
  801f62:	85 c0                	test   %eax,%eax
  801f64:	78 0f                	js     801f75 <getchar+0x29>
		return r;
	if (r < 1)
  801f66:	85 c0                	test   %eax,%eax
  801f68:	7e 06                	jle    801f70 <getchar+0x24>
		return -E_EOF;
	return c;
  801f6a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f6e:	eb 05                	jmp    801f75 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f70:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f75:	c9                   	leave  
  801f76:	c3                   	ret    

00801f77 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f80:	50                   	push   %eax
  801f81:	ff 75 08             	pushl  0x8(%ebp)
  801f84:	e8 99 ef ff ff       	call   800f22 <fd_lookup>
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	78 11                	js     801fa1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f93:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f99:	39 10                	cmp    %edx,(%eax)
  801f9b:	0f 94 c0             	sete   %al
  801f9e:	0f b6 c0             	movzbl %al,%eax
}
  801fa1:	c9                   	leave  
  801fa2:	c3                   	ret    

00801fa3 <opencons>:

int
opencons(void)
{
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fac:	50                   	push   %eax
  801fad:	e8 21 ef ff ff       	call   800ed3 <fd_alloc>
  801fb2:	83 c4 10             	add    $0x10,%esp
		return r;
  801fb5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	78 3e                	js     801ff9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fbb:	83 ec 04             	sub    $0x4,%esp
  801fbe:	68 07 04 00 00       	push   $0x407
  801fc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc6:	6a 00                	push   $0x0
  801fc8:	e8 28 ec ff ff       	call   800bf5 <sys_page_alloc>
  801fcd:	83 c4 10             	add    $0x10,%esp
		return r;
  801fd0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	78 23                	js     801ff9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fd6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801feb:	83 ec 0c             	sub    $0xc,%esp
  801fee:	50                   	push   %eax
  801fef:	e8 b8 ee ff ff       	call   800eac <fd2num>
  801ff4:	89 c2                	mov    %eax,%edx
  801ff6:	83 c4 10             	add    $0x10,%esp
}
  801ff9:	89 d0                	mov    %edx,%eax
  801ffb:	c9                   	leave  
  801ffc:	c3                   	ret    

00801ffd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	56                   	push   %esi
  802001:	53                   	push   %ebx
  802002:	8b 75 08             	mov    0x8(%ebp),%esi
  802005:	8b 45 0c             	mov    0xc(%ebp),%eax
  802008:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  80200b:	85 c0                	test   %eax,%eax
  80200d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802012:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  802015:	83 ec 0c             	sub    $0xc,%esp
  802018:	50                   	push   %eax
  802019:	e8 87 ed ff ff       	call   800da5 <sys_ipc_recv>
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	85 c0                	test   %eax,%eax
  802023:	79 16                	jns    80203b <ipc_recv+0x3e>
        if (from_env_store != NULL)
  802025:	85 f6                	test   %esi,%esi
  802027:	74 06                	je     80202f <ipc_recv+0x32>
            *from_env_store = 0;
  802029:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  80202f:	85 db                	test   %ebx,%ebx
  802031:	74 2c                	je     80205f <ipc_recv+0x62>
            *perm_store = 0;
  802033:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802039:	eb 24                	jmp    80205f <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  80203b:	85 f6                	test   %esi,%esi
  80203d:	74 0a                	je     802049 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  80203f:	a1 08 40 80 00       	mov    0x804008,%eax
  802044:	8b 40 74             	mov    0x74(%eax),%eax
  802047:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  802049:	85 db                	test   %ebx,%ebx
  80204b:	74 0a                	je     802057 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  80204d:	a1 08 40 80 00       	mov    0x804008,%eax
  802052:	8b 40 78             	mov    0x78(%eax),%eax
  802055:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  802057:	a1 08 40 80 00       	mov    0x804008,%eax
  80205c:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  80205f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802062:	5b                   	pop    %ebx
  802063:	5e                   	pop    %esi
  802064:	5d                   	pop    %ebp
  802065:	c3                   	ret    

00802066 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802066:	55                   	push   %ebp
  802067:	89 e5                	mov    %esp,%ebp
  802069:	57                   	push   %edi
  80206a:	56                   	push   %esi
  80206b:	53                   	push   %ebx
  80206c:	83 ec 0c             	sub    $0xc,%esp
  80206f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802072:	8b 75 0c             	mov    0xc(%ebp),%esi
  802075:	8b 45 10             	mov    0x10(%ebp),%eax
  802078:	85 c0                	test   %eax,%eax
  80207a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80207f:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802082:	eb 1c                	jmp    8020a0 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  802084:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802087:	74 12                	je     80209b <ipc_send+0x35>
  802089:	50                   	push   %eax
  80208a:	68 db 28 80 00       	push   $0x8028db
  80208f:	6a 3b                	push   $0x3b
  802091:	68 f1 28 80 00       	push   $0x8028f1
  802096:	e8 7a e0 ff ff       	call   800115 <_panic>
		sys_yield();
  80209b:	e8 36 eb ff ff       	call   800bd6 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8020a0:	ff 75 14             	pushl  0x14(%ebp)
  8020a3:	53                   	push   %ebx
  8020a4:	56                   	push   %esi
  8020a5:	57                   	push   %edi
  8020a6:	e8 d7 ec ff ff       	call   800d82 <sys_ipc_try_send>
  8020ab:	83 c4 10             	add    $0x10,%esp
  8020ae:	85 c0                	test   %eax,%eax
  8020b0:	78 d2                	js     802084 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8020b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b5:	5b                   	pop    %ebx
  8020b6:	5e                   	pop    %esi
  8020b7:	5f                   	pop    %edi
  8020b8:	5d                   	pop    %ebp
  8020b9:	c3                   	ret    

008020ba <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020c0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020c5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020c8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020ce:	8b 52 50             	mov    0x50(%edx),%edx
  8020d1:	39 ca                	cmp    %ecx,%edx
  8020d3:	75 0d                	jne    8020e2 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020dd:	8b 40 48             	mov    0x48(%eax),%eax
  8020e0:	eb 0f                	jmp    8020f1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020e2:	83 c0 01             	add    $0x1,%eax
  8020e5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020ea:	75 d9                	jne    8020c5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020f1:	5d                   	pop    %ebp
  8020f2:	c3                   	ret    

008020f3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f9:	89 d0                	mov    %edx,%eax
  8020fb:	c1 e8 16             	shr    $0x16,%eax
  8020fe:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802105:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80210a:	f6 c1 01             	test   $0x1,%cl
  80210d:	74 1d                	je     80212c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80210f:	c1 ea 0c             	shr    $0xc,%edx
  802112:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802119:	f6 c2 01             	test   $0x1,%dl
  80211c:	74 0e                	je     80212c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80211e:	c1 ea 0c             	shr    $0xc,%edx
  802121:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802128:	ef 
  802129:	0f b7 c0             	movzwl %ax,%eax
}
  80212c:	5d                   	pop    %ebp
  80212d:	c3                   	ret    
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__udivdi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	83 ec 1c             	sub    $0x1c,%esp
  802137:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80213b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80213f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802147:	85 f6                	test   %esi,%esi
  802149:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80214d:	89 ca                	mov    %ecx,%edx
  80214f:	89 f8                	mov    %edi,%eax
  802151:	75 3d                	jne    802190 <__udivdi3+0x60>
  802153:	39 cf                	cmp    %ecx,%edi
  802155:	0f 87 c5 00 00 00    	ja     802220 <__udivdi3+0xf0>
  80215b:	85 ff                	test   %edi,%edi
  80215d:	89 fd                	mov    %edi,%ebp
  80215f:	75 0b                	jne    80216c <__udivdi3+0x3c>
  802161:	b8 01 00 00 00       	mov    $0x1,%eax
  802166:	31 d2                	xor    %edx,%edx
  802168:	f7 f7                	div    %edi
  80216a:	89 c5                	mov    %eax,%ebp
  80216c:	89 c8                	mov    %ecx,%eax
  80216e:	31 d2                	xor    %edx,%edx
  802170:	f7 f5                	div    %ebp
  802172:	89 c1                	mov    %eax,%ecx
  802174:	89 d8                	mov    %ebx,%eax
  802176:	89 cf                	mov    %ecx,%edi
  802178:	f7 f5                	div    %ebp
  80217a:	89 c3                	mov    %eax,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	39 ce                	cmp    %ecx,%esi
  802192:	77 74                	ja     802208 <__udivdi3+0xd8>
  802194:	0f bd fe             	bsr    %esi,%edi
  802197:	83 f7 1f             	xor    $0x1f,%edi
  80219a:	0f 84 98 00 00 00    	je     802238 <__udivdi3+0x108>
  8021a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	89 c5                	mov    %eax,%ebp
  8021a9:	29 fb                	sub    %edi,%ebx
  8021ab:	d3 e6                	shl    %cl,%esi
  8021ad:	89 d9                	mov    %ebx,%ecx
  8021af:	d3 ed                	shr    %cl,%ebp
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	d3 e0                	shl    %cl,%eax
  8021b5:	09 ee                	or     %ebp,%esi
  8021b7:	89 d9                	mov    %ebx,%ecx
  8021b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021bd:	89 d5                	mov    %edx,%ebp
  8021bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021c3:	d3 ed                	shr    %cl,%ebp
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e2                	shl    %cl,%edx
  8021c9:	89 d9                	mov    %ebx,%ecx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	09 c2                	or     %eax,%edx
  8021cf:	89 d0                	mov    %edx,%eax
  8021d1:	89 ea                	mov    %ebp,%edx
  8021d3:	f7 f6                	div    %esi
  8021d5:	89 d5                	mov    %edx,%ebp
  8021d7:	89 c3                	mov    %eax,%ebx
  8021d9:	f7 64 24 0c          	mull   0xc(%esp)
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	72 10                	jb     8021f1 <__udivdi3+0xc1>
  8021e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	d3 e6                	shl    %cl,%esi
  8021e9:	39 c6                	cmp    %eax,%esi
  8021eb:	73 07                	jae    8021f4 <__udivdi3+0xc4>
  8021ed:	39 d5                	cmp    %edx,%ebp
  8021ef:	75 03                	jne    8021f4 <__udivdi3+0xc4>
  8021f1:	83 eb 01             	sub    $0x1,%ebx
  8021f4:	31 ff                	xor    %edi,%edi
  8021f6:	89 d8                	mov    %ebx,%eax
  8021f8:	89 fa                	mov    %edi,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	31 ff                	xor    %edi,%edi
  80220a:	31 db                	xor    %ebx,%ebx
  80220c:	89 d8                	mov    %ebx,%eax
  80220e:	89 fa                	mov    %edi,%edx
  802210:	83 c4 1c             	add    $0x1c,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    
  802218:	90                   	nop
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 d8                	mov    %ebx,%eax
  802222:	f7 f7                	div    %edi
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 c3                	mov    %eax,%ebx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 fa                	mov    %edi,%edx
  80222c:	83 c4 1c             	add    $0x1c,%esp
  80222f:	5b                   	pop    %ebx
  802230:	5e                   	pop    %esi
  802231:	5f                   	pop    %edi
  802232:	5d                   	pop    %ebp
  802233:	c3                   	ret    
  802234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802238:	39 ce                	cmp    %ecx,%esi
  80223a:	72 0c                	jb     802248 <__udivdi3+0x118>
  80223c:	31 db                	xor    %ebx,%ebx
  80223e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802242:	0f 87 34 ff ff ff    	ja     80217c <__udivdi3+0x4c>
  802248:	bb 01 00 00 00       	mov    $0x1,%ebx
  80224d:	e9 2a ff ff ff       	jmp    80217c <__udivdi3+0x4c>
  802252:	66 90                	xchg   %ax,%ax
  802254:	66 90                	xchg   %ax,%ax
  802256:	66 90                	xchg   %ax,%ax
  802258:	66 90                	xchg   %ax,%ax
  80225a:	66 90                	xchg   %ax,%ax
  80225c:	66 90                	xchg   %ax,%ax
  80225e:	66 90                	xchg   %ax,%ax

00802260 <__umoddi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	53                   	push   %ebx
  802264:	83 ec 1c             	sub    $0x1c,%esp
  802267:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80226b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80226f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802277:	85 d2                	test   %edx,%edx
  802279:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80227d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802281:	89 f3                	mov    %esi,%ebx
  802283:	89 3c 24             	mov    %edi,(%esp)
  802286:	89 74 24 04          	mov    %esi,0x4(%esp)
  80228a:	75 1c                	jne    8022a8 <__umoddi3+0x48>
  80228c:	39 f7                	cmp    %esi,%edi
  80228e:	76 50                	jbe    8022e0 <__umoddi3+0x80>
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	f7 f7                	div    %edi
  802296:	89 d0                	mov    %edx,%eax
  802298:	31 d2                	xor    %edx,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	39 f2                	cmp    %esi,%edx
  8022aa:	89 d0                	mov    %edx,%eax
  8022ac:	77 52                	ja     802300 <__umoddi3+0xa0>
  8022ae:	0f bd ea             	bsr    %edx,%ebp
  8022b1:	83 f5 1f             	xor    $0x1f,%ebp
  8022b4:	75 5a                	jne    802310 <__umoddi3+0xb0>
  8022b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ba:	0f 82 e0 00 00 00    	jb     8023a0 <__umoddi3+0x140>
  8022c0:	39 0c 24             	cmp    %ecx,(%esp)
  8022c3:	0f 86 d7 00 00 00    	jbe    8023a0 <__umoddi3+0x140>
  8022c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022d1:	83 c4 1c             	add    $0x1c,%esp
  8022d4:	5b                   	pop    %ebx
  8022d5:	5e                   	pop    %esi
  8022d6:	5f                   	pop    %edi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	85 ff                	test   %edi,%edi
  8022e2:	89 fd                	mov    %edi,%ebp
  8022e4:	75 0b                	jne    8022f1 <__umoddi3+0x91>
  8022e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f7                	div    %edi
  8022ef:	89 c5                	mov    %eax,%ebp
  8022f1:	89 f0                	mov    %esi,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f5                	div    %ebp
  8022f7:	89 c8                	mov    %ecx,%eax
  8022f9:	f7 f5                	div    %ebp
  8022fb:	89 d0                	mov    %edx,%eax
  8022fd:	eb 99                	jmp    802298 <__umoddi3+0x38>
  8022ff:	90                   	nop
  802300:	89 c8                	mov    %ecx,%eax
  802302:	89 f2                	mov    %esi,%edx
  802304:	83 c4 1c             	add    $0x1c,%esp
  802307:	5b                   	pop    %ebx
  802308:	5e                   	pop    %esi
  802309:	5f                   	pop    %edi
  80230a:	5d                   	pop    %ebp
  80230b:	c3                   	ret    
  80230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802310:	8b 34 24             	mov    (%esp),%esi
  802313:	bf 20 00 00 00       	mov    $0x20,%edi
  802318:	89 e9                	mov    %ebp,%ecx
  80231a:	29 ef                	sub    %ebp,%edi
  80231c:	d3 e0                	shl    %cl,%eax
  80231e:	89 f9                	mov    %edi,%ecx
  802320:	89 f2                	mov    %esi,%edx
  802322:	d3 ea                	shr    %cl,%edx
  802324:	89 e9                	mov    %ebp,%ecx
  802326:	09 c2                	or     %eax,%edx
  802328:	89 d8                	mov    %ebx,%eax
  80232a:	89 14 24             	mov    %edx,(%esp)
  80232d:	89 f2                	mov    %esi,%edx
  80232f:	d3 e2                	shl    %cl,%edx
  802331:	89 f9                	mov    %edi,%ecx
  802333:	89 54 24 04          	mov    %edx,0x4(%esp)
  802337:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80233b:	d3 e8                	shr    %cl,%eax
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	89 c6                	mov    %eax,%esi
  802341:	d3 e3                	shl    %cl,%ebx
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 d0                	mov    %edx,%eax
  802347:	d3 e8                	shr    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	09 d8                	or     %ebx,%eax
  80234d:	89 d3                	mov    %edx,%ebx
  80234f:	89 f2                	mov    %esi,%edx
  802351:	f7 34 24             	divl   (%esp)
  802354:	89 d6                	mov    %edx,%esi
  802356:	d3 e3                	shl    %cl,%ebx
  802358:	f7 64 24 04          	mull   0x4(%esp)
  80235c:	39 d6                	cmp    %edx,%esi
  80235e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802362:	89 d1                	mov    %edx,%ecx
  802364:	89 c3                	mov    %eax,%ebx
  802366:	72 08                	jb     802370 <__umoddi3+0x110>
  802368:	75 11                	jne    80237b <__umoddi3+0x11b>
  80236a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80236e:	73 0b                	jae    80237b <__umoddi3+0x11b>
  802370:	2b 44 24 04          	sub    0x4(%esp),%eax
  802374:	1b 14 24             	sbb    (%esp),%edx
  802377:	89 d1                	mov    %edx,%ecx
  802379:	89 c3                	mov    %eax,%ebx
  80237b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80237f:	29 da                	sub    %ebx,%edx
  802381:	19 ce                	sbb    %ecx,%esi
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 f0                	mov    %esi,%eax
  802387:	d3 e0                	shl    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	d3 ea                	shr    %cl,%edx
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	d3 ee                	shr    %cl,%esi
  802391:	09 d0                	or     %edx,%eax
  802393:	89 f2                	mov    %esi,%edx
  802395:	83 c4 1c             	add    $0x1c,%esp
  802398:	5b                   	pop    %ebx
  802399:	5e                   	pop    %esi
  80239a:	5f                   	pop    %edi
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    
  80239d:	8d 76 00             	lea    0x0(%esi),%esi
  8023a0:	29 f9                	sub    %edi,%ecx
  8023a2:	19 d6                	sbb    %edx,%esi
  8023a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ac:	e9 18 ff ff ff       	jmp    8022c9 <__umoddi3+0x69>
