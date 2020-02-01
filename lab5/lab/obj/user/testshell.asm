
obj/user/testshell.debug：     文件格式 elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 47 18 00 00       	call   801896 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 3d 18 00 00       	call   801896 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 40 2a 80 00 	movl   $0x802a40,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 ab 2a 80 00 	movl   $0x802aab,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 85 0e 00 00       	call   800f08 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 9e 16 00 00       	call   801730 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 ba 2a 80 00       	push   $0x802aba
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 50 0e 00 00       	call   800f08 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 69 16 00 00       	call   801730 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 b5 2a 80 00       	push   $0x802ab5
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 f9 14 00 00       	call   8015f4 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 ed 14 00 00       	call   8015f4 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 c8 2a 80 00       	push   $0x802ac8
  80011b:	e8 9b 1a 00 00       	call   801bbb <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 d5 2a 80 00       	push   $0x802ad5
  80012f:	6a 13                	push   $0x13
  800131:	68 eb 2a 80 00       	push   $0x802aeb
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 c9 22 00 00       	call   802410 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 fc 2a 80 00       	push   $0x802afc
  800154:	6a 15                	push   $0x15
  800156:	68 eb 2a 80 00       	push   $0x802aeb
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 64 2a 80 00       	push   $0x802a64
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 32 11 00 00       	call   8012a7 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 05 2b 80 00       	push   $0x802b05
  800182:	6a 1a                	push   $0x1a
  800184:	68 eb 2a 80 00       	push   $0x802aeb
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 a7 14 00 00       	call   801644 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 9c 14 00 00       	call   801644 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 44 14 00 00       	call   8015f4 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 3c 14 00 00       	call   8015f4 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 0e 2b 80 00       	push   $0x802b0e
  8001bf:	68 d2 2a 80 00       	push   $0x802ad2
  8001c4:	68 11 2b 80 00       	push   $0x802b11
  8001c9:	e8 f9 1f 00 00       	call   8021c7 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 15 2b 80 00       	push   $0x802b15
  8001dd:	6a 21                	push   $0x21
  8001df:	68 eb 2a 80 00       	push   $0x802aeb
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 01 14 00 00       	call   8015f4 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 f5 13 00 00       	call   8015f4 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 8f 23 00 00       	call   802596 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 dc 13 00 00       	call   8015f4 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 d4 13 00 00       	call   8015f4 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 1f 2b 80 00       	push   $0x802b1f
  800230:	e8 86 19 00 00       	call   801bbb <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 88 2a 80 00       	push   $0x802a88
  800245:	6a 2c                	push   $0x2c
  800247:	68 eb 2a 80 00       	push   $0x802aeb
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 c4 14 00 00       	call   801730 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 b1 14 00 00       	call   801730 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 2d 2b 80 00       	push   $0x802b2d
  80028c:	6a 33                	push   $0x33
  80028e:	68 eb 2a 80 00       	push   $0x802aeb
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 47 2b 80 00       	push   $0x802b47
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 eb 2a 80 00       	push   $0x802aeb
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 61 2b 80 00       	push   $0x802b61
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 76 2b 80 00       	push   $0x802b76
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 a3 08 00 00       	call   800bc1 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 f7 09 00 00       	call   800d53 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 a2 0b 00 00       	call   800f08 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 13 0c 00 00       	call   800fa5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 8f 0b 00 00       	call   800f26 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 3a 0b 00 00       	call   800f08 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 4a 13 00 00       	call   801730 <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 ba 10 00 00       	call   8014ca <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 42 10 00 00       	call   80147b <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 70 0b 00 00       	call   800fc4 <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 d9 0f 00 00       	call   801454 <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  80048f:	e8 f2 0a 00 00       	call   800f86 <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 04 50 80 00       	mov    %eax,0x805004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
        binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

    // call user main routine
    umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

    // exit gracefully
    exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 4a 11 00 00       	call   80161f <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 66 0a 00 00       	call   800f45 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 8f 0a 00 00       	call   800f86 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 8c 2b 80 00       	push   $0x802b8c
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 b8 2a 80 00 	movl   $0x802ab8,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 ae 09 00 00       	call   800f08 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 1a 01 00 00       	call   8006ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 53 09 00 00       	call   800f08 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 7b 21 00 00       	call   8027a0 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 68 22 00 00       	call   8028d0 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 af 2b 80 00 	movsbl 0x802baf(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800686:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	3b 50 04             	cmp    0x4(%eax),%edx
  80068f:	73 0a                	jae    80069b <sprintputch+0x1b>
		*b->buf++ = ch;
  800691:	8d 4a 01             	lea    0x1(%edx),%ecx
  800694:	89 08                	mov    %ecx,(%eax)
  800696:	8b 45 08             	mov    0x8(%ebp),%eax
  800699:	88 02                	mov    %al,(%edx)
}
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006a6:	50                   	push   %eax
  8006a7:	ff 75 10             	pushl  0x10(%ebp)
  8006aa:	ff 75 0c             	pushl  0xc(%ebp)
  8006ad:	ff 75 08             	pushl  0x8(%ebp)
  8006b0:	e8 05 00 00 00       	call   8006ba <vprintfmt>
	va_end(ap);
}
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    

