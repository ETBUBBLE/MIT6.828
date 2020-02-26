
obj/user/badsegment.debug：     文件格式 elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
        binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 c6 04 00 00       	call   800555 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 ca 22 80 00       	push   $0x8022ca
  800108:	6a 23                	push   $0x23
  80010a:	68 e7 22 80 00       	push   $0x8022e7
  80010f:	e8 c7 13 00 00       	call   8014db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 ca 22 80 00       	push   $0x8022ca
  800189:	6a 23                	push   $0x23
  80018b:	68 e7 22 80 00       	push   $0x8022e7
  800190:	e8 46 13 00 00       	call   8014db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 ca 22 80 00       	push   $0x8022ca
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 e7 22 80 00       	push   $0x8022e7
  8001d2:	e8 04 13 00 00       	call   8014db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 ca 22 80 00       	push   $0x8022ca
  80020d:	6a 23                	push   $0x23
  80020f:	68 e7 22 80 00       	push   $0x8022e7
  800214:	e8 c2 12 00 00       	call   8014db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 ca 22 80 00       	push   $0x8022ca
  80024f:	6a 23                	push   $0x23
  800251:	68 e7 22 80 00       	push   $0x8022e7
  800256:	e8 80 12 00 00       	call   8014db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 ca 22 80 00       	push   $0x8022ca
  800291:	6a 23                	push   $0x23
  800293:	68 e7 22 80 00       	push   $0x8022e7
  800298:	e8 3e 12 00 00       	call   8014db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 ca 22 80 00       	push   $0x8022ca
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 e7 22 80 00       	push   $0x8022e7
  8002da:	e8 fc 11 00 00       	call   8014db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 ca 22 80 00       	push   $0x8022ca
  800337:	6a 23                	push   $0x23
  800339:	68 e7 22 80 00       	push   $0x8022e7
  80033e:	e8 98 11 00 00       	call   8014db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035b:	89 d1                	mov    %edx,%ecx
  80035d:	89 d3                	mov    %edx,%ebx
  80035f:	89 d7                	mov    %edx,%edi
  800361:	89 d6                	mov    %edx,%esi
  800363:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800370:	b9 00 00 00 00       	mov    $0x0,%ecx
  800375:	b8 10 00 00 00       	mov    $0x10,%eax
  80037a:	8b 55 08             	mov    0x8(%ebp),%edx
  80037d:	89 cb                	mov    %ecx,%ebx
  80037f:	89 cf                	mov    %ecx,%edi
  800381:	89 ce                	mov    %ecx,%esi
  800383:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800385:	5b                   	pop    %ebx
  800386:	5e                   	pop    %esi
  800387:	5f                   	pop    %edi
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	05 00 00 00 30       	add    $0x30000000,%eax
  800395:	c1 e8 0c             	shr    $0xc,%eax
}
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003aa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003af:	5d                   	pop    %ebp
  8003b0:	c3                   	ret    

008003b1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003bc:	89 c2                	mov    %eax,%edx
  8003be:	c1 ea 16             	shr    $0x16,%edx
  8003c1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c8:	f6 c2 01             	test   $0x1,%dl
  8003cb:	74 11                	je     8003de <fd_alloc+0x2d>
  8003cd:	89 c2                	mov    %eax,%edx
  8003cf:	c1 ea 0c             	shr    $0xc,%edx
  8003d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d9:	f6 c2 01             	test   $0x1,%dl
  8003dc:	75 09                	jne    8003e7 <fd_alloc+0x36>
			*fd_store = fd;
  8003de:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e5:	eb 17                	jmp    8003fe <fd_alloc+0x4d>
  8003e7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ec:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f1:	75 c9                	jne    8003bc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800406:	83 f8 1f             	cmp    $0x1f,%eax
  800409:	77 36                	ja     800441 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80040b:	c1 e0 0c             	shl    $0xc,%eax
  80040e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800413:	89 c2                	mov    %eax,%edx
  800415:	c1 ea 16             	shr    $0x16,%edx
  800418:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041f:	f6 c2 01             	test   $0x1,%dl
  800422:	74 24                	je     800448 <fd_lookup+0x48>
  800424:	89 c2                	mov    %eax,%edx
  800426:	c1 ea 0c             	shr    $0xc,%edx
  800429:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800430:	f6 c2 01             	test   $0x1,%dl
  800433:	74 1a                	je     80044f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800435:	8b 55 0c             	mov    0xc(%ebp),%edx
  800438:	89 02                	mov    %eax,(%edx)
	return 0;
  80043a:	b8 00 00 00 00       	mov    $0x0,%eax
  80043f:	eb 13                	jmp    800454 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800441:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800446:	eb 0c                	jmp    800454 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800448:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044d:	eb 05                	jmp    800454 <fd_lookup+0x54>
  80044f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045f:	ba 74 23 80 00       	mov    $0x802374,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800464:	eb 13                	jmp    800479 <dev_lookup+0x23>
  800466:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800469:	39 08                	cmp    %ecx,(%eax)
  80046b:	75 0c                	jne    800479 <dev_lookup+0x23>
			*dev = devtab[i];
  80046d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800470:	89 01                	mov    %eax,(%ecx)
			return 0;
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	eb 2e                	jmp    8004a7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800479:	8b 02                	mov    (%edx),%eax
  80047b:	85 c0                	test   %eax,%eax
  80047d:	75 e7                	jne    800466 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047f:	a1 08 40 80 00       	mov    0x804008,%eax
  800484:	8b 40 48             	mov    0x48(%eax),%eax
  800487:	83 ec 04             	sub    $0x4,%esp
  80048a:	51                   	push   %ecx
  80048b:	50                   	push   %eax
  80048c:	68 f8 22 80 00       	push   $0x8022f8
  800491:	e8 1e 11 00 00       	call   8015b4 <cprintf>
	*dev = 0;
  800496:	8b 45 0c             	mov    0xc(%ebp),%eax
  800499:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a7:	c9                   	leave  
  8004a8:	c3                   	ret    

008004a9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 10             	sub    $0x10,%esp
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ba:	50                   	push   %eax
  8004bb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c1:	c1 e8 0c             	shr    $0xc,%eax
  8004c4:	50                   	push   %eax
  8004c5:	e8 36 ff ff ff       	call   800400 <fd_lookup>
  8004ca:	83 c4 08             	add    $0x8,%esp
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	78 05                	js     8004d6 <fd_close+0x2d>
	    || fd != fd2)
  8004d1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004d4:	74 0c                	je     8004e2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004d6:	84 db                	test   %bl,%bl
  8004d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004dd:	0f 44 c2             	cmove  %edx,%eax
  8004e0:	eb 41                	jmp    800523 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e8:	50                   	push   %eax
  8004e9:	ff 36                	pushl  (%esi)
  8004eb:	e8 66 ff ff ff       	call   800456 <dev_lookup>
  8004f0:	89 c3                	mov    %eax,%ebx
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	78 1a                	js     800513 <fd_close+0x6a>
		if (dev->dev_close)
  8004f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004fc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004ff:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800504:	85 c0                	test   %eax,%eax
  800506:	74 0b                	je     800513 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800508:	83 ec 0c             	sub    $0xc,%esp
  80050b:	56                   	push   %esi
  80050c:	ff d0                	call   *%eax
  80050e:	89 c3                	mov    %eax,%ebx
  800510:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	56                   	push   %esi
  800517:	6a 00                	push   $0x0
  800519:	e8 c1 fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	89 d8                	mov    %ebx,%eax
}
  800523:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800526:	5b                   	pop    %ebx
  800527:	5e                   	pop    %esi
  800528:	5d                   	pop    %ebp
  800529:	c3                   	ret    

0080052a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800530:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800533:	50                   	push   %eax
  800534:	ff 75 08             	pushl  0x8(%ebp)
  800537:	e8 c4 fe ff ff       	call   800400 <fd_lookup>
  80053c:	83 c4 08             	add    $0x8,%esp
  80053f:	85 c0                	test   %eax,%eax
  800541:	78 10                	js     800553 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	6a 01                	push   $0x1
  800548:	ff 75 f4             	pushl  -0xc(%ebp)
  80054b:	e8 59 ff ff ff       	call   8004a9 <fd_close>
  800550:	83 c4 10             	add    $0x10,%esp
}
  800553:	c9                   	leave  
  800554:	c3                   	ret    

00800555 <close_all>:

void
close_all(void)
{
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	53                   	push   %ebx
  800559:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80055c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800561:	83 ec 0c             	sub    $0xc,%esp
  800564:	53                   	push   %ebx
  800565:	e8 c0 ff ff ff       	call   80052a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80056a:	83 c3 01             	add    $0x1,%ebx
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	83 fb 20             	cmp    $0x20,%ebx
  800573:	75 ec                	jne    800561 <close_all+0xc>
		close(i);
}
  800575:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800578:	c9                   	leave  
  800579:	c3                   	ret    

0080057a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	57                   	push   %edi
  80057e:	56                   	push   %esi
  80057f:	53                   	push   %ebx
  800580:	83 ec 2c             	sub    $0x2c,%esp
  800583:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800586:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800589:	50                   	push   %eax
  80058a:	ff 75 08             	pushl  0x8(%ebp)
  80058d:	e8 6e fe ff ff       	call   800400 <fd_lookup>
  800592:	83 c4 08             	add    $0x8,%esp
  800595:	85 c0                	test   %eax,%eax
  800597:	0f 88 c1 00 00 00    	js     80065e <dup+0xe4>
		return r;
	close(newfdnum);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	56                   	push   %esi
  8005a1:	e8 84 ff ff ff       	call   80052a <close>

	newfd = INDEX2FD(newfdnum);
  8005a6:	89 f3                	mov    %esi,%ebx
  8005a8:	c1 e3 0c             	shl    $0xc,%ebx
  8005ab:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b1:	83 c4 04             	add    $0x4,%esp
  8005b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b7:	e8 de fd ff ff       	call   80039a <fd2data>
  8005bc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005be:	89 1c 24             	mov    %ebx,(%esp)
  8005c1:	e8 d4 fd ff ff       	call   80039a <fd2data>
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005cc:	89 f8                	mov    %edi,%eax
  8005ce:	c1 e8 16             	shr    $0x16,%eax
  8005d1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d8:	a8 01                	test   $0x1,%al
  8005da:	74 37                	je     800613 <dup+0x99>
  8005dc:	89 f8                	mov    %edi,%eax
  8005de:	c1 e8 0c             	shr    $0xc,%eax
  8005e1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e8:	f6 c2 01             	test   $0x1,%dl
  8005eb:	74 26                	je     800613 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f4:	83 ec 0c             	sub    $0xc,%esp
  8005f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fc:	50                   	push   %eax
  8005fd:	ff 75 d4             	pushl  -0x2c(%ebp)
  800600:	6a 00                	push   $0x0
  800602:	57                   	push   %edi
  800603:	6a 00                	push   $0x0
  800605:	e8 93 fb ff ff       	call   80019d <sys_page_map>
  80060a:	89 c7                	mov    %eax,%edi
  80060c:	83 c4 20             	add    $0x20,%esp
  80060f:	85 c0                	test   %eax,%eax
  800611:	78 2e                	js     800641 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800613:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800616:	89 d0                	mov    %edx,%eax
  800618:	c1 e8 0c             	shr    $0xc,%eax
  80061b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800622:	83 ec 0c             	sub    $0xc,%esp
  800625:	25 07 0e 00 00       	and    $0xe07,%eax
  80062a:	50                   	push   %eax
  80062b:	53                   	push   %ebx
  80062c:	6a 00                	push   $0x0
  80062e:	52                   	push   %edx
  80062f:	6a 00                	push   $0x0
  800631:	e8 67 fb ff ff       	call   80019d <sys_page_map>
  800636:	89 c7                	mov    %eax,%edi
  800638:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80063b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80063d:	85 ff                	test   %edi,%edi
  80063f:	79 1d                	jns    80065e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 00                	push   $0x0
  800647:	e8 93 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80064c:	83 c4 08             	add    $0x8,%esp
  80064f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800652:	6a 00                	push   $0x0
  800654:	e8 86 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	89 f8                	mov    %edi,%eax
}
  80065e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800661:	5b                   	pop    %ebx
  800662:	5e                   	pop    %esi
  800663:	5f                   	pop    %edi
  800664:	5d                   	pop    %ebp
  800665:	c3                   	ret    

