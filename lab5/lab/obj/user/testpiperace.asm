
obj/user/testpiperace.debug：     文件格式 elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 00 23 80 00       	push   $0x802300
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 76 1c 00 00       	call   801cc6 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 19 23 80 00       	push   $0x802319
  80005d:	6a 0d                	push   $0xd
  80005f:	68 22 23 80 00       	push   $0x802322
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 99 0f 00 00       	call   801007 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 36 23 80 00       	push   $0x802336
  80007a:	6a 10                	push   $0x10
  80007c:	68 22 23 80 00       	push   $0x802322
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 b5 13 00 00       	call   80144a <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 71 1d 00 00       	call   801e19 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 3f 23 80 00       	push   $0x80233f
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 3c 0c 00 00       	call   800d05 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 d8 10 00 00       	call   8011b4 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 5a 23 80 00       	push   $0x80235a
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 65 23 80 00       	push   $0x802365
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 80 13 00 00       	call   80149a <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 65 13 00 00       	call   80149a <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 70 23 80 00       	push   $0x802370
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 c1 1c 00 00       	call   801e19 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 cc 23 80 00       	push   $0x8023cc
  800167:	6a 3a                	push   $0x3a
  800169:	68 22 23 80 00       	push   $0x802322
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 9e 11 00 00       	call   801320 <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 86 23 80 00       	push   $0x802386
  80018f:	6a 3c                	push   $0x3c
  800191:	68 22 23 80 00       	push   $0x802322
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 14 11 00 00       	call   8012ba <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 07 19 00 00       	call   801ab5 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 9e 23 80 00       	push   $0x80239e
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 b4 23 80 00       	push   $0x8023b4
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8001ef:	e8 f2 0a 00 00       	call   800ce6 <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
        binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 40 12 00 00       	call   801475 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 66 0a 00 00       	call   800ca5 <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 8f 0a 00 00       	call   800ce6 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 00 24 80 00       	push   $0x802400
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 17 23 80 00 	movl   $0x802317,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 ae 09 00 00       	call   800c68 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 1a 01 00 00       	call   80041a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 53 09 00 00       	call   800c68 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 db 1c 00 00       	call   802060 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 c8 1d 00 00       	call   802190 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ef:	73 0a                	jae    8003fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f4:	89 08                	mov    %ecx,(%eax)
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	88 02                	mov    %al,(%edx)
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800403:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 10             	pushl  0x10(%ebp)
  80040a:	ff 75 0c             	pushl  0xc(%ebp)
  80040d:	ff 75 08             	pushl  0x8(%ebp)
  800410:	e8 05 00 00 00       	call   80041a <vprintfmt>
	va_end(ap);
}
  800415:	83 c4 10             	add    $0x10,%esp
  800418:	c9                   	leave  
  800419:	c3                   	ret    