008006ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	57                   	push   %edi
  8006be:	56                   	push   %esi
  8006bf:	53                   	push   %ebx
  8006c0:	83 ec 2c             	sub    $0x2c,%esp
  8006c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006cc:	eb 12                	jmp    8006e0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ce:	85 c0                	test   %eax,%eax
  8006d0:	0f 84 42 04 00 00    	je     800b18 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	50                   	push   %eax
  8006db:	ff d6                	call   *%esi
  8006dd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e0:	83 c7 01             	add    $0x1,%edi
  8006e3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e7:	83 f8 25             	cmp    $0x25,%eax
  8006ea:	75 e2                	jne    8006ce <vprintfmt+0x14>
  8006ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8006f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800705:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070a:	eb 07                	jmp    800713 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80070f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800713:	8d 47 01             	lea    0x1(%edi),%eax
  800716:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800719:	0f b6 07             	movzbl (%edi),%eax
  80071c:	0f b6 d0             	movzbl %al,%edx
  80071f:	83 e8 23             	sub    $0x23,%eax
  800722:	3c 55                	cmp    $0x55,%al
  800724:	0f 87 d3 03 00 00    	ja     800afd <vprintfmt+0x443>
  80072a:	0f b6 c0             	movzbl %al,%eax
  80072d:	ff 24 85 00 2d 80 00 	jmp    *0x802d00(,%eax,4)
  800734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800737:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80073b:	eb d6                	jmp    800713 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800748:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80074b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80074f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800752:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800755:	83 f9 09             	cmp    $0x9,%ecx
  800758:	77 3f                	ja     800799 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80075d:	eb e9                	jmp    800748 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8b 00                	mov    (%eax),%eax
  800764:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8d 40 04             	lea    0x4(%eax),%eax
  80076d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800770:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800773:	eb 2a                	jmp    80079f <vprintfmt+0xe5>
  800775:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800778:	85 c0                	test   %eax,%eax
  80077a:	ba 00 00 00 00       	mov    $0x0,%edx
  80077f:	0f 49 d0             	cmovns %eax,%edx
  800782:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800788:	eb 89                	jmp    800713 <vprintfmt+0x59>
  80078a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80078d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800794:	e9 7a ff ff ff       	jmp    800713 <vprintfmt+0x59>
  800799:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80079c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80079f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007a3:	0f 89 6a ff ff ff    	jns    800713 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007b6:	e9 58 ff ff ff       	jmp    800713 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007bb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007c1:	e9 4d ff ff ff       	jmp    800713 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 78 04             	lea    0x4(%eax),%edi
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	ff 30                	pushl  (%eax)
  8007d2:	ff d6                	call   *%esi
			break;
  8007d4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007d7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007dd:	e9 fe fe ff ff       	jmp    8006e0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 78 04             	lea    0x4(%eax),%edi
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	99                   	cltd   
  8007eb:	31 d0                	xor    %edx,%eax
  8007ed:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007ef:	83 f8 0f             	cmp    $0xf,%eax
  8007f2:	7f 0b                	jg     8007ff <vprintfmt+0x145>
  8007f4:	8b 14 85 60 2e 80 00 	mov    0x802e60(,%eax,4),%edx
  8007fb:	85 d2                	test   %edx,%edx
  8007fd:	75 1b                	jne    80081a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8007ff:	50                   	push   %eax
  800800:	68 c7 2b 80 00       	push   $0x802bc7
  800805:	53                   	push   %ebx
  800806:	56                   	push   %esi
  800807:	e8 91 fe ff ff       	call   80069d <printfmt>
  80080c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800812:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800815:	e9 c6 fe ff ff       	jmp    8006e0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80081a:	52                   	push   %edx
  80081b:	68 35 30 80 00       	push   $0x803035
  800820:	53                   	push   %ebx
  800821:	56                   	push   %esi
  800822:	e8 76 fe ff ff       	call   80069d <printfmt>
  800827:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80082a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800830:	e9 ab fe ff ff       	jmp    8006e0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	83 c0 04             	add    $0x4,%eax
  80083b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800843:	85 ff                	test   %edi,%edi
  800845:	b8 c0 2b 80 00       	mov    $0x802bc0,%eax
  80084a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80084d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800851:	0f 8e 94 00 00 00    	jle    8008eb <vprintfmt+0x231>
  800857:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80085b:	0f 84 98 00 00 00    	je     8008f9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800861:	83 ec 08             	sub    $0x8,%esp
  800864:	ff 75 d0             	pushl  -0x30(%ebp)
  800867:	57                   	push   %edi
  800868:	e8 33 03 00 00       	call   800ba0 <strnlen>
  80086d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800870:	29 c1                	sub    %eax,%ecx
  800872:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800875:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800878:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80087c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80087f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800882:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800884:	eb 0f                	jmp    800895 <vprintfmt+0x1db>
					putch(padc, putdat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	ff 75 e0             	pushl  -0x20(%ebp)
  80088d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ef 01             	sub    $0x1,%edi
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	85 ff                	test   %edi,%edi
  800897:	7f ed                	jg     800886 <vprintfmt+0x1cc>
  800899:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80089c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80089f:	85 c9                	test   %ecx,%ecx
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a6:	0f 49 c1             	cmovns %ecx,%eax
  8008a9:	29 c1                	sub    %eax,%ecx
  8008ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8008ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008b4:	89 cb                	mov    %ecx,%ebx
  8008b6:	eb 4d                	jmp    800905 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008bc:	74 1b                	je     8008d9 <vprintfmt+0x21f>
  8008be:	0f be c0             	movsbl %al,%eax
  8008c1:	83 e8 20             	sub    $0x20,%eax
  8008c4:	83 f8 5e             	cmp    $0x5e,%eax
  8008c7:	76 10                	jbe    8008d9 <vprintfmt+0x21f>
					putch('?', putdat);
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	ff 75 0c             	pushl  0xc(%ebp)
  8008cf:	6a 3f                	push   $0x3f
  8008d1:	ff 55 08             	call   *0x8(%ebp)
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	eb 0d                	jmp    8008e6 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8008d9:	83 ec 08             	sub    $0x8,%esp
  8008dc:	ff 75 0c             	pushl  0xc(%ebp)
  8008df:	52                   	push   %edx
  8008e0:	ff 55 08             	call   *0x8(%ebp)
  8008e3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008e6:	83 eb 01             	sub    $0x1,%ebx
  8008e9:	eb 1a                	jmp    800905 <vprintfmt+0x24b>
  8008eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8008ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008f7:	eb 0c                	jmp    800905 <vprintfmt+0x24b>
  8008f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800902:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800905:	83 c7 01             	add    $0x1,%edi
  800908:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80090c:	0f be d0             	movsbl %al,%edx
  80090f:	85 d2                	test   %edx,%edx
  800911:	74 23                	je     800936 <vprintfmt+0x27c>
  800913:	85 f6                	test   %esi,%esi
  800915:	78 a1                	js     8008b8 <vprintfmt+0x1fe>
  800917:	83 ee 01             	sub    $0x1,%esi
  80091a:	79 9c                	jns    8008b8 <vprintfmt+0x1fe>
  80091c:	89 df                	mov    %ebx,%edi
  80091e:	8b 75 08             	mov    0x8(%ebp),%esi
  800921:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800924:	eb 18                	jmp    80093e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800926:	83 ec 08             	sub    $0x8,%esp
  800929:	53                   	push   %ebx
  80092a:	6a 20                	push   $0x20
  80092c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092e:	83 ef 01             	sub    $0x1,%edi
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	eb 08                	jmp    80093e <vprintfmt+0x284>
  800936:	89 df                	mov    %ebx,%edi
  800938:	8b 75 08             	mov    0x8(%ebp),%esi
  80093b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80093e:	85 ff                	test   %edi,%edi
  800940:	7f e4                	jg     800926 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800942:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800945:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800948:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80094b:	e9 90 fd ff ff       	jmp    8006e0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800950:	83 f9 01             	cmp    $0x1,%ecx
  800953:	7e 19                	jle    80096e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800955:	8b 45 14             	mov    0x14(%ebp),%eax
  800958:	8b 50 04             	mov    0x4(%eax),%edx
  80095b:	8b 00                	mov    (%eax),%eax
  80095d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800960:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	8d 40 08             	lea    0x8(%eax),%eax
  800969:	89 45 14             	mov    %eax,0x14(%ebp)
  80096c:	eb 38                	jmp    8009a6 <vprintfmt+0x2ec>
	else if (lflag)
  80096e:	85 c9                	test   %ecx,%ecx
  800970:	74 1b                	je     80098d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8b 00                	mov    (%eax),%eax
  800977:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80097a:	89 c1                	mov    %eax,%ecx
  80097c:	c1 f9 1f             	sar    $0x1f,%ecx
  80097f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800982:	8b 45 14             	mov    0x14(%ebp),%eax
  800985:	8d 40 04             	lea    0x4(%eax),%eax
  800988:	89 45 14             	mov    %eax,0x14(%ebp)
  80098b:	eb 19                	jmp    8009a6 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80098d:	8b 45 14             	mov    0x14(%ebp),%eax
  800990:	8b 00                	mov    (%eax),%eax
  800992:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800995:	89 c1                	mov    %eax,%ecx
  800997:	c1 f9 1f             	sar    $0x1f,%ecx
  80099a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80099d:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a0:	8d 40 04             	lea    0x4(%eax),%eax
  8009a3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009ac:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009b5:	0f 89 0e 01 00 00    	jns    800ac9 <vprintfmt+0x40f>
				putch('-', putdat);
  8009bb:	83 ec 08             	sub    $0x8,%esp
  8009be:	53                   	push   %ebx
  8009bf:	6a 2d                	push   $0x2d
  8009c1:	ff d6                	call   *%esi
				num = -(long long) num;
  8009c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009c9:	f7 da                	neg    %edx
  8009cb:	83 d1 00             	adc    $0x0,%ecx
  8009ce:	f7 d9                	neg    %ecx
  8009d0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d8:	e9 ec 00 00 00       	jmp    800ac9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009dd:	83 f9 01             	cmp    $0x1,%ecx
  8009e0:	7e 18                	jle    8009fa <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8009e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e5:	8b 10                	mov    (%eax),%edx
  8009e7:	8b 48 04             	mov    0x4(%eax),%ecx
  8009ea:	8d 40 08             	lea    0x8(%eax),%eax
  8009ed:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8009f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009f5:	e9 cf 00 00 00       	jmp    800ac9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8009fa:	85 c9                	test   %ecx,%ecx
  8009fc:	74 1a                	je     800a18 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8009fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800a01:	8b 10                	mov    (%eax),%edx
  800a03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a08:	8d 40 04             	lea    0x4(%eax),%eax
  800a0b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800a0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a13:	e9 b1 00 00 00       	jmp    800ac9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800a18:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1b:	8b 10                	mov    (%eax),%edx
  800a1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a22:	8d 40 04             	lea    0x4(%eax),%eax
  800a25:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800a28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a2d:	e9 97 00 00 00       	jmp    800ac9 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800a32:	83 ec 08             	sub    $0x8,%esp
  800a35:	53                   	push   %ebx
  800a36:	6a 58                	push   $0x58
  800a38:	ff d6                	call   *%esi
			putch('X', putdat);
  800a3a:	83 c4 08             	add    $0x8,%esp
  800a3d:	53                   	push   %ebx
  800a3e:	6a 58                	push   $0x58
  800a40:	ff d6                	call   *%esi
			putch('X', putdat);
  800a42:	83 c4 08             	add    $0x8,%esp
  800a45:	53                   	push   %ebx
  800a46:	6a 58                	push   $0x58
  800a48:	ff d6                	call   *%esi
			break;
  800a4a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800a50:	e9 8b fc ff ff       	jmp    8006e0 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800a55:	83 ec 08             	sub    $0x8,%esp
  800a58:	53                   	push   %ebx
  800a59:	6a 30                	push   $0x30
  800a5b:	ff d6                	call   *%esi
			putch('x', putdat);
  800a5d:	83 c4 08             	add    $0x8,%esp
  800a60:	53                   	push   %ebx
  800a61:	6a 78                	push   $0x78
  800a63:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a65:	8b 45 14             	mov    0x14(%ebp),%eax
  800a68:	8b 10                	mov    (%eax),%edx
  800a6a:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a6f:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a72:	8d 40 04             	lea    0x4(%eax),%eax
  800a75:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a78:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a7d:	eb 4a                	jmp    800ac9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a7f:	83 f9 01             	cmp    $0x1,%ecx
  800a82:	7e 15                	jle    800a99 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800a84:	8b 45 14             	mov    0x14(%ebp),%eax
  800a87:	8b 10                	mov    (%eax),%edx
  800a89:	8b 48 04             	mov    0x4(%eax),%ecx
  800a8c:	8d 40 08             	lea    0x8(%eax),%eax
  800a8f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800a92:	b8 10 00 00 00       	mov    $0x10,%eax
  800a97:	eb 30                	jmp    800ac9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800a99:	85 c9                	test   %ecx,%ecx
  800a9b:	74 17                	je     800ab4 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800a9d:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa0:	8b 10                	mov    (%eax),%edx
  800aa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa7:	8d 40 04             	lea    0x4(%eax),%eax
  800aaa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800aad:	b8 10 00 00 00       	mov    $0x10,%eax
  800ab2:	eb 15                	jmp    800ac9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800ab4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab7:	8b 10                	mov    (%eax),%edx
  800ab9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abe:	8d 40 04             	lea    0x4(%eax),%eax
  800ac1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800ac4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800ad0:	57                   	push   %edi
  800ad1:	ff 75 e0             	pushl  -0x20(%ebp)
  800ad4:	50                   	push   %eax
  800ad5:	51                   	push   %ecx
  800ad6:	52                   	push   %edx
  800ad7:	89 da                	mov    %ebx,%edx
  800ad9:	89 f0                	mov    %esi,%eax
  800adb:	e8 f1 fa ff ff       	call   8005d1 <printnum>
			break;
  800ae0:	83 c4 20             	add    $0x20,%esp
  800ae3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ae6:	e9 f5 fb ff ff       	jmp    8006e0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aeb:	83 ec 08             	sub    $0x8,%esp
  800aee:	53                   	push   %ebx
  800aef:	52                   	push   %edx
  800af0:	ff d6                	call   *%esi
			break;
  800af2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800af8:	e9 e3 fb ff ff       	jmp    8006e0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800afd:	83 ec 08             	sub    $0x8,%esp
  800b00:	53                   	push   %ebx
  800b01:	6a 25                	push   $0x25
  800b03:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b05:	83 c4 10             	add    $0x10,%esp
  800b08:	eb 03                	jmp    800b0d <vprintfmt+0x453>
  800b0a:	83 ef 01             	sub    $0x1,%edi
  800b0d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b11:	75 f7                	jne    800b0a <vprintfmt+0x450>
  800b13:	e9 c8 fb ff ff       	jmp    8006e0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800b18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	83 ec 18             	sub    $0x18,%esp
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b2f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b33:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	74 26                	je     800b67 <vsnprintf+0x47>
  800b41:	85 d2                	test   %edx,%edx
  800b43:	7e 22                	jle    800b67 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b45:	ff 75 14             	pushl  0x14(%ebp)
  800b48:	ff 75 10             	pushl  0x10(%ebp)
  800b4b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b4e:	50                   	push   %eax
  800b4f:	68 80 06 80 00       	push   $0x800680
  800b54:	e8 61 fb ff ff       	call   8006ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b59:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b62:	83 c4 10             	add    $0x10,%esp
  800b65:	eb 05                	jmp    800b6c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b74:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b77:	50                   	push   %eax
  800b78:	ff 75 10             	pushl  0x10(%ebp)
  800b7b:	ff 75 0c             	pushl  0xc(%ebp)
  800b7e:	ff 75 08             	pushl  0x8(%ebp)
  800b81:	e8 9a ff ff ff       	call   800b20 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b93:	eb 03                	jmp    800b98 <strlen+0x10>
		n++;
  800b95:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b98:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b9c:	75 f7                	jne    800b95 <strlen+0xd>
		n++;
	return n;
}
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	eb 03                	jmp    800bb3 <strnlen+0x13>
		n++;
  800bb0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bb3:	39 c2                	cmp    %eax,%edx
  800bb5:	74 08                	je     800bbf <strnlen+0x1f>
  800bb7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800bbb:	75 f3                	jne    800bb0 <strnlen+0x10>
  800bbd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	53                   	push   %ebx
  800bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bcb:	89 c2                	mov    %eax,%edx
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800bd7:	88 5a ff             	mov    %bl,-0x1(%edx)
  800bda:	84 db                	test   %bl,%bl
  800bdc:	75 ef                	jne    800bcd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	53                   	push   %ebx
  800be5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be8:	53                   	push   %ebx
  800be9:	e8 9a ff ff ff       	call   800b88 <strlen>
  800bee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800bf1:	ff 75 0c             	pushl  0xc(%ebp)
  800bf4:	01 d8                	add    %ebx,%eax
  800bf6:	50                   	push   %eax
  800bf7:	e8 c5 ff ff ff       	call   800bc1 <strcpy>
	return dst;
}
  800bfc:	89 d8                	mov    %ebx,%eax
  800bfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	8b 75 08             	mov    0x8(%ebp),%esi
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	89 f3                	mov    %esi,%ebx
  800c10:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c13:	89 f2                	mov    %esi,%edx
  800c15:	eb 0f                	jmp    800c26 <strncpy+0x23>
		*dst++ = *src;
  800c17:	83 c2 01             	add    $0x1,%edx
  800c1a:	0f b6 01             	movzbl (%ecx),%eax
  800c1d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c20:	80 39 01             	cmpb   $0x1,(%ecx)
  800c23:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c26:	39 da                	cmp    %ebx,%edx
  800c28:	75 ed                	jne    800c17 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c2a:	89 f0                	mov    %esi,%eax
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	8b 75 08             	mov    0x8(%ebp),%esi
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 10             	mov    0x10(%ebp),%edx
  800c3e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c40:	85 d2                	test   %edx,%edx
  800c42:	74 21                	je     800c65 <strlcpy+0x35>
  800c44:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c48:	89 f2                	mov    %esi,%edx
  800c4a:	eb 09                	jmp    800c55 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c4c:	83 c2 01             	add    $0x1,%edx
  800c4f:	83 c1 01             	add    $0x1,%ecx
  800c52:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c55:	39 c2                	cmp    %eax,%edx
  800c57:	74 09                	je     800c62 <strlcpy+0x32>
  800c59:	0f b6 19             	movzbl (%ecx),%ebx
  800c5c:	84 db                	test   %bl,%bl
  800c5e:	75 ec                	jne    800c4c <strlcpy+0x1c>
  800c60:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c62:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c65:	29 f0                	sub    %esi,%eax
}
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c71:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c74:	eb 06                	jmp    800c7c <strcmp+0x11>
		p++, q++;
  800c76:	83 c1 01             	add    $0x1,%ecx
  800c79:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c7c:	0f b6 01             	movzbl (%ecx),%eax
  800c7f:	84 c0                	test   %al,%al
  800c81:	74 04                	je     800c87 <strcmp+0x1c>
  800c83:	3a 02                	cmp    (%edx),%al
  800c85:	74 ef                	je     800c76 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c87:	0f b6 c0             	movzbl %al,%eax
  800c8a:	0f b6 12             	movzbl (%edx),%edx
  800c8d:	29 d0                	sub    %edx,%eax
}
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	53                   	push   %ebx
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9b:	89 c3                	mov    %eax,%ebx
  800c9d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ca0:	eb 06                	jmp    800ca8 <strncmp+0x17>
		n--, p++, q++;
  800ca2:	83 c0 01             	add    $0x1,%eax
  800ca5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ca8:	39 d8                	cmp    %ebx,%eax
  800caa:	74 15                	je     800cc1 <strncmp+0x30>
  800cac:	0f b6 08             	movzbl (%eax),%ecx
  800caf:	84 c9                	test   %cl,%cl
  800cb1:	74 04                	je     800cb7 <strncmp+0x26>
  800cb3:	3a 0a                	cmp    (%edx),%cl
  800cb5:	74 eb                	je     800ca2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb7:	0f b6 00             	movzbl (%eax),%eax
  800cba:	0f b6 12             	movzbl (%edx),%edx
  800cbd:	29 d0                	sub    %edx,%eax
  800cbf:	eb 05                	jmp    800cc6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cc6:	5b                   	pop    %ebx
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd3:	eb 07                	jmp    800cdc <strchr+0x13>
		if (*s == c)
  800cd5:	38 ca                	cmp    %cl,%dl
  800cd7:	74 0f                	je     800ce8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cd9:	83 c0 01             	add    $0x1,%eax
  800cdc:	0f b6 10             	movzbl (%eax),%edx
  800cdf:	84 d2                	test   %dl,%dl
  800ce1:	75 f2                	jne    800cd5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf4:	eb 03                	jmp    800cf9 <strfind+0xf>
  800cf6:	83 c0 01             	add    $0x1,%eax
  800cf9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cfc:	38 ca                	cmp    %cl,%dl
  800cfe:	74 04                	je     800d04 <strfind+0x1a>
  800d00:	84 d2                	test   %dl,%dl
  800d02:	75 f2                	jne    800cf6 <strfind+0xc>
			break;
	return (char *) s;
}
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d12:	85 c9                	test   %ecx,%ecx
  800d14:	74 36                	je     800d4c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d16:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d1c:	75 28                	jne    800d46 <memset+0x40>
  800d1e:	f6 c1 03             	test   $0x3,%cl
  800d21:	75 23                	jne    800d46 <memset+0x40>
		c &= 0xFF;
  800d23:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d27:	89 d3                	mov    %edx,%ebx
  800d29:	c1 e3 08             	shl    $0x8,%ebx
  800d2c:	89 d6                	mov    %edx,%esi
  800d2e:	c1 e6 18             	shl    $0x18,%esi
  800d31:	89 d0                	mov    %edx,%eax
  800d33:	c1 e0 10             	shl    $0x10,%eax
  800d36:	09 f0                	or     %esi,%eax
  800d38:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800d3a:	89 d8                	mov    %ebx,%eax
  800d3c:	09 d0                	or     %edx,%eax
  800d3e:	c1 e9 02             	shr    $0x2,%ecx
  800d41:	fc                   	cld    
  800d42:	f3 ab                	rep stos %eax,%es:(%edi)
  800d44:	eb 06                	jmp    800d4c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d49:	fc                   	cld    
  800d4a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d4c:	89 f8                	mov    %edi,%eax
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d61:	39 c6                	cmp    %eax,%esi
  800d63:	73 35                	jae    800d9a <memmove+0x47>
  800d65:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d68:	39 d0                	cmp    %edx,%eax
  800d6a:	73 2e                	jae    800d9a <memmove+0x47>
		s += n;
		d += n;
  800d6c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d6f:	89 d6                	mov    %edx,%esi
  800d71:	09 fe                	or     %edi,%esi
  800d73:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d79:	75 13                	jne    800d8e <memmove+0x3b>
  800d7b:	f6 c1 03             	test   $0x3,%cl
  800d7e:	75 0e                	jne    800d8e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d80:	83 ef 04             	sub    $0x4,%edi
  800d83:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d86:	c1 e9 02             	shr    $0x2,%ecx
  800d89:	fd                   	std    
  800d8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d8c:	eb 09                	jmp    800d97 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d8e:	83 ef 01             	sub    $0x1,%edi
  800d91:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d94:	fd                   	std    
  800d95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d97:	fc                   	cld    
  800d98:	eb 1d                	jmp    800db7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d9a:	89 f2                	mov    %esi,%edx
  800d9c:	09 c2                	or     %eax,%edx
  800d9e:	f6 c2 03             	test   $0x3,%dl
  800da1:	75 0f                	jne    800db2 <memmove+0x5f>
  800da3:	f6 c1 03             	test   $0x3,%cl
  800da6:	75 0a                	jne    800db2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800da8:	c1 e9 02             	shr    $0x2,%ecx
  800dab:	89 c7                	mov    %eax,%edi
  800dad:	fc                   	cld    
  800dae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800db0:	eb 05                	jmp    800db7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800db2:	89 c7                	mov    %eax,%edi
  800db4:	fc                   	cld    
  800db5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800dbe:	ff 75 10             	pushl  0x10(%ebp)
  800dc1:	ff 75 0c             	pushl  0xc(%ebp)
  800dc4:	ff 75 08             	pushl  0x8(%ebp)
  800dc7:	e8 87 ff ff ff       	call   800d53 <memmove>
}
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    