00800666 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800666:	55                   	push   %ebp
  800667:	89 e5                	mov    %esp,%ebp
  800669:	53                   	push   %ebx
  80066a:	83 ec 14             	sub    $0x14,%esp
  80066d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800670:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800673:	50                   	push   %eax
  800674:	53                   	push   %ebx
  800675:	e8 86 fd ff ff       	call   800400 <fd_lookup>
  80067a:	83 c4 08             	add    $0x8,%esp
  80067d:	89 c2                	mov    %eax,%edx
  80067f:	85 c0                	test   %eax,%eax
  800681:	78 6d                	js     8006f0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800689:	50                   	push   %eax
  80068a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80068d:	ff 30                	pushl  (%eax)
  80068f:	e8 c2 fd ff ff       	call   800456 <dev_lookup>
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	85 c0                	test   %eax,%eax
  800699:	78 4c                	js     8006e7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80069b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80069e:	8b 42 08             	mov    0x8(%edx),%eax
  8006a1:	83 e0 03             	and    $0x3,%eax
  8006a4:	83 f8 01             	cmp    $0x1,%eax
  8006a7:	75 21                	jne    8006ca <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8006ae:	8b 40 48             	mov    0x48(%eax),%eax
  8006b1:	83 ec 04             	sub    $0x4,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	50                   	push   %eax
  8006b6:	68 39 23 80 00       	push   $0x802339
  8006bb:	e8 f4 0e 00 00       	call   8015b4 <cprintf>
		return -E_INVAL;
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c8:	eb 26                	jmp    8006f0 <read+0x8a>
	}
	if (!dev->dev_read)
  8006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cd:	8b 40 08             	mov    0x8(%eax),%eax
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 17                	je     8006eb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d4:	83 ec 04             	sub    $0x4,%esp
  8006d7:	ff 75 10             	pushl  0x10(%ebp)
  8006da:	ff 75 0c             	pushl  0xc(%ebp)
  8006dd:	52                   	push   %edx
  8006de:	ff d0                	call   *%eax
  8006e0:	89 c2                	mov    %eax,%edx
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	eb 09                	jmp    8006f0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e7:	89 c2                	mov    %eax,%edx
  8006e9:	eb 05                	jmp    8006f0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006f0:	89 d0                	mov    %edx,%eax
  8006f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	57                   	push   %edi
  8006fb:	56                   	push   %esi
  8006fc:	53                   	push   %ebx
  8006fd:	83 ec 0c             	sub    $0xc,%esp
  800700:	8b 7d 08             	mov    0x8(%ebp),%edi
  800703:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800706:	bb 00 00 00 00       	mov    $0x0,%ebx
  80070b:	eb 21                	jmp    80072e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80070d:	83 ec 04             	sub    $0x4,%esp
  800710:	89 f0                	mov    %esi,%eax
  800712:	29 d8                	sub    %ebx,%eax
  800714:	50                   	push   %eax
  800715:	89 d8                	mov    %ebx,%eax
  800717:	03 45 0c             	add    0xc(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	57                   	push   %edi
  80071c:	e8 45 ff ff ff       	call   800666 <read>
		if (m < 0)
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	85 c0                	test   %eax,%eax
  800726:	78 10                	js     800738 <readn+0x41>
			return m;
		if (m == 0)
  800728:	85 c0                	test   %eax,%eax
  80072a:	74 0a                	je     800736 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80072c:	01 c3                	add    %eax,%ebx
  80072e:	39 f3                	cmp    %esi,%ebx
  800730:	72 db                	jb     80070d <readn+0x16>
  800732:	89 d8                	mov    %ebx,%eax
  800734:	eb 02                	jmp    800738 <readn+0x41>
  800736:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800738:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073b:	5b                   	pop    %ebx
  80073c:	5e                   	pop    %esi
  80073d:	5f                   	pop    %edi
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	53                   	push   %ebx
  800744:	83 ec 14             	sub    $0x14,%esp
  800747:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80074a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80074d:	50                   	push   %eax
  80074e:	53                   	push   %ebx
  80074f:	e8 ac fc ff ff       	call   800400 <fd_lookup>
  800754:	83 c4 08             	add    $0x8,%esp
  800757:	89 c2                	mov    %eax,%edx
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 68                	js     8007c5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800763:	50                   	push   %eax
  800764:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800767:	ff 30                	pushl  (%eax)
  800769:	e8 e8 fc ff ff       	call   800456 <dev_lookup>
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	85 c0                	test   %eax,%eax
  800773:	78 47                	js     8007bc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800775:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800778:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80077c:	75 21                	jne    80079f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80077e:	a1 08 40 80 00       	mov    0x804008,%eax
  800783:	8b 40 48             	mov    0x48(%eax),%eax
  800786:	83 ec 04             	sub    $0x4,%esp
  800789:	53                   	push   %ebx
  80078a:	50                   	push   %eax
  80078b:	68 55 23 80 00       	push   $0x802355
  800790:	e8 1f 0e 00 00       	call   8015b4 <cprintf>
		return -E_INVAL;
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80079d:	eb 26                	jmp    8007c5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a2:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	74 17                	je     8007c0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a9:	83 ec 04             	sub    $0x4,%esp
  8007ac:	ff 75 10             	pushl  0x10(%ebp)
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	50                   	push   %eax
  8007b3:	ff d2                	call   *%edx
  8007b5:	89 c2                	mov    %eax,%edx
  8007b7:	83 c4 10             	add    $0x10,%esp
  8007ba:	eb 09                	jmp    8007c5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007bc:	89 c2                	mov    %eax,%edx
  8007be:	eb 05                	jmp    8007c5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c5:	89 d0                	mov    %edx,%eax
  8007c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <seek>:

int
seek(int fdnum, off_t offset)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	ff 75 08             	pushl  0x8(%ebp)
  8007d9:	e8 22 fc ff ff       	call   800400 <fd_lookup>
  8007de:	83 c4 08             	add    $0x8,%esp
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	78 0e                	js     8007f3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007eb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    

008007f5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	83 ec 14             	sub    $0x14,%esp
  8007fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800802:	50                   	push   %eax
  800803:	53                   	push   %ebx
  800804:	e8 f7 fb ff ff       	call   800400 <fd_lookup>
  800809:	83 c4 08             	add    $0x8,%esp
  80080c:	89 c2                	mov    %eax,%edx
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 65                	js     800877 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800818:	50                   	push   %eax
  800819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081c:	ff 30                	pushl  (%eax)
  80081e:	e8 33 fc ff ff       	call   800456 <dev_lookup>
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	85 c0                	test   %eax,%eax
  800828:	78 44                	js     80086e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80082a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800831:	75 21                	jne    800854 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800833:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800838:	8b 40 48             	mov    0x48(%eax),%eax
  80083b:	83 ec 04             	sub    $0x4,%esp
  80083e:	53                   	push   %ebx
  80083f:	50                   	push   %eax
  800840:	68 18 23 80 00       	push   $0x802318
  800845:	e8 6a 0d 00 00       	call   8015b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800852:	eb 23                	jmp    800877 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800854:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800857:	8b 52 18             	mov    0x18(%edx),%edx
  80085a:	85 d2                	test   %edx,%edx
  80085c:	74 14                	je     800872 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	ff 75 0c             	pushl  0xc(%ebp)
  800864:	50                   	push   %eax
  800865:	ff d2                	call   *%edx
  800867:	89 c2                	mov    %eax,%edx
  800869:	83 c4 10             	add    $0x10,%esp
  80086c:	eb 09                	jmp    800877 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	89 c2                	mov    %eax,%edx
  800870:	eb 05                	jmp    800877 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800872:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800877:	89 d0                	mov    %edx,%eax
  800879:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	53                   	push   %ebx
  800882:	83 ec 14             	sub    $0x14,%esp
  800885:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800888:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	ff 75 08             	pushl  0x8(%ebp)
  80088f:	e8 6c fb ff ff       	call   800400 <fd_lookup>
  800894:	83 c4 08             	add    $0x8,%esp
  800897:	89 c2                	mov    %eax,%edx
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 58                	js     8008f5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a3:	50                   	push   %eax
  8008a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a7:	ff 30                	pushl  (%eax)
  8008a9:	e8 a8 fb ff ff       	call   800456 <dev_lookup>
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	78 37                	js     8008ec <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008bc:	74 32                	je     8008f0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008be:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c8:	00 00 00 
	stat->st_isdir = 0;
  8008cb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d2:	00 00 00 
	stat->st_dev = dev;
  8008d5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008db:	83 ec 08             	sub    $0x8,%esp
  8008de:	53                   	push   %ebx
  8008df:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e2:	ff 50 14             	call   *0x14(%eax)
  8008e5:	89 c2                	mov    %eax,%edx
  8008e7:	83 c4 10             	add    $0x10,%esp
  8008ea:	eb 09                	jmp    8008f5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ec:	89 c2                	mov    %eax,%edx
  8008ee:	eb 05                	jmp    8008f5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f5:	89 d0                	mov    %edx,%eax
  8008f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fa:	c9                   	leave  
  8008fb:	c3                   	ret    

008008fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	6a 00                	push   $0x0
  800906:	ff 75 08             	pushl  0x8(%ebp)
  800909:	e8 e3 01 00 00       	call   800af1 <open>
  80090e:	89 c3                	mov    %eax,%ebx
  800910:	83 c4 10             	add    $0x10,%esp
  800913:	85 c0                	test   %eax,%eax
  800915:	78 1b                	js     800932 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800917:	83 ec 08             	sub    $0x8,%esp
  80091a:	ff 75 0c             	pushl  0xc(%ebp)
  80091d:	50                   	push   %eax
  80091e:	e8 5b ff ff ff       	call   80087e <fstat>
  800923:	89 c6                	mov    %eax,%esi
	close(fd);
  800925:	89 1c 24             	mov    %ebx,(%esp)
  800928:	e8 fd fb ff ff       	call   80052a <close>
	return r;
  80092d:	83 c4 10             	add    $0x10,%esp
  800930:	89 f0                	mov    %esi,%eax
}
  800932:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800935:	5b                   	pop    %ebx
  800936:	5e                   	pop    %esi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	89 c6                	mov    %eax,%esi
  800940:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800942:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800949:	75 12                	jne    80095d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80094b:	83 ec 0c             	sub    $0xc,%esp
  80094e:	6a 01                	push   $0x1
  800950:	e8 67 16 00 00       	call   801fbc <ipc_find_env>
  800955:	a3 00 40 80 00       	mov    %eax,0x804000
  80095a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80095d:	6a 07                	push   $0x7
  80095f:	68 00 50 80 00       	push   $0x805000
  800964:	56                   	push   %esi
  800965:	ff 35 00 40 80 00    	pushl  0x804000
  80096b:	e8 f8 15 00 00       	call   801f68 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800970:	83 c4 0c             	add    $0xc,%esp
  800973:	6a 00                	push   $0x0
  800975:	53                   	push   %ebx
  800976:	6a 00                	push   $0x0
  800978:	e8 82 15 00 00       	call   801eff <ipc_recv>
}
  80097d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 40 0c             	mov    0xc(%eax),%eax
  800990:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80099d:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a7:	e8 8d ff ff ff       	call   800939 <fsipc>
}
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    

008009ae <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c9:	e8 6b ff ff ff       	call   800939 <fsipc>
}
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	53                   	push   %ebx
  8009d4:	83 ec 04             	sub    $0x4,%esp
  8009d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ef:	e8 45 ff ff ff       	call   800939 <fsipc>
  8009f4:	85 c0                	test   %eax,%eax
  8009f6:	78 2c                	js     800a24 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f8:	83 ec 08             	sub    $0x8,%esp
  8009fb:	68 00 50 80 00       	push   $0x805000
  800a00:	53                   	push   %ebx
  800a01:	e8 b2 11 00 00       	call   801bb8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a06:	a1 80 50 80 00       	mov    0x805080,%eax
  800a0b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a11:	a1 84 50 80 00       	mov    0x805084,%eax
  800a16:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a1c:	83 c4 10             	add    $0x10,%esp
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a27:	c9                   	leave  
  800a28:	c3                   	ret    

00800a29 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	83 ec 0c             	sub    $0xc,%esp
  800a2f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a32:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a37:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a3c:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a42:	8b 52 0c             	mov    0xc(%edx),%edx
  800a45:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a4b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a50:	50                   	push   %eax
  800a51:	ff 75 0c             	pushl  0xc(%ebp)
  800a54:	68 08 50 80 00       	push   $0x805008
  800a59:	e8 ec 12 00 00       	call   801d4a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a63:	b8 04 00 00 00       	mov    $0x4,%eax
  800a68:	e8 cc fe ff ff       	call   800939 <fsipc>
	//panic("devfile_write not implemented");
}
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    

00800a6f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a7d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a82:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a88:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a92:	e8 a2 fe ff ff       	call   800939 <fsipc>
  800a97:	89 c3                	mov    %eax,%ebx
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	78 4b                	js     800ae8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a9d:	39 c6                	cmp    %eax,%esi
  800a9f:	73 16                	jae    800ab7 <devfile_read+0x48>
  800aa1:	68 88 23 80 00       	push   $0x802388
  800aa6:	68 8f 23 80 00       	push   $0x80238f
  800aab:	6a 7c                	push   $0x7c
  800aad:	68 a4 23 80 00       	push   $0x8023a4
  800ab2:	e8 24 0a 00 00       	call   8014db <_panic>
	assert(r <= PGSIZE);
  800ab7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800abc:	7e 16                	jle    800ad4 <devfile_read+0x65>
  800abe:	68 af 23 80 00       	push   $0x8023af
  800ac3:	68 8f 23 80 00       	push   $0x80238f
  800ac8:	6a 7d                	push   $0x7d
  800aca:	68 a4 23 80 00       	push   $0x8023a4
  800acf:	e8 07 0a 00 00       	call   8014db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad4:	83 ec 04             	sub    $0x4,%esp
  800ad7:	50                   	push   %eax
  800ad8:	68 00 50 80 00       	push   $0x805000
  800add:	ff 75 0c             	pushl  0xc(%ebp)
  800ae0:	e8 65 12 00 00       	call   801d4a <memmove>
	return r;
  800ae5:	83 c4 10             	add    $0x10,%esp
}
  800ae8:	89 d8                	mov    %ebx,%eax
  800aea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	53                   	push   %ebx
  800af5:	83 ec 20             	sub    $0x20,%esp
  800af8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800afb:	53                   	push   %ebx
  800afc:	e8 7e 10 00 00       	call   801b7f <strlen>
  800b01:	83 c4 10             	add    $0x10,%esp
  800b04:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b09:	7f 67                	jg     800b72 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0b:	83 ec 0c             	sub    $0xc,%esp
  800b0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b11:	50                   	push   %eax
  800b12:	e8 9a f8 ff ff       	call   8003b1 <fd_alloc>
  800b17:	83 c4 10             	add    $0x10,%esp
		return r;
  800b1a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1c:	85 c0                	test   %eax,%eax
  800b1e:	78 57                	js     800b77 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b20:	83 ec 08             	sub    $0x8,%esp
  800b23:	53                   	push   %ebx
  800b24:	68 00 50 80 00       	push   $0x805000
  800b29:	e8 8a 10 00 00       	call   801bb8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b39:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3e:	e8 f6 fd ff ff       	call   800939 <fsipc>
  800b43:	89 c3                	mov    %eax,%ebx
  800b45:	83 c4 10             	add    $0x10,%esp
  800b48:	85 c0                	test   %eax,%eax
  800b4a:	79 14                	jns    800b60 <open+0x6f>
		fd_close(fd, 0);
  800b4c:	83 ec 08             	sub    $0x8,%esp
  800b4f:	6a 00                	push   $0x0
  800b51:	ff 75 f4             	pushl  -0xc(%ebp)
  800b54:	e8 50 f9 ff ff       	call   8004a9 <fd_close>
		return r;
  800b59:	83 c4 10             	add    $0x10,%esp
  800b5c:	89 da                	mov    %ebx,%edx
  800b5e:	eb 17                	jmp    800b77 <open+0x86>
	}

	return fd2num(fd);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	ff 75 f4             	pushl  -0xc(%ebp)
  800b66:	e8 1f f8 ff ff       	call   80038a <fd2num>
  800b6b:	89 c2                	mov    %eax,%edx
  800b6d:	83 c4 10             	add    $0x10,%esp
  800b70:	eb 05                	jmp    800b77 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b72:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b77:	89 d0                	mov    %edx,%eax
  800b79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 08 00 00 00       	mov    $0x8,%eax
  800b8e:	e8 a6 fd ff ff       	call   800939 <fsipc>
}
  800b93:	c9                   	leave  
  800b94:	c3                   	ret    