0080041a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	57                   	push   %edi
  80041e:	56                   	push   %esi
  80041f:	53                   	push   %ebx
  800420:	83 ec 2c             	sub    $0x2c,%esp
  800423:	8b 75 08             	mov    0x8(%ebp),%esi
  800426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800429:	8b 7d 10             	mov    0x10(%ebp),%edi
  80042c:	eb 12                	jmp    800440 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042e:	85 c0                	test   %eax,%eax
  800430:	0f 84 42 04 00 00    	je     800878 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	53                   	push   %ebx
  80043a:	50                   	push   %eax
  80043b:	ff d6                	call   *%esi
  80043d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800440:	83 c7 01             	add    $0x1,%edi
  800443:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800447:	83 f8 25             	cmp    $0x25,%eax
  80044a:	75 e2                	jne    80042e <vprintfmt+0x14>
  80044c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800450:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800465:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046a:	eb 07                	jmp    800473 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80046f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8d 47 01             	lea    0x1(%edi),%eax
  800476:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800479:	0f b6 07             	movzbl (%edi),%eax
  80047c:	0f b6 d0             	movzbl %al,%edx
  80047f:	83 e8 23             	sub    $0x23,%eax
  800482:	3c 55                	cmp    $0x55,%al
  800484:	0f 87 d3 03 00 00    	ja     80085d <vprintfmt+0x443>
  80048a:	0f b6 c0             	movzbl %al,%eax
  80048d:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800497:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80049b:	eb d6                	jmp    800473 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004b5:	83 f9 09             	cmp    $0x9,%ecx
  8004b8:	77 3f                	ja     8004f9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004bd:	eb e9                	jmp    8004a8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 40 04             	lea    0x4(%eax),%eax
  8004cd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d3:	eb 2a                	jmp    8004ff <vprintfmt+0xe5>
  8004d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
  8004df:	0f 49 d0             	cmovns %eax,%edx
  8004e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e8:	eb 89                	jmp    800473 <vprintfmt+0x59>
  8004ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f4:	e9 7a ff ff ff       	jmp    800473 <vprintfmt+0x59>
  8004f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800503:	0f 89 6a ff ff ff    	jns    800473 <vprintfmt+0x59>
				width = precision, precision = -1;
  800509:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80050c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800516:	e9 58 ff ff ff       	jmp    800473 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800521:	e9 4d ff ff ff       	jmp    800473 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 78 04             	lea    0x4(%eax),%edi
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	53                   	push   %ebx
  800530:	ff 30                	pushl  (%eax)
  800532:	ff d6                	call   *%esi
			break;
  800534:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800537:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80053d:	e9 fe fe ff ff       	jmp    800440 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 78 04             	lea    0x4(%eax),%edi
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	99                   	cltd   
  80054b:	31 d0                	xor    %edx,%eax
  80054d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054f:	83 f8 0f             	cmp    $0xf,%eax
  800552:	7f 0b                	jg     80055f <vprintfmt+0x145>
  800554:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  80055b:	85 d2                	test   %edx,%edx
  80055d:	75 1b                	jne    80057a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80055f:	50                   	push   %eax
  800560:	68 3b 24 80 00       	push   $0x80243b
  800565:	53                   	push   %ebx
  800566:	56                   	push   %esi
  800567:	e8 91 fe ff ff       	call   8003fd <printfmt>
  80056c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800575:	e9 c6 fe ff ff       	jmp    800440 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80057a:	52                   	push   %edx
  80057b:	68 b9 28 80 00       	push   $0x8028b9
  800580:	53                   	push   %ebx
  800581:	56                   	push   %esi
  800582:	e8 76 fe ff ff       	call   8003fd <printfmt>
  800587:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800590:	e9 ab fe ff ff       	jmp    800440 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	83 c0 04             	add    $0x4,%eax
  80059b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a3:	85 ff                	test   %edi,%edi
  8005a5:	b8 34 24 80 00       	mov    $0x802434,%eax
  8005aa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b1:	0f 8e 94 00 00 00    	jle    80064b <vprintfmt+0x231>
  8005b7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bb:	0f 84 98 00 00 00    	je     800659 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c7:	57                   	push   %edi
  8005c8:	e8 33 03 00 00       	call   800900 <strnlen>
  8005cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d0:	29 c1                	sub    %eax,%ecx
  8005d2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005d5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005d8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005df:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	eb 0f                	jmp    8005f5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	53                   	push   %ebx
  8005ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ed:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 ef 01             	sub    $0x1,%edi
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	85 ff                	test   %edi,%edi
  8005f7:	7f ed                	jg     8005e6 <vprintfmt+0x1cc>
  8005f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005ff:	85 c9                	test   %ecx,%ecx
  800601:	b8 00 00 00 00       	mov    $0x0,%eax
  800606:	0f 49 c1             	cmovns %ecx,%eax
  800609:	29 c1                	sub    %eax,%ecx
  80060b:	89 75 08             	mov    %esi,0x8(%ebp)
  80060e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800611:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800614:	89 cb                	mov    %ecx,%ebx
  800616:	eb 4d                	jmp    800665 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800618:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061c:	74 1b                	je     800639 <vprintfmt+0x21f>
  80061e:	0f be c0             	movsbl %al,%eax
  800621:	83 e8 20             	sub    $0x20,%eax
  800624:	83 f8 5e             	cmp    $0x5e,%eax
  800627:	76 10                	jbe    800639 <vprintfmt+0x21f>
					putch('?', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	ff 75 0c             	pushl  0xc(%ebp)
  80062f:	6a 3f                	push   $0x3f
  800631:	ff 55 08             	call   *0x8(%ebp)
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	eb 0d                	jmp    800646 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	ff 75 0c             	pushl  0xc(%ebp)
  80063f:	52                   	push   %edx
  800640:	ff 55 08             	call   *0x8(%ebp)
  800643:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800646:	83 eb 01             	sub    $0x1,%ebx
  800649:	eb 1a                	jmp    800665 <vprintfmt+0x24b>
  80064b:	89 75 08             	mov    %esi,0x8(%ebp)
  80064e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800651:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800654:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800657:	eb 0c                	jmp    800665 <vprintfmt+0x24b>
  800659:	89 75 08             	mov    %esi,0x8(%ebp)
  80065c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800662:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800665:	83 c7 01             	add    $0x1,%edi
  800668:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066c:	0f be d0             	movsbl %al,%edx
  80066f:	85 d2                	test   %edx,%edx
  800671:	74 23                	je     800696 <vprintfmt+0x27c>
  800673:	85 f6                	test   %esi,%esi
  800675:	78 a1                	js     800618 <vprintfmt+0x1fe>
  800677:	83 ee 01             	sub    $0x1,%esi
  80067a:	79 9c                	jns    800618 <vprintfmt+0x1fe>
  80067c:	89 df                	mov    %ebx,%edi
  80067e:	8b 75 08             	mov    0x8(%ebp),%esi
  800681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800684:	eb 18                	jmp    80069e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 20                	push   $0x20
  80068c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068e:	83 ef 01             	sub    $0x1,%edi
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	eb 08                	jmp    80069e <vprintfmt+0x284>
  800696:	89 df                	mov    %ebx,%edi
  800698:	8b 75 08             	mov    0x8(%ebp),%esi
  80069b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069e:	85 ff                	test   %edi,%edi
  8006a0:	7f e4                	jg     800686 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ab:	e9 90 fd ff ff       	jmp    800440 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b0:	83 f9 01             	cmp    $0x1,%ecx
  8006b3:	7e 19                	jle    8006ce <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 50 04             	mov    0x4(%eax),%edx
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 40 08             	lea    0x8(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cc:	eb 38                	jmp    800706 <vprintfmt+0x2ec>
	else if (lflag)
  8006ce:	85 c9                	test   %ecx,%ecx
  8006d0:	74 1b                	je     8006ed <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006da:	89 c1                	mov    %eax,%ecx
  8006dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 40 04             	lea    0x4(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006eb:	eb 19                	jmp    800706 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f5:	89 c1                	mov    %eax,%ecx
  8006f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 40 04             	lea    0x4(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800706:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800709:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80070c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800711:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800715:	0f 89 0e 01 00 00    	jns    800829 <vprintfmt+0x40f>
				putch('-', putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	53                   	push   %ebx
  80071f:	6a 2d                	push   $0x2d
  800721:	ff d6                	call   *%esi
				num = -(long long) num;
  800723:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800726:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800729:	f7 da                	neg    %edx
  80072b:	83 d1 00             	adc    $0x0,%ecx
  80072e:	f7 d9                	neg    %ecx
  800730:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800733:	b8 0a 00 00 00       	mov    $0xa,%eax
  800738:	e9 ec 00 00 00       	jmp    800829 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073d:	83 f9 01             	cmp    $0x1,%ecx
  800740:	7e 18                	jle    80075a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8b 10                	mov    (%eax),%edx
  800747:	8b 48 04             	mov    0x4(%eax),%ecx
  80074a:	8d 40 08             	lea    0x8(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800750:	b8 0a 00 00 00       	mov    $0xa,%eax
  800755:	e9 cf 00 00 00       	jmp    800829 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80075a:	85 c9                	test   %ecx,%ecx
  80075c:	74 1a                	je     800778 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 10                	mov    (%eax),%edx
  800763:	b9 00 00 00 00       	mov    $0x0,%ecx
  800768:	8d 40 04             	lea    0x4(%eax),%eax
  80076b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800773:	e9 b1 00 00 00       	jmp    800829 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800782:	8d 40 04             	lea    0x4(%eax),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800788:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078d:	e9 97 00 00 00       	jmp    800829 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800792:	83 ec 08             	sub    $0x8,%esp
  800795:	53                   	push   %ebx
  800796:	6a 58                	push   $0x58
  800798:	ff d6                	call   *%esi
			putch('X', putdat);
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	53                   	push   %ebx
  80079e:	6a 58                	push   $0x58
  8007a0:	ff d6                	call   *%esi
			putch('X', putdat);
  8007a2:	83 c4 08             	add    $0x8,%esp
  8007a5:	53                   	push   %ebx
  8007a6:	6a 58                	push   $0x58
  8007a8:	ff d6                	call   *%esi
			break;
  8007aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007b0:	e9 8b fc ff ff       	jmp    800440 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	53                   	push   %ebx
  8007b9:	6a 30                	push   $0x30
  8007bb:	ff d6                	call   *%esi
			putch('x', putdat);
  8007bd:	83 c4 08             	add    $0x8,%esp
  8007c0:	53                   	push   %ebx
  8007c1:	6a 78                	push   $0x78
  8007c3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8b 10                	mov    (%eax),%edx
  8007ca:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007cf:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007dd:	eb 4a                	jmp    800829 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007df:	83 f9 01             	cmp    $0x1,%ecx
  8007e2:	7e 15                	jle    8007f9 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8b 10                	mov    (%eax),%edx
  8007e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ec:	8d 40 08             	lea    0x8(%eax),%eax
  8007ef:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007f2:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f7:	eb 30                	jmp    800829 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007f9:	85 c9                	test   %ecx,%ecx
  8007fb:	74 17                	je     800814 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8b 10                	mov    (%eax),%edx
  800802:	b9 00 00 00 00       	mov    $0x0,%ecx
  800807:	8d 40 04             	lea    0x4(%eax),%eax
  80080a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80080d:	b8 10 00 00 00       	mov    $0x10,%eax
  800812:	eb 15                	jmp    800829 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	8b 10                	mov    (%eax),%edx
  800819:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081e:	8d 40 04             	lea    0x4(%eax),%eax
  800821:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800824:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800829:	83 ec 0c             	sub    $0xc,%esp
  80082c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800830:	57                   	push   %edi
  800831:	ff 75 e0             	pushl  -0x20(%ebp)
  800834:	50                   	push   %eax
  800835:	51                   	push   %ecx
  800836:	52                   	push   %edx
  800837:	89 da                	mov    %ebx,%edx
  800839:	89 f0                	mov    %esi,%eax
  80083b:	e8 f1 fa ff ff       	call   800331 <printnum>
			break;
  800840:	83 c4 20             	add    $0x20,%esp
  800843:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800846:	e9 f5 fb ff ff       	jmp    800440 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	52                   	push   %edx
  800850:	ff d6                	call   *%esi
			break;
  800852:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800858:	e9 e3 fb ff ff       	jmp    800440 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	6a 25                	push   $0x25
  800863:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800865:	83 c4 10             	add    $0x10,%esp
  800868:	eb 03                	jmp    80086d <vprintfmt+0x453>
  80086a:	83 ef 01             	sub    $0x1,%edi
  80086d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800871:	75 f7                	jne    80086a <vprintfmt+0x450>
  800873:	e9 c8 fb ff ff       	jmp    800440 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800878:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	83 ec 18             	sub    $0x18,%esp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800893:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800896:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089d:	85 c0                	test   %eax,%eax
  80089f:	74 26                	je     8008c7 <vsnprintf+0x47>
  8008a1:	85 d2                	test   %edx,%edx
  8008a3:	7e 22                	jle    8008c7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a5:	ff 75 14             	pushl  0x14(%ebp)
  8008a8:	ff 75 10             	pushl  0x10(%ebp)
  8008ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ae:	50                   	push   %eax
  8008af:	68 e0 03 80 00       	push   $0x8003e0
  8008b4:	e8 61 fb ff ff       	call   80041a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	eb 05                	jmp    8008cc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008cc:	c9                   	leave  
  8008cd:	c3                   	ret    

008008ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d7:	50                   	push   %eax
  8008d8:	ff 75 10             	pushl  0x10(%ebp)
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	ff 75 08             	pushl  0x8(%ebp)
  8008e1:	e8 9a ff ff ff       	call   800880 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f3:	eb 03                	jmp    8008f8 <strlen+0x10>
		n++;
  8008f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008fc:	75 f7                	jne    8008f5 <strlen+0xd>
		n++;
	return n;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800906:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800909:	ba 00 00 00 00       	mov    $0x0,%edx
  80090e:	eb 03                	jmp    800913 <strnlen+0x13>
		n++;
  800910:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800913:	39 c2                	cmp    %eax,%edx
  800915:	74 08                	je     80091f <strnlen+0x1f>
  800917:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80091b:	75 f3                	jne    800910 <strnlen+0x10>
  80091d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	53                   	push   %ebx
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80092b:	89 c2                	mov    %eax,%edx
  80092d:	83 c2 01             	add    $0x1,%edx
  800930:	83 c1 01             	add    $0x1,%ecx
  800933:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800937:	88 5a ff             	mov    %bl,-0x1(%edx)
  80093a:	84 db                	test   %bl,%bl
  80093c:	75 ef                	jne    80092d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	53                   	push   %ebx
  800945:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800948:	53                   	push   %ebx
  800949:	e8 9a ff ff ff       	call   8008e8 <strlen>
  80094e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800951:	ff 75 0c             	pushl  0xc(%ebp)
  800954:	01 d8                	add    %ebx,%eax
  800956:	50                   	push   %eax
  800957:	e8 c5 ff ff ff       	call   800921 <strcpy>
	return dst;
}
  80095c:	89 d8                	mov    %ebx,%eax
  80095e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 75 08             	mov    0x8(%ebp),%esi
  80096b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096e:	89 f3                	mov    %esi,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800973:	89 f2                	mov    %esi,%edx
  800975:	eb 0f                	jmp    800986 <strncpy+0x23>
		*dst++ = *src;
  800977:	83 c2 01             	add    $0x1,%edx
  80097a:	0f b6 01             	movzbl (%ecx),%eax
  80097d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800980:	80 39 01             	cmpb   $0x1,(%ecx)
  800983:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800986:	39 da                	cmp    %ebx,%edx
  800988:	75 ed                	jne    800977 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80098a:	89 f0                	mov    %esi,%eax
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 75 08             	mov    0x8(%ebp),%esi
  800998:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099b:	8b 55 10             	mov    0x10(%ebp),%edx
  80099e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a0:	85 d2                	test   %edx,%edx
  8009a2:	74 21                	je     8009c5 <strlcpy+0x35>
  8009a4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009a8:	89 f2                	mov    %esi,%edx
  8009aa:	eb 09                	jmp    8009b5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ac:	83 c2 01             	add    $0x1,%edx
  8009af:	83 c1 01             	add    $0x1,%ecx
  8009b2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b5:	39 c2                	cmp    %eax,%edx
  8009b7:	74 09                	je     8009c2 <strlcpy+0x32>
  8009b9:	0f b6 19             	movzbl (%ecx),%ebx
  8009bc:	84 db                	test   %bl,%bl
  8009be:	75 ec                	jne    8009ac <strlcpy+0x1c>
  8009c0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009c2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c5:	29 f0                	sub    %esi,%eax
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d4:	eb 06                	jmp    8009dc <strcmp+0x11>
		p++, q++;
  8009d6:	83 c1 01             	add    $0x1,%ecx
  8009d9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009dc:	0f b6 01             	movzbl (%ecx),%eax
  8009df:	84 c0                	test   %al,%al
  8009e1:	74 04                	je     8009e7 <strcmp+0x1c>
  8009e3:	3a 02                	cmp    (%edx),%al
  8009e5:	74 ef                	je     8009d6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e7:	0f b6 c0             	movzbl %al,%eax
  8009ea:	0f b6 12             	movzbl (%edx),%edx
  8009ed:	29 d0                	sub    %edx,%eax
}
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fb:	89 c3                	mov    %eax,%ebx
  8009fd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a00:	eb 06                	jmp    800a08 <strncmp+0x17>
		n--, p++, q++;
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a08:	39 d8                	cmp    %ebx,%eax
  800a0a:	74 15                	je     800a21 <strncmp+0x30>
  800a0c:	0f b6 08             	movzbl (%eax),%ecx
  800a0f:	84 c9                	test   %cl,%cl
  800a11:	74 04                	je     800a17 <strncmp+0x26>
  800a13:	3a 0a                	cmp    (%edx),%cl
  800a15:	74 eb                	je     800a02 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a17:	0f b6 00             	movzbl (%eax),%eax
  800a1a:	0f b6 12             	movzbl (%edx),%edx
  800a1d:	29 d0                	sub    %edx,%eax
  800a1f:	eb 05                	jmp    800a26 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a33:	eb 07                	jmp    800a3c <strchr+0x13>
		if (*s == c)
  800a35:	38 ca                	cmp    %cl,%dl
  800a37:	74 0f                	je     800a48 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a39:	83 c0 01             	add    $0x1,%eax
  800a3c:	0f b6 10             	movzbl (%eax),%edx
  800a3f:	84 d2                	test   %dl,%dl
  800a41:	75 f2                	jne    800a35 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a54:	eb 03                	jmp    800a59 <strfind+0xf>
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a5c:	38 ca                	cmp    %cl,%dl
  800a5e:	74 04                	je     800a64 <strfind+0x1a>
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 f2                	jne    800a56 <strfind+0xc>
			break;
	return (char *) s;
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a72:	85 c9                	test   %ecx,%ecx
  800a74:	74 36                	je     800aac <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a76:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7c:	75 28                	jne    800aa6 <memset+0x40>
  800a7e:	f6 c1 03             	test   $0x3,%cl
  800a81:	75 23                	jne    800aa6 <memset+0x40>
		c &= 0xFF;
  800a83:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a87:	89 d3                	mov    %edx,%ebx
  800a89:	c1 e3 08             	shl    $0x8,%ebx
  800a8c:	89 d6                	mov    %edx,%esi
  800a8e:	c1 e6 18             	shl    $0x18,%esi
  800a91:	89 d0                	mov    %edx,%eax
  800a93:	c1 e0 10             	shl    $0x10,%eax
  800a96:	09 f0                	or     %esi,%eax
  800a98:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a9a:	89 d8                	mov    %ebx,%eax
  800a9c:	09 d0                	or     %edx,%eax
  800a9e:	c1 e9 02             	shr    $0x2,%ecx
  800aa1:	fc                   	cld    
  800aa2:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa4:	eb 06                	jmp    800aac <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa9:	fc                   	cld    
  800aaa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aac:	89 f8                	mov    %edi,%eax
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac1:	39 c6                	cmp    %eax,%esi
  800ac3:	73 35                	jae    800afa <memmove+0x47>
  800ac5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac8:	39 d0                	cmp    %edx,%eax
  800aca:	73 2e                	jae    800afa <memmove+0x47>
		s += n;
		d += n;
  800acc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	89 d6                	mov    %edx,%esi
  800ad1:	09 fe                	or     %edi,%esi
  800ad3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad9:	75 13                	jne    800aee <memmove+0x3b>
  800adb:	f6 c1 03             	test   $0x3,%cl
  800ade:	75 0e                	jne    800aee <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ae0:	83 ef 04             	sub    $0x4,%edi
  800ae3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae6:	c1 e9 02             	shr    $0x2,%ecx
  800ae9:	fd                   	std    
  800aea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aec:	eb 09                	jmp    800af7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aee:	83 ef 01             	sub    $0x1,%edi
  800af1:	8d 72 ff             	lea    -0x1(%edx),%esi
  800af4:	fd                   	std    
  800af5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af7:	fc                   	cld    
  800af8:	eb 1d                	jmp    800b17 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afa:	89 f2                	mov    %esi,%edx
  800afc:	09 c2                	or     %eax,%edx
  800afe:	f6 c2 03             	test   $0x3,%dl
  800b01:	75 0f                	jne    800b12 <memmove+0x5f>
  800b03:	f6 c1 03             	test   $0x3,%cl
  800b06:	75 0a                	jne    800b12 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b08:	c1 e9 02             	shr    $0x2,%ecx
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	fc                   	cld    
  800b0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b10:	eb 05                	jmp    800b17 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b12:	89 c7                	mov    %eax,%edi
  800b14:	fc                   	cld    
  800b15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b1e:	ff 75 10             	pushl  0x10(%ebp)
  800b21:	ff 75 0c             	pushl  0xc(%ebp)
  800b24:	ff 75 08             	pushl  0x8(%ebp)
  800b27:	e8 87 ff ff ff       	call   800ab3 <memmove>
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b39:	89 c6                	mov    %eax,%esi
  800b3b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3e:	eb 1a                	jmp    800b5a <memcmp+0x2c>
		if (*s1 != *s2)
  800b40:	0f b6 08             	movzbl (%eax),%ecx
  800b43:	0f b6 1a             	movzbl (%edx),%ebx
  800b46:	38 d9                	cmp    %bl,%cl
  800b48:	74 0a                	je     800b54 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b4a:	0f b6 c1             	movzbl %cl,%eax
  800b4d:	0f b6 db             	movzbl %bl,%ebx
  800b50:	29 d8                	sub    %ebx,%eax
  800b52:	eb 0f                	jmp    800b63 <memcmp+0x35>
		s1++, s2++;
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5a:	39 f0                	cmp    %esi,%eax
  800b5c:	75 e2                	jne    800b40 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	53                   	push   %ebx
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b6e:	89 c1                	mov    %eax,%ecx
  800b70:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b73:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b77:	eb 0a                	jmp    800b83 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b79:	0f b6 10             	movzbl (%eax),%edx
  800b7c:	39 da                	cmp    %ebx,%edx
  800b7e:	74 07                	je     800b87 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b80:	83 c0 01             	add    $0x1,%eax
  800b83:	39 c8                	cmp    %ecx,%eax
  800b85:	72 f2                	jb     800b79 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b87:	5b                   	pop    %ebx
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
  800b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b96:	eb 03                	jmp    800b9b <strtol+0x11>
		s++;
  800b98:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	3c 20                	cmp    $0x20,%al
  800ba0:	74 f6                	je     800b98 <strtol+0xe>
  800ba2:	3c 09                	cmp    $0x9,%al
  800ba4:	74 f2                	je     800b98 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba6:	3c 2b                	cmp    $0x2b,%al
  800ba8:	75 0a                	jne    800bb4 <strtol+0x2a>
		s++;
  800baa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bad:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb2:	eb 11                	jmp    800bc5 <strtol+0x3b>
  800bb4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb9:	3c 2d                	cmp    $0x2d,%al
  800bbb:	75 08                	jne    800bc5 <strtol+0x3b>
		s++, neg = 1;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bcb:	75 15                	jne    800be2 <strtol+0x58>
  800bcd:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd0:	75 10                	jne    800be2 <strtol+0x58>
  800bd2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bd6:	75 7c                	jne    800c54 <strtol+0xca>
		s += 2, base = 16;
  800bd8:	83 c1 02             	add    $0x2,%ecx
  800bdb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be0:	eb 16                	jmp    800bf8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800be2:	85 db                	test   %ebx,%ebx
  800be4:	75 12                	jne    800bf8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800beb:	80 39 30             	cmpb   $0x30,(%ecx)
  800bee:	75 08                	jne    800bf8 <strtol+0x6e>
		s++, base = 8;
  800bf0:	83 c1 01             	add    $0x1,%ecx
  800bf3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c00:	0f b6 11             	movzbl (%ecx),%edx
  800c03:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c06:	89 f3                	mov    %esi,%ebx
  800c08:	80 fb 09             	cmp    $0x9,%bl
  800c0b:	77 08                	ja     800c15 <strtol+0x8b>
			dig = *s - '0';
  800c0d:	0f be d2             	movsbl %dl,%edx
  800c10:	83 ea 30             	sub    $0x30,%edx
  800c13:	eb 22                	jmp    800c37 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c15:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c18:	89 f3                	mov    %esi,%ebx
  800c1a:	80 fb 19             	cmp    $0x19,%bl
  800c1d:	77 08                	ja     800c27 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c1f:	0f be d2             	movsbl %dl,%edx
  800c22:	83 ea 57             	sub    $0x57,%edx
  800c25:	eb 10                	jmp    800c37 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c27:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c2a:	89 f3                	mov    %esi,%ebx
  800c2c:	80 fb 19             	cmp    $0x19,%bl
  800c2f:	77 16                	ja     800c47 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c31:	0f be d2             	movsbl %dl,%edx
  800c34:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c37:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c3a:	7d 0b                	jge    800c47 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c3c:	83 c1 01             	add    $0x1,%ecx
  800c3f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c43:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c45:	eb b9                	jmp    800c00 <strtol+0x76>

	if (endptr)
  800c47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4b:	74 0d                	je     800c5a <strtol+0xd0>
		*endptr = (char *) s;
  800c4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c50:	89 0e                	mov    %ecx,(%esi)
  800c52:	eb 06                	jmp    800c5a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c54:	85 db                	test   %ebx,%ebx
  800c56:	74 98                	je     800bf0 <strtol+0x66>
  800c58:	eb 9e                	jmp    800bf8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c5a:	89 c2                	mov    %eax,%edx
  800c5c:	f7 da                	neg    %edx
  800c5e:	85 ff                	test   %edi,%edi
  800c60:	0f 45 c2             	cmovne %edx,%eax
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 c3                	mov    %eax,%ebx
  800c7b:	89 c7                	mov    %eax,%edi
  800c7d:	89 c6                	mov    %eax,%esi
  800c7f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 01 00 00 00       	mov    $0x1,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 cb                	mov    %ecx,%ebx
  800cbd:	89 cf                	mov    %ecx,%edi
  800cbf:	89 ce                	mov    %ecx,%esi
  800cc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 17                	jle    800cde <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 03                	push   $0x3
  800ccd:	68 1f 27 80 00       	push   $0x80271f
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 3c 27 80 00       	push   $0x80273c
  800cd9:	e8 66 f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf1:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf6:	89 d1                	mov    %edx,%ecx
  800cf8:	89 d3                	mov    %edx,%ebx
  800cfa:	89 d7                	mov    %edx,%edi
  800cfc:	89 d6                	mov    %edx,%esi
  800cfe:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_yield>:

void
sys_yield(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	be 00 00 00 00       	mov    $0x0,%esi
  800d32:	b8 04 00 00 00       	mov    $0x4,%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d40:	89 f7                	mov    %esi,%edi
  800d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 04                	push   $0x4
  800d4e:	68 1f 27 80 00       	push   $0x80271f
  800d53:	6a 23                	push   $0x23
  800d55:	68 3c 27 80 00       	push   $0x80273c
  800d5a:	e8 e5 f4 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800d70:	b8 05 00 00 00       	mov    $0x5,%eax
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d81:	8b 75 18             	mov    0x18(%ebp),%esi
  800d84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 05                	push   $0x5
  800d90:	68 1f 27 80 00       	push   $0x80271f
  800d95:	6a 23                	push   $0x23
  800d97:	68 3c 27 80 00       	push   $0x80273c
  800d9c:	e8 a3 f4 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db7:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	89 df                	mov    %ebx,%edi
  800dc4:	89 de                	mov    %ebx,%esi
  800dc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 17                	jle    800de3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	50                   	push   %eax
  800dd0:	6a 06                	push   $0x6
  800dd2:	68 1f 27 80 00       	push   $0x80271f
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 3c 27 80 00       	push   $0x80273c
  800dde:	e8 61 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	89 df                	mov    %ebx,%edi
  800e06:	89 de                	mov    %ebx,%esi
  800e08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	7e 17                	jle    800e25 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	50                   	push   %eax
  800e12:	6a 08                	push   $0x8
  800e14:	68 1f 27 80 00       	push   $0x80271f
  800e19:	6a 23                	push   $0x23
  800e1b:	68 3c 27 80 00       	push   $0x80273c
  800e20:	e8 1f f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3b:	b8 09 00 00 00       	mov    $0x9,%eax
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	8b 55 08             	mov    0x8(%ebp),%edx
  800e46:	89 df                	mov    %ebx,%edi
  800e48:	89 de                	mov    %ebx,%esi
  800e4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7e 17                	jle    800e67 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	50                   	push   %eax
  800e54:	6a 09                	push   $0x9
  800e56:	68 1f 27 80 00       	push   $0x80271f
  800e5b:	6a 23                	push   $0x23
  800e5d:	68 3c 27 80 00       	push   $0x80273c
  800e62:	e8 dd f3 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	89 df                	mov    %ebx,%edi
  800e8a:	89 de                	mov    %ebx,%esi
  800e8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	7e 17                	jle    800ea9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	50                   	push   %eax
  800e96:	6a 0a                	push   $0xa
  800e98:	68 1f 27 80 00       	push   $0x80271f
  800e9d:	6a 23                	push   $0x23
  800e9f:	68 3c 27 80 00       	push   $0x80273c
  800ea4:	e8 9b f3 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb7:	be 00 00 00 00       	mov    $0x0,%esi
  800ebc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eca:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ecd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eea:	89 cb                	mov    %ecx,%ebx
  800eec:	89 cf                	mov    %ecx,%edi
  800eee:	89 ce                	mov    %ecx,%esi
  800ef0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	7e 17                	jle    800f0d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	50                   	push   %eax
  800efa:	6a 0d                	push   $0xd
  800efc:	68 1f 27 80 00       	push   $0x80271f
  800f01:	6a 23                	push   $0x23
  800f03:	68 3c 27 80 00       	push   $0x80273c
  800f08:	e8 37 f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	53                   	push   %ebx
  800f19:	83 ec 04             	sub    $0x4,%esp
  800f1c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f1f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800f21:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f25:	74 2d                	je     800f54 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800f27:	89 d8                	mov    %ebx,%eax
  800f29:	c1 e8 16             	shr    $0x16,%eax
  800f2c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f33:	a8 01                	test   $0x1,%al
  800f35:	74 1d                	je     800f54 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f37:	89 d8                	mov    %ebx,%eax
  800f39:	c1 e8 0c             	shr    $0xc,%eax
  800f3c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800f43:	f6 c2 01             	test   $0x1,%dl
  800f46:	74 0c                	je     800f54 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f48:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800f4f:	f6 c4 08             	test   $0x8,%ah
  800f52:	75 14                	jne    800f68 <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	68 4c 27 80 00       	push   $0x80274c
  800f5c:	6a 1f                	push   $0x1f
  800f5e:	68 82 27 80 00       	push   $0x802782
  800f63:	e8 dc f2 ff ff       	call   800244 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	6a 07                	push   $0x7
  800f6d:	68 00 f0 7f 00       	push   $0x7ff000
  800f72:	6a 00                	push   $0x0
  800f74:	e8 ab fd ff ff       	call   800d24 <sys_page_alloc>
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	79 12                	jns    800f92 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800f80:	50                   	push   %eax
  800f81:	68 8d 27 80 00       	push   $0x80278d
  800f86:	6a 29                	push   $0x29
  800f88:	68 82 27 80 00       	push   $0x802782
  800f8d:	e8 b2 f2 ff ff       	call   800244 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f92:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800f98:	83 ec 04             	sub    $0x4,%esp
  800f9b:	68 00 10 00 00       	push   $0x1000
  800fa0:	53                   	push   %ebx
  800fa1:	68 00 f0 7f 00       	push   $0x7ff000
  800fa6:	e8 70 fb ff ff       	call   800b1b <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800fab:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fb2:	53                   	push   %ebx
  800fb3:	6a 00                	push   $0x0
  800fb5:	68 00 f0 7f 00       	push   $0x7ff000
  800fba:	6a 00                	push   $0x0
  800fbc:	e8 a6 fd ff ff       	call   800d67 <sys_page_map>
  800fc1:	83 c4 20             	add    $0x20,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	79 12                	jns    800fda <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800fc8:	50                   	push   %eax
  800fc9:	68 a1 27 80 00       	push   $0x8027a1
  800fce:	6a 2e                	push   $0x2e
  800fd0:	68 82 27 80 00       	push   $0x802782
  800fd5:	e8 6a f2 ff ff       	call   800244 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	68 00 f0 7f 00       	push   $0x7ff000
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 c0 fd ff ff       	call   800da9 <sys_page_unmap>
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	79 12                	jns    801002 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800ff0:	50                   	push   %eax
  800ff1:	68 b3 27 80 00       	push   $0x8027b3
  800ff6:	6a 30                	push   $0x30
  800ff8:	68 82 27 80 00       	push   $0x802782
  800ffd:	e8 42 f2 ff ff       	call   800244 <_panic>
	//panic("pgfault not implemented");
}
  801002:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
  80100d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  801010:	68 15 0f 80 00       	push   $0x800f15
  801015:	e8 b5 0f 00 00       	call   801fcf <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80101a:	b8 07 00 00 00       	mov    $0x7,%eax
  80101f:	cd 30                	int    $0x30
  801021:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	79 14                	jns    80103f <fork+0x38>
		panic("sys_exofork failed");
  80102b:	83 ec 04             	sub    $0x4,%esp
  80102e:	68 c7 27 80 00       	push   $0x8027c7
  801033:	6a 6f                	push   $0x6f
  801035:	68 82 27 80 00       	push   $0x802782
  80103a:	e8 05 f2 ff ff       	call   800244 <_panic>
  80103f:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  801041:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801045:	0f 8e 2b 01 00 00    	jle    801176 <fork+0x16f>
  80104b:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  801050:	89 d8                	mov    %ebx,%eax
  801052:	c1 e8 0a             	shr    $0xa,%eax
  801055:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105c:	a8 01                	test   $0x1,%al
  80105e:	0f 84 bf 00 00 00    	je     801123 <fork+0x11c>
  801064:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80106b:	a8 01                	test   $0x1,%al
  80106d:	0f 84 b0 00 00 00    	je     801123 <fork+0x11c>
  801073:	89 de                	mov    %ebx,%esi
  801075:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  801078:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80107f:	f6 c4 04             	test   $0x4,%ah
  801082:	74 29                	je     8010ad <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  801084:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80108b:	83 ec 0c             	sub    $0xc,%esp
  80108e:	25 07 0e 00 00       	and    $0xe07,%eax
  801093:	50                   	push   %eax
  801094:	56                   	push   %esi
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	6a 00                	push   $0x0
  801099:	e8 c9 fc ff ff       	call   800d67 <sys_page_map>
  80109e:	83 c4 20             	add    $0x20,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a8:	0f 4f c2             	cmovg  %edx,%eax
  8010ab:	eb 72                	jmp    80111f <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  8010ad:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010b4:	a8 02                	test   $0x2,%al
  8010b6:	75 0c                	jne    8010c4 <fork+0xbd>
  8010b8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010bf:	f6 c4 08             	test   $0x8,%ah
  8010c2:	74 3f                	je     801103 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	68 05 08 00 00       	push   $0x805
  8010cc:	56                   	push   %esi
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	6a 00                	push   $0x0
  8010d1:	e8 91 fc ff ff       	call   800d67 <sys_page_map>
  8010d6:	83 c4 20             	add    $0x20,%esp
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	0f 88 b1 00 00 00    	js     801192 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	68 05 08 00 00       	push   $0x805
  8010e9:	56                   	push   %esi
  8010ea:	6a 00                	push   $0x0
  8010ec:	56                   	push   %esi
  8010ed:	6a 00                	push   $0x0
  8010ef:	e8 73 fc ff ff       	call   800d67 <sys_page_map>
  8010f4:	83 c4 20             	add    $0x20,%esp
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010fe:	0f 4f c1             	cmovg  %ecx,%eax
  801101:	eb 1c                	jmp    80111f <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	6a 05                	push   $0x5
  801108:	56                   	push   %esi
  801109:	57                   	push   %edi
  80110a:	56                   	push   %esi
  80110b:	6a 00                	push   $0x0
  80110d:	e8 55 fc ff ff       	call   800d67 <sys_page_map>
  801112:	83 c4 20             	add    $0x20,%esp
  801115:	85 c0                	test   %eax,%eax
  801117:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111c:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 6f                	js     801192 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801123:	83 c3 01             	add    $0x1,%ebx
  801126:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80112c:	0f 85 1e ff ff ff    	jne    801050 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  801132:	83 ec 04             	sub    $0x4,%esp
  801135:	6a 07                	push   $0x7
  801137:	68 00 f0 bf ee       	push   $0xeebff000
  80113c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80113f:	57                   	push   %edi
  801140:	e8 df fb ff ff       	call   800d24 <sys_page_alloc>
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 46                	js     801192 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  80114c:	83 ec 08             	sub    $0x8,%esp
  80114f:	68 32 20 80 00       	push   $0x802032
  801154:	57                   	push   %edi
  801155:	e8 15 fd ff ff       	call   800e6f <sys_env_set_pgfault_upcall>
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 31                	js     801192 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  801161:	83 ec 08             	sub    $0x8,%esp
  801164:	6a 02                	push   $0x2
  801166:	57                   	push   %edi
  801167:	e8 7f fc ff ff       	call   800deb <sys_env_set_status>
  80116c:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  80116f:	85 c0                	test   %eax,%eax
  801171:	0f 49 c7             	cmovns %edi,%eax
  801174:	eb 1c                	jmp    801192 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  801176:	e8 6b fb ff ff       	call   800ce6 <sys_getenvid>
  80117b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801180:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801183:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801188:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80118d:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <sfork>:

// Challenge!
int
sfork(void)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a0:	68 da 27 80 00       	push   $0x8027da
  8011a5:	68 8d 00 00 00       	push   $0x8d
  8011aa:	68 82 27 80 00       	push   $0x802782
  8011af:	e8 90 f0 ff ff       	call   800244 <_panic>

008011b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	56                   	push   %esi
  8011b8:	53                   	push   %ebx
  8011b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011c9:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8011cc:	83 ec 0c             	sub    $0xc,%esp
  8011cf:	50                   	push   %eax
  8011d0:	e8 ff fc ff ff       	call   800ed4 <sys_ipc_recv>
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	79 16                	jns    8011f2 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8011dc:	85 f6                	test   %esi,%esi
  8011de:	74 06                	je     8011e6 <ipc_recv+0x32>
            *from_env_store = 0;
  8011e0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  8011e6:	85 db                	test   %ebx,%ebx
  8011e8:	74 2c                	je     801216 <ipc_recv+0x62>
            *perm_store = 0;
  8011ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011f0:	eb 24                	jmp    801216 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  8011f2:	85 f6                	test   %esi,%esi
  8011f4:	74 0a                	je     801200 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  8011f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fb:	8b 40 74             	mov    0x74(%eax),%eax
  8011fe:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801200:	85 db                	test   %ebx,%ebx
  801202:	74 0a                	je     80120e <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801204:	a1 04 40 80 00       	mov    0x804004,%eax
  801209:	8b 40 78             	mov    0x78(%eax),%eax
  80120c:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  80120e:	a1 04 40 80 00       	mov    0x804004,%eax
  801213:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801216:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801219:	5b                   	pop    %ebx
  80121a:	5e                   	pop    %esi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	57                   	push   %edi
  801221:	56                   	push   %esi
  801222:	53                   	push   %ebx
  801223:	83 ec 0c             	sub    $0xc,%esp
  801226:	8b 7d 08             	mov    0x8(%ebp),%edi
  801229:	8b 75 0c             	mov    0xc(%ebp),%esi
  80122c:	8b 45 10             	mov    0x10(%ebp),%eax
  80122f:	85 c0                	test   %eax,%eax
  801231:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801236:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801239:	eb 1c                	jmp    801257 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80123b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80123e:	74 12                	je     801252 <ipc_send+0x35>
  801240:	50                   	push   %eax
  801241:	68 f0 27 80 00       	push   $0x8027f0
  801246:	6a 3a                	push   $0x3a
  801248:	68 06 28 80 00       	push   $0x802806
  80124d:	e8 f2 ef ff ff       	call   800244 <_panic>
		sys_yield();
  801252:	e8 ae fa ff ff       	call   800d05 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801257:	ff 75 14             	pushl  0x14(%ebp)
  80125a:	53                   	push   %ebx
  80125b:	56                   	push   %esi
  80125c:	57                   	push   %edi
  80125d:	e8 4f fc ff ff       	call   800eb1 <sys_ipc_try_send>
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	78 d2                	js     80123b <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5f                   	pop    %edi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801277:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80127c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80127f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801285:	8b 52 50             	mov    0x50(%edx),%edx
  801288:	39 ca                	cmp    %ecx,%edx
  80128a:	75 0d                	jne    801299 <ipc_find_env+0x28>
			return envs[i].env_id;
  80128c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80128f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801294:	8b 40 48             	mov    0x48(%eax),%eax
  801297:	eb 0f                	jmp    8012a8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801299:	83 c0 01             	add    $0x1,%eax
  80129c:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012a1:	75 d9                	jne    80127c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b0:	05 00 00 00 30       	add    $0x30000000,%eax
  8012b5:	c1 e8 0c             	shr    $0xc,%eax
}
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    

008012ba <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c0:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012ca:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012cf:	5d                   	pop    %ebp
  8012d0:	c3                   	ret    

008012d1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012dc:	89 c2                	mov    %eax,%edx
  8012de:	c1 ea 16             	shr    $0x16,%edx
  8012e1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e8:	f6 c2 01             	test   $0x1,%dl
  8012eb:	74 11                	je     8012fe <fd_alloc+0x2d>
  8012ed:	89 c2                	mov    %eax,%edx
  8012ef:	c1 ea 0c             	shr    $0xc,%edx
  8012f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f9:	f6 c2 01             	test   $0x1,%dl
  8012fc:	75 09                	jne    801307 <fd_alloc+0x36>
			*fd_store = fd;
  8012fe:	89 01                	mov    %eax,(%ecx)
			return 0;
  801300:	b8 00 00 00 00       	mov    $0x0,%eax
  801305:	eb 17                	jmp    80131e <fd_alloc+0x4d>
  801307:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80130c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801311:	75 c9                	jne    8012dc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801313:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801319:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801326:	83 f8 1f             	cmp    $0x1f,%eax
  801329:	77 36                	ja     801361 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80132b:	c1 e0 0c             	shl    $0xc,%eax
  80132e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801333:	89 c2                	mov    %eax,%edx
  801335:	c1 ea 16             	shr    $0x16,%edx
  801338:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80133f:	f6 c2 01             	test   $0x1,%dl
  801342:	74 24                	je     801368 <fd_lookup+0x48>
  801344:	89 c2                	mov    %eax,%edx
  801346:	c1 ea 0c             	shr    $0xc,%edx
  801349:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801350:	f6 c2 01             	test   $0x1,%dl
  801353:	74 1a                	je     80136f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801355:	8b 55 0c             	mov    0xc(%ebp),%edx
  801358:	89 02                	mov    %eax,(%edx)
	return 0;
  80135a:	b8 00 00 00 00       	mov    $0x0,%eax
  80135f:	eb 13                	jmp    801374 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801361:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801366:	eb 0c                	jmp    801374 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801368:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136d:	eb 05                	jmp    801374 <fd_lookup+0x54>
  80136f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    

00801376 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137f:	ba 90 28 80 00       	mov    $0x802890,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801384:	eb 13                	jmp    801399 <dev_lookup+0x23>
  801386:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801389:	39 08                	cmp    %ecx,(%eax)
  80138b:	75 0c                	jne    801399 <dev_lookup+0x23>
			*dev = devtab[i];
  80138d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801390:	89 01                	mov    %eax,(%ecx)
			return 0;
  801392:	b8 00 00 00 00       	mov    $0x0,%eax
  801397:	eb 2e                	jmp    8013c7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801399:	8b 02                	mov    (%edx),%eax
  80139b:	85 c0                	test   %eax,%eax
  80139d:	75 e7                	jne    801386 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80139f:	a1 04 40 80 00       	mov    0x804004,%eax
  8013a4:	8b 40 48             	mov    0x48(%eax),%eax
  8013a7:	83 ec 04             	sub    $0x4,%esp
  8013aa:	51                   	push   %ecx
  8013ab:	50                   	push   %eax
  8013ac:	68 10 28 80 00       	push   $0x802810
  8013b1:	e8 67 ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  8013b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    

008013c9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	56                   	push   %esi
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 10             	sub    $0x10,%esp
  8013d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013da:	50                   	push   %eax
  8013db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013e1:	c1 e8 0c             	shr    $0xc,%eax
  8013e4:	50                   	push   %eax
  8013e5:	e8 36 ff ff ff       	call   801320 <fd_lookup>
  8013ea:	83 c4 08             	add    $0x8,%esp
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 05                	js     8013f6 <fd_close+0x2d>
	    || fd != fd2)
  8013f1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013f4:	74 0c                	je     801402 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013f6:	84 db                	test   %bl,%bl
  8013f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fd:	0f 44 c2             	cmove  %edx,%eax
  801400:	eb 41                	jmp    801443 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	ff 36                	pushl  (%esi)
  80140b:	e8 66 ff ff ff       	call   801376 <dev_lookup>
  801410:	89 c3                	mov    %eax,%ebx
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	85 c0                	test   %eax,%eax
  801417:	78 1a                	js     801433 <fd_close+0x6a>
		if (dev->dev_close)
  801419:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80141f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801424:	85 c0                	test   %eax,%eax
  801426:	74 0b                	je     801433 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801428:	83 ec 0c             	sub    $0xc,%esp
  80142b:	56                   	push   %esi
  80142c:	ff d0                	call   *%eax
  80142e:	89 c3                	mov    %eax,%ebx
  801430:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	56                   	push   %esi
  801437:	6a 00                	push   $0x0
  801439:	e8 6b f9 ff ff       	call   800da9 <sys_page_unmap>
	return r;
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	89 d8                	mov    %ebx,%eax
}
  801443:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801446:	5b                   	pop    %ebx
  801447:	5e                   	pop    %esi
  801448:	5d                   	pop    %ebp
  801449:	c3                   	ret    

0080144a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801450:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801453:	50                   	push   %eax
  801454:	ff 75 08             	pushl  0x8(%ebp)
  801457:	e8 c4 fe ff ff       	call   801320 <fd_lookup>
  80145c:	83 c4 08             	add    $0x8,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 10                	js     801473 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	6a 01                	push   $0x1
  801468:	ff 75 f4             	pushl  -0xc(%ebp)
  80146b:	e8 59 ff ff ff       	call   8013c9 <fd_close>
  801470:	83 c4 10             	add    $0x10,%esp
}
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <close_all>:

void
close_all(void)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	53                   	push   %ebx
  801479:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80147c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801481:	83 ec 0c             	sub    $0xc,%esp
  801484:	53                   	push   %ebx
  801485:	e8 c0 ff ff ff       	call   80144a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80148a:	83 c3 01             	add    $0x1,%ebx
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	83 fb 20             	cmp    $0x20,%ebx
  801493:	75 ec                	jne    801481 <close_all+0xc>
		close(i);
}
  801495:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	57                   	push   %edi
  80149e:	56                   	push   %esi
  80149f:	53                   	push   %ebx
  8014a0:	83 ec 2c             	sub    $0x2c,%esp
  8014a3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014a9:	50                   	push   %eax
  8014aa:	ff 75 08             	pushl  0x8(%ebp)
  8014ad:	e8 6e fe ff ff       	call   801320 <fd_lookup>
  8014b2:	83 c4 08             	add    $0x8,%esp
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	0f 88 c1 00 00 00    	js     80157e <dup+0xe4>
		return r;
	close(newfdnum);
  8014bd:	83 ec 0c             	sub    $0xc,%esp
  8014c0:	56                   	push   %esi
  8014c1:	e8 84 ff ff ff       	call   80144a <close>

	newfd = INDEX2FD(newfdnum);
  8014c6:	89 f3                	mov    %esi,%ebx
  8014c8:	c1 e3 0c             	shl    $0xc,%ebx
  8014cb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014d1:	83 c4 04             	add    $0x4,%esp
  8014d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014d7:	e8 de fd ff ff       	call   8012ba <fd2data>
  8014dc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014de:	89 1c 24             	mov    %ebx,(%esp)
  8014e1:	e8 d4 fd ff ff       	call   8012ba <fd2data>
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ec:	89 f8                	mov    %edi,%eax
  8014ee:	c1 e8 16             	shr    $0x16,%eax
  8014f1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014f8:	a8 01                	test   $0x1,%al
  8014fa:	74 37                	je     801533 <dup+0x99>
  8014fc:	89 f8                	mov    %edi,%eax
  8014fe:	c1 e8 0c             	shr    $0xc,%eax
  801501:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801508:	f6 c2 01             	test   $0x1,%dl
  80150b:	74 26                	je     801533 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80150d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801514:	83 ec 0c             	sub    $0xc,%esp
  801517:	25 07 0e 00 00       	and    $0xe07,%eax
  80151c:	50                   	push   %eax
  80151d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801520:	6a 00                	push   $0x0
  801522:	57                   	push   %edi
  801523:	6a 00                	push   $0x0
  801525:	e8 3d f8 ff ff       	call   800d67 <sys_page_map>
  80152a:	89 c7                	mov    %eax,%edi
  80152c:	83 c4 20             	add    $0x20,%esp
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 2e                	js     801561 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801533:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801536:	89 d0                	mov    %edx,%eax
  801538:	c1 e8 0c             	shr    $0xc,%eax
  80153b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801542:	83 ec 0c             	sub    $0xc,%esp
  801545:	25 07 0e 00 00       	and    $0xe07,%eax
  80154a:	50                   	push   %eax
  80154b:	53                   	push   %ebx
  80154c:	6a 00                	push   $0x0
  80154e:	52                   	push   %edx
  80154f:	6a 00                	push   $0x0
  801551:	e8 11 f8 ff ff       	call   800d67 <sys_page_map>
  801556:	89 c7                	mov    %eax,%edi
  801558:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80155b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80155d:	85 ff                	test   %edi,%edi
  80155f:	79 1d                	jns    80157e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801561:	83 ec 08             	sub    $0x8,%esp
  801564:	53                   	push   %ebx
  801565:	6a 00                	push   $0x0
  801567:	e8 3d f8 ff ff       	call   800da9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80156c:	83 c4 08             	add    $0x8,%esp
  80156f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801572:	6a 00                	push   $0x0
  801574:	e8 30 f8 ff ff       	call   800da9 <sys_page_unmap>
	return r;
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	89 f8                	mov    %edi,%eax
}
  80157e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801581:	5b                   	pop    %ebx
  801582:	5e                   	pop    %esi
  801583:	5f                   	pop    %edi
  801584:	5d                   	pop    %ebp
  801585:	c3                   	ret    