00800dce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd9:	89 c6                	mov    %eax,%esi
  800ddb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dde:	eb 1a                	jmp    800dfa <memcmp+0x2c>
		if (*s1 != *s2)
  800de0:	0f b6 08             	movzbl (%eax),%ecx
  800de3:	0f b6 1a             	movzbl (%edx),%ebx
  800de6:	38 d9                	cmp    %bl,%cl
  800de8:	74 0a                	je     800df4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800dea:	0f b6 c1             	movzbl %cl,%eax
  800ded:	0f b6 db             	movzbl %bl,%ebx
  800df0:	29 d8                	sub    %ebx,%eax
  800df2:	eb 0f                	jmp    800e03 <memcmp+0x35>
		s1++, s2++;
  800df4:	83 c0 01             	add    $0x1,%eax
  800df7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dfa:	39 f0                	cmp    %esi,%eax
  800dfc:	75 e2                	jne    800de0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	53                   	push   %ebx
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e0e:	89 c1                	mov    %eax,%ecx
  800e10:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800e13:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e17:	eb 0a                	jmp    800e23 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e19:	0f b6 10             	movzbl (%eax),%edx
  800e1c:	39 da                	cmp    %ebx,%edx
  800e1e:	74 07                	je     800e27 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e20:	83 c0 01             	add    $0x1,%eax
  800e23:	39 c8                	cmp    %ecx,%eax
  800e25:	72 f2                	jb     800e19 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e27:	5b                   	pop    %ebx
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e36:	eb 03                	jmp    800e3b <strtol+0x11>
		s++;
  800e38:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e3b:	0f b6 01             	movzbl (%ecx),%eax
  800e3e:	3c 20                	cmp    $0x20,%al
  800e40:	74 f6                	je     800e38 <strtol+0xe>
  800e42:	3c 09                	cmp    $0x9,%al
  800e44:	74 f2                	je     800e38 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e46:	3c 2b                	cmp    $0x2b,%al
  800e48:	75 0a                	jne    800e54 <strtol+0x2a>
		s++;
  800e4a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800e52:	eb 11                	jmp    800e65 <strtol+0x3b>
  800e54:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e59:	3c 2d                	cmp    $0x2d,%al
  800e5b:	75 08                	jne    800e65 <strtol+0x3b>
		s++, neg = 1;
  800e5d:	83 c1 01             	add    $0x1,%ecx
  800e60:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e65:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e6b:	75 15                	jne    800e82 <strtol+0x58>
  800e6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800e70:	75 10                	jne    800e82 <strtol+0x58>
  800e72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e76:	75 7c                	jne    800ef4 <strtol+0xca>
		s += 2, base = 16;
  800e78:	83 c1 02             	add    $0x2,%ecx
  800e7b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e80:	eb 16                	jmp    800e98 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e82:	85 db                	test   %ebx,%ebx
  800e84:	75 12                	jne    800e98 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e86:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e8b:	80 39 30             	cmpb   $0x30,(%ecx)
  800e8e:	75 08                	jne    800e98 <strtol+0x6e>
		s++, base = 8;
  800e90:	83 c1 01             	add    $0x1,%ecx
  800e93:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e98:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ea0:	0f b6 11             	movzbl (%ecx),%edx
  800ea3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ea6:	89 f3                	mov    %esi,%ebx
  800ea8:	80 fb 09             	cmp    $0x9,%bl
  800eab:	77 08                	ja     800eb5 <strtol+0x8b>
			dig = *s - '0';
  800ead:	0f be d2             	movsbl %dl,%edx
  800eb0:	83 ea 30             	sub    $0x30,%edx
  800eb3:	eb 22                	jmp    800ed7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800eb5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800eb8:	89 f3                	mov    %esi,%ebx
  800eba:	80 fb 19             	cmp    $0x19,%bl
  800ebd:	77 08                	ja     800ec7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ebf:	0f be d2             	movsbl %dl,%edx
  800ec2:	83 ea 57             	sub    $0x57,%edx
  800ec5:	eb 10                	jmp    800ed7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ec7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eca:	89 f3                	mov    %esi,%ebx
  800ecc:	80 fb 19             	cmp    $0x19,%bl
  800ecf:	77 16                	ja     800ee7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ed1:	0f be d2             	movsbl %dl,%edx
  800ed4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ed7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800eda:	7d 0b                	jge    800ee7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800edc:	83 c1 01             	add    $0x1,%ecx
  800edf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ee3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ee5:	eb b9                	jmp    800ea0 <strtol+0x76>

	if (endptr)
  800ee7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eeb:	74 0d                	je     800efa <strtol+0xd0>
		*endptr = (char *) s;
  800eed:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ef0:	89 0e                	mov    %ecx,(%esi)
  800ef2:	eb 06                	jmp    800efa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ef4:	85 db                	test   %ebx,%ebx
  800ef6:	74 98                	je     800e90 <strtol+0x66>
  800ef8:	eb 9e                	jmp    800e98 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800efa:	89 c2                	mov    %eax,%edx
  800efc:	f7 da                	neg    %edx
  800efe:	85 ff                	test   %edi,%edi
  800f00:	0f 45 c2             	cmovne %edx,%eax
}
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	8b 55 08             	mov    0x8(%ebp),%edx
  800f19:	89 c3                	mov    %eax,%ebx
  800f1b:	89 c7                	mov    %eax,%edi
  800f1d:	89 c6                	mov    %eax,%esi
  800f1f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 01 00 00 00       	mov    $0x1,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f53:	b8 03 00 00 00       	mov    $0x3,%eax
  800f58:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5b:	89 cb                	mov    %ecx,%ebx
  800f5d:	89 cf                	mov    %ecx,%edi
  800f5f:	89 ce                	mov    %ecx,%esi
  800f61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f63:	85 c0                	test   %eax,%eax
  800f65:	7e 17                	jle    800f7e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f67:	83 ec 0c             	sub    $0xc,%esp
  800f6a:	50                   	push   %eax
  800f6b:	6a 03                	push   $0x3
  800f6d:	68 bf 2e 80 00       	push   $0x802ebf
  800f72:	6a 23                	push   $0x23
  800f74:	68 dc 2e 80 00       	push   $0x802edc
  800f79:	e8 66 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f91:	b8 02 00 00 00       	mov    $0x2,%eax
  800f96:	89 d1                	mov    %edx,%ecx
  800f98:	89 d3                	mov    %edx,%ebx
  800f9a:	89 d7                	mov    %edx,%edi
  800f9c:	89 d6                	mov    %edx,%esi
  800f9e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <sys_yield>:

void
sys_yield(void)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	57                   	push   %edi
  800fa9:	56                   	push   %esi
  800faa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	89 d3                	mov    %edx,%ebx
  800fb9:	89 d7                	mov    %edx,%edi
  800fbb:	89 d6                	mov    %edx,%esi
  800fbd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
  800fca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcd:	be 00 00 00 00       	mov    $0x0,%esi
  800fd2:	b8 04 00 00 00       	mov    $0x4,%eax
  800fd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fda:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe0:	89 f7                	mov    %esi,%edi
  800fe2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	7e 17                	jle    800fff <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe8:	83 ec 0c             	sub    $0xc,%esp
  800feb:	50                   	push   %eax
  800fec:	6a 04                	push   $0x4
  800fee:	68 bf 2e 80 00       	push   $0x802ebf
  800ff3:	6a 23                	push   $0x23
  800ff5:	68 dc 2e 80 00       	push   $0x802edc
  800ffa:	e8 e5 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5f                   	pop    %edi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
  80100d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801010:	b8 05 00 00 00       	mov    $0x5,%eax
  801015:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801018:	8b 55 08             	mov    0x8(%ebp),%edx
  80101b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80101e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801021:	8b 75 18             	mov    0x18(%ebp),%esi
  801024:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801026:	85 c0                	test   %eax,%eax
  801028:	7e 17                	jle    801041 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	50                   	push   %eax
  80102e:	6a 05                	push   $0x5
  801030:	68 bf 2e 80 00       	push   $0x802ebf
  801035:	6a 23                	push   $0x23
  801037:	68 dc 2e 80 00       	push   $0x802edc
  80103c:	e8 a3 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801041:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5f                   	pop    %edi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    

00801049 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	57                   	push   %edi
  80104d:	56                   	push   %esi
  80104e:	53                   	push   %ebx
  80104f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801052:	bb 00 00 00 00       	mov    $0x0,%ebx
  801057:	b8 06 00 00 00       	mov    $0x6,%eax
  80105c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105f:	8b 55 08             	mov    0x8(%ebp),%edx
  801062:	89 df                	mov    %ebx,%edi
  801064:	89 de                	mov    %ebx,%esi
  801066:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801068:	85 c0                	test   %eax,%eax
  80106a:	7e 17                	jle    801083 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	50                   	push   %eax
  801070:	6a 06                	push   $0x6
  801072:	68 bf 2e 80 00       	push   $0x802ebf
  801077:	6a 23                	push   $0x23
  801079:	68 dc 2e 80 00       	push   $0x802edc
  80107e:	e8 61 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801083:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801086:	5b                   	pop    %ebx
  801087:	5e                   	pop    %esi
  801088:	5f                   	pop    %edi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    

0080108b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	57                   	push   %edi
  80108f:	56                   	push   %esi
  801090:	53                   	push   %ebx
  801091:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801094:	bb 00 00 00 00       	mov    $0x0,%ebx
  801099:	b8 08 00 00 00       	mov    $0x8,%eax
  80109e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a4:	89 df                	mov    %ebx,%edi
  8010a6:	89 de                	mov    %ebx,%esi
  8010a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	7e 17                	jle    8010c5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	50                   	push   %eax
  8010b2:	6a 08                	push   $0x8
  8010b4:	68 bf 2e 80 00       	push   $0x802ebf
  8010b9:	6a 23                	push   $0x23
  8010bb:	68 dc 2e 80 00       	push   $0x802edc
  8010c0:	e8 1f f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	57                   	push   %edi
  8010d1:	56                   	push   %esi
  8010d2:	53                   	push   %ebx
  8010d3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010db:	b8 09 00 00 00       	mov    $0x9,%eax
  8010e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e6:	89 df                	mov    %ebx,%edi
  8010e8:	89 de                	mov    %ebx,%esi
  8010ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	7e 17                	jle    801107 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	50                   	push   %eax
  8010f4:	6a 09                	push   $0x9
  8010f6:	68 bf 2e 80 00       	push   $0x802ebf
  8010fb:	6a 23                	push   $0x23
  8010fd:	68 dc 2e 80 00       	push   $0x802edc
  801102:	e8 dd f3 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110a:	5b                   	pop    %ebx
  80110b:	5e                   	pop    %esi
  80110c:	5f                   	pop    %edi
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	57                   	push   %edi
  801113:	56                   	push   %esi
  801114:	53                   	push   %ebx
  801115:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801118:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801122:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801125:	8b 55 08             	mov    0x8(%ebp),%edx
  801128:	89 df                	mov    %ebx,%edi
  80112a:	89 de                	mov    %ebx,%esi
  80112c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80112e:	85 c0                	test   %eax,%eax
  801130:	7e 17                	jle    801149 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801132:	83 ec 0c             	sub    $0xc,%esp
  801135:	50                   	push   %eax
  801136:	6a 0a                	push   $0xa
  801138:	68 bf 2e 80 00       	push   $0x802ebf
  80113d:	6a 23                	push   $0x23
  80113f:	68 dc 2e 80 00       	push   $0x802edc
  801144:	e8 9b f3 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801149:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	57                   	push   %edi
  801155:	56                   	push   %esi
  801156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801157:	be 00 00 00 00       	mov    $0x0,%esi
  80115c:	b8 0c 00 00 00       	mov    $0xc,%eax
  801161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801164:	8b 55 08             	mov    0x8(%ebp),%edx
  801167:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80116a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80116d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	56                   	push   %esi
  801179:	53                   	push   %ebx
  80117a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801182:	b8 0d 00 00 00       	mov    $0xd,%eax
  801187:	8b 55 08             	mov    0x8(%ebp),%edx
  80118a:	89 cb                	mov    %ecx,%ebx
  80118c:	89 cf                	mov    %ecx,%edi
  80118e:	89 ce                	mov    %ecx,%esi
  801190:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801192:	85 c0                	test   %eax,%eax
  801194:	7e 17                	jle    8011ad <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	50                   	push   %eax
  80119a:	6a 0d                	push   $0xd
  80119c:	68 bf 2e 80 00       	push   $0x802ebf
  8011a1:	6a 23                	push   $0x23
  8011a3:	68 dc 2e 80 00       	push   $0x802edc
  8011a8:	e8 37 f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	53                   	push   %ebx
  8011b9:	83 ec 04             	sub    $0x4,%esp
  8011bc:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011bf:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  8011c1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011c5:	74 2d                	je     8011f4 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  8011c7:	89 d8                	mov    %ebx,%eax
  8011c9:	c1 e8 16             	shr    $0x16,%eax
  8011cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011d3:	a8 01                	test   $0x1,%al
  8011d5:	74 1d                	je     8011f4 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  8011d7:	89 d8                	mov    %ebx,%eax
  8011d9:	c1 e8 0c             	shr    $0xc,%eax
  8011dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  8011e3:	f6 c2 01             	test   $0x1,%dl
  8011e6:	74 0c                	je     8011f4 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  8011e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  8011ef:	f6 c4 08             	test   $0x8,%ah
  8011f2:	75 14                	jne    801208 <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  8011f4:	83 ec 04             	sub    $0x4,%esp
  8011f7:	68 ec 2e 80 00       	push   $0x802eec
  8011fc:	6a 1f                	push   $0x1f
  8011fe:	68 22 2f 80 00       	push   $0x802f22
  801203:	e8 dc f2 ff ff       	call   8004e4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  801208:	83 ec 04             	sub    $0x4,%esp
  80120b:	6a 07                	push   $0x7
  80120d:	68 00 f0 7f 00       	push   $0x7ff000
  801212:	6a 00                	push   $0x0
  801214:	e8 ab fd ff ff       	call   800fc4 <sys_page_alloc>
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	79 12                	jns    801232 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  801220:	50                   	push   %eax
  801221:	68 2d 2f 80 00       	push   $0x802f2d
  801226:	6a 29                	push   $0x29
  801228:	68 22 2f 80 00       	push   $0x802f22
  80122d:	e8 b2 f2 ff ff       	call   8004e4 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801232:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	68 00 10 00 00       	push   $0x1000
  801240:	53                   	push   %ebx
  801241:	68 00 f0 7f 00       	push   $0x7ff000
  801246:	e8 70 fb ff ff       	call   800dbb <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  80124b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801252:	53                   	push   %ebx
  801253:	6a 00                	push   $0x0
  801255:	68 00 f0 7f 00       	push   $0x7ff000
  80125a:	6a 00                	push   $0x0
  80125c:	e8 a6 fd ff ff       	call   801007 <sys_page_map>
  801261:	83 c4 20             	add    $0x20,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	79 12                	jns    80127a <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  801268:	50                   	push   %eax
  801269:	68 41 2f 80 00       	push   $0x802f41
  80126e:	6a 2e                	push   $0x2e
  801270:	68 22 2f 80 00       	push   $0x802f22
  801275:	e8 6a f2 ff ff       	call   8004e4 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	68 00 f0 7f 00       	push   $0x7ff000
  801282:	6a 00                	push   $0x0
  801284:	e8 c0 fd ff ff       	call   801049 <sys_page_unmap>
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	85 c0                	test   %eax,%eax
  80128e:	79 12                	jns    8012a2 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  801290:	50                   	push   %eax
  801291:	68 53 2f 80 00       	push   $0x802f53
  801296:	6a 30                	push   $0x30
  801298:	68 22 2f 80 00       	push   $0x802f22
  80129d:	e8 42 f2 ff ff       	call   8004e4 <_panic>
	//panic("pgfault not implemented");
}
  8012a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	57                   	push   %edi
  8012ab:	56                   	push   %esi
  8012ac:	53                   	push   %ebx
  8012ad:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  8012b0:	68 b5 11 80 00       	push   $0x8011b5
  8012b5:	e8 2b 13 00 00       	call   8025e5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8012ba:	b8 07 00 00 00       	mov    $0x7,%eax
  8012bf:	cd 30                	int    $0x30
  8012c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  8012c4:	83 c4 10             	add    $0x10,%esp
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	79 14                	jns    8012df <fork+0x38>
		panic("sys_exofork failed");
  8012cb:	83 ec 04             	sub    $0x4,%esp
  8012ce:	68 67 2f 80 00       	push   $0x802f67
  8012d3:	6a 6f                	push   $0x6f
  8012d5:	68 22 2f 80 00       	push   $0x802f22
  8012da:	e8 05 f2 ff ff       	call   8004e4 <_panic>
  8012df:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  8012e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012e5:	0f 8e 2b 01 00 00    	jle    801416 <fork+0x16f>
  8012eb:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  8012f0:	89 d8                	mov    %ebx,%eax
  8012f2:	c1 e8 0a             	shr    $0xa,%eax
  8012f5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012fc:	a8 01                	test   $0x1,%al
  8012fe:	0f 84 bf 00 00 00    	je     8013c3 <fork+0x11c>
  801304:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80130b:	a8 01                	test   $0x1,%al
  80130d:	0f 84 b0 00 00 00    	je     8013c3 <fork+0x11c>
  801313:	89 de                	mov    %ebx,%esi
  801315:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  801318:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80131f:	f6 c4 04             	test   $0x4,%ah
  801322:	74 29                	je     80134d <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  801324:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80132b:	83 ec 0c             	sub    $0xc,%esp
  80132e:	25 07 0e 00 00       	and    $0xe07,%eax
  801333:	50                   	push   %eax
  801334:	56                   	push   %esi
  801335:	57                   	push   %edi
  801336:	56                   	push   %esi
  801337:	6a 00                	push   $0x0
  801339:	e8 c9 fc ff ff       	call   801007 <sys_page_map>
  80133e:	83 c4 20             	add    $0x20,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	ba 00 00 00 00       	mov    $0x0,%edx
  801348:	0f 4f c2             	cmovg  %edx,%eax
  80134b:	eb 72                	jmp    8013bf <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  80134d:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801354:	a8 02                	test   $0x2,%al
  801356:	75 0c                	jne    801364 <fork+0xbd>
  801358:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80135f:	f6 c4 08             	test   $0x8,%ah
  801362:	74 3f                	je     8013a3 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801364:	83 ec 0c             	sub    $0xc,%esp
  801367:	68 05 08 00 00       	push   $0x805
  80136c:	56                   	push   %esi
  80136d:	57                   	push   %edi
  80136e:	56                   	push   %esi
  80136f:	6a 00                	push   $0x0
  801371:	e8 91 fc ff ff       	call   801007 <sys_page_map>
  801376:	83 c4 20             	add    $0x20,%esp
  801379:	85 c0                	test   %eax,%eax
  80137b:	0f 88 b1 00 00 00    	js     801432 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801381:	83 ec 0c             	sub    $0xc,%esp
  801384:	68 05 08 00 00       	push   $0x805
  801389:	56                   	push   %esi
  80138a:	6a 00                	push   $0x0
  80138c:	56                   	push   %esi
  80138d:	6a 00                	push   $0x0
  80138f:	e8 73 fc ff ff       	call   801007 <sys_page_map>
  801394:	83 c4 20             	add    $0x20,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	b9 00 00 00 00       	mov    $0x0,%ecx
  80139e:	0f 4f c1             	cmovg  %ecx,%eax
  8013a1:	eb 1c                	jmp    8013bf <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  8013a3:	83 ec 0c             	sub    $0xc,%esp
  8013a6:	6a 05                	push   $0x5
  8013a8:	56                   	push   %esi
  8013a9:	57                   	push   %edi
  8013aa:	56                   	push   %esi
  8013ab:	6a 00                	push   $0x0
  8013ad:	e8 55 fc ff ff       	call   801007 <sys_page_map>
  8013b2:	83 c4 20             	add    $0x20,%esp
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013bc:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 6f                	js     801432 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  8013c3:	83 c3 01             	add    $0x1,%ebx
  8013c6:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8013cc:	0f 85 1e ff ff ff    	jne    8012f0 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  8013d2:	83 ec 04             	sub    $0x4,%esp
  8013d5:	6a 07                	push   $0x7
  8013d7:	68 00 f0 bf ee       	push   $0xeebff000
  8013dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013df:	57                   	push   %edi
  8013e0:	e8 df fb ff ff       	call   800fc4 <sys_page_alloc>
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 46                	js     801432 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	68 48 26 80 00       	push   $0x802648
  8013f4:	57                   	push   %edi
  8013f5:	e8 15 fd ff ff       	call   80110f <sys_env_set_pgfault_upcall>
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	78 31                	js     801432 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  801401:	83 ec 08             	sub    $0x8,%esp
  801404:	6a 02                	push   $0x2
  801406:	57                   	push   %edi
  801407:	e8 7f fc ff ff       	call   80108b <sys_env_set_status>
  80140c:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  80140f:	85 c0                	test   %eax,%eax
  801411:	0f 49 c7             	cmovns %edi,%eax
  801414:	eb 1c                	jmp    801432 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  801416:	e8 6b fb ff ff       	call   800f86 <sys_getenvid>
  80141b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801420:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801423:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801428:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  80142d:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801432:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801435:	5b                   	pop    %ebx
  801436:	5e                   	pop    %esi
  801437:	5f                   	pop    %edi
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    