00800b95 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b9b:	68 bb 23 80 00       	push   $0x8023bb
  800ba0:	ff 75 0c             	pushl  0xc(%ebp)
  800ba3:	e8 10 10 00 00       	call   801bb8 <strcpy>
	return 0;
}
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	53                   	push   %ebx
  800bb3:	83 ec 10             	sub    $0x10,%esp
  800bb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bb9:	53                   	push   %ebx
  800bba:	e8 36 14 00 00       	call   801ff5 <pageref>
  800bbf:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bc7:	83 f8 01             	cmp    $0x1,%eax
  800bca:	75 10                	jne    800bdc <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	ff 73 0c             	pushl  0xc(%ebx)
  800bd2:	e8 c0 02 00 00       	call   800e97 <nsipc_close>
  800bd7:	89 c2                	mov    %eax,%edx
  800bd9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bdc:	89 d0                	mov    %edx,%eax
  800bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800be9:	6a 00                	push   $0x0
  800beb:	ff 75 10             	pushl  0x10(%ebp)
  800bee:	ff 75 0c             	pushl  0xc(%ebp)
  800bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf4:	ff 70 0c             	pushl  0xc(%eax)
  800bf7:	e8 78 03 00 00       	call   800f74 <nsipc_send>
}
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c04:	6a 00                	push   $0x0
  800c06:	ff 75 10             	pushl  0x10(%ebp)
  800c09:	ff 75 0c             	pushl  0xc(%ebp)
  800c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0f:	ff 70 0c             	pushl  0xc(%eax)
  800c12:	e8 f1 02 00 00       	call   800f08 <nsipc_recv>
}
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    

00800c19 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c1f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c22:	52                   	push   %edx
  800c23:	50                   	push   %eax
  800c24:	e8 d7 f7 ff ff       	call   800400 <fd_lookup>
  800c29:	83 c4 10             	add    $0x10,%esp
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	78 17                	js     800c47 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c33:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c39:	39 08                	cmp    %ecx,(%eax)
  800c3b:	75 05                	jne    800c42 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c3d:	8b 40 0c             	mov    0xc(%eax),%eax
  800c40:	eb 05                	jmp    800c47 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c42:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    

00800c49 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 1c             	sub    $0x1c,%esp
  800c51:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c56:	50                   	push   %eax
  800c57:	e8 55 f7 ff ff       	call   8003b1 <fd_alloc>
  800c5c:	89 c3                	mov    %eax,%ebx
  800c5e:	83 c4 10             	add    $0x10,%esp
  800c61:	85 c0                	test   %eax,%eax
  800c63:	78 1b                	js     800c80 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c65:	83 ec 04             	sub    $0x4,%esp
  800c68:	68 07 04 00 00       	push   $0x407
  800c6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800c70:	6a 00                	push   $0x0
  800c72:	e8 e3 f4 ff ff       	call   80015a <sys_page_alloc>
  800c77:	89 c3                	mov    %eax,%ebx
  800c79:	83 c4 10             	add    $0x10,%esp
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	79 10                	jns    800c90 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	56                   	push   %esi
  800c84:	e8 0e 02 00 00       	call   800e97 <nsipc_close>
		return r;
  800c89:	83 c4 10             	add    $0x10,%esp
  800c8c:	89 d8                	mov    %ebx,%eax
  800c8e:	eb 24                	jmp    800cb4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c90:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c99:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ca5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	e8 d9 f6 ff ff       	call   80038a <fd2num>
  800cb1:	83 c4 10             	add    $0x10,%esp
}
  800cb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc4:	e8 50 ff ff ff       	call   800c19 <fd2sockid>
		return r;
  800cc9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	78 1f                	js     800cee <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ccf:	83 ec 04             	sub    $0x4,%esp
  800cd2:	ff 75 10             	pushl  0x10(%ebp)
  800cd5:	ff 75 0c             	pushl  0xc(%ebp)
  800cd8:	50                   	push   %eax
  800cd9:	e8 12 01 00 00       	call   800df0 <nsipc_accept>
  800cde:	83 c4 10             	add    $0x10,%esp
		return r;
  800ce1:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	78 07                	js     800cee <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800ce7:	e8 5d ff ff ff       	call   800c49 <alloc_sockfd>
  800cec:	89 c1                	mov    %eax,%ecx
}
  800cee:	89 c8                	mov    %ecx,%eax
  800cf0:	c9                   	leave  
  800cf1:	c3                   	ret    

00800cf2 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfb:	e8 19 ff ff ff       	call   800c19 <fd2sockid>
  800d00:	85 c0                	test   %eax,%eax
  800d02:	78 12                	js     800d16 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d04:	83 ec 04             	sub    $0x4,%esp
  800d07:	ff 75 10             	pushl  0x10(%ebp)
  800d0a:	ff 75 0c             	pushl  0xc(%ebp)
  800d0d:	50                   	push   %eax
  800d0e:	e8 2d 01 00 00       	call   800e40 <nsipc_bind>
  800d13:	83 c4 10             	add    $0x10,%esp
}
  800d16:	c9                   	leave  
  800d17:	c3                   	ret    

00800d18 <shutdown>:

int
shutdown(int s, int how)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	e8 f3 fe ff ff       	call   800c19 <fd2sockid>
  800d26:	85 c0                	test   %eax,%eax
  800d28:	78 0f                	js     800d39 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d2a:	83 ec 08             	sub    $0x8,%esp
  800d2d:	ff 75 0c             	pushl  0xc(%ebp)
  800d30:	50                   	push   %eax
  800d31:	e8 3f 01 00 00       	call   800e75 <nsipc_shutdown>
  800d36:	83 c4 10             	add    $0x10,%esp
}
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d41:	8b 45 08             	mov    0x8(%ebp),%eax
  800d44:	e8 d0 fe ff ff       	call   800c19 <fd2sockid>
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	78 12                	js     800d5f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d4d:	83 ec 04             	sub    $0x4,%esp
  800d50:	ff 75 10             	pushl  0x10(%ebp)
  800d53:	ff 75 0c             	pushl  0xc(%ebp)
  800d56:	50                   	push   %eax
  800d57:	e8 55 01 00 00       	call   800eb1 <nsipc_connect>
  800d5c:	83 c4 10             	add    $0x10,%esp
}
  800d5f:	c9                   	leave  
  800d60:	c3                   	ret    

00800d61 <listen>:

int
listen(int s, int backlog)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d67:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6a:	e8 aa fe ff ff       	call   800c19 <fd2sockid>
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	78 0f                	js     800d82 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d73:	83 ec 08             	sub    $0x8,%esp
  800d76:	ff 75 0c             	pushl  0xc(%ebp)
  800d79:	50                   	push   %eax
  800d7a:	e8 67 01 00 00       	call   800ee6 <nsipc_listen>
  800d7f:	83 c4 10             	add    $0x10,%esp
}
  800d82:	c9                   	leave  
  800d83:	c3                   	ret    

00800d84 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d8a:	ff 75 10             	pushl  0x10(%ebp)
  800d8d:	ff 75 0c             	pushl  0xc(%ebp)
  800d90:	ff 75 08             	pushl  0x8(%ebp)
  800d93:	e8 3a 02 00 00       	call   800fd2 <nsipc_socket>
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	78 05                	js     800da4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d9f:	e8 a5 fe ff ff       	call   800c49 <alloc_sockfd>
}
  800da4:	c9                   	leave  
  800da5:	c3                   	ret    

00800da6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	53                   	push   %ebx
  800daa:	83 ec 04             	sub    $0x4,%esp
  800dad:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800daf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800db6:	75 12                	jne    800dca <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	6a 02                	push   $0x2
  800dbd:	e8 fa 11 00 00       	call   801fbc <ipc_find_env>
  800dc2:	a3 04 40 80 00       	mov    %eax,0x804004
  800dc7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dca:	6a 07                	push   $0x7
  800dcc:	68 00 60 80 00       	push   $0x806000
  800dd1:	53                   	push   %ebx
  800dd2:	ff 35 04 40 80 00    	pushl  0x804004
  800dd8:	e8 8b 11 00 00       	call   801f68 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800ddd:	83 c4 0c             	add    $0xc,%esp
  800de0:	6a 00                	push   $0x0
  800de2:	6a 00                	push   $0x0
  800de4:	6a 00                	push   $0x0
  800de6:	e8 14 11 00 00       	call   801eff <ipc_recv>
}
  800deb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dee:	c9                   	leave  
  800def:	c3                   	ret    

00800df0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
  800df5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e00:	8b 06                	mov    (%esi),%eax
  800e02:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e07:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0c:	e8 95 ff ff ff       	call   800da6 <nsipc>
  800e11:	89 c3                	mov    %eax,%ebx
  800e13:	85 c0                	test   %eax,%eax
  800e15:	78 20                	js     800e37 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	ff 35 10 60 80 00    	pushl  0x806010
  800e20:	68 00 60 80 00       	push   $0x806000
  800e25:	ff 75 0c             	pushl  0xc(%ebp)
  800e28:	e8 1d 0f 00 00       	call   801d4a <memmove>
		*addrlen = ret->ret_addrlen;
  800e2d:	a1 10 60 80 00       	mov    0x806010,%eax
  800e32:	89 06                	mov    %eax,(%esi)
  800e34:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e37:	89 d8                	mov    %ebx,%eax
  800e39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	53                   	push   %ebx
  800e44:	83 ec 08             	sub    $0x8,%esp
  800e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e52:	53                   	push   %ebx
  800e53:	ff 75 0c             	pushl  0xc(%ebp)
  800e56:	68 04 60 80 00       	push   $0x806004
  800e5b:	e8 ea 0e 00 00       	call   801d4a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e60:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e66:	b8 02 00 00 00       	mov    $0x2,%eax
  800e6b:	e8 36 ff ff ff       	call   800da6 <nsipc>
}
  800e70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e73:	c9                   	leave  
  800e74:	c3                   	ret    

00800e75 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e86:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800e90:	e8 11 ff ff ff       	call   800da6 <nsipc>
}
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <nsipc_close>:

int
nsipc_close(int s)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ea5:	b8 04 00 00 00       	mov    $0x4,%eax
  800eaa:	e8 f7 fe ff ff       	call   800da6 <nsipc>
}
  800eaf:	c9                   	leave  
  800eb0:	c3                   	ret    

00800eb1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	53                   	push   %ebx
  800eb5:	83 ec 08             	sub    $0x8,%esp
  800eb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebe:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ec3:	53                   	push   %ebx
  800ec4:	ff 75 0c             	pushl  0xc(%ebp)
  800ec7:	68 04 60 80 00       	push   $0x806004
  800ecc:	e8 79 0e 00 00       	call   801d4a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ed1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ed7:	b8 05 00 00 00       	mov    $0x5,%eax
  800edc:	e8 c5 fe ff ff       	call   800da6 <nsipc>
}
  800ee1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800eec:	8b 45 08             	mov    0x8(%ebp),%eax
  800eef:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800efc:	b8 06 00 00 00       	mov    $0x6,%eax
  800f01:	e8 a0 fe ff ff       	call   800da6 <nsipc>
}
  800f06:	c9                   	leave  
  800f07:	c3                   	ret    