00801586 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	53                   	push   %ebx
  80158a:	83 ec 14             	sub    $0x14,%esp
  80158d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801590:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	53                   	push   %ebx
  801595:	e8 86 fd ff ff       	call   801320 <fd_lookup>
  80159a:	83 c4 08             	add    $0x8,%esp
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 6d                	js     801610 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	ff 30                	pushl  (%eax)
  8015af:	e8 c2 fd ff ff       	call   801376 <dev_lookup>
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 4c                	js     801607 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015be:	8b 42 08             	mov    0x8(%edx),%eax
  8015c1:	83 e0 03             	and    $0x3,%eax
  8015c4:	83 f8 01             	cmp    $0x1,%eax
  8015c7:	75 21                	jne    8015ea <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ce:	8b 40 48             	mov    0x48(%eax),%eax
  8015d1:	83 ec 04             	sub    $0x4,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	50                   	push   %eax
  8015d6:	68 54 28 80 00       	push   $0x802854
  8015db:	e8 3d ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e8:	eb 26                	jmp    801610 <read+0x8a>
	}
	if (!dev->dev_read)
  8015ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ed:	8b 40 08             	mov    0x8(%eax),%eax
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	74 17                	je     80160b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015f4:	83 ec 04             	sub    $0x4,%esp
  8015f7:	ff 75 10             	pushl  0x10(%ebp)
  8015fa:	ff 75 0c             	pushl  0xc(%ebp)
  8015fd:	52                   	push   %edx
  8015fe:	ff d0                	call   *%eax
  801600:	89 c2                	mov    %eax,%edx
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	eb 09                	jmp    801610 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801607:	89 c2                	mov    %eax,%edx
  801609:	eb 05                	jmp    801610 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80160b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801610:	89 d0                	mov    %edx,%eax
  801612:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	57                   	push   %edi
  80161b:	56                   	push   %esi
  80161c:	53                   	push   %ebx
  80161d:	83 ec 0c             	sub    $0xc,%esp
  801620:	8b 7d 08             	mov    0x8(%ebp),%edi
  801623:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801626:	bb 00 00 00 00       	mov    $0x0,%ebx
  80162b:	eb 21                	jmp    80164e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80162d:	83 ec 04             	sub    $0x4,%esp
  801630:	89 f0                	mov    %esi,%eax
  801632:	29 d8                	sub    %ebx,%eax
  801634:	50                   	push   %eax
  801635:	89 d8                	mov    %ebx,%eax
  801637:	03 45 0c             	add    0xc(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	57                   	push   %edi
  80163c:	e8 45 ff ff ff       	call   801586 <read>
		if (m < 0)
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	85 c0                	test   %eax,%eax
  801646:	78 10                	js     801658 <readn+0x41>
			return m;
		if (m == 0)
  801648:	85 c0                	test   %eax,%eax
  80164a:	74 0a                	je     801656 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164c:	01 c3                	add    %eax,%ebx
  80164e:	39 f3                	cmp    %esi,%ebx
  801650:	72 db                	jb     80162d <readn+0x16>
  801652:	89 d8                	mov    %ebx,%eax
  801654:	eb 02                	jmp    801658 <readn+0x41>
  801656:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801658:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165b:	5b                   	pop    %ebx
  80165c:	5e                   	pop    %esi
  80165d:	5f                   	pop    %edi
  80165e:	5d                   	pop    %ebp
  80165f:	c3                   	ret    

00801660 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	53                   	push   %ebx
  801664:	83 ec 14             	sub    $0x14,%esp
  801667:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166d:	50                   	push   %eax
  80166e:	53                   	push   %ebx
  80166f:	e8 ac fc ff ff       	call   801320 <fd_lookup>
  801674:	83 c4 08             	add    $0x8,%esp
  801677:	89 c2                	mov    %eax,%edx
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 68                	js     8016e5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167d:	83 ec 08             	sub    $0x8,%esp
  801680:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801683:	50                   	push   %eax
  801684:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801687:	ff 30                	pushl  (%eax)
  801689:	e8 e8 fc ff ff       	call   801376 <dev_lookup>
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	85 c0                	test   %eax,%eax
  801693:	78 47                	js     8016dc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801695:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801698:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80169c:	75 21                	jne    8016bf <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80169e:	a1 04 40 80 00       	mov    0x804004,%eax
  8016a3:	8b 40 48             	mov    0x48(%eax),%eax
  8016a6:	83 ec 04             	sub    $0x4,%esp
  8016a9:	53                   	push   %ebx
  8016aa:	50                   	push   %eax
  8016ab:	68 70 28 80 00       	push   $0x802870
  8016b0:	e8 68 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016bd:	eb 26                	jmp    8016e5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c2:	8b 52 0c             	mov    0xc(%edx),%edx
  8016c5:	85 d2                	test   %edx,%edx
  8016c7:	74 17                	je     8016e0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016c9:	83 ec 04             	sub    $0x4,%esp
  8016cc:	ff 75 10             	pushl  0x10(%ebp)
  8016cf:	ff 75 0c             	pushl  0xc(%ebp)
  8016d2:	50                   	push   %eax
  8016d3:	ff d2                	call   *%edx
  8016d5:	89 c2                	mov    %eax,%edx
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	eb 09                	jmp    8016e5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dc:	89 c2                	mov    %eax,%edx
  8016de:	eb 05                	jmp    8016e5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016e5:	89 d0                	mov    %edx,%eax
  8016e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    

008016ec <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016f2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016f5:	50                   	push   %eax
  8016f6:	ff 75 08             	pushl  0x8(%ebp)
  8016f9:	e8 22 fc ff ff       	call   801320 <fd_lookup>
  8016fe:	83 c4 08             	add    $0x8,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	78 0e                	js     801713 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801705:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801708:	8b 55 0c             	mov    0xc(%ebp),%edx
  80170b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80170e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	53                   	push   %ebx
  801719:	83 ec 14             	sub    $0x14,%esp
  80171c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801722:	50                   	push   %eax
  801723:	53                   	push   %ebx
  801724:	e8 f7 fb ff ff       	call   801320 <fd_lookup>
  801729:	83 c4 08             	add    $0x8,%esp
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 65                	js     801797 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801738:	50                   	push   %eax
  801739:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173c:	ff 30                	pushl  (%eax)
  80173e:	e8 33 fc ff ff       	call   801376 <dev_lookup>
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	85 c0                	test   %eax,%eax
  801748:	78 44                	js     80178e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80174a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801751:	75 21                	jne    801774 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801753:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801758:	8b 40 48             	mov    0x48(%eax),%eax
  80175b:	83 ec 04             	sub    $0x4,%esp
  80175e:	53                   	push   %ebx
  80175f:	50                   	push   %eax
  801760:	68 30 28 80 00       	push   $0x802830
  801765:	e8 b3 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801772:	eb 23                	jmp    801797 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801774:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801777:	8b 52 18             	mov    0x18(%edx),%edx
  80177a:	85 d2                	test   %edx,%edx
  80177c:	74 14                	je     801792 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80177e:	83 ec 08             	sub    $0x8,%esp
  801781:	ff 75 0c             	pushl  0xc(%ebp)
  801784:	50                   	push   %eax
  801785:	ff d2                	call   *%edx
  801787:	89 c2                	mov    %eax,%edx
  801789:	83 c4 10             	add    $0x10,%esp
  80178c:	eb 09                	jmp    801797 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178e:	89 c2                	mov    %eax,%edx
  801790:	eb 05                	jmp    801797 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801792:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801797:	89 d0                	mov    %edx,%eax
  801799:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    

0080179e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	53                   	push   %ebx
  8017a2:	83 ec 14             	sub    $0x14,%esp
  8017a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ab:	50                   	push   %eax
  8017ac:	ff 75 08             	pushl  0x8(%ebp)
  8017af:	e8 6c fb ff ff       	call   801320 <fd_lookup>
  8017b4:	83 c4 08             	add    $0x8,%esp
  8017b7:	89 c2                	mov    %eax,%edx
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 58                	js     801815 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c3:	50                   	push   %eax
  8017c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c7:	ff 30                	pushl  (%eax)
  8017c9:	e8 a8 fb ff ff       	call   801376 <dev_lookup>
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 37                	js     80180c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017dc:	74 32                	je     801810 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017de:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017e1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017e8:	00 00 00 
	stat->st_isdir = 0;
  8017eb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017f2:	00 00 00 
	stat->st_dev = dev;
  8017f5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	53                   	push   %ebx
  8017ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801802:	ff 50 14             	call   *0x14(%eax)
  801805:	89 c2                	mov    %eax,%edx
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	eb 09                	jmp    801815 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180c:	89 c2                	mov    %eax,%edx
  80180e:	eb 05                	jmp    801815 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801810:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801815:	89 d0                	mov    %edx,%eax
  801817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	6a 00                	push   $0x0
  801826:	ff 75 08             	pushl  0x8(%ebp)
  801829:	e8 e3 01 00 00       	call   801a11 <open>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	78 1b                	js     801852 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801837:	83 ec 08             	sub    $0x8,%esp
  80183a:	ff 75 0c             	pushl  0xc(%ebp)
  80183d:	50                   	push   %eax
  80183e:	e8 5b ff ff ff       	call   80179e <fstat>
  801843:	89 c6                	mov    %eax,%esi
	close(fd);
  801845:	89 1c 24             	mov    %ebx,(%esp)
  801848:	e8 fd fb ff ff       	call   80144a <close>
	return r;
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	89 f0                	mov    %esi,%eax
}
  801852:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801855:	5b                   	pop    %ebx
  801856:	5e                   	pop    %esi
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    