0080143a <sfork>:

// Challenge!
int
sfork(void)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801440:	68 7a 2f 80 00       	push   $0x802f7a
  801445:	68 8d 00 00 00       	push   $0x8d
  80144a:	68 22 2f 80 00       	push   $0x802f22
  80144f:	e8 90 f0 ff ff       	call   8004e4 <_panic>

00801454 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801457:	8b 45 08             	mov    0x8(%ebp),%eax
  80145a:	05 00 00 00 30       	add    $0x30000000,%eax
  80145f:	c1 e8 0c             	shr    $0xc,%eax
}
  801462:	5d                   	pop    %ebp
  801463:	c3                   	ret    

00801464 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801467:	8b 45 08             	mov    0x8(%ebp),%eax
  80146a:	05 00 00 00 30       	add    $0x30000000,%eax
  80146f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801474:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801481:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801486:	89 c2                	mov    %eax,%edx
  801488:	c1 ea 16             	shr    $0x16,%edx
  80148b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801492:	f6 c2 01             	test   $0x1,%dl
  801495:	74 11                	je     8014a8 <fd_alloc+0x2d>
  801497:	89 c2                	mov    %eax,%edx
  801499:	c1 ea 0c             	shr    $0xc,%edx
  80149c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a3:	f6 c2 01             	test   $0x1,%dl
  8014a6:	75 09                	jne    8014b1 <fd_alloc+0x36>
			*fd_store = fd;
  8014a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8014af:	eb 17                	jmp    8014c8 <fd_alloc+0x4d>
  8014b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014bb:	75 c9                	jne    801486 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014d0:	83 f8 1f             	cmp    $0x1f,%eax
  8014d3:	77 36                	ja     80150b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014d5:	c1 e0 0c             	shl    $0xc,%eax
  8014d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	c1 ea 16             	shr    $0x16,%edx
  8014e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014e9:	f6 c2 01             	test   $0x1,%dl
  8014ec:	74 24                	je     801512 <fd_lookup+0x48>
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	c1 ea 0c             	shr    $0xc,%edx
  8014f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014fa:	f6 c2 01             	test   $0x1,%dl
  8014fd:	74 1a                	je     801519 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801502:	89 02                	mov    %eax,(%edx)
	return 0;
  801504:	b8 00 00 00 00       	mov    $0x0,%eax
  801509:	eb 13                	jmp    80151e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80150b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801510:	eb 0c                	jmp    80151e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801512:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801517:	eb 05                	jmp    80151e <fd_lookup+0x54>
  801519:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    

00801520 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801529:	ba 0c 30 80 00       	mov    $0x80300c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80152e:	eb 13                	jmp    801543 <dev_lookup+0x23>
  801530:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801533:	39 08                	cmp    %ecx,(%eax)
  801535:	75 0c                	jne    801543 <dev_lookup+0x23>
			*dev = devtab[i];
  801537:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80153a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80153c:	b8 00 00 00 00       	mov    $0x0,%eax
  801541:	eb 2e                	jmp    801571 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801543:	8b 02                	mov    (%edx),%eax
  801545:	85 c0                	test   %eax,%eax
  801547:	75 e7                	jne    801530 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801549:	a1 04 50 80 00       	mov    0x805004,%eax
  80154e:	8b 40 48             	mov    0x48(%eax),%eax
  801551:	83 ec 04             	sub    $0x4,%esp
  801554:	51                   	push   %ecx
  801555:	50                   	push   %eax
  801556:	68 90 2f 80 00       	push   $0x802f90
  80155b:	e8 5d f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  801560:	8b 45 0c             	mov    0xc(%ebp),%eax
  801563:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801571:	c9                   	leave  
  801572:	c3                   	ret    

00801573 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	56                   	push   %esi
  801577:	53                   	push   %ebx
  801578:	83 ec 10             	sub    $0x10,%esp
  80157b:	8b 75 08             	mov    0x8(%ebp),%esi
  80157e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801581:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80158b:	c1 e8 0c             	shr    $0xc,%eax
  80158e:	50                   	push   %eax
  80158f:	e8 36 ff ff ff       	call   8014ca <fd_lookup>
  801594:	83 c4 08             	add    $0x8,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 05                	js     8015a0 <fd_close+0x2d>
	    || fd != fd2)
  80159b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80159e:	74 0c                	je     8015ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8015a0:	84 db                	test   %bl,%bl
  8015a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a7:	0f 44 c2             	cmove  %edx,%eax
  8015aa:	eb 41                	jmp    8015ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	ff 36                	pushl  (%esi)
  8015b5:	e8 66 ff ff ff       	call   801520 <dev_lookup>
  8015ba:	89 c3                	mov    %eax,%ebx
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 1a                	js     8015dd <fd_close+0x6a>
		if (dev->dev_close)
  8015c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	74 0b                	je     8015dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015d2:	83 ec 0c             	sub    $0xc,%esp
  8015d5:	56                   	push   %esi
  8015d6:	ff d0                	call   *%eax
  8015d8:	89 c3                	mov    %eax,%ebx
  8015da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	56                   	push   %esi
  8015e1:	6a 00                	push   $0x0
  8015e3:	e8 61 fa ff ff       	call   801049 <sys_page_unmap>
	return r;
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	89 d8                	mov    %ebx,%eax
}
  8015ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f0:	5b                   	pop    %ebx
  8015f1:	5e                   	pop    %esi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	ff 75 08             	pushl  0x8(%ebp)
  801601:	e8 c4 fe ff ff       	call   8014ca <fd_lookup>
  801606:	83 c4 08             	add    $0x8,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 10                	js     80161d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80160d:	83 ec 08             	sub    $0x8,%esp
  801610:	6a 01                	push   $0x1
  801612:	ff 75 f4             	pushl  -0xc(%ebp)
  801615:	e8 59 ff ff ff       	call   801573 <fd_close>
  80161a:	83 c4 10             	add    $0x10,%esp
}
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <close_all>:

void
close_all(void)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	53                   	push   %ebx
  801623:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801626:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80162b:	83 ec 0c             	sub    $0xc,%esp
  80162e:	53                   	push   %ebx
  80162f:	e8 c0 ff ff ff       	call   8015f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801634:	83 c3 01             	add    $0x1,%ebx
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	83 fb 20             	cmp    $0x20,%ebx
  80163d:	75 ec                	jne    80162b <close_all+0xc>
		close(i);
}
  80163f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	57                   	push   %edi
  801648:	56                   	push   %esi
  801649:	53                   	push   %ebx
  80164a:	83 ec 2c             	sub    $0x2c,%esp
  80164d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801650:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	ff 75 08             	pushl  0x8(%ebp)
  801657:	e8 6e fe ff ff       	call   8014ca <fd_lookup>
  80165c:	83 c4 08             	add    $0x8,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	0f 88 c1 00 00 00    	js     801728 <dup+0xe4>
		return r;
	close(newfdnum);
  801667:	83 ec 0c             	sub    $0xc,%esp
  80166a:	56                   	push   %esi
  80166b:	e8 84 ff ff ff       	call   8015f4 <close>

	newfd = INDEX2FD(newfdnum);
  801670:	89 f3                	mov    %esi,%ebx
  801672:	c1 e3 0c             	shl    $0xc,%ebx
  801675:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80167b:	83 c4 04             	add    $0x4,%esp
  80167e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801681:	e8 de fd ff ff       	call   801464 <fd2data>
  801686:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801688:	89 1c 24             	mov    %ebx,(%esp)
  80168b:	e8 d4 fd ff ff       	call   801464 <fd2data>
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801696:	89 f8                	mov    %edi,%eax
  801698:	c1 e8 16             	shr    $0x16,%eax
  80169b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016a2:	a8 01                	test   $0x1,%al
  8016a4:	74 37                	je     8016dd <dup+0x99>
  8016a6:	89 f8                	mov    %edi,%eax
  8016a8:	c1 e8 0c             	shr    $0xc,%eax
  8016ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016b2:	f6 c2 01             	test   $0x1,%dl
  8016b5:	74 26                	je     8016dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8016c6:	50                   	push   %eax
  8016c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016ca:	6a 00                	push   $0x0
  8016cc:	57                   	push   %edi
  8016cd:	6a 00                	push   $0x0
  8016cf:	e8 33 f9 ff ff       	call   801007 <sys_page_map>
  8016d4:	89 c7                	mov    %eax,%edi
  8016d6:	83 c4 20             	add    $0x20,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 2e                	js     80170b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016e0:	89 d0                	mov    %edx,%eax
  8016e2:	c1 e8 0c             	shr    $0xc,%eax
  8016e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ec:	83 ec 0c             	sub    $0xc,%esp
  8016ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8016f4:	50                   	push   %eax
  8016f5:	53                   	push   %ebx
  8016f6:	6a 00                	push   $0x0
  8016f8:	52                   	push   %edx
  8016f9:	6a 00                	push   $0x0
  8016fb:	e8 07 f9 ff ff       	call   801007 <sys_page_map>
  801700:	89 c7                	mov    %eax,%edi
  801702:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801705:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801707:	85 ff                	test   %edi,%edi
  801709:	79 1d                	jns    801728 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80170b:	83 ec 08             	sub    $0x8,%esp
  80170e:	53                   	push   %ebx
  80170f:	6a 00                	push   $0x0
  801711:	e8 33 f9 ff ff       	call   801049 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801716:	83 c4 08             	add    $0x8,%esp
  801719:	ff 75 d4             	pushl  -0x2c(%ebp)
  80171c:	6a 00                	push   $0x0
  80171e:	e8 26 f9 ff ff       	call   801049 <sys_page_unmap>
	return r;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	89 f8                	mov    %edi,%eax
}
  801728:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172b:	5b                   	pop    %ebx
  80172c:	5e                   	pop    %esi
  80172d:	5f                   	pop    %edi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	53                   	push   %ebx
  801734:	83 ec 14             	sub    $0x14,%esp
  801737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	53                   	push   %ebx
  80173f:	e8 86 fd ff ff       	call   8014ca <fd_lookup>
  801744:	83 c4 08             	add    $0x8,%esp
  801747:	89 c2                	mov    %eax,%edx
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 6d                	js     8017ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174d:	83 ec 08             	sub    $0x8,%esp
  801750:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801753:	50                   	push   %eax
  801754:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801757:	ff 30                	pushl  (%eax)
  801759:	e8 c2 fd ff ff       	call   801520 <dev_lookup>
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	85 c0                	test   %eax,%eax
  801763:	78 4c                	js     8017b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801765:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801768:	8b 42 08             	mov    0x8(%edx),%eax
  80176b:	83 e0 03             	and    $0x3,%eax
  80176e:	83 f8 01             	cmp    $0x1,%eax
  801771:	75 21                	jne    801794 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801773:	a1 04 50 80 00       	mov    0x805004,%eax
  801778:	8b 40 48             	mov    0x48(%eax),%eax
  80177b:	83 ec 04             	sub    $0x4,%esp
  80177e:	53                   	push   %ebx
  80177f:	50                   	push   %eax
  801780:	68 d1 2f 80 00       	push   $0x802fd1
  801785:	e8 33 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801792:	eb 26                	jmp    8017ba <read+0x8a>
	}
	if (!dev->dev_read)
  801794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801797:	8b 40 08             	mov    0x8(%eax),%eax
  80179a:	85 c0                	test   %eax,%eax
  80179c:	74 17                	je     8017b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80179e:	83 ec 04             	sub    $0x4,%esp
  8017a1:	ff 75 10             	pushl  0x10(%ebp)
  8017a4:	ff 75 0c             	pushl  0xc(%ebp)
  8017a7:	52                   	push   %edx
  8017a8:	ff d0                	call   *%eax
  8017aa:	89 c2                	mov    %eax,%edx
  8017ac:	83 c4 10             	add    $0x10,%esp
  8017af:	eb 09                	jmp    8017ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b1:	89 c2                	mov    %eax,%edx
  8017b3:	eb 05                	jmp    8017ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017ba:	89 d0                	mov    %edx,%eax
  8017bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017bf:	c9                   	leave  
  8017c0:	c3                   	ret    

008017c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	57                   	push   %edi
  8017c5:	56                   	push   %esi
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 0c             	sub    $0xc,%esp
  8017ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017d5:	eb 21                	jmp    8017f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017d7:	83 ec 04             	sub    $0x4,%esp
  8017da:	89 f0                	mov    %esi,%eax
  8017dc:	29 d8                	sub    %ebx,%eax
  8017de:	50                   	push   %eax
  8017df:	89 d8                	mov    %ebx,%eax
  8017e1:	03 45 0c             	add    0xc(%ebp),%eax
  8017e4:	50                   	push   %eax
  8017e5:	57                   	push   %edi
  8017e6:	e8 45 ff ff ff       	call   801730 <read>
		if (m < 0)
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 10                	js     801802 <readn+0x41>
			return m;
		if (m == 0)
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	74 0a                	je     801800 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017f6:	01 c3                	add    %eax,%ebx
  8017f8:	39 f3                	cmp    %esi,%ebx
  8017fa:	72 db                	jb     8017d7 <readn+0x16>
  8017fc:	89 d8                	mov    %ebx,%eax
  8017fe:	eb 02                	jmp    801802 <readn+0x41>
  801800:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801802:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801805:	5b                   	pop    %ebx
  801806:	5e                   	pop    %esi
  801807:	5f                   	pop    %edi
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	53                   	push   %ebx
  80180e:	83 ec 14             	sub    $0x14,%esp
  801811:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801814:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801817:	50                   	push   %eax
  801818:	53                   	push   %ebx
  801819:	e8 ac fc ff ff       	call   8014ca <fd_lookup>
  80181e:	83 c4 08             	add    $0x8,%esp
  801821:	89 c2                	mov    %eax,%edx
  801823:	85 c0                	test   %eax,%eax
  801825:	78 68                	js     80188f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801827:	83 ec 08             	sub    $0x8,%esp
  80182a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182d:	50                   	push   %eax
  80182e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801831:	ff 30                	pushl  (%eax)
  801833:	e8 e8 fc ff ff       	call   801520 <dev_lookup>
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 47                	js     801886 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80183f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801842:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801846:	75 21                	jne    801869 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801848:	a1 04 50 80 00       	mov    0x805004,%eax
  80184d:	8b 40 48             	mov    0x48(%eax),%eax
  801850:	83 ec 04             	sub    $0x4,%esp
  801853:	53                   	push   %ebx
  801854:	50                   	push   %eax
  801855:	68 ed 2f 80 00       	push   $0x802fed
  80185a:	e8 5e ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801867:	eb 26                	jmp    80188f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801869:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80186c:	8b 52 0c             	mov    0xc(%edx),%edx
  80186f:	85 d2                	test   %edx,%edx
  801871:	74 17                	je     80188a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801873:	83 ec 04             	sub    $0x4,%esp
  801876:	ff 75 10             	pushl  0x10(%ebp)
  801879:	ff 75 0c             	pushl  0xc(%ebp)
  80187c:	50                   	push   %eax
  80187d:	ff d2                	call   *%edx
  80187f:	89 c2                	mov    %eax,%edx
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	eb 09                	jmp    80188f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801886:	89 c2                	mov    %eax,%edx
  801888:	eb 05                	jmp    80188f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80188a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80188f:	89 d0                	mov    %edx,%eax
  801891:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <seek>:

int
seek(int fdnum, off_t offset)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80189c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80189f:	50                   	push   %eax
  8018a0:	ff 75 08             	pushl  0x8(%ebp)
  8018a3:	e8 22 fc ff ff       	call   8014ca <fd_lookup>
  8018a8:	83 c4 08             	add    $0x8,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 0e                	js     8018bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 14             	sub    $0x14,%esp
  8018c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018cc:	50                   	push   %eax
  8018cd:	53                   	push   %ebx
  8018ce:	e8 f7 fb ff ff       	call   8014ca <fd_lookup>
  8018d3:	83 c4 08             	add    $0x8,%esp
  8018d6:	89 c2                	mov    %eax,%edx
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 65                	js     801941 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018dc:	83 ec 08             	sub    $0x8,%esp
  8018df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e2:	50                   	push   %eax
  8018e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e6:	ff 30                	pushl  (%eax)
  8018e8:	e8 33 fc ff ff       	call   801520 <dev_lookup>
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 44                	js     801938 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018fb:	75 21                	jne    80191e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018fd:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801902:	8b 40 48             	mov    0x48(%eax),%eax
  801905:	83 ec 04             	sub    $0x4,%esp
  801908:	53                   	push   %ebx
  801909:	50                   	push   %eax
  80190a:	68 b0 2f 80 00       	push   $0x802fb0
  80190f:	e8 a9 ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80191c:	eb 23                	jmp    801941 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80191e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801921:	8b 52 18             	mov    0x18(%edx),%edx
  801924:	85 d2                	test   %edx,%edx
  801926:	74 14                	je     80193c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801928:	83 ec 08             	sub    $0x8,%esp
  80192b:	ff 75 0c             	pushl  0xc(%ebp)
  80192e:	50                   	push   %eax
  80192f:	ff d2                	call   *%edx
  801931:	89 c2                	mov    %eax,%edx
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	eb 09                	jmp    801941 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801938:	89 c2                	mov    %eax,%edx
  80193a:	eb 05                	jmp    801941 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80193c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801941:	89 d0                	mov    %edx,%eax
  801943:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	53                   	push   %ebx
  80194c:	83 ec 14             	sub    $0x14,%esp
  80194f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801952:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801955:	50                   	push   %eax
  801956:	ff 75 08             	pushl  0x8(%ebp)
  801959:	e8 6c fb ff ff       	call   8014ca <fd_lookup>
  80195e:	83 c4 08             	add    $0x8,%esp
  801961:	89 c2                	mov    %eax,%edx
  801963:	85 c0                	test   %eax,%eax
  801965:	78 58                	js     8019bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801967:	83 ec 08             	sub    $0x8,%esp
  80196a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196d:	50                   	push   %eax
  80196e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801971:	ff 30                	pushl  (%eax)
  801973:	e8 a8 fb ff ff       	call   801520 <dev_lookup>
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	85 c0                	test   %eax,%eax
  80197d:	78 37                	js     8019b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801982:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801986:	74 32                	je     8019ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801988:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80198b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801992:	00 00 00 
	stat->st_isdir = 0;
  801995:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80199c:	00 00 00 
	stat->st_dev = dev;
  80199f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019a5:	83 ec 08             	sub    $0x8,%esp
  8019a8:	53                   	push   %ebx
  8019a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ac:	ff 50 14             	call   *0x14(%eax)
  8019af:	89 c2                	mov    %eax,%edx
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	eb 09                	jmp    8019bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b6:	89 c2                	mov    %eax,%edx
  8019b8:	eb 05                	jmp    8019bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019bf:	89 d0                	mov    %edx,%eax
  8019c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019cb:	83 ec 08             	sub    $0x8,%esp
  8019ce:	6a 00                	push   $0x0
  8019d0:	ff 75 08             	pushl  0x8(%ebp)
  8019d3:	e8 e3 01 00 00       	call   801bbb <open>
  8019d8:	89 c3                	mov    %eax,%ebx
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	78 1b                	js     8019fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	ff 75 0c             	pushl  0xc(%ebp)
  8019e7:	50                   	push   %eax
  8019e8:	e8 5b ff ff ff       	call   801948 <fstat>
  8019ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8019ef:	89 1c 24             	mov    %ebx,(%esp)
  8019f2:	e8 fd fb ff ff       	call   8015f4 <close>
	return r;
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	89 f0                	mov    %esi,%eax
}
  8019fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ff:	5b                   	pop    %ebx
  801a00:	5e                   	pop    %esi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	56                   	push   %esi
  801a07:	53                   	push   %ebx
  801a08:	89 c6                	mov    %eax,%esi
  801a0a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a0c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a13:	75 12                	jne    801a27 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a15:	83 ec 0c             	sub    $0xc,%esp
  801a18:	6a 01                	push   $0x1
  801a1a:	e8 0a 0d 00 00       	call   802729 <ipc_find_env>
  801a1f:	a3 00 50 80 00       	mov    %eax,0x805000
  801a24:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a27:	6a 07                	push   $0x7
  801a29:	68 00 60 80 00       	push   $0x806000
  801a2e:	56                   	push   %esi
  801a2f:	ff 35 00 50 80 00    	pushl  0x805000
  801a35:	e8 9b 0c 00 00       	call   8026d5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a3a:	83 c4 0c             	add    $0xc,%esp
  801a3d:	6a 00                	push   $0x0
  801a3f:	53                   	push   %ebx
  801a40:	6a 00                	push   $0x0
  801a42:	e8 25 0c 00 00       	call   80266c <ipc_recv>
}
  801a47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4a:	5b                   	pop    %ebx
  801a4b:	5e                   	pop    %esi
  801a4c:	5d                   	pop    %ebp
  801a4d:	c3                   	ret    

00801a4e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a54:	8b 45 08             	mov    0x8(%ebp),%eax
  801a57:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a62:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a67:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6c:	b8 02 00 00 00       	mov    $0x2,%eax
  801a71:	e8 8d ff ff ff       	call   801a03 <fsipc>
}
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a81:	8b 40 0c             	mov    0xc(%eax),%eax
  801a84:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a89:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8e:	b8 06 00 00 00       	mov    $0x6,%eax
  801a93:	e8 6b ff ff ff       	call   801a03 <fsipc>
}
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 04             	sub    $0x4,%esp
  801aa1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aaa:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab4:	b8 05 00 00 00       	mov    $0x5,%eax
  801ab9:	e8 45 ff ff ff       	call   801a03 <fsipc>
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	78 2c                	js     801aee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ac2:	83 ec 08             	sub    $0x8,%esp
  801ac5:	68 00 60 80 00       	push   $0x806000
  801aca:	53                   	push   %ebx
  801acb:	e8 f1 f0 ff ff       	call   800bc1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ad0:	a1 80 60 80 00       	mov    0x806080,%eax
  801ad5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801adb:	a1 84 60 80 00       	mov    0x806084,%eax
  801ae0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	8b 45 10             	mov    0x10(%ebp),%eax
  801afc:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b01:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b06:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b09:	8b 55 08             	mov    0x8(%ebp),%edx
  801b0c:	8b 52 0c             	mov    0xc(%edx),%edx
  801b0f:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b15:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b1a:	50                   	push   %eax
  801b1b:	ff 75 0c             	pushl  0xc(%ebp)
  801b1e:	68 08 60 80 00       	push   $0x806008
  801b23:	e8 2b f2 ff ff       	call   800d53 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801b28:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2d:	b8 04 00 00 00       	mov    $0x4,%eax
  801b32:	e8 cc fe ff ff       	call   801a03 <fsipc>
	//panic("devfile_write not implemented");
}
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	56                   	push   %esi
  801b3d:	53                   	push   %ebx
  801b3e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b41:	8b 45 08             	mov    0x8(%ebp),%eax
  801b44:	8b 40 0c             	mov    0xc(%eax),%eax
  801b47:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b4c:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b52:	ba 00 00 00 00       	mov    $0x0,%edx
  801b57:	b8 03 00 00 00       	mov    $0x3,%eax
  801b5c:	e8 a2 fe ff ff       	call   801a03 <fsipc>
  801b61:	89 c3                	mov    %eax,%ebx
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 4b                	js     801bb2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b67:	39 c6                	cmp    %eax,%esi
  801b69:	73 16                	jae    801b81 <devfile_read+0x48>
  801b6b:	68 1c 30 80 00       	push   $0x80301c
  801b70:	68 23 30 80 00       	push   $0x803023
  801b75:	6a 7c                	push   $0x7c
  801b77:	68 38 30 80 00       	push   $0x803038
  801b7c:	e8 63 e9 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801b81:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b86:	7e 16                	jle    801b9e <devfile_read+0x65>
  801b88:	68 43 30 80 00       	push   $0x803043
  801b8d:	68 23 30 80 00       	push   $0x803023
  801b92:	6a 7d                	push   $0x7d
  801b94:	68 38 30 80 00       	push   $0x803038
  801b99:	e8 46 e9 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b9e:	83 ec 04             	sub    $0x4,%esp
  801ba1:	50                   	push   %eax
  801ba2:	68 00 60 80 00       	push   $0x806000
  801ba7:	ff 75 0c             	pushl  0xc(%ebp)
  801baa:	e8 a4 f1 ff ff       	call   800d53 <memmove>
	return r;
  801baf:	83 c4 10             	add    $0x10,%esp
}
  801bb2:	89 d8                	mov    %ebx,%eax
  801bb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb7:	5b                   	pop    %ebx
  801bb8:	5e                   	pop    %esi
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    