00800f08 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
  800f0d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f10:	8b 45 08             	mov    0x8(%ebp),%eax
  800f13:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f18:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f1e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f21:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f26:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2b:	e8 76 fe ff ff       	call   800da6 <nsipc>
  800f30:	89 c3                	mov    %eax,%ebx
  800f32:	85 c0                	test   %eax,%eax
  800f34:	78 35                	js     800f6b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f36:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f3b:	7f 04                	jg     800f41 <nsipc_recv+0x39>
  800f3d:	39 c6                	cmp    %eax,%esi
  800f3f:	7d 16                	jge    800f57 <nsipc_recv+0x4f>
  800f41:	68 c7 23 80 00       	push   $0x8023c7
  800f46:	68 8f 23 80 00       	push   $0x80238f
  800f4b:	6a 62                	push   $0x62
  800f4d:	68 dc 23 80 00       	push   $0x8023dc
  800f52:	e8 84 05 00 00       	call   8014db <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f57:	83 ec 04             	sub    $0x4,%esp
  800f5a:	50                   	push   %eax
  800f5b:	68 00 60 80 00       	push   $0x806000
  800f60:	ff 75 0c             	pushl  0xc(%ebp)
  800f63:	e8 e2 0d 00 00       	call   801d4a <memmove>
  800f68:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f6b:	89 d8                	mov    %ebx,%eax
  800f6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	53                   	push   %ebx
  800f78:	83 ec 04             	sub    $0x4,%esp
  800f7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f86:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f8c:	7e 16                	jle    800fa4 <nsipc_send+0x30>
  800f8e:	68 e8 23 80 00       	push   $0x8023e8
  800f93:	68 8f 23 80 00       	push   $0x80238f
  800f98:	6a 6d                	push   $0x6d
  800f9a:	68 dc 23 80 00       	push   $0x8023dc
  800f9f:	e8 37 05 00 00       	call   8014db <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fa4:	83 ec 04             	sub    $0x4,%esp
  800fa7:	53                   	push   %ebx
  800fa8:	ff 75 0c             	pushl  0xc(%ebp)
  800fab:	68 0c 60 80 00       	push   $0x80600c
  800fb0:	e8 95 0d 00 00       	call   801d4a <memmove>
	nsipcbuf.send.req_size = size;
  800fb5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fbb:	8b 45 14             	mov    0x14(%ebp),%eax
  800fbe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fc3:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc8:	e8 d9 fd ff ff       	call   800da6 <nsipc>
}
  800fcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe3:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fe8:	8b 45 10             	mov    0x10(%ebp),%eax
  800feb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ff0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff5:	e8 ac fd ff ff       	call   800da6 <nsipc>
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
  801001:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	ff 75 08             	pushl  0x8(%ebp)
  80100a:	e8 8b f3 ff ff       	call   80039a <fd2data>
  80100f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801011:	83 c4 08             	add    $0x8,%esp
  801014:	68 f4 23 80 00       	push   $0x8023f4
  801019:	53                   	push   %ebx
  80101a:	e8 99 0b 00 00       	call   801bb8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80101f:	8b 46 04             	mov    0x4(%esi),%eax
  801022:	2b 06                	sub    (%esi),%eax
  801024:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80102a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801031:	00 00 00 
	stat->st_dev = &devpipe;
  801034:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80103b:	30 80 00 
	return 0;
}
  80103e:	b8 00 00 00 00       	mov    $0x0,%eax
  801043:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801046:	5b                   	pop    %ebx
  801047:	5e                   	pop    %esi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    

0080104a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	53                   	push   %ebx
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801054:	53                   	push   %ebx
  801055:	6a 00                	push   $0x0
  801057:	e8 83 f1 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80105c:	89 1c 24             	mov    %ebx,(%esp)
  80105f:	e8 36 f3 ff ff       	call   80039a <fd2data>
  801064:	83 c4 08             	add    $0x8,%esp
  801067:	50                   	push   %eax
  801068:	6a 00                	push   $0x0
  80106a:	e8 70 f1 ff ff       	call   8001df <sys_page_unmap>
}
  80106f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801072:	c9                   	leave  
  801073:	c3                   	ret    

00801074 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	83 ec 1c             	sub    $0x1c,%esp
  80107d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801080:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801082:	a1 08 40 80 00       	mov    0x804008,%eax
  801087:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	ff 75 e0             	pushl  -0x20(%ebp)
  801090:	e8 60 0f 00 00       	call   801ff5 <pageref>
  801095:	89 c3                	mov    %eax,%ebx
  801097:	89 3c 24             	mov    %edi,(%esp)
  80109a:	e8 56 0f 00 00       	call   801ff5 <pageref>
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	39 c3                	cmp    %eax,%ebx
  8010a4:	0f 94 c1             	sete   %cl
  8010a7:	0f b6 c9             	movzbl %cl,%ecx
  8010aa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010ad:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010b3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010b6:	39 ce                	cmp    %ecx,%esi
  8010b8:	74 1b                	je     8010d5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010ba:	39 c3                	cmp    %eax,%ebx
  8010bc:	75 c4                	jne    801082 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010be:	8b 42 58             	mov    0x58(%edx),%eax
  8010c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c4:	50                   	push   %eax
  8010c5:	56                   	push   %esi
  8010c6:	68 fb 23 80 00       	push   $0x8023fb
  8010cb:	e8 e4 04 00 00       	call   8015b4 <cprintf>
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	eb ad                	jmp    801082 <_pipeisclosed+0xe>
	}
}
  8010d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 28             	sub    $0x28,%esp
  8010e9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010ec:	56                   	push   %esi
  8010ed:	e8 a8 f2 ff ff       	call   80039a <fd2data>
  8010f2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8010fc:	eb 4b                	jmp    801149 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010fe:	89 da                	mov    %ebx,%edx
  801100:	89 f0                	mov    %esi,%eax
  801102:	e8 6d ff ff ff       	call   801074 <_pipeisclosed>
  801107:	85 c0                	test   %eax,%eax
  801109:	75 48                	jne    801153 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80110b:	e8 2b f0 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801110:	8b 43 04             	mov    0x4(%ebx),%eax
  801113:	8b 0b                	mov    (%ebx),%ecx
  801115:	8d 51 20             	lea    0x20(%ecx),%edx
  801118:	39 d0                	cmp    %edx,%eax
  80111a:	73 e2                	jae    8010fe <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80111c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801123:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801126:	89 c2                	mov    %eax,%edx
  801128:	c1 fa 1f             	sar    $0x1f,%edx
  80112b:	89 d1                	mov    %edx,%ecx
  80112d:	c1 e9 1b             	shr    $0x1b,%ecx
  801130:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801133:	83 e2 1f             	and    $0x1f,%edx
  801136:	29 ca                	sub    %ecx,%edx
  801138:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80113c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801140:	83 c0 01             	add    $0x1,%eax
  801143:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801146:	83 c7 01             	add    $0x1,%edi
  801149:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80114c:	75 c2                	jne    801110 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80114e:	8b 45 10             	mov    0x10(%ebp),%eax
  801151:	eb 05                	jmp    801158 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801153:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801158:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5f                   	pop    %edi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	57                   	push   %edi
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	83 ec 18             	sub    $0x18,%esp
  801169:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80116c:	57                   	push   %edi
  80116d:	e8 28 f2 ff ff       	call   80039a <fd2data>
  801172:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117c:	eb 3d                	jmp    8011bb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80117e:	85 db                	test   %ebx,%ebx
  801180:	74 04                	je     801186 <devpipe_read+0x26>
				return i;
  801182:	89 d8                	mov    %ebx,%eax
  801184:	eb 44                	jmp    8011ca <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801186:	89 f2                	mov    %esi,%edx
  801188:	89 f8                	mov    %edi,%eax
  80118a:	e8 e5 fe ff ff       	call   801074 <_pipeisclosed>
  80118f:	85 c0                	test   %eax,%eax
  801191:	75 32                	jne    8011c5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801193:	e8 a3 ef ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801198:	8b 06                	mov    (%esi),%eax
  80119a:	3b 46 04             	cmp    0x4(%esi),%eax
  80119d:	74 df                	je     80117e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80119f:	99                   	cltd   
  8011a0:	c1 ea 1b             	shr    $0x1b,%edx
  8011a3:	01 d0                	add    %edx,%eax
  8011a5:	83 e0 1f             	and    $0x1f,%eax
  8011a8:	29 d0                	sub    %edx,%eax
  8011aa:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011b5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011b8:	83 c3 01             	add    $0x1,%ebx
  8011bb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011be:	75 d8                	jne    801198 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c3:	eb 05                	jmp    8011ca <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011c5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5f                   	pop    %edi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011dd:	50                   	push   %eax
  8011de:	e8 ce f1 ff ff       	call   8003b1 <fd_alloc>
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	0f 88 2c 01 00 00    	js     80131c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f0:	83 ec 04             	sub    $0x4,%esp
  8011f3:	68 07 04 00 00       	push   $0x407
  8011f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8011fb:	6a 00                	push   $0x0
  8011fd:	e8 58 ef ff ff       	call   80015a <sys_page_alloc>
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	89 c2                	mov    %eax,%edx
  801207:	85 c0                	test   %eax,%eax
  801209:	0f 88 0d 01 00 00    	js     80131c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80120f:	83 ec 0c             	sub    $0xc,%esp
  801212:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	e8 96 f1 ff ff       	call   8003b1 <fd_alloc>
  80121b:	89 c3                	mov    %eax,%ebx
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	0f 88 e2 00 00 00    	js     80130a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	68 07 04 00 00       	push   $0x407
  801230:	ff 75 f0             	pushl  -0x10(%ebp)
  801233:	6a 00                	push   $0x0
  801235:	e8 20 ef ff ff       	call   80015a <sys_page_alloc>
  80123a:	89 c3                	mov    %eax,%ebx
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	0f 88 c3 00 00 00    	js     80130a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801247:	83 ec 0c             	sub    $0xc,%esp
  80124a:	ff 75 f4             	pushl  -0xc(%ebp)
  80124d:	e8 48 f1 ff ff       	call   80039a <fd2data>
  801252:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801254:	83 c4 0c             	add    $0xc,%esp
  801257:	68 07 04 00 00       	push   $0x407
  80125c:	50                   	push   %eax
  80125d:	6a 00                	push   $0x0
  80125f:	e8 f6 ee ff ff       	call   80015a <sys_page_alloc>
  801264:	89 c3                	mov    %eax,%ebx
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	0f 88 89 00 00 00    	js     8012fa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801271:	83 ec 0c             	sub    $0xc,%esp
  801274:	ff 75 f0             	pushl  -0x10(%ebp)
  801277:	e8 1e f1 ff ff       	call   80039a <fd2data>
  80127c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801283:	50                   	push   %eax
  801284:	6a 00                	push   $0x0
  801286:	56                   	push   %esi
  801287:	6a 00                	push   $0x0
  801289:	e8 0f ef ff ff       	call   80019d <sys_page_map>
  80128e:	89 c3                	mov    %eax,%ebx
  801290:	83 c4 20             	add    $0x20,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 55                	js     8012ec <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801297:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80129d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012ac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012c1:	83 ec 0c             	sub    $0xc,%esp
  8012c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c7:	e8 be f0 ff ff       	call   80038a <fd2num>
  8012cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012d1:	83 c4 04             	add    $0x4,%esp
  8012d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d7:	e8 ae f0 ff ff       	call   80038a <fd2num>
  8012dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012df:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ea:	eb 30                	jmp    80131c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	56                   	push   %esi
  8012f0:	6a 00                	push   $0x0
  8012f2:	e8 e8 ee ff ff       	call   8001df <sys_page_unmap>
  8012f7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801300:	6a 00                	push   $0x0
  801302:	e8 d8 ee ff ff       	call   8001df <sys_page_unmap>
  801307:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	ff 75 f4             	pushl  -0xc(%ebp)
  801310:	6a 00                	push   $0x0
  801312:	e8 c8 ee ff ff       	call   8001df <sys_page_unmap>
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80131c:	89 d0                	mov    %edx,%eax
  80131e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132e:	50                   	push   %eax
  80132f:	ff 75 08             	pushl  0x8(%ebp)
  801332:	e8 c9 f0 ff ff       	call   800400 <fd_lookup>
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 18                	js     801356 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80133e:	83 ec 0c             	sub    $0xc,%esp
  801341:	ff 75 f4             	pushl  -0xc(%ebp)
  801344:	e8 51 f0 ff ff       	call   80039a <fd2data>
	return _pipeisclosed(fd, p);
  801349:	89 c2                	mov    %eax,%edx
  80134b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134e:	e8 21 fd ff ff       	call   801074 <_pipeisclosed>
  801353:	83 c4 10             	add    $0x10,%esp
}
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80135b:	b8 00 00 00 00       	mov    $0x0,%eax
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801368:	68 13 24 80 00       	push   $0x802413
  80136d:	ff 75 0c             	pushl  0xc(%ebp)
  801370:	e8 43 08 00 00       	call   801bb8 <strcpy>
	return 0;
}
  801375:	b8 00 00 00 00       	mov    $0x0,%eax
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	57                   	push   %edi
  801380:	56                   	push   %esi
  801381:	53                   	push   %ebx
  801382:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801388:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80138d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801393:	eb 2d                	jmp    8013c2 <devcons_write+0x46>
		m = n - tot;
  801395:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801398:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80139a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80139d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013a2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a5:	83 ec 04             	sub    $0x4,%esp
  8013a8:	53                   	push   %ebx
  8013a9:	03 45 0c             	add    0xc(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	57                   	push   %edi
  8013ae:	e8 97 09 00 00       	call   801d4a <memmove>
		sys_cputs(buf, m);
  8013b3:	83 c4 08             	add    $0x8,%esp
  8013b6:	53                   	push   %ebx
  8013b7:	57                   	push   %edi
  8013b8:	e8 e1 ec ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013bd:	01 de                	add    %ebx,%esi
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	89 f0                	mov    %esi,%eax
  8013c4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013c7:	72 cc                	jb     801395 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013cc:	5b                   	pop    %ebx
  8013cd:	5e                   	pop    %esi
  8013ce:	5f                   	pop    %edi
  8013cf:	5d                   	pop    %ebp
  8013d0:	c3                   	ret    

008013d1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013e0:	74 2a                	je     80140c <devcons_read+0x3b>
  8013e2:	eb 05                	jmp    8013e9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013e4:	e8 52 ed ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013e9:	e8 ce ec ff ff       	call   8000bc <sys_cgetc>
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	74 f2                	je     8013e4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 16                	js     80140c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013f6:	83 f8 04             	cmp    $0x4,%eax
  8013f9:	74 0c                	je     801407 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fe:	88 02                	mov    %al,(%edx)
	return 1;
  801400:	b8 01 00 00 00       	mov    $0x1,%eax
  801405:	eb 05                	jmp    80140c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801407:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80140c:	c9                   	leave  
  80140d:	c3                   	ret    

0080140e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801414:	8b 45 08             	mov    0x8(%ebp),%eax
  801417:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80141a:	6a 01                	push   $0x1
  80141c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80141f:	50                   	push   %eax
  801420:	e8 79 ec ff ff       	call   80009e <sys_cputs>
}
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	c9                   	leave  
  801429:	c3                   	ret    