00801859 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	56                   	push   %esi
  80185d:	53                   	push   %ebx
  80185e:	89 c6                	mov    %eax,%esi
  801860:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801862:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801869:	75 12                	jne    80187d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80186b:	83 ec 0c             	sub    $0xc,%esp
  80186e:	6a 01                	push   $0x1
  801870:	e8 fc f9 ff ff       	call   801271 <ipc_find_env>
  801875:	a3 00 40 80 00       	mov    %eax,0x804000
  80187a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80187d:	6a 07                	push   $0x7
  80187f:	68 00 50 80 00       	push   $0x805000
  801884:	56                   	push   %esi
  801885:	ff 35 00 40 80 00    	pushl  0x804000
  80188b:	e8 8d f9 ff ff       	call   80121d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801890:	83 c4 0c             	add    $0xc,%esp
  801893:	6a 00                	push   $0x0
  801895:	53                   	push   %ebx
  801896:	6a 00                	push   $0x0
  801898:	e8 17 f9 ff ff       	call   8011b4 <ipc_recv>
}
  80189d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a0:	5b                   	pop    %ebx
  8018a1:	5e                   	pop    %esi
  8018a2:	5d                   	pop    %ebp
  8018a3:	c3                   	ret    

008018a4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c2:	b8 02 00 00 00       	mov    $0x2,%eax
  8018c7:	e8 8d ff ff ff       	call   801859 <fsipc>
}
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018da:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018df:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e4:	b8 06 00 00 00       	mov    $0x6,%eax
  8018e9:	e8 6b ff ff ff       	call   801859 <fsipc>
}
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	53                   	push   %ebx
  8018f4:	83 ec 04             	sub    $0x4,%esp
  8018f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801900:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801905:	ba 00 00 00 00       	mov    $0x0,%edx
  80190a:	b8 05 00 00 00       	mov    $0x5,%eax
  80190f:	e8 45 ff ff ff       	call   801859 <fsipc>
  801914:	85 c0                	test   %eax,%eax
  801916:	78 2c                	js     801944 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801918:	83 ec 08             	sub    $0x8,%esp
  80191b:	68 00 50 80 00       	push   $0x805000
  801920:	53                   	push   %ebx
  801921:	e8 fb ef ff ff       	call   800921 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801926:	a1 80 50 80 00       	mov    0x805080,%eax
  80192b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801931:	a1 84 50 80 00       	mov    0x805084,%eax
  801936:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801944:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801947:	c9                   	leave  
  801948:	c3                   	ret    