00801bbb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	53                   	push   %ebx
  801bbf:	83 ec 20             	sub    $0x20,%esp
  801bc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bc5:	53                   	push   %ebx
  801bc6:	e8 bd ef ff ff       	call   800b88 <strlen>
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bd3:	7f 67                	jg     801c3c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bd5:	83 ec 0c             	sub    $0xc,%esp
  801bd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdb:	50                   	push   %eax
  801bdc:	e8 9a f8 ff ff       	call   80147b <fd_alloc>
  801be1:	83 c4 10             	add    $0x10,%esp
		return r;
  801be4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801be6:	85 c0                	test   %eax,%eax
  801be8:	78 57                	js     801c41 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bea:	83 ec 08             	sub    $0x8,%esp
  801bed:	53                   	push   %ebx
  801bee:	68 00 60 80 00       	push   $0x806000
  801bf3:	e8 c9 ef ff ff       	call   800bc1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfb:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c03:	b8 01 00 00 00       	mov    $0x1,%eax
  801c08:	e8 f6 fd ff ff       	call   801a03 <fsipc>
  801c0d:	89 c3                	mov    %eax,%ebx
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	85 c0                	test   %eax,%eax
  801c14:	79 14                	jns    801c2a <open+0x6f>
		fd_close(fd, 0);
  801c16:	83 ec 08             	sub    $0x8,%esp
  801c19:	6a 00                	push   $0x0
  801c1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1e:	e8 50 f9 ff ff       	call   801573 <fd_close>
		return r;
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	89 da                	mov    %ebx,%edx
  801c28:	eb 17                	jmp    801c41 <open+0x86>
	}

	return fd2num(fd);
  801c2a:	83 ec 0c             	sub    $0xc,%esp
  801c2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c30:	e8 1f f8 ff ff       	call   801454 <fd2num>
  801c35:	89 c2                	mov    %eax,%edx
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	eb 05                	jmp    801c41 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c3c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c41:	89 d0                	mov    %edx,%eax
  801c43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c53:	b8 08 00 00 00       	mov    $0x8,%eax
  801c58:	e8 a6 fd ff ff       	call   801a03 <fsipc>
}
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	57                   	push   %edi
  801c63:	56                   	push   %esi
  801c64:	53                   	push   %ebx
  801c65:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c6b:	6a 00                	push   $0x0
  801c6d:	ff 75 08             	pushl  0x8(%ebp)
  801c70:	e8 46 ff ff ff       	call   801bbb <open>
  801c75:	89 c7                	mov    %eax,%edi
  801c77:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	85 c0                	test   %eax,%eax
  801c82:	0f 88 82 04 00 00    	js     80210a <spawn+0x4ab>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c88:	83 ec 04             	sub    $0x4,%esp
  801c8b:	68 00 02 00 00       	push   $0x200
  801c90:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c96:	50                   	push   %eax
  801c97:	57                   	push   %edi
  801c98:	e8 24 fb ff ff       	call   8017c1 <readn>
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	3d 00 02 00 00       	cmp    $0x200,%eax
  801ca5:	75 0c                	jne    801cb3 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801ca7:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801cae:	45 4c 46 
  801cb1:	74 33                	je     801ce6 <spawn+0x87>
		close(fd);
  801cb3:	83 ec 0c             	sub    $0xc,%esp
  801cb6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cbc:	e8 33 f9 ff ff       	call   8015f4 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801cc1:	83 c4 0c             	add    $0xc,%esp
  801cc4:	68 7f 45 4c 46       	push   $0x464c457f
  801cc9:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801ccf:	68 4f 30 80 00       	push   $0x80304f
  801cd4:	e8 e4 e8 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801cd9:	83 c4 10             	add    $0x10,%esp
  801cdc:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801ce1:	e9 d7 04 00 00       	jmp    8021bd <spawn+0x55e>
  801ce6:	b8 07 00 00 00       	mov    $0x7,%eax
  801ceb:	cd 30                	int    $0x30
  801ced:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801cf3:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	0f 88 14 04 00 00    	js     802115 <spawn+0x4b6>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d01:	89 c6                	mov    %eax,%esi
  801d03:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801d09:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801d0c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d12:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d18:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d1f:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d25:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d30:	be 00 00 00 00       	mov    $0x0,%esi
  801d35:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d38:	eb 13                	jmp    801d4d <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d3a:	83 ec 0c             	sub    $0xc,%esp
  801d3d:	50                   	push   %eax
  801d3e:	e8 45 ee ff ff       	call   800b88 <strlen>
  801d43:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d47:	83 c3 01             	add    $0x1,%ebx
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d54:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d57:	85 c0                	test   %eax,%eax
  801d59:	75 df                	jne    801d3a <spawn+0xdb>
  801d5b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d61:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d67:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d6c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 e2 fc             	and    $0xfffffffc,%edx
  801d73:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d7a:	29 c2                	sub    %eax,%edx
  801d7c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d82:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d85:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d8a:	0f 86 9b 03 00 00    	jbe    80212b <spawn+0x4cc>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d90:	83 ec 04             	sub    $0x4,%esp
  801d93:	6a 07                	push   $0x7
  801d95:	68 00 00 40 00       	push   $0x400000
  801d9a:	6a 00                	push   $0x0
  801d9c:	e8 23 f2 ff ff       	call   800fc4 <sys_page_alloc>
  801da1:	83 c4 10             	add    $0x10,%esp
  801da4:	85 c0                	test   %eax,%eax
  801da6:	0f 88 89 03 00 00    	js     802135 <spawn+0x4d6>
  801dac:	be 00 00 00 00       	mov    $0x0,%esi
  801db1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801db7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dba:	eb 30                	jmp    801dec <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801dbc:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801dc2:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801dc8:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801dcb:	83 ec 08             	sub    $0x8,%esp
  801dce:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801dd1:	57                   	push   %edi
  801dd2:	e8 ea ed ff ff       	call   800bc1 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801dd7:	83 c4 04             	add    $0x4,%esp
  801dda:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ddd:	e8 a6 ed ff ff       	call   800b88 <strlen>
  801de2:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801de6:	83 c6 01             	add    $0x1,%esi
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801df2:	7f c8                	jg     801dbc <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801df4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801dfa:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801e00:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e07:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e0d:	74 19                	je     801e28 <spawn+0x1c9>
  801e0f:	68 dc 30 80 00       	push   $0x8030dc
  801e14:	68 23 30 80 00       	push   $0x803023
  801e19:	68 f2 00 00 00       	push   $0xf2
  801e1e:	68 69 30 80 00       	push   $0x803069
  801e23:	e8 bc e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e28:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e2e:	89 f8                	mov    %edi,%eax
  801e30:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e35:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e38:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e3e:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e41:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801e47:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	6a 07                	push   $0x7
  801e52:	68 00 d0 bf ee       	push   $0xeebfd000
  801e57:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e5d:	68 00 00 40 00       	push   $0x400000
  801e62:	6a 00                	push   $0x0
  801e64:	e8 9e f1 ff ff       	call   801007 <sys_page_map>
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	83 c4 20             	add    $0x20,%esp
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	0f 88 35 03 00 00    	js     8021ab <spawn+0x54c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e76:	83 ec 08             	sub    $0x8,%esp
  801e79:	68 00 00 40 00       	push   $0x400000
  801e7e:	6a 00                	push   $0x0
  801e80:	e8 c4 f1 ff ff       	call   801049 <sys_page_unmap>
  801e85:	89 c3                	mov    %eax,%ebx
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	0f 88 19 03 00 00    	js     8021ab <spawn+0x54c>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e92:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e98:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e9f:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ea5:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801eac:	00 00 00 
  801eaf:	e9 88 01 00 00       	jmp    80203c <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801eb4:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801eba:	83 38 01             	cmpl   $0x1,(%eax)
  801ebd:	0f 85 6b 01 00 00    	jne    80202e <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ec3:	89 c1                	mov    %eax,%ecx
  801ec5:	8b 40 18             	mov    0x18(%eax),%eax
  801ec8:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ece:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801ed1:	83 f8 01             	cmp    $0x1,%eax
  801ed4:	19 c0                	sbb    %eax,%eax
  801ed6:	83 e0 fe             	and    $0xfffffffe,%eax
  801ed9:	83 c0 07             	add    $0x7,%eax
  801edc:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ee2:	89 c8                	mov    %ecx,%eax
  801ee4:	8b 79 04             	mov    0x4(%ecx),%edi
  801ee7:	89 f9                	mov    %edi,%ecx
  801ee9:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801eef:	8b 78 10             	mov    0x10(%eax),%edi
  801ef2:	8b 50 14             	mov    0x14(%eax),%edx
  801ef5:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801efb:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801efe:	89 f0                	mov    %esi,%eax
  801f00:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f05:	74 14                	je     801f1b <spawn+0x2bc>
		va -= i;
  801f07:	29 c6                	sub    %eax,%esi
		memsz += i;
  801f09:	01 c2                	add    %eax,%edx
  801f0b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801f11:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801f13:	29 c1                	sub    %eax,%ecx
  801f15:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f20:	e9 f7 00 00 00       	jmp    80201c <spawn+0x3bd>
		if (i >= filesz) {
  801f25:	39 fb                	cmp    %edi,%ebx
  801f27:	72 27                	jb     801f50 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f29:	83 ec 04             	sub    $0x4,%esp
  801f2c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f32:	56                   	push   %esi
  801f33:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f39:	e8 86 f0 ff ff       	call   800fc4 <sys_page_alloc>
  801f3e:	83 c4 10             	add    $0x10,%esp
  801f41:	85 c0                	test   %eax,%eax
  801f43:	0f 89 c7 00 00 00    	jns    802010 <spawn+0x3b1>
  801f49:	89 c3                	mov    %eax,%ebx
  801f4b:	e9 f6 01 00 00       	jmp    802146 <spawn+0x4e7>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f50:	83 ec 04             	sub    $0x4,%esp
  801f53:	6a 07                	push   $0x7
  801f55:	68 00 00 40 00       	push   $0x400000
  801f5a:	6a 00                	push   $0x0
  801f5c:	e8 63 f0 ff ff       	call   800fc4 <sys_page_alloc>
  801f61:	83 c4 10             	add    $0x10,%esp
  801f64:	85 c0                	test   %eax,%eax
  801f66:	0f 88 d0 01 00 00    	js     80213c <spawn+0x4dd>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f6c:	83 ec 08             	sub    $0x8,%esp
  801f6f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f75:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f7b:	50                   	push   %eax
  801f7c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f82:	e8 0f f9 ff ff       	call   801896 <seek>
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	0f 88 ae 01 00 00    	js     802140 <spawn+0x4e1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f92:	83 ec 04             	sub    $0x4,%esp
  801f95:	89 f8                	mov    %edi,%eax
  801f97:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801f9d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801fa2:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801fa7:	0f 47 c1             	cmova  %ecx,%eax
  801faa:	50                   	push   %eax
  801fab:	68 00 00 40 00       	push   $0x400000
  801fb0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fb6:	e8 06 f8 ff ff       	call   8017c1 <readn>
  801fbb:	83 c4 10             	add    $0x10,%esp
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	0f 88 7e 01 00 00    	js     802144 <spawn+0x4e5>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801fc6:	83 ec 0c             	sub    $0xc,%esp
  801fc9:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fcf:	56                   	push   %esi
  801fd0:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fd6:	68 00 00 40 00       	push   $0x400000
  801fdb:	6a 00                	push   $0x0
  801fdd:	e8 25 f0 ff ff       	call   801007 <sys_page_map>
  801fe2:	83 c4 20             	add    $0x20,%esp
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	79 15                	jns    801ffe <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801fe9:	50                   	push   %eax
  801fea:	68 75 30 80 00       	push   $0x803075
  801fef:	68 25 01 00 00       	push   $0x125
  801ff4:	68 69 30 80 00       	push   $0x803069
  801ff9:	e8 e6 e4 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  801ffe:	83 ec 08             	sub    $0x8,%esp
  802001:	68 00 00 40 00       	push   $0x400000
  802006:	6a 00                	push   $0x0
  802008:	e8 3c f0 ff ff       	call   801049 <sys_page_unmap>
  80200d:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802010:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802016:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80201c:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802022:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802028:	0f 82 f7 fe ff ff    	jb     801f25 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80202e:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802035:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80203c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802043:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802049:	0f 8c 65 fe ff ff    	jl     801eb4 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80204f:	83 ec 0c             	sub    $0xc,%esp
  802052:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802058:	e8 97 f5 ff ff       	call   8015f4 <close>
  80205d:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  802060:	bb 00 08 00 00       	mov    $0x800,%ebx
  802065:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        if ((uvpd[pn >> 10] & PTE_P) &&uvpt[pn] & PTE_SHARE)
  80206b:	89 d8                	mov    %ebx,%eax
  80206d:	c1 f8 0a             	sar    $0xa,%eax
  802070:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802077:	a8 01                	test   $0x1,%al
  802079:	74 3e                	je     8020b9 <spawn+0x45a>
  80207b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  802082:	f6 c4 04             	test   $0x4,%ah
  802085:	74 32                	je     8020b9 <spawn+0x45a>
            if ( (r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), child, (void *)(pn*PGSIZE), uvpt[pn] & PTE_SYSCALL )) < 0)
  802087:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80208e:	89 da                	mov    %ebx,%edx
  802090:	c1 e2 0c             	shl    $0xc,%edx
  802093:	8b 0d 04 50 80 00    	mov    0x805004,%ecx
  802099:	8b 49 48             	mov    0x48(%ecx),%ecx
  80209c:	83 ec 0c             	sub    $0xc,%esp
  80209f:	25 07 0e 00 00       	and    $0xe07,%eax
  8020a4:	50                   	push   %eax
  8020a5:	52                   	push   %edx
  8020a6:	56                   	push   %esi
  8020a7:	52                   	push   %edx
  8020a8:	51                   	push   %ecx
  8020a9:	e8 59 ef ff ff       	call   801007 <sys_page_map>
  8020ae:	83 c4 20             	add    $0x20,%esp
  8020b1:	85 c0                	test   %eax,%eax
  8020b3:	0f 88 dd 00 00 00    	js     802196 <spawn+0x537>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  8020b9:	83 c3 01             	add    $0x1,%ebx
  8020bc:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8020c2:	75 a7                	jne    80206b <spawn+0x40c>
  8020c4:	e9 9e 00 00 00       	jmp    802167 <spawn+0x508>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8020c9:	50                   	push   %eax
  8020ca:	68 92 30 80 00       	push   $0x803092
  8020cf:	68 86 00 00 00       	push   $0x86
  8020d4:	68 69 30 80 00       	push   $0x803069
  8020d9:	e8 06 e4 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8020de:	83 ec 08             	sub    $0x8,%esp
  8020e1:	6a 02                	push   $0x2
  8020e3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020e9:	e8 9d ef ff ff       	call   80108b <sys_env_set_status>
  8020ee:	83 c4 10             	add    $0x10,%esp
  8020f1:	85 c0                	test   %eax,%eax
  8020f3:	79 2b                	jns    802120 <spawn+0x4c1>
		panic("sys_env_set_status: %e", r);
  8020f5:	50                   	push   %eax
  8020f6:	68 ac 30 80 00       	push   $0x8030ac
  8020fb:	68 89 00 00 00       	push   $0x89
  802100:	68 69 30 80 00       	push   $0x803069
  802105:	e8 da e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80210a:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802110:	e9 a8 00 00 00       	jmp    8021bd <spawn+0x55e>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802115:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80211b:	e9 9d 00 00 00       	jmp    8021bd <spawn+0x55e>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802120:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802126:	e9 92 00 00 00       	jmp    8021bd <spawn+0x55e>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80212b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802130:	e9 88 00 00 00       	jmp    8021bd <spawn+0x55e>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802135:	89 c3                	mov    %eax,%ebx
  802137:	e9 81 00 00 00       	jmp    8021bd <spawn+0x55e>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80213c:	89 c3                	mov    %eax,%ebx
  80213e:	eb 06                	jmp    802146 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802140:	89 c3                	mov    %eax,%ebx
  802142:	eb 02                	jmp    802146 <spawn+0x4e7>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802144:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802146:	83 ec 0c             	sub    $0xc,%esp
  802149:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80214f:	e8 f1 ed ff ff       	call   800f45 <sys_env_destroy>
	close(fd);
  802154:	83 c4 04             	add    $0x4,%esp
  802157:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80215d:	e8 92 f4 ff ff       	call   8015f4 <close>
	return r;
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	eb 56                	jmp    8021bd <spawn+0x55e>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802167:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80216e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802171:	83 ec 08             	sub    $0x8,%esp
  802174:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80217a:	50                   	push   %eax
  80217b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802181:	e8 47 ef ff ff       	call   8010cd <sys_env_set_trapframe>
  802186:	83 c4 10             	add    $0x10,%esp
  802189:	85 c0                	test   %eax,%eax
  80218b:	0f 89 4d ff ff ff    	jns    8020de <spawn+0x47f>
  802191:	e9 33 ff ff ff       	jmp    8020c9 <spawn+0x46a>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802196:	50                   	push   %eax
  802197:	68 c3 30 80 00       	push   $0x8030c3
  80219c:	68 82 00 00 00       	push   $0x82
  8021a1:	68 69 30 80 00       	push   $0x803069
  8021a6:	e8 39 e3 ff ff       	call   8004e4 <_panic>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8021ab:	83 ec 08             	sub    $0x8,%esp
  8021ae:	68 00 00 40 00       	push   $0x400000
  8021b3:	6a 00                	push   $0x0
  8021b5:	e8 8f ee ff ff       	call   801049 <sys_page_unmap>
  8021ba:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8021bd:	89 d8                	mov    %ebx,%eax
  8021bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c2:	5b                   	pop    %ebx
  8021c3:	5e                   	pop    %esi
  8021c4:	5f                   	pop    %edi
  8021c5:	5d                   	pop    %ebp
  8021c6:	c3                   	ret    

008021c7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	56                   	push   %esi
  8021cb:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021cc:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021cf:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021d4:	eb 03                	jmp    8021d9 <spawnl+0x12>
		argc++;
  8021d6:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021d9:	83 c2 04             	add    $0x4,%edx
  8021dc:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8021e0:	75 f4                	jne    8021d6 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021e2:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8021e9:	83 e2 f0             	and    $0xfffffff0,%edx
  8021ec:	29 d4                	sub    %edx,%esp
  8021ee:	8d 54 24 03          	lea    0x3(%esp),%edx
  8021f2:	c1 ea 02             	shr    $0x2,%edx
  8021f5:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021fc:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802201:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802208:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80220f:	00 
  802210:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802212:	b8 00 00 00 00       	mov    $0x0,%eax
  802217:	eb 0a                	jmp    802223 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802219:	83 c0 01             	add    $0x1,%eax
  80221c:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802220:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802223:	39 d0                	cmp    %edx,%eax
  802225:	75 f2                	jne    802219 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802227:	83 ec 08             	sub    $0x8,%esp
  80222a:	56                   	push   %esi
  80222b:	ff 75 08             	pushl  0x8(%ebp)
  80222e:	e8 2c fa ff ff       	call   801c5f <spawn>
}
  802233:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802236:	5b                   	pop    %ebx
  802237:	5e                   	pop    %esi
  802238:	5d                   	pop    %ebp
  802239:	c3                   	ret    

0080223a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80223a:	55                   	push   %ebp
  80223b:	89 e5                	mov    %esp,%ebp
  80223d:	56                   	push   %esi
  80223e:	53                   	push   %ebx
  80223f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802242:	83 ec 0c             	sub    $0xc,%esp
  802245:	ff 75 08             	pushl  0x8(%ebp)
  802248:	e8 17 f2 ff ff       	call   801464 <fd2data>
  80224d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80224f:	83 c4 08             	add    $0x8,%esp
  802252:	68 04 31 80 00       	push   $0x803104
  802257:	53                   	push   %ebx
  802258:	e8 64 e9 ff ff       	call   800bc1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80225d:	8b 46 04             	mov    0x4(%esi),%eax
  802260:	2b 06                	sub    (%esi),%eax
  802262:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802268:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80226f:	00 00 00 
	stat->st_dev = &devpipe;
  802272:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802279:	40 80 00 
	return 0;
}
  80227c:	b8 00 00 00 00       	mov    $0x0,%eax
  802281:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    

00802288 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	53                   	push   %ebx
  80228c:	83 ec 0c             	sub    $0xc,%esp
  80228f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802292:	53                   	push   %ebx
  802293:	6a 00                	push   $0x0
  802295:	e8 af ed ff ff       	call   801049 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80229a:	89 1c 24             	mov    %ebx,(%esp)
  80229d:	e8 c2 f1 ff ff       	call   801464 <fd2data>
  8022a2:	83 c4 08             	add    $0x8,%esp
  8022a5:	50                   	push   %eax
  8022a6:	6a 00                	push   $0x0
  8022a8:	e8 9c ed ff ff       	call   801049 <sys_page_unmap>
}
  8022ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022b0:	c9                   	leave  
  8022b1:	c3                   	ret    

008022b2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	57                   	push   %edi
  8022b6:	56                   	push   %esi
  8022b7:	53                   	push   %ebx
  8022b8:	83 ec 1c             	sub    $0x1c,%esp
  8022bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8022be:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022c0:	a1 04 50 80 00       	mov    0x805004,%eax
  8022c5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8022c8:	83 ec 0c             	sub    $0xc,%esp
  8022cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8022ce:	e8 8f 04 00 00       	call   802762 <pageref>
  8022d3:	89 c3                	mov    %eax,%ebx
  8022d5:	89 3c 24             	mov    %edi,(%esp)
  8022d8:	e8 85 04 00 00       	call   802762 <pageref>
  8022dd:	83 c4 10             	add    $0x10,%esp
  8022e0:	39 c3                	cmp    %eax,%ebx
  8022e2:	0f 94 c1             	sete   %cl
  8022e5:	0f b6 c9             	movzbl %cl,%ecx
  8022e8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8022eb:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8022f1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022f4:	39 ce                	cmp    %ecx,%esi
  8022f6:	74 1b                	je     802313 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8022f8:	39 c3                	cmp    %eax,%ebx
  8022fa:	75 c4                	jne    8022c0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022fc:	8b 42 58             	mov    0x58(%edx),%eax
  8022ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  802302:	50                   	push   %eax
  802303:	56                   	push   %esi
  802304:	68 0b 31 80 00       	push   $0x80310b
  802309:	e8 af e2 ff ff       	call   8005bd <cprintf>
  80230e:	83 c4 10             	add    $0x10,%esp
  802311:	eb ad                	jmp    8022c0 <_pipeisclosed+0xe>
	}
}
  802313:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802316:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802319:	5b                   	pop    %ebx
  80231a:	5e                   	pop    %esi
  80231b:	5f                   	pop    %edi
  80231c:	5d                   	pop    %ebp
  80231d:	c3                   	ret    