0080142a <getchar>:

int
getchar(void)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801430:	6a 01                	push   $0x1
  801432:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	6a 00                	push   $0x0
  801438:	e8 29 f2 ff ff       	call   800666 <read>
	if (r < 0)
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 0f                	js     801453 <getchar+0x29>
		return r;
	if (r < 1)
  801444:	85 c0                	test   %eax,%eax
  801446:	7e 06                	jle    80144e <getchar+0x24>
		return -E_EOF;
	return c;
  801448:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80144c:	eb 05                	jmp    801453 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80144e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801453:	c9                   	leave  
  801454:	c3                   	ret    

00801455 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145e:	50                   	push   %eax
  80145f:	ff 75 08             	pushl  0x8(%ebp)
  801462:	e8 99 ef ff ff       	call   800400 <fd_lookup>
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 11                	js     80147f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80146e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801471:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801477:	39 10                	cmp    %edx,(%eax)
  801479:	0f 94 c0             	sete   %al
  80147c:	0f b6 c0             	movzbl %al,%eax
}
  80147f:	c9                   	leave  
  801480:	c3                   	ret    

00801481 <opencons>:

int
opencons(void)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801487:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	e8 21 ef ff ff       	call   8003b1 <fd_alloc>
  801490:	83 c4 10             	add    $0x10,%esp
		return r;
  801493:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801495:	85 c0                	test   %eax,%eax
  801497:	78 3e                	js     8014d7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801499:	83 ec 04             	sub    $0x4,%esp
  80149c:	68 07 04 00 00       	push   $0x407
  8014a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a4:	6a 00                	push   $0x0
  8014a6:	e8 af ec ff ff       	call   80015a <sys_page_alloc>
  8014ab:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ae:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 23                	js     8014d7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014b4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014c9:	83 ec 0c             	sub    $0xc,%esp
  8014cc:	50                   	push   %eax
  8014cd:	e8 b8 ee ff ff       	call   80038a <fd2num>
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	83 c4 10             	add    $0x10,%esp
}
  8014d7:	89 d0                	mov    %edx,%eax
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	56                   	push   %esi
  8014df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014e9:	e8 2e ec ff ff       	call   80011c <sys_getenvid>
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	ff 75 0c             	pushl  0xc(%ebp)
  8014f4:	ff 75 08             	pushl  0x8(%ebp)
  8014f7:	56                   	push   %esi
  8014f8:	50                   	push   %eax
  8014f9:	68 20 24 80 00       	push   $0x802420
  8014fe:	e8 b1 00 00 00       	call   8015b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801503:	83 c4 18             	add    $0x18,%esp
  801506:	53                   	push   %ebx
  801507:	ff 75 10             	pushl  0x10(%ebp)
  80150a:	e8 54 00 00 00       	call   801563 <vcprintf>
	cprintf("\n");
  80150f:	c7 04 24 0c 24 80 00 	movl   $0x80240c,(%esp)
  801516:	e8 99 00 00 00       	call   8015b4 <cprintf>
  80151b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80151e:	cc                   	int3   
  80151f:	eb fd                	jmp    80151e <_panic+0x43>

00801521 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	53                   	push   %ebx
  801525:	83 ec 04             	sub    $0x4,%esp
  801528:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80152b:	8b 13                	mov    (%ebx),%edx
  80152d:	8d 42 01             	lea    0x1(%edx),%eax
  801530:	89 03                	mov    %eax,(%ebx)
  801532:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801535:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801539:	3d ff 00 00 00       	cmp    $0xff,%eax
  80153e:	75 1a                	jne    80155a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	68 ff 00 00 00       	push   $0xff
  801548:	8d 43 08             	lea    0x8(%ebx),%eax
  80154b:	50                   	push   %eax
  80154c:	e8 4d eb ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  801551:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801557:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80155a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80155e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80156c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801573:	00 00 00 
	b.cnt = 0;
  801576:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80157d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801580:	ff 75 0c             	pushl  0xc(%ebp)
  801583:	ff 75 08             	pushl  0x8(%ebp)
  801586:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80158c:	50                   	push   %eax
  80158d:	68 21 15 80 00       	push   $0x801521
  801592:	e8 1a 01 00 00       	call   8016b1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801597:	83 c4 08             	add    $0x8,%esp
  80159a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	e8 f2 ea ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  8015ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    

008015b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015bd:	50                   	push   %eax
  8015be:	ff 75 08             	pushl  0x8(%ebp)
  8015c1:	e8 9d ff ff ff       	call   801563 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015c6:	c9                   	leave  
  8015c7:	c3                   	ret    

008015c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	57                   	push   %edi
  8015cc:	56                   	push   %esi
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 1c             	sub    $0x1c,%esp
  8015d1:	89 c7                	mov    %eax,%edi
  8015d3:	89 d6                	mov    %edx,%esi
  8015d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015ef:	39 d3                	cmp    %edx,%ebx
  8015f1:	72 05                	jb     8015f8 <printnum+0x30>
  8015f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015f6:	77 45                	ja     80163d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015f8:	83 ec 0c             	sub    $0xc,%esp
  8015fb:	ff 75 18             	pushl  0x18(%ebp)
  8015fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801601:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801604:	53                   	push   %ebx
  801605:	ff 75 10             	pushl  0x10(%ebp)
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80160e:	ff 75 e0             	pushl  -0x20(%ebp)
  801611:	ff 75 dc             	pushl  -0x24(%ebp)
  801614:	ff 75 d8             	pushl  -0x28(%ebp)
  801617:	e8 14 0a 00 00       	call   802030 <__udivdi3>
  80161c:	83 c4 18             	add    $0x18,%esp
  80161f:	52                   	push   %edx
  801620:	50                   	push   %eax
  801621:	89 f2                	mov    %esi,%edx
  801623:	89 f8                	mov    %edi,%eax
  801625:	e8 9e ff ff ff       	call   8015c8 <printnum>
  80162a:	83 c4 20             	add    $0x20,%esp
  80162d:	eb 18                	jmp    801647 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	56                   	push   %esi
  801633:	ff 75 18             	pushl  0x18(%ebp)
  801636:	ff d7                	call   *%edi
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	eb 03                	jmp    801640 <printnum+0x78>
  80163d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801640:	83 eb 01             	sub    $0x1,%ebx
  801643:	85 db                	test   %ebx,%ebx
  801645:	7f e8                	jg     80162f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	56                   	push   %esi
  80164b:	83 ec 04             	sub    $0x4,%esp
  80164e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801651:	ff 75 e0             	pushl  -0x20(%ebp)
  801654:	ff 75 dc             	pushl  -0x24(%ebp)
  801657:	ff 75 d8             	pushl  -0x28(%ebp)
  80165a:	e8 01 0b 00 00       	call   802160 <__umoddi3>
  80165f:	83 c4 14             	add    $0x14,%esp
  801662:	0f be 80 43 24 80 00 	movsbl 0x802443(%eax),%eax
  801669:	50                   	push   %eax
  80166a:	ff d7                	call   *%edi
}
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5f                   	pop    %edi
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80167d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801681:	8b 10                	mov    (%eax),%edx
  801683:	3b 50 04             	cmp    0x4(%eax),%edx
  801686:	73 0a                	jae    801692 <sprintputch+0x1b>
		*b->buf++ = ch;
  801688:	8d 4a 01             	lea    0x1(%edx),%ecx
  80168b:	89 08                	mov    %ecx,(%eax)
  80168d:	8b 45 08             	mov    0x8(%ebp),%eax
  801690:	88 02                	mov    %al,(%edx)
}
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    

00801694 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80169a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80169d:	50                   	push   %eax
  80169e:	ff 75 10             	pushl  0x10(%ebp)
  8016a1:	ff 75 0c             	pushl  0xc(%ebp)
  8016a4:	ff 75 08             	pushl  0x8(%ebp)
  8016a7:	e8 05 00 00 00       	call   8016b1 <vprintfmt>
	va_end(ap);
}
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    