00801949 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	83 ec 0c             	sub    $0xc,%esp
  80194f:	8b 45 10             	mov    0x10(%ebp),%eax
  801952:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801957:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80195c:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80195f:	8b 55 08             	mov    0x8(%ebp),%edx
  801962:	8b 52 0c             	mov    0xc(%edx),%edx
  801965:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80196b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801970:	50                   	push   %eax
  801971:	ff 75 0c             	pushl  0xc(%ebp)
  801974:	68 08 50 80 00       	push   $0x805008
  801979:	e8 35 f1 ff ff       	call   800ab3 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80197e:	ba 00 00 00 00       	mov    $0x0,%edx
  801983:	b8 04 00 00 00       	mov    $0x4,%eax
  801988:	e8 cc fe ff ff       	call   801859 <fsipc>
	//panic("devfile_write not implemented");
}
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	56                   	push   %esi
  801993:	53                   	push   %ebx
  801994:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801997:	8b 45 08             	mov    0x8(%ebp),%eax
  80199a:	8b 40 0c             	mov    0xc(%eax),%eax
  80199d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019a2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b2:	e8 a2 fe ff ff       	call   801859 <fsipc>
  8019b7:	89 c3                	mov    %eax,%ebx
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	78 4b                	js     801a08 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019bd:	39 c6                	cmp    %eax,%esi
  8019bf:	73 16                	jae    8019d7 <devfile_read+0x48>
  8019c1:	68 a0 28 80 00       	push   $0x8028a0
  8019c6:	68 a7 28 80 00       	push   $0x8028a7
  8019cb:	6a 7c                	push   $0x7c
  8019cd:	68 bc 28 80 00       	push   $0x8028bc
  8019d2:	e8 6d e8 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  8019d7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019dc:	7e 16                	jle    8019f4 <devfile_read+0x65>
  8019de:	68 c7 28 80 00       	push   $0x8028c7
  8019e3:	68 a7 28 80 00       	push   $0x8028a7
  8019e8:	6a 7d                	push   $0x7d
  8019ea:	68 bc 28 80 00       	push   $0x8028bc
  8019ef:	e8 50 e8 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019f4:	83 ec 04             	sub    $0x4,%esp
  8019f7:	50                   	push   %eax
  8019f8:	68 00 50 80 00       	push   $0x805000
  8019fd:	ff 75 0c             	pushl  0xc(%ebp)
  801a00:	e8 ae f0 ff ff       	call   800ab3 <memmove>
	return r;
  801a05:	83 c4 10             	add    $0x10,%esp
}
  801a08:	89 d8                	mov    %ebx,%eax
  801a0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5e                   	pop    %esi
  801a0f:	5d                   	pop    %ebp
  801a10:	c3                   	ret    

00801a11 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	53                   	push   %ebx
  801a15:	83 ec 20             	sub    $0x20,%esp
  801a18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a1b:	53                   	push   %ebx
  801a1c:	e8 c7 ee ff ff       	call   8008e8 <strlen>
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a29:	7f 67                	jg     801a92 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a31:	50                   	push   %eax
  801a32:	e8 9a f8 ff ff       	call   8012d1 <fd_alloc>
  801a37:	83 c4 10             	add    $0x10,%esp
		return r;
  801a3a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 57                	js     801a97 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	53                   	push   %ebx
  801a44:	68 00 50 80 00       	push   $0x805000
  801a49:	e8 d3 ee ff ff       	call   800921 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a51:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a59:	b8 01 00 00 00       	mov    $0x1,%eax
  801a5e:	e8 f6 fd ff ff       	call   801859 <fsipc>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	79 14                	jns    801a80 <open+0x6f>
		fd_close(fd, 0);
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	6a 00                	push   $0x0
  801a71:	ff 75 f4             	pushl  -0xc(%ebp)
  801a74:	e8 50 f9 ff ff       	call   8013c9 <fd_close>
		return r;
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	89 da                	mov    %ebx,%edx
  801a7e:	eb 17                	jmp    801a97 <open+0x86>
	}

	return fd2num(fd);
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	ff 75 f4             	pushl  -0xc(%ebp)
  801a86:	e8 1f f8 ff ff       	call   8012aa <fd2num>
  801a8b:	89 c2                	mov    %eax,%edx
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	eb 05                	jmp    801a97 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a92:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a97:	89 d0                	mov    %edx,%eax
  801a99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa9:	b8 08 00 00 00       	mov    $0x8,%eax
  801aae:	e8 a6 fd ff ff       	call   801859 <fsipc>
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801abb:	89 d0                	mov    %edx,%eax
  801abd:	c1 e8 16             	shr    $0x16,%eax
  801ac0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ac7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801acc:	f6 c1 01             	test   $0x1,%cl
  801acf:	74 1d                	je     801aee <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ad1:	c1 ea 0c             	shr    $0xc,%edx
  801ad4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801adb:	f6 c2 01             	test   $0x1,%dl
  801ade:	74 0e                	je     801aee <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ae0:	c1 ea 0c             	shr    $0xc,%edx
  801ae3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801aea:	ef 
  801aeb:	0f b7 c0             	movzwl %ax,%eax
}
  801aee:	5d                   	pop    %ebp
  801aef:	c3                   	ret    

00801af0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	56                   	push   %esi
  801af4:	53                   	push   %ebx
  801af5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	ff 75 08             	pushl  0x8(%ebp)
  801afe:	e8 b7 f7 ff ff       	call   8012ba <fd2data>
  801b03:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b05:	83 c4 08             	add    $0x8,%esp
  801b08:	68 d3 28 80 00       	push   $0x8028d3
  801b0d:	53                   	push   %ebx
  801b0e:	e8 0e ee ff ff       	call   800921 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b13:	8b 46 04             	mov    0x4(%esi),%eax
  801b16:	2b 06                	sub    (%esi),%eax
  801b18:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b1e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b25:	00 00 00 
	stat->st_dev = &devpipe;
  801b28:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b2f:	30 80 00 
	return 0;
}
  801b32:	b8 00 00 00 00       	mov    $0x0,%eax
  801b37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5e                   	pop    %esi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	53                   	push   %ebx
  801b42:	83 ec 0c             	sub    $0xc,%esp
  801b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b48:	53                   	push   %ebx
  801b49:	6a 00                	push   $0x0
  801b4b:	e8 59 f2 ff ff       	call   800da9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b50:	89 1c 24             	mov    %ebx,(%esp)
  801b53:	e8 62 f7 ff ff       	call   8012ba <fd2data>
  801b58:	83 c4 08             	add    $0x8,%esp
  801b5b:	50                   	push   %eax
  801b5c:	6a 00                	push   $0x0
  801b5e:	e8 46 f2 ff ff       	call   800da9 <sys_page_unmap>
}
  801b63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b66:	c9                   	leave  
  801b67:	c3                   	ret    