0080231e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	53                   	push   %ebx
  802324:	83 ec 28             	sub    $0x28,%esp
  802327:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80232a:	56                   	push   %esi
  80232b:	e8 34 f1 ff ff       	call   801464 <fd2data>
  802330:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802332:	83 c4 10             	add    $0x10,%esp
  802335:	bf 00 00 00 00       	mov    $0x0,%edi
  80233a:	eb 4b                	jmp    802387 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80233c:	89 da                	mov    %ebx,%edx
  80233e:	89 f0                	mov    %esi,%eax
  802340:	e8 6d ff ff ff       	call   8022b2 <_pipeisclosed>
  802345:	85 c0                	test   %eax,%eax
  802347:	75 48                	jne    802391 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802349:	e8 57 ec ff ff       	call   800fa5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80234e:	8b 43 04             	mov    0x4(%ebx),%eax
  802351:	8b 0b                	mov    (%ebx),%ecx
  802353:	8d 51 20             	lea    0x20(%ecx),%edx
  802356:	39 d0                	cmp    %edx,%eax
  802358:	73 e2                	jae    80233c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80235a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80235d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802361:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802364:	89 c2                	mov    %eax,%edx
  802366:	c1 fa 1f             	sar    $0x1f,%edx
  802369:	89 d1                	mov    %edx,%ecx
  80236b:	c1 e9 1b             	shr    $0x1b,%ecx
  80236e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802371:	83 e2 1f             	and    $0x1f,%edx
  802374:	29 ca                	sub    %ecx,%edx
  802376:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80237a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80237e:	83 c0 01             	add    $0x1,%eax
  802381:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802384:	83 c7 01             	add    $0x1,%edi
  802387:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80238a:	75 c2                	jne    80234e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80238c:	8b 45 10             	mov    0x10(%ebp),%eax
  80238f:	eb 05                	jmp    802396 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802391:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802396:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802399:	5b                   	pop    %ebx
  80239a:	5e                   	pop    %esi
  80239b:	5f                   	pop    %edi
  80239c:	5d                   	pop    %ebp
  80239d:	c3                   	ret    

0080239e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80239e:	55                   	push   %ebp
  80239f:	89 e5                	mov    %esp,%ebp
  8023a1:	57                   	push   %edi
  8023a2:	56                   	push   %esi
  8023a3:	53                   	push   %ebx
  8023a4:	83 ec 18             	sub    $0x18,%esp
  8023a7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023aa:	57                   	push   %edi
  8023ab:	e8 b4 f0 ff ff       	call   801464 <fd2data>
  8023b0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023b2:	83 c4 10             	add    $0x10,%esp
  8023b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023ba:	eb 3d                	jmp    8023f9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023bc:	85 db                	test   %ebx,%ebx
  8023be:	74 04                	je     8023c4 <devpipe_read+0x26>
				return i;
  8023c0:	89 d8                	mov    %ebx,%eax
  8023c2:	eb 44                	jmp    802408 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023c4:	89 f2                	mov    %esi,%edx
  8023c6:	89 f8                	mov    %edi,%eax
  8023c8:	e8 e5 fe ff ff       	call   8022b2 <_pipeisclosed>
  8023cd:	85 c0                	test   %eax,%eax
  8023cf:	75 32                	jne    802403 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023d1:	e8 cf eb ff ff       	call   800fa5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023d6:	8b 06                	mov    (%esi),%eax
  8023d8:	3b 46 04             	cmp    0x4(%esi),%eax
  8023db:	74 df                	je     8023bc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023dd:	99                   	cltd   
  8023de:	c1 ea 1b             	shr    $0x1b,%edx
  8023e1:	01 d0                	add    %edx,%eax
  8023e3:	83 e0 1f             	and    $0x1f,%eax
  8023e6:	29 d0                	sub    %edx,%eax
  8023e8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8023ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023f0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023f3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023f6:	83 c3 01             	add    $0x1,%ebx
  8023f9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023fc:	75 d8                	jne    8023d6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023fe:	8b 45 10             	mov    0x10(%ebp),%eax
  802401:	eb 05                	jmp    802408 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802403:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802408:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80240b:	5b                   	pop    %ebx
  80240c:	5e                   	pop    %esi
  80240d:	5f                   	pop    %edi
  80240e:	5d                   	pop    %ebp
  80240f:	c3                   	ret    

00802410 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802410:	55                   	push   %ebp
  802411:	89 e5                	mov    %esp,%ebp
  802413:	56                   	push   %esi
  802414:	53                   	push   %ebx
  802415:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802418:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80241b:	50                   	push   %eax
  80241c:	e8 5a f0 ff ff       	call   80147b <fd_alloc>
  802421:	83 c4 10             	add    $0x10,%esp
  802424:	89 c2                	mov    %eax,%edx
  802426:	85 c0                	test   %eax,%eax
  802428:	0f 88 2c 01 00 00    	js     80255a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80242e:	83 ec 04             	sub    $0x4,%esp
  802431:	68 07 04 00 00       	push   $0x407
  802436:	ff 75 f4             	pushl  -0xc(%ebp)
  802439:	6a 00                	push   $0x0
  80243b:	e8 84 eb ff ff       	call   800fc4 <sys_page_alloc>
  802440:	83 c4 10             	add    $0x10,%esp
  802443:	89 c2                	mov    %eax,%edx
  802445:	85 c0                	test   %eax,%eax
  802447:	0f 88 0d 01 00 00    	js     80255a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80244d:	83 ec 0c             	sub    $0xc,%esp
  802450:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802453:	50                   	push   %eax
  802454:	e8 22 f0 ff ff       	call   80147b <fd_alloc>
  802459:	89 c3                	mov    %eax,%ebx
  80245b:	83 c4 10             	add    $0x10,%esp
  80245e:	85 c0                	test   %eax,%eax
  802460:	0f 88 e2 00 00 00    	js     802548 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802466:	83 ec 04             	sub    $0x4,%esp
  802469:	68 07 04 00 00       	push   $0x407
  80246e:	ff 75 f0             	pushl  -0x10(%ebp)
  802471:	6a 00                	push   $0x0
  802473:	e8 4c eb ff ff       	call   800fc4 <sys_page_alloc>
  802478:	89 c3                	mov    %eax,%ebx
  80247a:	83 c4 10             	add    $0x10,%esp
  80247d:	85 c0                	test   %eax,%eax
  80247f:	0f 88 c3 00 00 00    	js     802548 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802485:	83 ec 0c             	sub    $0xc,%esp
  802488:	ff 75 f4             	pushl  -0xc(%ebp)
  80248b:	e8 d4 ef ff ff       	call   801464 <fd2data>
  802490:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802492:	83 c4 0c             	add    $0xc,%esp
  802495:	68 07 04 00 00       	push   $0x407
  80249a:	50                   	push   %eax
  80249b:	6a 00                	push   $0x0
  80249d:	e8 22 eb ff ff       	call   800fc4 <sys_page_alloc>
  8024a2:	89 c3                	mov    %eax,%ebx
  8024a4:	83 c4 10             	add    $0x10,%esp
  8024a7:	85 c0                	test   %eax,%eax
  8024a9:	0f 88 89 00 00 00    	js     802538 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024af:	83 ec 0c             	sub    $0xc,%esp
  8024b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8024b5:	e8 aa ef ff ff       	call   801464 <fd2data>
  8024ba:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8024c1:	50                   	push   %eax
  8024c2:	6a 00                	push   $0x0
  8024c4:	56                   	push   %esi
  8024c5:	6a 00                	push   $0x0
  8024c7:	e8 3b eb ff ff       	call   801007 <sys_page_map>
  8024cc:	89 c3                	mov    %eax,%ebx
  8024ce:	83 c4 20             	add    $0x20,%esp
  8024d1:	85 c0                	test   %eax,%eax
  8024d3:	78 55                	js     80252a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024d5:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024de:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024ea:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024f3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024f8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024ff:	83 ec 0c             	sub    $0xc,%esp
  802502:	ff 75 f4             	pushl  -0xc(%ebp)
  802505:	e8 4a ef ff ff       	call   801454 <fd2num>
  80250a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80250d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80250f:	83 c4 04             	add    $0x4,%esp
  802512:	ff 75 f0             	pushl  -0x10(%ebp)
  802515:	e8 3a ef ff ff       	call   801454 <fd2num>
  80251a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80251d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802520:	83 c4 10             	add    $0x10,%esp
  802523:	ba 00 00 00 00       	mov    $0x0,%edx
  802528:	eb 30                	jmp    80255a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80252a:	83 ec 08             	sub    $0x8,%esp
  80252d:	56                   	push   %esi
  80252e:	6a 00                	push   $0x0
  802530:	e8 14 eb ff ff       	call   801049 <sys_page_unmap>
  802535:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802538:	83 ec 08             	sub    $0x8,%esp
  80253b:	ff 75 f0             	pushl  -0x10(%ebp)
  80253e:	6a 00                	push   $0x0
  802540:	e8 04 eb ff ff       	call   801049 <sys_page_unmap>
  802545:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802548:	83 ec 08             	sub    $0x8,%esp
  80254b:	ff 75 f4             	pushl  -0xc(%ebp)
  80254e:	6a 00                	push   $0x0
  802550:	e8 f4 ea ff ff       	call   801049 <sys_page_unmap>
  802555:	83 c4 10             	add    $0x10,%esp
  802558:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80255a:	89 d0                	mov    %edx,%eax
  80255c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80255f:	5b                   	pop    %ebx
  802560:	5e                   	pop    %esi
  802561:	5d                   	pop    %ebp
  802562:	c3                   	ret    

00802563 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802563:	55                   	push   %ebp
  802564:	89 e5                	mov    %esp,%ebp
  802566:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802569:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80256c:	50                   	push   %eax
  80256d:	ff 75 08             	pushl  0x8(%ebp)
  802570:	e8 55 ef ff ff       	call   8014ca <fd_lookup>
  802575:	83 c4 10             	add    $0x10,%esp
  802578:	85 c0                	test   %eax,%eax
  80257a:	78 18                	js     802594 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80257c:	83 ec 0c             	sub    $0xc,%esp
  80257f:	ff 75 f4             	pushl  -0xc(%ebp)
  802582:	e8 dd ee ff ff       	call   801464 <fd2data>
	return _pipeisclosed(fd, p);
  802587:	89 c2                	mov    %eax,%edx
  802589:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80258c:	e8 21 fd ff ff       	call   8022b2 <_pipeisclosed>
  802591:	83 c4 10             	add    $0x10,%esp
}
  802594:	c9                   	leave  
  802595:	c3                   	ret    

00802596 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802596:	55                   	push   %ebp
  802597:	89 e5                	mov    %esp,%ebp
  802599:	56                   	push   %esi
  80259a:	53                   	push   %ebx
  80259b:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80259e:	85 f6                	test   %esi,%esi
  8025a0:	75 16                	jne    8025b8 <wait+0x22>
  8025a2:	68 23 31 80 00       	push   $0x803123
  8025a7:	68 23 30 80 00       	push   $0x803023
  8025ac:	6a 09                	push   $0x9
  8025ae:	68 2e 31 80 00       	push   $0x80312e
  8025b3:	e8 2c df ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  8025b8:	89 f3                	mov    %esi,%ebx
  8025ba:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025c0:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8025c3:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8025c9:	eb 05                	jmp    8025d0 <wait+0x3a>
		sys_yield();
  8025cb:	e8 d5 e9 ff ff       	call   800fa5 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025d0:	8b 43 48             	mov    0x48(%ebx),%eax
  8025d3:	39 c6                	cmp    %eax,%esi
  8025d5:	75 07                	jne    8025de <wait+0x48>
  8025d7:	8b 43 54             	mov    0x54(%ebx),%eax
  8025da:	85 c0                	test   %eax,%eax
  8025dc:	75 ed                	jne    8025cb <wait+0x35>
		sys_yield();
}
  8025de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025e1:	5b                   	pop    %ebx
  8025e2:	5e                   	pop    %esi
  8025e3:	5d                   	pop    %ebp
  8025e4:	c3                   	ret    

008025e5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025e5:	55                   	push   %ebp
  8025e6:	89 e5                	mov    %esp,%ebp
  8025e8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025eb:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8025f2:	75 4a                	jne    80263e <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  8025f4:	a1 04 50 80 00       	mov    0x805004,%eax
  8025f9:	8b 40 48             	mov    0x48(%eax),%eax
  8025fc:	83 ec 04             	sub    $0x4,%esp
  8025ff:	6a 07                	push   $0x7
  802601:	68 00 f0 bf ee       	push   $0xeebff000
  802606:	50                   	push   %eax
  802607:	e8 b8 e9 ff ff       	call   800fc4 <sys_page_alloc>
  80260c:	83 c4 10             	add    $0x10,%esp
  80260f:	85 c0                	test   %eax,%eax
  802611:	79 12                	jns    802625 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  802613:	50                   	push   %eax
  802614:	68 39 31 80 00       	push   $0x803139
  802619:	6a 21                	push   $0x21
  80261b:	68 51 31 80 00       	push   $0x803151
  802620:	e8 bf de ff ff       	call   8004e4 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802625:	a1 04 50 80 00       	mov    0x805004,%eax
  80262a:	8b 40 48             	mov    0x48(%eax),%eax
  80262d:	83 ec 08             	sub    $0x8,%esp
  802630:	68 48 26 80 00       	push   $0x802648
  802635:	50                   	push   %eax
  802636:	e8 d4 ea ff ff       	call   80110f <sys_env_set_pgfault_upcall>
  80263b:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80263e:	8b 45 08             	mov    0x8(%ebp),%eax
  802641:	a3 00 70 80 00       	mov    %eax,0x807000
  802646:	c9                   	leave  
  802647:	c3                   	ret    

00802648 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802648:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802649:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80264e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802650:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  802653:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  802656:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  80265a:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  80265f:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  802663:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802665:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  802666:	83 c4 04             	add    $0x4,%esp
	popfl
  802669:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80266a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  80266b:	c3                   	ret    

0080266c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80266c:	55                   	push   %ebp
  80266d:	89 e5                	mov    %esp,%ebp
  80266f:	56                   	push   %esi
  802670:	53                   	push   %ebx
  802671:	8b 75 08             	mov    0x8(%ebp),%esi
  802674:	8b 45 0c             	mov    0xc(%ebp),%eax
  802677:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  80267a:	85 c0                	test   %eax,%eax
  80267c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802681:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  802684:	83 ec 0c             	sub    $0xc,%esp
  802687:	50                   	push   %eax
  802688:	e8 e7 ea ff ff       	call   801174 <sys_ipc_recv>
  80268d:	83 c4 10             	add    $0x10,%esp
  802690:	85 c0                	test   %eax,%eax
  802692:	79 16                	jns    8026aa <ipc_recv+0x3e>
        if (from_env_store != NULL)
  802694:	85 f6                	test   %esi,%esi
  802696:	74 06                	je     80269e <ipc_recv+0x32>
            *from_env_store = 0;
  802698:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  80269e:	85 db                	test   %ebx,%ebx
  8026a0:	74 2c                	je     8026ce <ipc_recv+0x62>
            *perm_store = 0;
  8026a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026a8:	eb 24                	jmp    8026ce <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  8026aa:	85 f6                	test   %esi,%esi
  8026ac:	74 0a                	je     8026b8 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  8026ae:	a1 04 50 80 00       	mov    0x805004,%eax
  8026b3:	8b 40 74             	mov    0x74(%eax),%eax
  8026b6:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  8026b8:	85 db                	test   %ebx,%ebx
  8026ba:	74 0a                	je     8026c6 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  8026bc:	a1 04 50 80 00       	mov    0x805004,%eax
  8026c1:	8b 40 78             	mov    0x78(%eax),%eax
  8026c4:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  8026c6:	a1 04 50 80 00       	mov    0x805004,%eax
  8026cb:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8026ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026d1:	5b                   	pop    %ebx
  8026d2:	5e                   	pop    %esi
  8026d3:	5d                   	pop    %ebp
  8026d4:	c3                   	ret    