008016b1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	57                   	push   %edi
  8016b5:	56                   	push   %esi
  8016b6:	53                   	push   %ebx
  8016b7:	83 ec 2c             	sub    $0x2c,%esp
  8016ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8016bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016c3:	eb 12                	jmp    8016d7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	0f 84 42 04 00 00    	je     801b0f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8016cd:	83 ec 08             	sub    $0x8,%esp
  8016d0:	53                   	push   %ebx
  8016d1:	50                   	push   %eax
  8016d2:	ff d6                	call   *%esi
  8016d4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016d7:	83 c7 01             	add    $0x1,%edi
  8016da:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016de:	83 f8 25             	cmp    $0x25,%eax
  8016e1:	75 e2                	jne    8016c5 <vprintfmt+0x14>
  8016e3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016e7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016f5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8016fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801701:	eb 07                	jmp    80170a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801703:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801706:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170a:	8d 47 01             	lea    0x1(%edi),%eax
  80170d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801710:	0f b6 07             	movzbl (%edi),%eax
  801713:	0f b6 d0             	movzbl %al,%edx
  801716:	83 e8 23             	sub    $0x23,%eax
  801719:	3c 55                	cmp    $0x55,%al
  80171b:	0f 87 d3 03 00 00    	ja     801af4 <vprintfmt+0x443>
  801721:	0f b6 c0             	movzbl %al,%eax
  801724:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  80172b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80172e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801732:	eb d6                	jmp    80170a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801737:	b8 00 00 00 00       	mov    $0x0,%eax
  80173c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80173f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801742:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801746:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801749:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80174c:	83 f9 09             	cmp    $0x9,%ecx
  80174f:	77 3f                	ja     801790 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801751:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801754:	eb e9                	jmp    80173f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801756:	8b 45 14             	mov    0x14(%ebp),%eax
  801759:	8b 00                	mov    (%eax),%eax
  80175b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80175e:	8b 45 14             	mov    0x14(%ebp),%eax
  801761:	8d 40 04             	lea    0x4(%eax),%eax
  801764:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801767:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80176a:	eb 2a                	jmp    801796 <vprintfmt+0xe5>
  80176c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80176f:	85 c0                	test   %eax,%eax
  801771:	ba 00 00 00 00       	mov    $0x0,%edx
  801776:	0f 49 d0             	cmovns %eax,%edx
  801779:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80177f:	eb 89                	jmp    80170a <vprintfmt+0x59>
  801781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801784:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80178b:	e9 7a ff ff ff       	jmp    80170a <vprintfmt+0x59>
  801790:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801793:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801796:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80179a:	0f 89 6a ff ff ff    	jns    80170a <vprintfmt+0x59>
				width = precision, precision = -1;
  8017a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017ad:	e9 58 ff ff ff       	jmp    80170a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017b2:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017b8:	e9 4d ff ff ff       	jmp    80170a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c0:	8d 78 04             	lea    0x4(%eax),%edi
  8017c3:	83 ec 08             	sub    $0x8,%esp
  8017c6:	53                   	push   %ebx
  8017c7:	ff 30                	pushl  (%eax)
  8017c9:	ff d6                	call   *%esi
			break;
  8017cb:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017ce:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017d4:	e9 fe fe ff ff       	jmp    8016d7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017dc:	8d 78 04             	lea    0x4(%eax),%edi
  8017df:	8b 00                	mov    (%eax),%eax
  8017e1:	99                   	cltd   
  8017e2:	31 d0                	xor    %edx,%eax
  8017e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017e6:	83 f8 0f             	cmp    $0xf,%eax
  8017e9:	7f 0b                	jg     8017f6 <vprintfmt+0x145>
  8017eb:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  8017f2:	85 d2                	test   %edx,%edx
  8017f4:	75 1b                	jne    801811 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8017f6:	50                   	push   %eax
  8017f7:	68 5b 24 80 00       	push   $0x80245b
  8017fc:	53                   	push   %ebx
  8017fd:	56                   	push   %esi
  8017fe:	e8 91 fe ff ff       	call   801694 <printfmt>
  801803:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801806:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801809:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80180c:	e9 c6 fe ff ff       	jmp    8016d7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801811:	52                   	push   %edx
  801812:	68 a1 23 80 00       	push   $0x8023a1
  801817:	53                   	push   %ebx
  801818:	56                   	push   %esi
  801819:	e8 76 fe ff ff       	call   801694 <printfmt>
  80181e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801821:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801824:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801827:	e9 ab fe ff ff       	jmp    8016d7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80182c:	8b 45 14             	mov    0x14(%ebp),%eax
  80182f:	83 c0 04             	add    $0x4,%eax
  801832:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801835:	8b 45 14             	mov    0x14(%ebp),%eax
  801838:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80183a:	85 ff                	test   %edi,%edi
  80183c:	b8 54 24 80 00       	mov    $0x802454,%eax
  801841:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801844:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801848:	0f 8e 94 00 00 00    	jle    8018e2 <vprintfmt+0x231>
  80184e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801852:	0f 84 98 00 00 00    	je     8018f0 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801858:	83 ec 08             	sub    $0x8,%esp
  80185b:	ff 75 d0             	pushl  -0x30(%ebp)
  80185e:	57                   	push   %edi
  80185f:	e8 33 03 00 00       	call   801b97 <strnlen>
  801864:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801867:	29 c1                	sub    %eax,%ecx
  801869:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80186c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80186f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801873:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801876:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801879:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80187b:	eb 0f                	jmp    80188c <vprintfmt+0x1db>
					putch(padc, putdat);
  80187d:	83 ec 08             	sub    $0x8,%esp
  801880:	53                   	push   %ebx
  801881:	ff 75 e0             	pushl  -0x20(%ebp)
  801884:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801886:	83 ef 01             	sub    $0x1,%edi
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	85 ff                	test   %edi,%edi
  80188e:	7f ed                	jg     80187d <vprintfmt+0x1cc>
  801890:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801893:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801896:	85 c9                	test   %ecx,%ecx
  801898:	b8 00 00 00 00       	mov    $0x0,%eax
  80189d:	0f 49 c1             	cmovns %ecx,%eax
  8018a0:	29 c1                	sub    %eax,%ecx
  8018a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8018a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018ab:	89 cb                	mov    %ecx,%ebx
  8018ad:	eb 4d                	jmp    8018fc <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018b3:	74 1b                	je     8018d0 <vprintfmt+0x21f>
  8018b5:	0f be c0             	movsbl %al,%eax
  8018b8:	83 e8 20             	sub    $0x20,%eax
  8018bb:	83 f8 5e             	cmp    $0x5e,%eax
  8018be:	76 10                	jbe    8018d0 <vprintfmt+0x21f>
					putch('?', putdat);
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	6a 3f                	push   $0x3f
  8018c8:	ff 55 08             	call   *0x8(%ebp)
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	eb 0d                	jmp    8018dd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	ff 75 0c             	pushl  0xc(%ebp)
  8018d6:	52                   	push   %edx
  8018d7:	ff 55 08             	call   *0x8(%ebp)
  8018da:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018dd:	83 eb 01             	sub    $0x1,%ebx
  8018e0:	eb 1a                	jmp    8018fc <vprintfmt+0x24b>
  8018e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018eb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018ee:	eb 0c                	jmp    8018fc <vprintfmt+0x24b>
  8018f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018fc:	83 c7 01             	add    $0x1,%edi
  8018ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801903:	0f be d0             	movsbl %al,%edx
  801906:	85 d2                	test   %edx,%edx
  801908:	74 23                	je     80192d <vprintfmt+0x27c>
  80190a:	85 f6                	test   %esi,%esi
  80190c:	78 a1                	js     8018af <vprintfmt+0x1fe>
  80190e:	83 ee 01             	sub    $0x1,%esi
  801911:	79 9c                	jns    8018af <vprintfmt+0x1fe>
  801913:	89 df                	mov    %ebx,%edi
  801915:	8b 75 08             	mov    0x8(%ebp),%esi
  801918:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80191b:	eb 18                	jmp    801935 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	53                   	push   %ebx
  801921:	6a 20                	push   $0x20
  801923:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801925:	83 ef 01             	sub    $0x1,%edi
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	eb 08                	jmp    801935 <vprintfmt+0x284>
  80192d:	89 df                	mov    %ebx,%edi
  80192f:	8b 75 08             	mov    0x8(%ebp),%esi
  801932:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801935:	85 ff                	test   %edi,%edi
  801937:	7f e4                	jg     80191d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801939:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80193c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80193f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801942:	e9 90 fd ff ff       	jmp    8016d7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801947:	83 f9 01             	cmp    $0x1,%ecx
  80194a:	7e 19                	jle    801965 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80194c:	8b 45 14             	mov    0x14(%ebp),%eax
  80194f:	8b 50 04             	mov    0x4(%eax),%edx
  801952:	8b 00                	mov    (%eax),%eax
  801954:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801957:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80195a:	8b 45 14             	mov    0x14(%ebp),%eax
  80195d:	8d 40 08             	lea    0x8(%eax),%eax
  801960:	89 45 14             	mov    %eax,0x14(%ebp)
  801963:	eb 38                	jmp    80199d <vprintfmt+0x2ec>
	else if (lflag)
  801965:	85 c9                	test   %ecx,%ecx
  801967:	74 1b                	je     801984 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801969:	8b 45 14             	mov    0x14(%ebp),%eax
  80196c:	8b 00                	mov    (%eax),%eax
  80196e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801971:	89 c1                	mov    %eax,%ecx
  801973:	c1 f9 1f             	sar    $0x1f,%ecx
  801976:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801979:	8b 45 14             	mov    0x14(%ebp),%eax
  80197c:	8d 40 04             	lea    0x4(%eax),%eax
  80197f:	89 45 14             	mov    %eax,0x14(%ebp)
  801982:	eb 19                	jmp    80199d <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801984:	8b 45 14             	mov    0x14(%ebp),%eax
  801987:	8b 00                	mov    (%eax),%eax
  801989:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80198c:	89 c1                	mov    %eax,%ecx
  80198e:	c1 f9 1f             	sar    $0x1f,%ecx
  801991:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801994:	8b 45 14             	mov    0x14(%ebp),%eax
  801997:	8d 40 04             	lea    0x4(%eax),%eax
  80199a:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80199d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019a3:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019ac:	0f 89 0e 01 00 00    	jns    801ac0 <vprintfmt+0x40f>
				putch('-', putdat);
  8019b2:	83 ec 08             	sub    $0x8,%esp
  8019b5:	53                   	push   %ebx
  8019b6:	6a 2d                	push   $0x2d
  8019b8:	ff d6                	call   *%esi
				num = -(long long) num;
  8019ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019c0:	f7 da                	neg    %edx
  8019c2:	83 d1 00             	adc    $0x0,%ecx
  8019c5:	f7 d9                	neg    %ecx
  8019c7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019cf:	e9 ec 00 00 00       	jmp    801ac0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019d4:	83 f9 01             	cmp    $0x1,%ecx
  8019d7:	7e 18                	jle    8019f1 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8019d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019dc:	8b 10                	mov    (%eax),%edx
  8019de:	8b 48 04             	mov    0x4(%eax),%ecx
  8019e1:	8d 40 08             	lea    0x8(%eax),%eax
  8019e4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8019e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019ec:	e9 cf 00 00 00       	jmp    801ac0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8019f1:	85 c9                	test   %ecx,%ecx
  8019f3:	74 1a                	je     801a0f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8019f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f8:	8b 10                	mov    (%eax),%edx
  8019fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ff:	8d 40 04             	lea    0x4(%eax),%eax
  801a02:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a05:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a0a:	e9 b1 00 00 00       	jmp    801ac0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801a0f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a12:	8b 10                	mov    (%eax),%edx
  801a14:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a19:	8d 40 04             	lea    0x4(%eax),%eax
  801a1c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a1f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a24:	e9 97 00 00 00       	jmp    801ac0 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801a29:	83 ec 08             	sub    $0x8,%esp
  801a2c:	53                   	push   %ebx
  801a2d:	6a 58                	push   $0x58
  801a2f:	ff d6                	call   *%esi
			putch('X', putdat);
  801a31:	83 c4 08             	add    $0x8,%esp
  801a34:	53                   	push   %ebx
  801a35:	6a 58                	push   $0x58
  801a37:	ff d6                	call   *%esi
			putch('X', putdat);
  801a39:	83 c4 08             	add    $0x8,%esp
  801a3c:	53                   	push   %ebx
  801a3d:	6a 58                	push   $0x58
  801a3f:	ff d6                	call   *%esi
			break;
  801a41:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801a47:	e9 8b fc ff ff       	jmp    8016d7 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a4c:	83 ec 08             	sub    $0x8,%esp
  801a4f:	53                   	push   %ebx
  801a50:	6a 30                	push   $0x30
  801a52:	ff d6                	call   *%esi
			putch('x', putdat);
  801a54:	83 c4 08             	add    $0x8,%esp
  801a57:	53                   	push   %ebx
  801a58:	6a 78                	push   $0x78
  801a5a:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a5c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5f:	8b 10                	mov    (%eax),%edx
  801a61:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a66:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a69:	8d 40 04             	lea    0x4(%eax),%eax
  801a6c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a6f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801a74:	eb 4a                	jmp    801ac0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a76:	83 f9 01             	cmp    $0x1,%ecx
  801a79:	7e 15                	jle    801a90 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801a7b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7e:	8b 10                	mov    (%eax),%edx
  801a80:	8b 48 04             	mov    0x4(%eax),%ecx
  801a83:	8d 40 08             	lea    0x8(%eax),%eax
  801a86:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801a89:	b8 10 00 00 00       	mov    $0x10,%eax
  801a8e:	eb 30                	jmp    801ac0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801a90:	85 c9                	test   %ecx,%ecx
  801a92:	74 17                	je     801aab <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801a94:	8b 45 14             	mov    0x14(%ebp),%eax
  801a97:	8b 10                	mov    (%eax),%edx
  801a99:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a9e:	8d 40 04             	lea    0x4(%eax),%eax
  801aa1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801aa4:	b8 10 00 00 00       	mov    $0x10,%eax
  801aa9:	eb 15                	jmp    801ac0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801aab:	8b 45 14             	mov    0x14(%ebp),%eax
  801aae:	8b 10                	mov    (%eax),%edx
  801ab0:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ab5:	8d 40 04             	lea    0x4(%eax),%eax
  801ab8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801abb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ac0:	83 ec 0c             	sub    $0xc,%esp
  801ac3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ac7:	57                   	push   %edi
  801ac8:	ff 75 e0             	pushl  -0x20(%ebp)
  801acb:	50                   	push   %eax
  801acc:	51                   	push   %ecx
  801acd:	52                   	push   %edx
  801ace:	89 da                	mov    %ebx,%edx
  801ad0:	89 f0                	mov    %esi,%eax
  801ad2:	e8 f1 fa ff ff       	call   8015c8 <printnum>
			break;
  801ad7:	83 c4 20             	add    $0x20,%esp
  801ada:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801add:	e9 f5 fb ff ff       	jmp    8016d7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ae2:	83 ec 08             	sub    $0x8,%esp
  801ae5:	53                   	push   %ebx
  801ae6:	52                   	push   %edx
  801ae7:	ff d6                	call   *%esi
			break;
  801ae9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801aef:	e9 e3 fb ff ff       	jmp    8016d7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801af4:	83 ec 08             	sub    $0x8,%esp
  801af7:	53                   	push   %ebx
  801af8:	6a 25                	push   $0x25
  801afa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	eb 03                	jmp    801b04 <vprintfmt+0x453>
  801b01:	83 ef 01             	sub    $0x1,%edi
  801b04:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b08:	75 f7                	jne    801b01 <vprintfmt+0x450>
  801b0a:	e9 c8 fb ff ff       	jmp    8016d7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b12:	5b                   	pop    %ebx
  801b13:	5e                   	pop    %esi
  801b14:	5f                   	pop    %edi
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    

00801b17 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	83 ec 18             	sub    $0x18,%esp
  801b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b20:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b23:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b26:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b2a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b34:	85 c0                	test   %eax,%eax
  801b36:	74 26                	je     801b5e <vsnprintf+0x47>
  801b38:	85 d2                	test   %edx,%edx
  801b3a:	7e 22                	jle    801b5e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b3c:	ff 75 14             	pushl  0x14(%ebp)
  801b3f:	ff 75 10             	pushl  0x10(%ebp)
  801b42:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b45:	50                   	push   %eax
  801b46:	68 77 16 80 00       	push   $0x801677
  801b4b:	e8 61 fb ff ff       	call   8016b1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b50:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b53:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	eb 05                	jmp    801b63 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    

00801b65 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b6b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b6e:	50                   	push   %eax
  801b6f:	ff 75 10             	pushl  0x10(%ebp)
  801b72:	ff 75 0c             	pushl  0xc(%ebp)
  801b75:	ff 75 08             	pushl  0x8(%ebp)
  801b78:	e8 9a ff ff ff       	call   801b17 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b85:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8a:	eb 03                	jmp    801b8f <strlen+0x10>
		n++;
  801b8c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b8f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b93:	75 f7                	jne    801b8c <strlen+0xd>
		n++;
	return n;
}
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba5:	eb 03                	jmp    801baa <strnlen+0x13>
		n++;
  801ba7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801baa:	39 c2                	cmp    %eax,%edx
  801bac:	74 08                	je     801bb6 <strnlen+0x1f>
  801bae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bb2:	75 f3                	jne    801ba7 <strnlen+0x10>
  801bb4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    

00801bb8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	53                   	push   %ebx
  801bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bc2:	89 c2                	mov    %eax,%edx
  801bc4:	83 c2 01             	add    $0x1,%edx
  801bc7:	83 c1 01             	add    $0x1,%ecx
  801bca:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bce:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bd1:	84 db                	test   %bl,%bl
  801bd3:	75 ef                	jne    801bc4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bd5:	5b                   	pop    %ebx
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	53                   	push   %ebx
  801bdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bdf:	53                   	push   %ebx
  801be0:	e8 9a ff ff ff       	call   801b7f <strlen>
  801be5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801be8:	ff 75 0c             	pushl  0xc(%ebp)
  801beb:	01 d8                	add    %ebx,%eax
  801bed:	50                   	push   %eax
  801bee:	e8 c5 ff ff ff       	call   801bb8 <strcpy>
	return dst;
}
  801bf3:	89 d8                	mov    %ebx,%eax
  801bf5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf8:	c9                   	leave  
  801bf9:	c3                   	ret    