00801b68 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	57                   	push   %edi
  801b6c:	56                   	push   %esi
  801b6d:	53                   	push   %ebx
  801b6e:	83 ec 1c             	sub    $0x1c,%esp
  801b71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b74:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b76:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	ff 75 e0             	pushl  -0x20(%ebp)
  801b84:	e8 2c ff ff ff       	call   801ab5 <pageref>
  801b89:	89 c3                	mov    %eax,%ebx
  801b8b:	89 3c 24             	mov    %edi,(%esp)
  801b8e:	e8 22 ff ff ff       	call   801ab5 <pageref>
  801b93:	83 c4 10             	add    $0x10,%esp
  801b96:	39 c3                	cmp    %eax,%ebx
  801b98:	0f 94 c1             	sete   %cl
  801b9b:	0f b6 c9             	movzbl %cl,%ecx
  801b9e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ba1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ba7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801baa:	39 ce                	cmp    %ecx,%esi
  801bac:	74 1b                	je     801bc9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bae:	39 c3                	cmp    %eax,%ebx
  801bb0:	75 c4                	jne    801b76 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bb2:	8b 42 58             	mov    0x58(%edx),%eax
  801bb5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb8:	50                   	push   %eax
  801bb9:	56                   	push   %esi
  801bba:	68 da 28 80 00       	push   $0x8028da
  801bbf:	e8 59 e7 ff ff       	call   80031d <cprintf>
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	eb ad                	jmp    801b76 <_pipeisclosed+0xe>
	}
}
  801bc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5f                   	pop    %edi
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	57                   	push   %edi
  801bd8:	56                   	push   %esi
  801bd9:	53                   	push   %ebx
  801bda:	83 ec 28             	sub    $0x28,%esp
  801bdd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801be0:	56                   	push   %esi
  801be1:	e8 d4 f6 ff ff       	call   8012ba <fd2data>
  801be6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	bf 00 00 00 00       	mov    $0x0,%edi
  801bf0:	eb 4b                	jmp    801c3d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bf2:	89 da                	mov    %ebx,%edx
  801bf4:	89 f0                	mov    %esi,%eax
  801bf6:	e8 6d ff ff ff       	call   801b68 <_pipeisclosed>
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	75 48                	jne    801c47 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bff:	e8 01 f1 ff ff       	call   800d05 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c04:	8b 43 04             	mov    0x4(%ebx),%eax
  801c07:	8b 0b                	mov    (%ebx),%ecx
  801c09:	8d 51 20             	lea    0x20(%ecx),%edx
  801c0c:	39 d0                	cmp    %edx,%eax
  801c0e:	73 e2                	jae    801bf2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c13:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c17:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c1a:	89 c2                	mov    %eax,%edx
  801c1c:	c1 fa 1f             	sar    $0x1f,%edx
  801c1f:	89 d1                	mov    %edx,%ecx
  801c21:	c1 e9 1b             	shr    $0x1b,%ecx
  801c24:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c27:	83 e2 1f             	and    $0x1f,%edx
  801c2a:	29 ca                	sub    %ecx,%edx
  801c2c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c30:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c34:	83 c0 01             	add    $0x1,%eax
  801c37:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3a:	83 c7 01             	add    $0x1,%edi
  801c3d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c40:	75 c2                	jne    801c04 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c42:	8b 45 10             	mov    0x10(%ebp),%eax
  801c45:	eb 05                	jmp    801c4c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c47:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4f:	5b                   	pop    %ebx
  801c50:	5e                   	pop    %esi
  801c51:	5f                   	pop    %edi
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    

00801c54 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	57                   	push   %edi
  801c58:	56                   	push   %esi
  801c59:	53                   	push   %ebx
  801c5a:	83 ec 18             	sub    $0x18,%esp
  801c5d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c60:	57                   	push   %edi
  801c61:	e8 54 f6 ff ff       	call   8012ba <fd2data>
  801c66:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c70:	eb 3d                	jmp    801caf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c72:	85 db                	test   %ebx,%ebx
  801c74:	74 04                	je     801c7a <devpipe_read+0x26>
				return i;
  801c76:	89 d8                	mov    %ebx,%eax
  801c78:	eb 44                	jmp    801cbe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c7a:	89 f2                	mov    %esi,%edx
  801c7c:	89 f8                	mov    %edi,%eax
  801c7e:	e8 e5 fe ff ff       	call   801b68 <_pipeisclosed>
  801c83:	85 c0                	test   %eax,%eax
  801c85:	75 32                	jne    801cb9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c87:	e8 79 f0 ff ff       	call   800d05 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c8c:	8b 06                	mov    (%esi),%eax
  801c8e:	3b 46 04             	cmp    0x4(%esi),%eax
  801c91:	74 df                	je     801c72 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c93:	99                   	cltd   
  801c94:	c1 ea 1b             	shr    $0x1b,%edx
  801c97:	01 d0                	add    %edx,%eax
  801c99:	83 e0 1f             	and    $0x1f,%eax
  801c9c:	29 d0                	sub    %edx,%eax
  801c9e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ca9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cac:	83 c3 01             	add    $0x1,%ebx
  801caf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cb2:	75 d8                	jne    801c8c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cb4:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb7:	eb 05                	jmp    801cbe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc1:	5b                   	pop    %ebx
  801cc2:	5e                   	pop    %esi
  801cc3:	5f                   	pop    %edi
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    

00801cc6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	56                   	push   %esi
  801cca:	53                   	push   %ebx
  801ccb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd1:	50                   	push   %eax
  801cd2:	e8 fa f5 ff ff       	call   8012d1 <fd_alloc>
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	89 c2                	mov    %eax,%edx
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	0f 88 2c 01 00 00    	js     801e10 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce4:	83 ec 04             	sub    $0x4,%esp
  801ce7:	68 07 04 00 00       	push   $0x407
  801cec:	ff 75 f4             	pushl  -0xc(%ebp)
  801cef:	6a 00                	push   $0x0
  801cf1:	e8 2e f0 ff ff       	call   800d24 <sys_page_alloc>
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	89 c2                	mov    %eax,%edx
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	0f 88 0d 01 00 00    	js     801e10 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d03:	83 ec 0c             	sub    $0xc,%esp
  801d06:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d09:	50                   	push   %eax
  801d0a:	e8 c2 f5 ff ff       	call   8012d1 <fd_alloc>
  801d0f:	89 c3                	mov    %eax,%ebx
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	85 c0                	test   %eax,%eax
  801d16:	0f 88 e2 00 00 00    	js     801dfe <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1c:	83 ec 04             	sub    $0x4,%esp
  801d1f:	68 07 04 00 00       	push   $0x407
  801d24:	ff 75 f0             	pushl  -0x10(%ebp)
  801d27:	6a 00                	push   $0x0
  801d29:	e8 f6 ef ff ff       	call   800d24 <sys_page_alloc>
  801d2e:	89 c3                	mov    %eax,%ebx
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	85 c0                	test   %eax,%eax
  801d35:	0f 88 c3 00 00 00    	js     801dfe <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d3b:	83 ec 0c             	sub    $0xc,%esp
  801d3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d41:	e8 74 f5 ff ff       	call   8012ba <fd2data>
  801d46:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d48:	83 c4 0c             	add    $0xc,%esp
  801d4b:	68 07 04 00 00       	push   $0x407
  801d50:	50                   	push   %eax
  801d51:	6a 00                	push   $0x0
  801d53:	e8 cc ef ff ff       	call   800d24 <sys_page_alloc>
  801d58:	89 c3                	mov    %eax,%ebx
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	0f 88 89 00 00 00    	js     801dee <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d65:	83 ec 0c             	sub    $0xc,%esp
  801d68:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6b:	e8 4a f5 ff ff       	call   8012ba <fd2data>
  801d70:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d77:	50                   	push   %eax
  801d78:	6a 00                	push   $0x0
  801d7a:	56                   	push   %esi
  801d7b:	6a 00                	push   $0x0
  801d7d:	e8 e5 ef ff ff       	call   800d67 <sys_page_map>
  801d82:	89 c3                	mov    %eax,%ebx
  801d84:	83 c4 20             	add    $0x20,%esp
  801d87:	85 c0                	test   %eax,%eax
  801d89:	78 55                	js     801de0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d8b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d94:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d99:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801da0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801db5:	83 ec 0c             	sub    $0xc,%esp
  801db8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbb:	e8 ea f4 ff ff       	call   8012aa <fd2num>
  801dc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc5:	83 c4 04             	add    $0x4,%esp
  801dc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801dcb:	e8 da f4 ff ff       	call   8012aa <fd2num>
  801dd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	ba 00 00 00 00       	mov    $0x0,%edx
  801dde:	eb 30                	jmp    801e10 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801de0:	83 ec 08             	sub    $0x8,%esp
  801de3:	56                   	push   %esi
  801de4:	6a 00                	push   $0x0
  801de6:	e8 be ef ff ff       	call   800da9 <sys_page_unmap>
  801deb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dee:	83 ec 08             	sub    $0x8,%esp
  801df1:	ff 75 f0             	pushl  -0x10(%ebp)
  801df4:	6a 00                	push   $0x0
  801df6:	e8 ae ef ff ff       	call   800da9 <sys_page_unmap>
  801dfb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dfe:	83 ec 08             	sub    $0x8,%esp
  801e01:	ff 75 f4             	pushl  -0xc(%ebp)
  801e04:	6a 00                	push   $0x0
  801e06:	e8 9e ef ff ff       	call   800da9 <sys_page_unmap>
  801e0b:	83 c4 10             	add    $0x10,%esp
  801e0e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e10:	89 d0                	mov    %edx,%eax
  801e12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e15:	5b                   	pop    %ebx
  801e16:	5e                   	pop    %esi
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    

00801e19 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e22:	50                   	push   %eax
  801e23:	ff 75 08             	pushl  0x8(%ebp)
  801e26:	e8 f5 f4 ff ff       	call   801320 <fd_lookup>
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 18                	js     801e4a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e32:	83 ec 0c             	sub    $0xc,%esp
  801e35:	ff 75 f4             	pushl  -0xc(%ebp)
  801e38:	e8 7d f4 ff ff       	call   8012ba <fd2data>
	return _pipeisclosed(fd, p);
  801e3d:	89 c2                	mov    %eax,%edx
  801e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e42:	e8 21 fd ff ff       	call   801b68 <_pipeisclosed>
  801e47:	83 c4 10             	add    $0x10,%esp
}
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e54:	5d                   	pop    %ebp
  801e55:	c3                   	ret    

00801e56 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e5c:	68 f2 28 80 00       	push   $0x8028f2
  801e61:	ff 75 0c             	pushl  0xc(%ebp)
  801e64:	e8 b8 ea ff ff       	call   800921 <strcpy>
	return 0;
}
  801e69:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	57                   	push   %edi
  801e74:	56                   	push   %esi
  801e75:	53                   	push   %ebx
  801e76:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e81:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e87:	eb 2d                	jmp    801eb6 <devcons_write+0x46>
		m = n - tot;
  801e89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e8c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e8e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e91:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e96:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e99:	83 ec 04             	sub    $0x4,%esp
  801e9c:	53                   	push   %ebx
  801e9d:	03 45 0c             	add    0xc(%ebp),%eax
  801ea0:	50                   	push   %eax
  801ea1:	57                   	push   %edi
  801ea2:	e8 0c ec ff ff       	call   800ab3 <memmove>
		sys_cputs(buf, m);
  801ea7:	83 c4 08             	add    $0x8,%esp
  801eaa:	53                   	push   %ebx
  801eab:	57                   	push   %edi
  801eac:	e8 b7 ed ff ff       	call   800c68 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb1:	01 de                	add    %ebx,%esi
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	89 f0                	mov    %esi,%eax
  801eb8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ebb:	72 cc                	jb     801e89 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ebd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec0:	5b                   	pop    %ebx
  801ec1:	5e                   	pop    %esi
  801ec2:	5f                   	pop    %edi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    

00801ec5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	83 ec 08             	sub    $0x8,%esp
  801ecb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ed0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed4:	74 2a                	je     801f00 <devcons_read+0x3b>
  801ed6:	eb 05                	jmp    801edd <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ed8:	e8 28 ee ff ff       	call   800d05 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801edd:	e8 a4 ed ff ff       	call   800c86 <sys_cgetc>
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	74 f2                	je     801ed8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	78 16                	js     801f00 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eea:	83 f8 04             	cmp    $0x4,%eax
  801eed:	74 0c                	je     801efb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eef:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef2:	88 02                	mov    %al,(%edx)
	return 1;
  801ef4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef9:	eb 05                	jmp    801f00 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f00:	c9                   	leave  
  801f01:	c3                   	ret    