008026d5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026d5:	55                   	push   %ebp
  8026d6:	89 e5                	mov    %esp,%ebp
  8026d8:	57                   	push   %edi
  8026d9:	56                   	push   %esi
  8026da:	53                   	push   %ebx
  8026db:	83 ec 0c             	sub    $0xc,%esp
  8026de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8026e7:	85 c0                	test   %eax,%eax
  8026e9:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8026ee:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8026f1:	eb 1c                	jmp    80270f <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  8026f3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026f6:	74 12                	je     80270a <ipc_send+0x35>
  8026f8:	50                   	push   %eax
  8026f9:	68 5f 31 80 00       	push   $0x80315f
  8026fe:	6a 3a                	push   $0x3a
  802700:	68 75 31 80 00       	push   $0x803175
  802705:	e8 da dd ff ff       	call   8004e4 <_panic>
		sys_yield();
  80270a:	e8 96 e8 ff ff       	call   800fa5 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80270f:	ff 75 14             	pushl  0x14(%ebp)
  802712:	53                   	push   %ebx
  802713:	56                   	push   %esi
  802714:	57                   	push   %edi
  802715:	e8 37 ea ff ff       	call   801151 <sys_ipc_try_send>
  80271a:	83 c4 10             	add    $0x10,%esp
  80271d:	85 c0                	test   %eax,%eax
  80271f:	78 d2                	js     8026f3 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802721:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802724:	5b                   	pop    %ebx
  802725:	5e                   	pop    %esi
  802726:	5f                   	pop    %edi
  802727:	5d                   	pop    %ebp
  802728:	c3                   	ret    

00802729 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802729:	55                   	push   %ebp
  80272a:	89 e5                	mov    %esp,%ebp
  80272c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80272f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802734:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802737:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80273d:	8b 52 50             	mov    0x50(%edx),%edx
  802740:	39 ca                	cmp    %ecx,%edx
  802742:	75 0d                	jne    802751 <ipc_find_env+0x28>
			return envs[i].env_id;
  802744:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802747:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80274c:	8b 40 48             	mov    0x48(%eax),%eax
  80274f:	eb 0f                	jmp    802760 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802751:	83 c0 01             	add    $0x1,%eax
  802754:	3d 00 04 00 00       	cmp    $0x400,%eax
  802759:	75 d9                	jne    802734 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80275b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802760:	5d                   	pop    %ebp
  802761:	c3                   	ret    

00802762 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802762:	55                   	push   %ebp
  802763:	89 e5                	mov    %esp,%ebp
  802765:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802768:	89 d0                	mov    %edx,%eax
  80276a:	c1 e8 16             	shr    $0x16,%eax
  80276d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802774:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802779:	f6 c1 01             	test   $0x1,%cl
  80277c:	74 1d                	je     80279b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80277e:	c1 ea 0c             	shr    $0xc,%edx
  802781:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802788:	f6 c2 01             	test   $0x1,%dl
  80278b:	74 0e                	je     80279b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80278d:	c1 ea 0c             	shr    $0xc,%edx
  802790:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802797:	ef 
  802798:	0f b7 c0             	movzwl %ax,%eax
}
  80279b:	5d                   	pop    %ebp
  80279c:	c3                   	ret    
  80279d:	66 90                	xchg   %ax,%ax
  80279f:	90                   	nop

008027a0 <__udivdi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 f6                	test   %esi,%esi
  8027b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027bd:	89 ca                	mov    %ecx,%edx
  8027bf:	89 f8                	mov    %edi,%eax
  8027c1:	75 3d                	jne    802800 <__udivdi3+0x60>
  8027c3:	39 cf                	cmp    %ecx,%edi
  8027c5:	0f 87 c5 00 00 00    	ja     802890 <__udivdi3+0xf0>
  8027cb:	85 ff                	test   %edi,%edi
  8027cd:	89 fd                	mov    %edi,%ebp
  8027cf:	75 0b                	jne    8027dc <__udivdi3+0x3c>
  8027d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d6:	31 d2                	xor    %edx,%edx
  8027d8:	f7 f7                	div    %edi
  8027da:	89 c5                	mov    %eax,%ebp
  8027dc:	89 c8                	mov    %ecx,%eax
  8027de:	31 d2                	xor    %edx,%edx
  8027e0:	f7 f5                	div    %ebp
  8027e2:	89 c1                	mov    %eax,%ecx
  8027e4:	89 d8                	mov    %ebx,%eax
  8027e6:	89 cf                	mov    %ecx,%edi
  8027e8:	f7 f5                	div    %ebp
  8027ea:	89 c3                	mov    %eax,%ebx
  8027ec:	89 d8                	mov    %ebx,%eax
  8027ee:	89 fa                	mov    %edi,%edx
  8027f0:	83 c4 1c             	add    $0x1c,%esp
  8027f3:	5b                   	pop    %ebx
  8027f4:	5e                   	pop    %esi
  8027f5:	5f                   	pop    %edi
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    
  8027f8:	90                   	nop
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	39 ce                	cmp    %ecx,%esi
  802802:	77 74                	ja     802878 <__udivdi3+0xd8>
  802804:	0f bd fe             	bsr    %esi,%edi
  802807:	83 f7 1f             	xor    $0x1f,%edi
  80280a:	0f 84 98 00 00 00    	je     8028a8 <__udivdi3+0x108>
  802810:	bb 20 00 00 00       	mov    $0x20,%ebx
  802815:	89 f9                	mov    %edi,%ecx
  802817:	89 c5                	mov    %eax,%ebp
  802819:	29 fb                	sub    %edi,%ebx
  80281b:	d3 e6                	shl    %cl,%esi
  80281d:	89 d9                	mov    %ebx,%ecx
  80281f:	d3 ed                	shr    %cl,%ebp
  802821:	89 f9                	mov    %edi,%ecx
  802823:	d3 e0                	shl    %cl,%eax
  802825:	09 ee                	or     %ebp,%esi
  802827:	89 d9                	mov    %ebx,%ecx
  802829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80282d:	89 d5                	mov    %edx,%ebp
  80282f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802833:	d3 ed                	shr    %cl,%ebp
  802835:	89 f9                	mov    %edi,%ecx
  802837:	d3 e2                	shl    %cl,%edx
  802839:	89 d9                	mov    %ebx,%ecx
  80283b:	d3 e8                	shr    %cl,%eax
  80283d:	09 c2                	or     %eax,%edx
  80283f:	89 d0                	mov    %edx,%eax
  802841:	89 ea                	mov    %ebp,%edx
  802843:	f7 f6                	div    %esi
  802845:	89 d5                	mov    %edx,%ebp
  802847:	89 c3                	mov    %eax,%ebx
  802849:	f7 64 24 0c          	mull   0xc(%esp)
  80284d:	39 d5                	cmp    %edx,%ebp
  80284f:	72 10                	jb     802861 <__udivdi3+0xc1>
  802851:	8b 74 24 08          	mov    0x8(%esp),%esi
  802855:	89 f9                	mov    %edi,%ecx
  802857:	d3 e6                	shl    %cl,%esi
  802859:	39 c6                	cmp    %eax,%esi
  80285b:	73 07                	jae    802864 <__udivdi3+0xc4>
  80285d:	39 d5                	cmp    %edx,%ebp
  80285f:	75 03                	jne    802864 <__udivdi3+0xc4>
  802861:	83 eb 01             	sub    $0x1,%ebx
  802864:	31 ff                	xor    %edi,%edi
  802866:	89 d8                	mov    %ebx,%eax
  802868:	89 fa                	mov    %edi,%edx
  80286a:	83 c4 1c             	add    $0x1c,%esp
  80286d:	5b                   	pop    %ebx
  80286e:	5e                   	pop    %esi
  80286f:	5f                   	pop    %edi
  802870:	5d                   	pop    %ebp
  802871:	c3                   	ret    
  802872:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802878:	31 ff                	xor    %edi,%edi
  80287a:	31 db                	xor    %ebx,%ebx
  80287c:	89 d8                	mov    %ebx,%eax
  80287e:	89 fa                	mov    %edi,%edx
  802880:	83 c4 1c             	add    $0x1c,%esp
  802883:	5b                   	pop    %ebx
  802884:	5e                   	pop    %esi
  802885:	5f                   	pop    %edi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    
  802888:	90                   	nop
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	89 d8                	mov    %ebx,%eax
  802892:	f7 f7                	div    %edi
  802894:	31 ff                	xor    %edi,%edi
  802896:	89 c3                	mov    %eax,%ebx
  802898:	89 d8                	mov    %ebx,%eax
  80289a:	89 fa                	mov    %edi,%edx
  80289c:	83 c4 1c             	add    $0x1c,%esp
  80289f:	5b                   	pop    %ebx
  8028a0:	5e                   	pop    %esi
  8028a1:	5f                   	pop    %edi
  8028a2:	5d                   	pop    %ebp
  8028a3:	c3                   	ret    
  8028a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028a8:	39 ce                	cmp    %ecx,%esi
  8028aa:	72 0c                	jb     8028b8 <__udivdi3+0x118>
  8028ac:	31 db                	xor    %ebx,%ebx
  8028ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028b2:	0f 87 34 ff ff ff    	ja     8027ec <__udivdi3+0x4c>
  8028b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028bd:	e9 2a ff ff ff       	jmp    8027ec <__udivdi3+0x4c>
  8028c2:	66 90                	xchg   %ax,%ax
  8028c4:	66 90                	xchg   %ax,%ax
  8028c6:	66 90                	xchg   %ax,%ax
  8028c8:	66 90                	xchg   %ax,%ax
  8028ca:	66 90                	xchg   %ax,%ax
  8028cc:	66 90                	xchg   %ax,%ax
  8028ce:	66 90                	xchg   %ax,%ax

008028d0 <__umoddi3>:
  8028d0:	55                   	push   %ebp
  8028d1:	57                   	push   %edi
  8028d2:	56                   	push   %esi
  8028d3:	53                   	push   %ebx
  8028d4:	83 ec 1c             	sub    $0x1c,%esp
  8028d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028e7:	85 d2                	test   %edx,%edx
  8028e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028f1:	89 f3                	mov    %esi,%ebx
  8028f3:	89 3c 24             	mov    %edi,(%esp)
  8028f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028fa:	75 1c                	jne    802918 <__umoddi3+0x48>
  8028fc:	39 f7                	cmp    %esi,%edi
  8028fe:	76 50                	jbe    802950 <__umoddi3+0x80>
  802900:	89 c8                	mov    %ecx,%eax
  802902:	89 f2                	mov    %esi,%edx
  802904:	f7 f7                	div    %edi
  802906:	89 d0                	mov    %edx,%eax
  802908:	31 d2                	xor    %edx,%edx
  80290a:	83 c4 1c             	add    $0x1c,%esp
  80290d:	5b                   	pop    %ebx
  80290e:	5e                   	pop    %esi
  80290f:	5f                   	pop    %edi
  802910:	5d                   	pop    %ebp
  802911:	c3                   	ret    
  802912:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802918:	39 f2                	cmp    %esi,%edx
  80291a:	89 d0                	mov    %edx,%eax
  80291c:	77 52                	ja     802970 <__umoddi3+0xa0>
  80291e:	0f bd ea             	bsr    %edx,%ebp
  802921:	83 f5 1f             	xor    $0x1f,%ebp
  802924:	75 5a                	jne    802980 <__umoddi3+0xb0>
  802926:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80292a:	0f 82 e0 00 00 00    	jb     802a10 <__umoddi3+0x140>
  802930:	39 0c 24             	cmp    %ecx,(%esp)
  802933:	0f 86 d7 00 00 00    	jbe    802a10 <__umoddi3+0x140>
  802939:	8b 44 24 08          	mov    0x8(%esp),%eax
  80293d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802941:	83 c4 1c             	add    $0x1c,%esp
  802944:	5b                   	pop    %ebx
  802945:	5e                   	pop    %esi
  802946:	5f                   	pop    %edi
  802947:	5d                   	pop    %ebp
  802948:	c3                   	ret    
  802949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802950:	85 ff                	test   %edi,%edi
  802952:	89 fd                	mov    %edi,%ebp
  802954:	75 0b                	jne    802961 <__umoddi3+0x91>
  802956:	b8 01 00 00 00       	mov    $0x1,%eax
  80295b:	31 d2                	xor    %edx,%edx
  80295d:	f7 f7                	div    %edi
  80295f:	89 c5                	mov    %eax,%ebp
  802961:	89 f0                	mov    %esi,%eax
  802963:	31 d2                	xor    %edx,%edx
  802965:	f7 f5                	div    %ebp
  802967:	89 c8                	mov    %ecx,%eax
  802969:	f7 f5                	div    %ebp
  80296b:	89 d0                	mov    %edx,%eax
  80296d:	eb 99                	jmp    802908 <__umoddi3+0x38>
  80296f:	90                   	nop
  802970:	89 c8                	mov    %ecx,%eax
  802972:	89 f2                	mov    %esi,%edx
  802974:	83 c4 1c             	add    $0x1c,%esp
  802977:	5b                   	pop    %ebx
  802978:	5e                   	pop    %esi
  802979:	5f                   	pop    %edi
  80297a:	5d                   	pop    %ebp
  80297b:	c3                   	ret    
  80297c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802980:	8b 34 24             	mov    (%esp),%esi
  802983:	bf 20 00 00 00       	mov    $0x20,%edi
  802988:	89 e9                	mov    %ebp,%ecx
  80298a:	29 ef                	sub    %ebp,%edi
  80298c:	d3 e0                	shl    %cl,%eax
  80298e:	89 f9                	mov    %edi,%ecx
  802990:	89 f2                	mov    %esi,%edx
  802992:	d3 ea                	shr    %cl,%edx
  802994:	89 e9                	mov    %ebp,%ecx
  802996:	09 c2                	or     %eax,%edx
  802998:	89 d8                	mov    %ebx,%eax
  80299a:	89 14 24             	mov    %edx,(%esp)
  80299d:	89 f2                	mov    %esi,%edx
  80299f:	d3 e2                	shl    %cl,%edx
  8029a1:	89 f9                	mov    %edi,%ecx
  8029a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029ab:	d3 e8                	shr    %cl,%eax
  8029ad:	89 e9                	mov    %ebp,%ecx
  8029af:	89 c6                	mov    %eax,%esi
  8029b1:	d3 e3                	shl    %cl,%ebx
  8029b3:	89 f9                	mov    %edi,%ecx
  8029b5:	89 d0                	mov    %edx,%eax
  8029b7:	d3 e8                	shr    %cl,%eax
  8029b9:	89 e9                	mov    %ebp,%ecx
  8029bb:	09 d8                	or     %ebx,%eax
  8029bd:	89 d3                	mov    %edx,%ebx
  8029bf:	89 f2                	mov    %esi,%edx
  8029c1:	f7 34 24             	divl   (%esp)
  8029c4:	89 d6                	mov    %edx,%esi
  8029c6:	d3 e3                	shl    %cl,%ebx
  8029c8:	f7 64 24 04          	mull   0x4(%esp)
  8029cc:	39 d6                	cmp    %edx,%esi
  8029ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029d2:	89 d1                	mov    %edx,%ecx
  8029d4:	89 c3                	mov    %eax,%ebx
  8029d6:	72 08                	jb     8029e0 <__umoddi3+0x110>
  8029d8:	75 11                	jne    8029eb <__umoddi3+0x11b>
  8029da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029de:	73 0b                	jae    8029eb <__umoddi3+0x11b>
  8029e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029e4:	1b 14 24             	sbb    (%esp),%edx
  8029e7:	89 d1                	mov    %edx,%ecx
  8029e9:	89 c3                	mov    %eax,%ebx
  8029eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029ef:	29 da                	sub    %ebx,%edx
  8029f1:	19 ce                	sbb    %ecx,%esi
  8029f3:	89 f9                	mov    %edi,%ecx
  8029f5:	89 f0                	mov    %esi,%eax
  8029f7:	d3 e0                	shl    %cl,%eax
  8029f9:	89 e9                	mov    %ebp,%ecx
  8029fb:	d3 ea                	shr    %cl,%edx
  8029fd:	89 e9                	mov    %ebp,%ecx
  8029ff:	d3 ee                	shr    %cl,%esi
  802a01:	09 d0                	or     %edx,%eax
  802a03:	89 f2                	mov    %esi,%edx
  802a05:	83 c4 1c             	add    $0x1c,%esp
  802a08:	5b                   	pop    %ebx
  802a09:	5e                   	pop    %esi
  802a0a:	5f                   	pop    %edi
  802a0b:	5d                   	pop    %ebp
  802a0c:	c3                   	ret    
  802a0d:	8d 76 00             	lea    0x0(%esi),%esi
  802a10:	29 f9                	sub    %edi,%ecx
  802a12:	19 d6                	sbb    %edx,%esi
  802a14:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a1c:	e9 18 ff ff ff       	jmp    802939 <__umoddi3+0x69>