00801bfa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	56                   	push   %esi
  801bfe:	53                   	push   %ebx
  801bff:	8b 75 08             	mov    0x8(%ebp),%esi
  801c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c05:	89 f3                	mov    %esi,%ebx
  801c07:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c0a:	89 f2                	mov    %esi,%edx
  801c0c:	eb 0f                	jmp    801c1d <strncpy+0x23>
		*dst++ = *src;
  801c0e:	83 c2 01             	add    $0x1,%edx
  801c11:	0f b6 01             	movzbl (%ecx),%eax
  801c14:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c17:	80 39 01             	cmpb   $0x1,(%ecx)
  801c1a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c1d:	39 da                	cmp    %ebx,%edx
  801c1f:	75 ed                	jne    801c0e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c21:	89 f0                	mov    %esi,%eax
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    

00801c27 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	56                   	push   %esi
  801c2b:	53                   	push   %ebx
  801c2c:	8b 75 08             	mov    0x8(%ebp),%esi
  801c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c32:	8b 55 10             	mov    0x10(%ebp),%edx
  801c35:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c37:	85 d2                	test   %edx,%edx
  801c39:	74 21                	je     801c5c <strlcpy+0x35>
  801c3b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c3f:	89 f2                	mov    %esi,%edx
  801c41:	eb 09                	jmp    801c4c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c43:	83 c2 01             	add    $0x1,%edx
  801c46:	83 c1 01             	add    $0x1,%ecx
  801c49:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c4c:	39 c2                	cmp    %eax,%edx
  801c4e:	74 09                	je     801c59 <strlcpy+0x32>
  801c50:	0f b6 19             	movzbl (%ecx),%ebx
  801c53:	84 db                	test   %bl,%bl
  801c55:	75 ec                	jne    801c43 <strlcpy+0x1c>
  801c57:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c59:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c5c:	29 f0                	sub    %esi,%eax
}
  801c5e:	5b                   	pop    %ebx
  801c5f:	5e                   	pop    %esi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c68:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c6b:	eb 06                	jmp    801c73 <strcmp+0x11>
		p++, q++;
  801c6d:	83 c1 01             	add    $0x1,%ecx
  801c70:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c73:	0f b6 01             	movzbl (%ecx),%eax
  801c76:	84 c0                	test   %al,%al
  801c78:	74 04                	je     801c7e <strcmp+0x1c>
  801c7a:	3a 02                	cmp    (%edx),%al
  801c7c:	74 ef                	je     801c6d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c7e:	0f b6 c0             	movzbl %al,%eax
  801c81:	0f b6 12             	movzbl (%edx),%edx
  801c84:	29 d0                	sub    %edx,%eax
}
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    

00801c88 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	53                   	push   %ebx
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c92:	89 c3                	mov    %eax,%ebx
  801c94:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c97:	eb 06                	jmp    801c9f <strncmp+0x17>
		n--, p++, q++;
  801c99:	83 c0 01             	add    $0x1,%eax
  801c9c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c9f:	39 d8                	cmp    %ebx,%eax
  801ca1:	74 15                	je     801cb8 <strncmp+0x30>
  801ca3:	0f b6 08             	movzbl (%eax),%ecx
  801ca6:	84 c9                	test   %cl,%cl
  801ca8:	74 04                	je     801cae <strncmp+0x26>
  801caa:	3a 0a                	cmp    (%edx),%cl
  801cac:	74 eb                	je     801c99 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cae:	0f b6 00             	movzbl (%eax),%eax
  801cb1:	0f b6 12             	movzbl (%edx),%edx
  801cb4:	29 d0                	sub    %edx,%eax
  801cb6:	eb 05                	jmp    801cbd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cb8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cbd:	5b                   	pop    %ebx
  801cbe:	5d                   	pop    %ebp
  801cbf:	c3                   	ret    

00801cc0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cca:	eb 07                	jmp    801cd3 <strchr+0x13>
		if (*s == c)
  801ccc:	38 ca                	cmp    %cl,%dl
  801cce:	74 0f                	je     801cdf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cd0:	83 c0 01             	add    $0x1,%eax
  801cd3:	0f b6 10             	movzbl (%eax),%edx
  801cd6:	84 d2                	test   %dl,%dl
  801cd8:	75 f2                	jne    801ccc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cdf:	5d                   	pop    %ebp
  801ce0:	c3                   	ret    

00801ce1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ceb:	eb 03                	jmp    801cf0 <strfind+0xf>
  801ced:	83 c0 01             	add    $0x1,%eax
  801cf0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cf3:	38 ca                	cmp    %cl,%dl
  801cf5:	74 04                	je     801cfb <strfind+0x1a>
  801cf7:	84 d2                	test   %dl,%dl
  801cf9:	75 f2                	jne    801ced <strfind+0xc>
			break;
	return (char *) s;
}
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    

00801cfd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cfd:	55                   	push   %ebp
  801cfe:	89 e5                	mov    %esp,%ebp
  801d00:	57                   	push   %edi
  801d01:	56                   	push   %esi
  801d02:	53                   	push   %ebx
  801d03:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d09:	85 c9                	test   %ecx,%ecx
  801d0b:	74 36                	je     801d43 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d13:	75 28                	jne    801d3d <memset+0x40>
  801d15:	f6 c1 03             	test   $0x3,%cl
  801d18:	75 23                	jne    801d3d <memset+0x40>
		c &= 0xFF;
  801d1a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d1e:	89 d3                	mov    %edx,%ebx
  801d20:	c1 e3 08             	shl    $0x8,%ebx
  801d23:	89 d6                	mov    %edx,%esi
  801d25:	c1 e6 18             	shl    $0x18,%esi
  801d28:	89 d0                	mov    %edx,%eax
  801d2a:	c1 e0 10             	shl    $0x10,%eax
  801d2d:	09 f0                	or     %esi,%eax
  801d2f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d31:	89 d8                	mov    %ebx,%eax
  801d33:	09 d0                	or     %edx,%eax
  801d35:	c1 e9 02             	shr    $0x2,%ecx
  801d38:	fc                   	cld    
  801d39:	f3 ab                	rep stos %eax,%es:(%edi)
  801d3b:	eb 06                	jmp    801d43 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d40:	fc                   	cld    
  801d41:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d43:	89 f8                	mov    %edi,%eax
  801d45:	5b                   	pop    %ebx
  801d46:	5e                   	pop    %esi
  801d47:	5f                   	pop    %edi
  801d48:	5d                   	pop    %ebp
  801d49:	c3                   	ret    

00801d4a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	57                   	push   %edi
  801d4e:	56                   	push   %esi
  801d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d52:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d58:	39 c6                	cmp    %eax,%esi
  801d5a:	73 35                	jae    801d91 <memmove+0x47>
  801d5c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d5f:	39 d0                	cmp    %edx,%eax
  801d61:	73 2e                	jae    801d91 <memmove+0x47>
		s += n;
		d += n;
  801d63:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d66:	89 d6                	mov    %edx,%esi
  801d68:	09 fe                	or     %edi,%esi
  801d6a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d70:	75 13                	jne    801d85 <memmove+0x3b>
  801d72:	f6 c1 03             	test   $0x3,%cl
  801d75:	75 0e                	jne    801d85 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d77:	83 ef 04             	sub    $0x4,%edi
  801d7a:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d7d:	c1 e9 02             	shr    $0x2,%ecx
  801d80:	fd                   	std    
  801d81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d83:	eb 09                	jmp    801d8e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d85:	83 ef 01             	sub    $0x1,%edi
  801d88:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d8b:	fd                   	std    
  801d8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d8e:	fc                   	cld    
  801d8f:	eb 1d                	jmp    801dae <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d91:	89 f2                	mov    %esi,%edx
  801d93:	09 c2                	or     %eax,%edx
  801d95:	f6 c2 03             	test   $0x3,%dl
  801d98:	75 0f                	jne    801da9 <memmove+0x5f>
  801d9a:	f6 c1 03             	test   $0x3,%cl
  801d9d:	75 0a                	jne    801da9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d9f:	c1 e9 02             	shr    $0x2,%ecx
  801da2:	89 c7                	mov    %eax,%edi
  801da4:	fc                   	cld    
  801da5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801da7:	eb 05                	jmp    801dae <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801da9:	89 c7                	mov    %eax,%edi
  801dab:	fc                   	cld    
  801dac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    

00801db2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801db5:	ff 75 10             	pushl  0x10(%ebp)
  801db8:	ff 75 0c             	pushl  0xc(%ebp)
  801dbb:	ff 75 08             	pushl  0x8(%ebp)
  801dbe:	e8 87 ff ff ff       	call   801d4a <memmove>
}
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	56                   	push   %esi
  801dc9:	53                   	push   %ebx
  801dca:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd0:	89 c6                	mov    %eax,%esi
  801dd2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dd5:	eb 1a                	jmp    801df1 <memcmp+0x2c>
		if (*s1 != *s2)
  801dd7:	0f b6 08             	movzbl (%eax),%ecx
  801dda:	0f b6 1a             	movzbl (%edx),%ebx
  801ddd:	38 d9                	cmp    %bl,%cl
  801ddf:	74 0a                	je     801deb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801de1:	0f b6 c1             	movzbl %cl,%eax
  801de4:	0f b6 db             	movzbl %bl,%ebx
  801de7:	29 d8                	sub    %ebx,%eax
  801de9:	eb 0f                	jmp    801dfa <memcmp+0x35>
		s1++, s2++;
  801deb:	83 c0 01             	add    $0x1,%eax
  801dee:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801df1:	39 f0                	cmp    %esi,%eax
  801df3:	75 e2                	jne    801dd7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801df5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dfa:	5b                   	pop    %ebx
  801dfb:	5e                   	pop    %esi
  801dfc:	5d                   	pop    %ebp
  801dfd:	c3                   	ret    

00801dfe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	53                   	push   %ebx
  801e02:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e05:	89 c1                	mov    %eax,%ecx
  801e07:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e0a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e0e:	eb 0a                	jmp    801e1a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e10:	0f b6 10             	movzbl (%eax),%edx
  801e13:	39 da                	cmp    %ebx,%edx
  801e15:	74 07                	je     801e1e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e17:	83 c0 01             	add    $0x1,%eax
  801e1a:	39 c8                	cmp    %ecx,%eax
  801e1c:	72 f2                	jb     801e10 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e1e:	5b                   	pop    %ebx
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	57                   	push   %edi
  801e25:	56                   	push   %esi
  801e26:	53                   	push   %ebx
  801e27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e2d:	eb 03                	jmp    801e32 <strtol+0x11>
		s++;
  801e2f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e32:	0f b6 01             	movzbl (%ecx),%eax
  801e35:	3c 20                	cmp    $0x20,%al
  801e37:	74 f6                	je     801e2f <strtol+0xe>
  801e39:	3c 09                	cmp    $0x9,%al
  801e3b:	74 f2                	je     801e2f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e3d:	3c 2b                	cmp    $0x2b,%al
  801e3f:	75 0a                	jne    801e4b <strtol+0x2a>
		s++;
  801e41:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e44:	bf 00 00 00 00       	mov    $0x0,%edi
  801e49:	eb 11                	jmp    801e5c <strtol+0x3b>
  801e4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e50:	3c 2d                	cmp    $0x2d,%al
  801e52:	75 08                	jne    801e5c <strtol+0x3b>
		s++, neg = 1;
  801e54:	83 c1 01             	add    $0x1,%ecx
  801e57:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e5c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e62:	75 15                	jne    801e79 <strtol+0x58>
  801e64:	80 39 30             	cmpb   $0x30,(%ecx)
  801e67:	75 10                	jne    801e79 <strtol+0x58>
  801e69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e6d:	75 7c                	jne    801eeb <strtol+0xca>
		s += 2, base = 16;
  801e6f:	83 c1 02             	add    $0x2,%ecx
  801e72:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e77:	eb 16                	jmp    801e8f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e79:	85 db                	test   %ebx,%ebx
  801e7b:	75 12                	jne    801e8f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e7d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e82:	80 39 30             	cmpb   $0x30,(%ecx)
  801e85:	75 08                	jne    801e8f <strtol+0x6e>
		s++, base = 8;
  801e87:	83 c1 01             	add    $0x1,%ecx
  801e8a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e94:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e97:	0f b6 11             	movzbl (%ecx),%edx
  801e9a:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e9d:	89 f3                	mov    %esi,%ebx
  801e9f:	80 fb 09             	cmp    $0x9,%bl
  801ea2:	77 08                	ja     801eac <strtol+0x8b>
			dig = *s - '0';
  801ea4:	0f be d2             	movsbl %dl,%edx
  801ea7:	83 ea 30             	sub    $0x30,%edx
  801eaa:	eb 22                	jmp    801ece <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801eac:	8d 72 9f             	lea    -0x61(%edx),%esi
  801eaf:	89 f3                	mov    %esi,%ebx
  801eb1:	80 fb 19             	cmp    $0x19,%bl
  801eb4:	77 08                	ja     801ebe <strtol+0x9d>
			dig = *s - 'a' + 10;
  801eb6:	0f be d2             	movsbl %dl,%edx
  801eb9:	83 ea 57             	sub    $0x57,%edx
  801ebc:	eb 10                	jmp    801ece <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ebe:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ec1:	89 f3                	mov    %esi,%ebx
  801ec3:	80 fb 19             	cmp    $0x19,%bl
  801ec6:	77 16                	ja     801ede <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ec8:	0f be d2             	movsbl %dl,%edx
  801ecb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ece:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ed1:	7d 0b                	jge    801ede <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ed3:	83 c1 01             	add    $0x1,%ecx
  801ed6:	0f af 45 10          	imul   0x10(%ebp),%eax
  801eda:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801edc:	eb b9                	jmp    801e97 <strtol+0x76>

	if (endptr)
  801ede:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ee2:	74 0d                	je     801ef1 <strtol+0xd0>
		*endptr = (char *) s;
  801ee4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ee7:	89 0e                	mov    %ecx,(%esi)
  801ee9:	eb 06                	jmp    801ef1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eeb:	85 db                	test   %ebx,%ebx
  801eed:	74 98                	je     801e87 <strtol+0x66>
  801eef:	eb 9e                	jmp    801e8f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ef1:	89 c2                	mov    %eax,%edx
  801ef3:	f7 da                	neg    %edx
  801ef5:	85 ff                	test   %edi,%edi
  801ef7:	0f 45 c2             	cmovne %edx,%eax
}
  801efa:	5b                   	pop    %ebx
  801efb:	5e                   	pop    %esi
  801efc:	5f                   	pop    %edi
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    