00801f02 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f08:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f0e:	6a 01                	push   $0x1
  801f10:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f13:	50                   	push   %eax
  801f14:	e8 4f ed ff ff       	call   800c68 <sys_cputs>
}
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	c9                   	leave  
  801f1d:	c3                   	ret    

00801f1e <getchar>:

int
getchar(void)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f24:	6a 01                	push   $0x1
  801f26:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f29:	50                   	push   %eax
  801f2a:	6a 00                	push   $0x0
  801f2c:	e8 55 f6 ff ff       	call   801586 <read>
	if (r < 0)
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	85 c0                	test   %eax,%eax
  801f36:	78 0f                	js     801f47 <getchar+0x29>
		return r;
	if (r < 1)
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	7e 06                	jle    801f42 <getchar+0x24>
		return -E_EOF;
	return c;
  801f3c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f40:	eb 05                	jmp    801f47 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f42:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f52:	50                   	push   %eax
  801f53:	ff 75 08             	pushl  0x8(%ebp)
  801f56:	e8 c5 f3 ff ff       	call   801320 <fd_lookup>
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	78 11                	js     801f73 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f65:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f6b:	39 10                	cmp    %edx,(%eax)
  801f6d:	0f 94 c0             	sete   %al
  801f70:	0f b6 c0             	movzbl %al,%eax
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <opencons>:

int
opencons(void)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7e:	50                   	push   %eax
  801f7f:	e8 4d f3 ff ff       	call   8012d1 <fd_alloc>
  801f84:	83 c4 10             	add    $0x10,%esp
		return r;
  801f87:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	78 3e                	js     801fcb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8d:	83 ec 04             	sub    $0x4,%esp
  801f90:	68 07 04 00 00       	push   $0x407
  801f95:	ff 75 f4             	pushl  -0xc(%ebp)
  801f98:	6a 00                	push   $0x0
  801f9a:	e8 85 ed ff ff       	call   800d24 <sys_page_alloc>
  801f9f:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	78 23                	js     801fcb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fa8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fbd:	83 ec 0c             	sub    $0xc,%esp
  801fc0:	50                   	push   %eax
  801fc1:	e8 e4 f2 ff ff       	call   8012aa <fd2num>
  801fc6:	89 c2                	mov    %eax,%edx
  801fc8:	83 c4 10             	add    $0x10,%esp
}
  801fcb:	89 d0                	mov    %edx,%eax
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    

00801fcf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fd5:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fdc:	75 4a                	jne    802028 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801fde:	a1 04 40 80 00       	mov    0x804004,%eax
  801fe3:	8b 40 48             	mov    0x48(%eax),%eax
  801fe6:	83 ec 04             	sub    $0x4,%esp
  801fe9:	6a 07                	push   $0x7
  801feb:	68 00 f0 bf ee       	push   $0xeebff000
  801ff0:	50                   	push   %eax
  801ff1:	e8 2e ed ff ff       	call   800d24 <sys_page_alloc>
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	79 12                	jns    80200f <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801ffd:	50                   	push   %eax
  801ffe:	68 fe 28 80 00       	push   $0x8028fe
  802003:	6a 21                	push   $0x21
  802005:	68 16 29 80 00       	push   $0x802916
  80200a:	e8 35 e2 ff ff       	call   800244 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80200f:	a1 04 40 80 00       	mov    0x804004,%eax
  802014:	8b 40 48             	mov    0x48(%eax),%eax
  802017:	83 ec 08             	sub    $0x8,%esp
  80201a:	68 32 20 80 00       	push   $0x802032
  80201f:	50                   	push   %eax
  802020:	e8 4a ee ff ff       	call   800e6f <sys_env_set_pgfault_upcall>
  802025:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802028:	8b 45 08             	mov    0x8(%ebp),%eax
  80202b:	a3 00 60 80 00       	mov    %eax,0x806000
  802030:	c9                   	leave  
  802031:	c3                   	ret    

00802032 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802032:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802033:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802038:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80203a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  80203d:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  802040:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  802044:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  802049:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  80204d:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80204f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  802050:	83 c4 04             	add    $0x4,%esp
	popfl
  802053:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802054:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  802055:	c3                   	ret    
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80206b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80206f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 f6                	test   %esi,%esi
  802079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80207d:	89 ca                	mov    %ecx,%edx
  80207f:	89 f8                	mov    %edi,%eax
  802081:	75 3d                	jne    8020c0 <__udivdi3+0x60>
  802083:	39 cf                	cmp    %ecx,%edi
  802085:	0f 87 c5 00 00 00    	ja     802150 <__udivdi3+0xf0>
  80208b:	85 ff                	test   %edi,%edi
  80208d:	89 fd                	mov    %edi,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f7                	div    %edi
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 c8                	mov    %ecx,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c1                	mov    %eax,%ecx
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	89 cf                	mov    %ecx,%edi
  8020a8:	f7 f5                	div    %ebp
  8020aa:	89 c3                	mov    %eax,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 ce                	cmp    %ecx,%esi
  8020c2:	77 74                	ja     802138 <__udivdi3+0xd8>
  8020c4:	0f bd fe             	bsr    %esi,%edi
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	0f 84 98 00 00 00    	je     802168 <__udivdi3+0x108>
  8020d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	89 c5                	mov    %eax,%ebp
  8020d9:	29 fb                	sub    %edi,%ebx
  8020db:	d3 e6                	shl    %cl,%esi
  8020dd:	89 d9                	mov    %ebx,%ecx
  8020df:	d3 ed                	shr    %cl,%ebp
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	09 ee                	or     %ebp,%esi
  8020e7:	89 d9                	mov    %ebx,%ecx
  8020e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ed:	89 d5                	mov    %edx,%ebp
  8020ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020f3:	d3 ed                	shr    %cl,%ebp
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e2                	shl    %cl,%edx
  8020f9:	89 d9                	mov    %ebx,%ecx
  8020fb:	d3 e8                	shr    %cl,%eax
  8020fd:	09 c2                	or     %eax,%edx
  8020ff:	89 d0                	mov    %edx,%eax
  802101:	89 ea                	mov    %ebp,%edx
  802103:	f7 f6                	div    %esi
  802105:	89 d5                	mov    %edx,%ebp
  802107:	89 c3                	mov    %eax,%ebx
  802109:	f7 64 24 0c          	mull   0xc(%esp)
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	72 10                	jb     802121 <__udivdi3+0xc1>
  802111:	8b 74 24 08          	mov    0x8(%esp),%esi
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e6                	shl    %cl,%esi
  802119:	39 c6                	cmp    %eax,%esi
  80211b:	73 07                	jae    802124 <__udivdi3+0xc4>
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	75 03                	jne    802124 <__udivdi3+0xc4>
  802121:	83 eb 01             	sub    $0x1,%ebx
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 d8                	mov    %ebx,%eax
  802128:	89 fa                	mov    %edi,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	31 ff                	xor    %edi,%edi
  80213a:	31 db                	xor    %ebx,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 d8                	mov    %ebx,%eax
  802152:	f7 f7                	div    %edi
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 c3                	mov    %eax,%ebx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 fa                	mov    %edi,%edx
  80215c:	83 c4 1c             	add    $0x1c,%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	39 ce                	cmp    %ecx,%esi
  80216a:	72 0c                	jb     802178 <__udivdi3+0x118>
  80216c:	31 db                	xor    %ebx,%ebx
  80216e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802172:	0f 87 34 ff ff ff    	ja     8020ac <__udivdi3+0x4c>
  802178:	bb 01 00 00 00       	mov    $0x1,%ebx
  80217d:	e9 2a ff ff ff       	jmp    8020ac <__udivdi3+0x4c>
  802182:	66 90                	xchg   %ax,%ax
  802184:	66 90                	xchg   %ax,%ax
  802186:	66 90                	xchg   %ax,%ax
  802188:	66 90                	xchg   %ax,%ax
  80218a:	66 90                	xchg   %ax,%ax
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 d2                	test   %edx,%edx
  8021a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b1:	89 f3                	mov    %esi,%ebx
  8021b3:	89 3c 24             	mov    %edi,(%esp)
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	75 1c                	jne    8021d8 <__umoddi3+0x48>
  8021bc:	39 f7                	cmp    %esi,%edi
  8021be:	76 50                	jbe    802210 <__umoddi3+0x80>
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	f7 f7                	div    %edi
  8021c6:	89 d0                	mov    %edx,%eax
  8021c8:	31 d2                	xor    %edx,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	89 d0                	mov    %edx,%eax
  8021dc:	77 52                	ja     802230 <__umoddi3+0xa0>
  8021de:	0f bd ea             	bsr    %edx,%ebp
  8021e1:	83 f5 1f             	xor    $0x1f,%ebp
  8021e4:	75 5a                	jne    802240 <__umoddi3+0xb0>
  8021e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ea:	0f 82 e0 00 00 00    	jb     8022d0 <__umoddi3+0x140>
  8021f0:	39 0c 24             	cmp    %ecx,(%esp)
  8021f3:	0f 86 d7 00 00 00    	jbe    8022d0 <__umoddi3+0x140>
  8021f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802201:	83 c4 1c             	add    $0x1c,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	85 ff                	test   %edi,%edi
  802212:	89 fd                	mov    %edi,%ebp
  802214:	75 0b                	jne    802221 <__umoddi3+0x91>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f7                	div    %edi
  80221f:	89 c5                	mov    %eax,%ebp
  802221:	89 f0                	mov    %esi,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f5                	div    %ebp
  802227:	89 c8                	mov    %ecx,%eax
  802229:	f7 f5                	div    %ebp
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	eb 99                	jmp    8021c8 <__umoddi3+0x38>
  80222f:	90                   	nop
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	8b 34 24             	mov    (%esp),%esi
  802243:	bf 20 00 00 00       	mov    $0x20,%edi
  802248:	89 e9                	mov    %ebp,%ecx
  80224a:	29 ef                	sub    %ebp,%edi
  80224c:	d3 e0                	shl    %cl,%eax
  80224e:	89 f9                	mov    %edi,%ecx
  802250:	89 f2                	mov    %esi,%edx
  802252:	d3 ea                	shr    %cl,%edx
  802254:	89 e9                	mov    %ebp,%ecx
  802256:	09 c2                	or     %eax,%edx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 14 24             	mov    %edx,(%esp)
  80225d:	89 f2                	mov    %esi,%edx
  80225f:	d3 e2                	shl    %cl,%edx
  802261:	89 f9                	mov    %edi,%ecx
  802263:	89 54 24 04          	mov    %edx,0x4(%esp)
  802267:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	89 c6                	mov    %eax,%esi
  802271:	d3 e3                	shl    %cl,%ebx
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 d0                	mov    %edx,%eax
  802277:	d3 e8                	shr    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	09 d8                	or     %ebx,%eax
  80227d:	89 d3                	mov    %edx,%ebx
  80227f:	89 f2                	mov    %esi,%edx
  802281:	f7 34 24             	divl   (%esp)
  802284:	89 d6                	mov    %edx,%esi
  802286:	d3 e3                	shl    %cl,%ebx
  802288:	f7 64 24 04          	mull   0x4(%esp)
  80228c:	39 d6                	cmp    %edx,%esi
  80228e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802292:	89 d1                	mov    %edx,%ecx
  802294:	89 c3                	mov    %eax,%ebx
  802296:	72 08                	jb     8022a0 <__umoddi3+0x110>
  802298:	75 11                	jne    8022ab <__umoddi3+0x11b>
  80229a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80229e:	73 0b                	jae    8022ab <__umoddi3+0x11b>
  8022a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022a4:	1b 14 24             	sbb    (%esp),%edx
  8022a7:	89 d1                	mov    %edx,%ecx
  8022a9:	89 c3                	mov    %eax,%ebx
  8022ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022af:	29 da                	sub    %ebx,%edx
  8022b1:	19 ce                	sbb    %ecx,%esi
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 f0                	mov    %esi,%eax
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	d3 ea                	shr    %cl,%edx
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	d3 ee                	shr    %cl,%esi
  8022c1:	09 d0                	or     %edx,%eax
  8022c3:	89 f2                	mov    %esi,%edx
  8022c5:	83 c4 1c             	add    $0x1c,%esp
  8022c8:	5b                   	pop    %ebx
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    
  8022cd:	8d 76 00             	lea    0x0(%esi),%esi
  8022d0:	29 f9                	sub    %edi,%ecx
  8022d2:	19 d6                	sbb    %edx,%esi
  8022d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022dc:	e9 18 ff ff ff       	jmp    8021f9 <__umoddi3+0x69>