00801eff <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	8b 75 08             	mov    0x8(%ebp),%esi
  801f07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f14:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f17:	83 ec 0c             	sub    $0xc,%esp
  801f1a:	50                   	push   %eax
  801f1b:	e8 ea e3 ff ff       	call   80030a <sys_ipc_recv>
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	85 c0                	test   %eax,%eax
  801f25:	79 16                	jns    801f3d <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f27:	85 f6                	test   %esi,%esi
  801f29:	74 06                	je     801f31 <ipc_recv+0x32>
            *from_env_store = 0;
  801f2b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f31:	85 db                	test   %ebx,%ebx
  801f33:	74 2c                	je     801f61 <ipc_recv+0x62>
            *perm_store = 0;
  801f35:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f3b:	eb 24                	jmp    801f61 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f3d:	85 f6                	test   %esi,%esi
  801f3f:	74 0a                	je     801f4b <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f41:	a1 08 40 80 00       	mov    0x804008,%eax
  801f46:	8b 40 74             	mov    0x74(%eax),%eax
  801f49:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f4b:	85 db                	test   %ebx,%ebx
  801f4d:	74 0a                	je     801f59 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f4f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f54:	8b 40 78             	mov    0x78(%eax),%eax
  801f57:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f59:	a1 08 40 80 00       	mov    0x804008,%eax
  801f5e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f64:	5b                   	pop    %ebx
  801f65:	5e                   	pop    %esi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    

00801f68 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	57                   	push   %edi
  801f6c:	56                   	push   %esi
  801f6d:	53                   	push   %ebx
  801f6e:	83 ec 0c             	sub    $0xc,%esp
  801f71:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f74:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f77:	8b 45 10             	mov    0x10(%ebp),%eax
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f81:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801f84:	eb 1c                	jmp    801fa2 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801f86:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f89:	74 12                	je     801f9d <ipc_send+0x35>
  801f8b:	50                   	push   %eax
  801f8c:	68 40 27 80 00       	push   $0x802740
  801f91:	6a 3b                	push   $0x3b
  801f93:	68 56 27 80 00       	push   $0x802756
  801f98:	e8 3e f5 ff ff       	call   8014db <_panic>
		sys_yield();
  801f9d:	e8 99 e1 ff ff       	call   80013b <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fa2:	ff 75 14             	pushl  0x14(%ebp)
  801fa5:	53                   	push   %ebx
  801fa6:	56                   	push   %esi
  801fa7:	57                   	push   %edi
  801fa8:	e8 3a e3 ff ff       	call   8002e7 <sys_ipc_try_send>
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 d2                	js     801f86 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801fb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	5f                   	pop    %edi
  801fba:	5d                   	pop    %ebp
  801fbb:	c3                   	ret    

00801fbc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fc2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fc7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fd0:	8b 52 50             	mov    0x50(%edx),%edx
  801fd3:	39 ca                	cmp    %ecx,%edx
  801fd5:	75 0d                	jne    801fe4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fd7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fda:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fdf:	8b 40 48             	mov    0x48(%eax),%eax
  801fe2:	eb 0f                	jmp    801ff3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe4:	83 c0 01             	add    $0x1,%eax
  801fe7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fec:	75 d9                	jne    801fc7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ff3:	5d                   	pop    %ebp
  801ff4:	c3                   	ret    

00801ff5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ff5:	55                   	push   %ebp
  801ff6:	89 e5                	mov    %esp,%ebp
  801ff8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ffb:	89 d0                	mov    %edx,%eax
  801ffd:	c1 e8 16             	shr    $0x16,%eax
  802000:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802007:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80200c:	f6 c1 01             	test   $0x1,%cl
  80200f:	74 1d                	je     80202e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802011:	c1 ea 0c             	shr    $0xc,%edx
  802014:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80201b:	f6 c2 01             	test   $0x1,%dl
  80201e:	74 0e                	je     80202e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802020:	c1 ea 0c             	shr    $0xc,%edx
  802023:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80202a:	ef 
  80202b:	0f b7 c0             	movzwl %ax,%eax
}
  80202e:	5d                   	pop    %ebp
  80202f:	c3                   	ret    

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80203b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80203f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 f6                	test   %esi,%esi
  802049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204d:	89 ca                	mov    %ecx,%edx
  80204f:	89 f8                	mov    %edi,%eax
  802051:	75 3d                	jne    802090 <__udivdi3+0x60>
  802053:	39 cf                	cmp    %ecx,%edi
  802055:	0f 87 c5 00 00 00    	ja     802120 <__udivdi3+0xf0>
  80205b:	85 ff                	test   %edi,%edi
  80205d:	89 fd                	mov    %edi,%ebp
  80205f:	75 0b                	jne    80206c <__udivdi3+0x3c>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	31 d2                	xor    %edx,%edx
  802068:	f7 f7                	div    %edi
  80206a:	89 c5                	mov    %eax,%ebp
  80206c:	89 c8                	mov    %ecx,%eax
  80206e:	31 d2                	xor    %edx,%edx
  802070:	f7 f5                	div    %ebp
  802072:	89 c1                	mov    %eax,%ecx
  802074:	89 d8                	mov    %ebx,%eax
  802076:	89 cf                	mov    %ecx,%edi
  802078:	f7 f5                	div    %ebp
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	39 ce                	cmp    %ecx,%esi
  802092:	77 74                	ja     802108 <__udivdi3+0xd8>
  802094:	0f bd fe             	bsr    %esi,%edi
  802097:	83 f7 1f             	xor    $0x1f,%edi
  80209a:	0f 84 98 00 00 00    	je     802138 <__udivdi3+0x108>
  8020a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	89 c5                	mov    %eax,%ebp
  8020a9:	29 fb                	sub    %edi,%ebx
  8020ab:	d3 e6                	shl    %cl,%esi
  8020ad:	89 d9                	mov    %ebx,%ecx
  8020af:	d3 ed                	shr    %cl,%ebp
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	09 ee                	or     %ebp,%esi
  8020b7:	89 d9                	mov    %ebx,%ecx
  8020b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bd:	89 d5                	mov    %edx,%ebp
  8020bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020c3:	d3 ed                	shr    %cl,%ebp
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e2                	shl    %cl,%edx
  8020c9:	89 d9                	mov    %ebx,%ecx
  8020cb:	d3 e8                	shr    %cl,%eax
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	89 d0                	mov    %edx,%eax
  8020d1:	89 ea                	mov    %ebp,%edx
  8020d3:	f7 f6                	div    %esi
  8020d5:	89 d5                	mov    %edx,%ebp
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	f7 64 24 0c          	mull   0xc(%esp)
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	72 10                	jb     8020f1 <__udivdi3+0xc1>
  8020e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e6                	shl    %cl,%esi
  8020e9:	39 c6                	cmp    %eax,%esi
  8020eb:	73 07                	jae    8020f4 <__udivdi3+0xc4>
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	75 03                	jne    8020f4 <__udivdi3+0xc4>
  8020f1:	83 eb 01             	sub    $0x1,%ebx
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	89 fa                	mov    %edi,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	31 ff                	xor    %edi,%edi
  80210a:	31 db                	xor    %ebx,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d8                	mov    %ebx,%eax
  802122:	f7 f7                	div    %edi
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 c3                	mov    %eax,%ebx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 fa                	mov    %edi,%edx
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	39 ce                	cmp    %ecx,%esi
  80213a:	72 0c                	jb     802148 <__udivdi3+0x118>
  80213c:	31 db                	xor    %ebx,%ebx
  80213e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802142:	0f 87 34 ff ff ff    	ja     80207c <__udivdi3+0x4c>
  802148:	bb 01 00 00 00       	mov    $0x1,%ebx
  80214d:	e9 2a ff ff ff       	jmp    80207c <__udivdi3+0x4c>
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80216b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80216f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 d2                	test   %edx,%edx
  802179:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f3                	mov    %esi,%ebx
  802183:	89 3c 24             	mov    %edi,(%esp)
  802186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218a:	75 1c                	jne    8021a8 <__umoddi3+0x48>
  80218c:	39 f7                	cmp    %esi,%edi
  80218e:	76 50                	jbe    8021e0 <__umoddi3+0x80>
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	f7 f7                	div    %edi
  802196:	89 d0                	mov    %edx,%eax
  802198:	31 d2                	xor    %edx,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	77 52                	ja     802200 <__umoddi3+0xa0>
  8021ae:	0f bd ea             	bsr    %edx,%ebp
  8021b1:	83 f5 1f             	xor    $0x1f,%ebp
  8021b4:	75 5a                	jne    802210 <__umoddi3+0xb0>
  8021b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ba:	0f 82 e0 00 00 00    	jb     8022a0 <__umoddi3+0x140>
  8021c0:	39 0c 24             	cmp    %ecx,(%esp)
  8021c3:	0f 86 d7 00 00 00    	jbe    8022a0 <__umoddi3+0x140>
  8021c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021d1:	83 c4 1c             	add    $0x1c,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	89 fd                	mov    %edi,%ebp
  8021e4:	75 0b                	jne    8021f1 <__umoddi3+0x91>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f7                	div    %edi
  8021ef:	89 c5                	mov    %eax,%ebp
  8021f1:	89 f0                	mov    %esi,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f5                	div    %ebp
  8021f7:	89 c8                	mov    %ecx,%eax
  8021f9:	f7 f5                	div    %ebp
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	eb 99                	jmp    802198 <__umoddi3+0x38>
  8021ff:	90                   	nop
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 1c             	add    $0x1c,%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	8b 34 24             	mov    (%esp),%esi
  802213:	bf 20 00 00 00       	mov    $0x20,%edi
  802218:	89 e9                	mov    %ebp,%ecx
  80221a:	29 ef                	sub    %ebp,%edi
  80221c:	d3 e0                	shl    %cl,%eax
  80221e:	89 f9                	mov    %edi,%ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	d3 ea                	shr    %cl,%edx
  802224:	89 e9                	mov    %ebp,%ecx
  802226:	09 c2                	or     %eax,%edx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 14 24             	mov    %edx,(%esp)
  80222d:	89 f2                	mov    %esi,%edx
  80222f:	d3 e2                	shl    %cl,%edx
  802231:	89 f9                	mov    %edi,%ecx
  802233:	89 54 24 04          	mov    %edx,0x4(%esp)
  802237:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	89 c6                	mov    %eax,%esi
  802241:	d3 e3                	shl    %cl,%ebx
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 d0                	mov    %edx,%eax
  802247:	d3 e8                	shr    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	09 d8                	or     %ebx,%eax
  80224d:	89 d3                	mov    %edx,%ebx
  80224f:	89 f2                	mov    %esi,%edx
  802251:	f7 34 24             	divl   (%esp)
  802254:	89 d6                	mov    %edx,%esi
  802256:	d3 e3                	shl    %cl,%ebx
  802258:	f7 64 24 04          	mull   0x4(%esp)
  80225c:	39 d6                	cmp    %edx,%esi
  80225e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802262:	89 d1                	mov    %edx,%ecx
  802264:	89 c3                	mov    %eax,%ebx
  802266:	72 08                	jb     802270 <__umoddi3+0x110>
  802268:	75 11                	jne    80227b <__umoddi3+0x11b>
  80226a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80226e:	73 0b                	jae    80227b <__umoddi3+0x11b>
  802270:	2b 44 24 04          	sub    0x4(%esp),%eax
  802274:	1b 14 24             	sbb    (%esp),%edx
  802277:	89 d1                	mov    %edx,%ecx
  802279:	89 c3                	mov    %eax,%ebx
  80227b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80227f:	29 da                	sub    %ebx,%edx
  802281:	19 ce                	sbb    %ecx,%esi
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 f0                	mov    %esi,%eax
  802287:	d3 e0                	shl    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	d3 ea                	shr    %cl,%edx
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	d3 ee                	shr    %cl,%esi
  802291:	09 d0                	or     %edx,%eax
  802293:	89 f2                	mov    %esi,%edx
  802295:	83 c4 1c             	add    $0x1c,%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	29 f9                	sub    %edi,%ecx
  8022a2:	19 d6                	sbb    %edx,%esi
  8022a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ac:	e9 18 ff ff ff       	jmp    8021c9 <__umoddi3+0x69>
