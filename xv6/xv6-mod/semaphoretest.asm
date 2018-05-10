
_semaphoretest:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00000000 <printf>:
int empty;
int full;

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  write(fd, s, strlen(s));
   6:	83 ec 0c             	sub    $0xc,%esp
   9:	ff 75 0c             	pushl  0xc(%ebp)
   c:	e8 c9 02 00 00       	call   2da <strlen>
  11:	83 c4 10             	add    $0x10,%esp
  14:	83 ec 04             	sub    $0x4,%esp
  17:	50                   	push   %eax
  18:	ff 75 0c             	pushl  0xc(%ebp)
  1b:	ff 75 08             	pushl  0x8(%ebp)
  1e:	e8 99 04 00 00       	call   4bc <write>
  23:	83 c4 10             	add    $0x10,%esp
}
  26:	90                   	nop
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <encolar>:



void
encolar (int nuevo)
{
  29:	55                   	push   %ebp
  2a:	89 e5                	mov    %esp,%ebp
  2c:	83 ec 08             	sub    $0x8,%esp
  //printf(1,"antes semdownql de encolar\n" );
  semdown(ql);
  2f:	a1 e8 07 00 00       	mov    0x7e8,%eax
  34:	83 ec 0c             	sub    $0xc,%esp
  37:	50                   	push   %eax
  38:	e8 1f 05 00 00       	call   55c <semdown>
  3d:	83 c4 10             	add    $0x10,%esp
  //printf(1,"despues semdownql de encolar\n" );
  cola[cantcola]=nuevo;
  40:	a1 e4 07 00 00       	mov    0x7e4,%eax
  45:	8b 55 08             	mov    0x8(%ebp),%edx
  48:	89 14 85 00 08 00 00 	mov    %edx,0x800(,%eax,4)

  cantcola++;
  4f:	a1 e4 07 00 00       	mov    0x7e4,%eax
  54:	83 c0 01             	add    $0x1,%eax
  57:	a3 e4 07 00 00       	mov    %eax,0x7e4
  //printf(1,"antes semupql de encolar\n" );
  semup(ql);
  5c:	a1 e8 07 00 00       	mov    0x7e8,%eax
  61:	83 ec 0c             	sub    $0xc,%esp
  64:	50                   	push   %eax
  65:	e8 fa 04 00 00       	call   564 <semup>
  6a:	83 c4 10             	add    $0x10,%esp
  //printf(1,"depsues semupql de encolar\n" );
}
  6d:	90                   	nop
  6e:	c9                   	leave  
  6f:	c3                   	ret    

00000070 <desencolar>:

int
desencolar()
{
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	83 ec 18             	sub    $0x18,%esp
  int res;
  int i;
  //printf(1,"antes semdownql de desencolar\n" );
  semdown(ql);
  76:	a1 e8 07 00 00       	mov    0x7e8,%eax
  7b:	83 ec 0c             	sub    $0xc,%esp
  7e:	50                   	push   %eax
  7f:	e8 d8 04 00 00       	call   55c <semdown>
  84:	83 c4 10             	add    $0x10,%esp
  //printf(1,"despues semdownql de desencolar\n" );
  res =cola[0];
  87:	a1 00 08 00 00       	mov    0x800,%eax
  8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i=0;i<cantcola-1;i++){
  8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  96:	eb 1b                	jmp    b3 <desencolar+0x43>
    cola[i]=cola[i+1];
  98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  9b:	83 c0 01             	add    $0x1,%eax
  9e:	8b 14 85 00 08 00 00 	mov    0x800(,%eax,4),%edx
  a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a8:	89 14 85 00 08 00 00 	mov    %edx,0x800(,%eax,4)
  int i;
  //printf(1,"antes semdownql de desencolar\n" );
  semdown(ql);
  //printf(1,"despues semdownql de desencolar\n" );
  res =cola[0];
  for(i=0;i<cantcola-1;i++){
  af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  b3:	a1 e4 07 00 00       	mov    0x7e4,%eax
  b8:	83 e8 01             	sub    $0x1,%eax
  bb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  be:	7f d8                	jg     98 <desencolar+0x28>
    cola[i]=cola[i+1];
  }
  //printf(1,"antes semupql de desencolar\n" );
  semup(ql);
  c0:	a1 e8 07 00 00       	mov    0x7e8,%eax
  c5:	83 ec 0c             	sub    $0xc,%esp
  c8:	50                   	push   %eax
  c9:	e8 96 04 00 00       	call   564 <semup>
  ce:	83 c4 10             	add    $0x10,%esp
  //printf(1,"depsues semupql de desencolar\n" );
  return res;
  d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  //printf(1,"fin del desencolar\n" );
}
  d4:	c9                   	leave  
  d5:	c3                   	ret    

000000d6 <consumidor>:


void
consumidor(void)
{
  d6:	55                   	push   %ebp
  d7:	89 e5                	mov    %esp,%ebp
  d9:	83 ec 08             	sub    $0x8,%esp
  for(;;) {
  //  printf(1,"antes semudownempty de consumidor\n" );
    semdown(empty);
  dc:	a1 90 09 00 00       	mov    0x990,%eax
  e1:	83 ec 0c             	sub    $0xc,%esp
  e4:	50                   	push   %eax
  e5:	e8 72 04 00 00       	call   55c <semdown>
  ea:	83 c4 10             	add    $0x10,%esp
  //  printf(1,"depsues semudownempty de consumidor\n" );
    printf(1,"%d\n",desencolar() );
  ed:	e8 7e ff ff ff       	call   70 <desencolar>
  f2:	83 ec 04             	sub    $0x4,%esp
  f5:	50                   	push   %eax
  f6:	68 6c 05 00 00       	push   $0x56c
  fb:	6a 01                	push   $0x1
  fd:	e8 fe fe ff ff       	call   0 <printf>
 102:	83 c4 10             	add    $0x10,%esp
  //  printf(1,"antes semupfull de consumidor\n" );
    semup(full);
 105:	a1 e0 07 00 00       	mov    0x7e0,%eax
 10a:	83 ec 0c             	sub    $0xc,%esp
 10d:	50                   	push   %eax
 10e:	e8 51 04 00 00       	call   564 <semup>
 113:	83 c4 10             	add    $0x10,%esp
  //  printf(1,"depsues semupfull de consumidor\n" );
  }
 116:	eb c4                	jmp    dc <consumidor+0x6>

00000118 <productor>:
}

void
productor(void)
{
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	83 ec 18             	sub    $0x18,%esp
  int item=0;
 11e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for(;;) {
    item=item+1;
 125:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    //printf(1,"produje %i \n",item );
    semdown(full);
 129:	a1 e0 07 00 00       	mov    0x7e0,%eax
 12e:	83 ec 0c             	sub    $0xc,%esp
 131:	50                   	push   %eax
 132:	e8 25 04 00 00       	call   55c <semdown>
 137:	83 c4 10             	add    $0x10,%esp
    encolar(item);
 13a:	83 ec 0c             	sub    $0xc,%esp
 13d:	ff 75 f4             	pushl  -0xc(%ebp)
 140:	e8 e4 fe ff ff       	call   29 <encolar>
 145:	83 c4 10             	add    $0x10,%esp
    semup(empty);
 148:	a1 90 09 00 00       	mov    0x990,%eax
 14d:	83 ec 0c             	sub    $0xc,%esp
 150:	50                   	push   %eax
 151:	e8 0e 04 00 00       	call   564 <semup>
 156:	83 c4 10             	add    $0x10,%esp
  }
 159:	eb ca                	jmp    125 <productor+0xd>

0000015b <semtest>:
}

void
semtest(void)
{
 15b:	55                   	push   %ebp
 15c:	89 e5                	mov    %esp,%ebp
 15e:	83 ec 18             	sub    $0x18,%esp
  int i;
  int pid;
  for(i=0;i<CANTPRODUCTORES;i++){
 161:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 168:	eb 26                	jmp    190 <semtest+0x35>

    pid=fork();
 16a:	e8 25 03 00 00       	call   494 <fork>
 16f:	89 45 f0             	mov    %eax,-0x10(%ebp)

    if(pid==0){
 172:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 176:	75 14                	jne    18c <semtest+0x31>
      printf(1,"SOY PRODUCTOR\n" );
 178:	83 ec 08             	sub    $0x8,%esp
 17b:	68 70 05 00 00       	push   $0x570
 180:	6a 01                	push   $0x1
 182:	e8 79 fe ff ff       	call   0 <printf>
 187:	83 c4 10             	add    $0x10,%esp
      break;
 18a:	eb 0a                	jmp    196 <semtest+0x3b>
void
semtest(void)
{
  int i;
  int pid;
  for(i=0;i<CANTPRODUCTORES;i++){
 18c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 190:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 194:	7e d4                	jle    16a <semtest+0xf>
      printf(1,"SOY PRODUCTOR\n" );
      break;
    }

  }
  if(pid==0){
 196:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 19a:	75 05                	jne    1a1 <semtest+0x46>
    productor();
 19c:	e8 77 ff ff ff       	call   118 <productor>
  }

  for(i=0;i<CANTCONSUMIDORES;i++){
 1a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a8:	eb 26                	jmp    1d0 <semtest+0x75>
    pid=fork();
 1aa:	e8 e5 02 00 00       	call   494 <fork>
 1af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid==0){
 1b2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b6:	75 14                	jne    1cc <semtest+0x71>
      printf(1,"SOY CONSUMIDOR\n" );
 1b8:	83 ec 08             	sub    $0x8,%esp
 1bb:	68 7f 05 00 00       	push   $0x57f
 1c0:	6a 01                	push   $0x1
 1c2:	e8 39 fe ff ff       	call   0 <printf>
 1c7:	83 c4 10             	add    $0x10,%esp
      break;
 1ca:	eb 0a                	jmp    1d6 <semtest+0x7b>
  }
  if(pid==0){
    productor();
  }

  for(i=0;i<CANTCONSUMIDORES;i++){
 1cc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1d4:	7e d4                	jle    1aa <semtest+0x4f>
      printf(1,"SOY CONSUMIDOR\n" );
      break;
    }

  }
  if(pid==0){
 1d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1da:	75 05                	jne    1e1 <semtest+0x86>
    consumidor();
 1dc:	e8 f5 fe ff ff       	call   d6 <consumidor>
  }


}
 1e1:	90                   	nop
 1e2:	c9                   	leave  
 1e3:	c3                   	ret    

000001e4 <main>:


int
main(void)
{
 1e4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 1e8:	83 e4 f0             	and    $0xfffffff0,%esp
 1eb:	ff 71 fc             	pushl  -0x4(%ecx)
 1ee:	55                   	push   %ebp
 1ef:	89 e5                	mov    %esp,%ebp
 1f1:	51                   	push   %ecx
 1f2:	83 ec 04             	sub    $0x4,%esp
  cantcola=0;
 1f5:	c7 05 e4 07 00 00 00 	movl   $0x0,0x7e4
 1fc:	00 00 00 
  ql = semget(-1,1);
 1ff:	83 ec 08             	sub    $0x8,%esp
 202:	6a 01                	push   $0x1
 204:	6a ff                	push   $0xffffffff
 206:	e8 41 03 00 00       	call   54c <semget>
 20b:	83 c4 10             	add    $0x10,%esp
 20e:	a3 e8 07 00 00       	mov    %eax,0x7e8
  full= semget(-1,N);
 213:	83 ec 08             	sub    $0x8,%esp
 216:	6a 64                	push   $0x64
 218:	6a ff                	push   $0xffffffff
 21a:	e8 2d 03 00 00       	call   54c <semget>
 21f:	83 c4 10             	add    $0x10,%esp
 222:	a3 e0 07 00 00       	mov    %eax,0x7e0
  empty= semget(-1,0);
 227:	83 ec 08             	sub    $0x8,%esp
 22a:	6a 00                	push   $0x0
 22c:	6a ff                	push   $0xffffffff
 22e:	e8 19 03 00 00       	call   54c <semget>
 233:	83 c4 10             	add    $0x10,%esp
 236:	a3 90 09 00 00       	mov    %eax,0x990
  semtest();
 23b:	e8 1b ff ff ff       	call   15b <semtest>
  exit();
 240:	e8 57 02 00 00       	call   49c <exit>

00000245 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 245:	55                   	push   %ebp
 246:	89 e5                	mov    %esp,%ebp
 248:	57                   	push   %edi
 249:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 24a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 24d:	8b 55 10             	mov    0x10(%ebp),%edx
 250:	8b 45 0c             	mov    0xc(%ebp),%eax
 253:	89 cb                	mov    %ecx,%ebx
 255:	89 df                	mov    %ebx,%edi
 257:	89 d1                	mov    %edx,%ecx
 259:	fc                   	cld    
 25a:	f3 aa                	rep stos %al,%es:(%edi)
 25c:	89 ca                	mov    %ecx,%edx
 25e:	89 fb                	mov    %edi,%ebx
 260:	89 5d 08             	mov    %ebx,0x8(%ebp)
 263:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 266:	90                   	nop
 267:	5b                   	pop    %ebx
 268:	5f                   	pop    %edi
 269:	5d                   	pop    %ebp
 26a:	c3                   	ret    

0000026b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 26b:	55                   	push   %ebp
 26c:	89 e5                	mov    %esp,%ebp
 26e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 271:	8b 45 08             	mov    0x8(%ebp),%eax
 274:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 277:	90                   	nop
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	8d 50 01             	lea    0x1(%eax),%edx
 27e:	89 55 08             	mov    %edx,0x8(%ebp)
 281:	8b 55 0c             	mov    0xc(%ebp),%edx
 284:	8d 4a 01             	lea    0x1(%edx),%ecx
 287:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 28a:	0f b6 12             	movzbl (%edx),%edx
 28d:	88 10                	mov    %dl,(%eax)
 28f:	0f b6 00             	movzbl (%eax),%eax
 292:	84 c0                	test   %al,%al
 294:	75 e2                	jne    278 <strcpy+0xd>
    ;
  return os;
 296:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 299:	c9                   	leave  
 29a:	c3                   	ret    

0000029b <strcmp>:

int
strcmp(const char *p, const char *q)
{
 29b:	55                   	push   %ebp
 29c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 29e:	eb 08                	jmp    2a8 <strcmp+0xd>
    p++, q++;
 2a0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2a4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2a8:	8b 45 08             	mov    0x8(%ebp),%eax
 2ab:	0f b6 00             	movzbl (%eax),%eax
 2ae:	84 c0                	test   %al,%al
 2b0:	74 10                	je     2c2 <strcmp+0x27>
 2b2:	8b 45 08             	mov    0x8(%ebp),%eax
 2b5:	0f b6 10             	movzbl (%eax),%edx
 2b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bb:	0f b6 00             	movzbl (%eax),%eax
 2be:	38 c2                	cmp    %al,%dl
 2c0:	74 de                	je     2a0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2c2:	8b 45 08             	mov    0x8(%ebp),%eax
 2c5:	0f b6 00             	movzbl (%eax),%eax
 2c8:	0f b6 d0             	movzbl %al,%edx
 2cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ce:	0f b6 00             	movzbl (%eax),%eax
 2d1:	0f b6 c0             	movzbl %al,%eax
 2d4:	29 c2                	sub    %eax,%edx
 2d6:	89 d0                	mov    %edx,%eax
}
 2d8:	5d                   	pop    %ebp
 2d9:	c3                   	ret    

000002da <strlen>:

uint
strlen(char *s)
{
 2da:	55                   	push   %ebp
 2db:	89 e5                	mov    %esp,%ebp
 2dd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2e7:	eb 04                	jmp    2ed <strlen+0x13>
 2e9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2ed:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f0:	8b 45 08             	mov    0x8(%ebp),%eax
 2f3:	01 d0                	add    %edx,%eax
 2f5:	0f b6 00             	movzbl (%eax),%eax
 2f8:	84 c0                	test   %al,%al
 2fa:	75 ed                	jne    2e9 <strlen+0xf>
    ;
  return n;
 2fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2ff:	c9                   	leave  
 300:	c3                   	ret    

00000301 <memset>:

void*
memset(void *dst, int c, uint n)
{
 301:	55                   	push   %ebp
 302:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 304:	8b 45 10             	mov    0x10(%ebp),%eax
 307:	50                   	push   %eax
 308:	ff 75 0c             	pushl  0xc(%ebp)
 30b:	ff 75 08             	pushl  0x8(%ebp)
 30e:	e8 32 ff ff ff       	call   245 <stosb>
 313:	83 c4 0c             	add    $0xc,%esp
  return dst;
 316:	8b 45 08             	mov    0x8(%ebp),%eax
}
 319:	c9                   	leave  
 31a:	c3                   	ret    

0000031b <strchr>:

char*
strchr(const char *s, char c)
{
 31b:	55                   	push   %ebp
 31c:	89 e5                	mov    %esp,%ebp
 31e:	83 ec 04             	sub    $0x4,%esp
 321:	8b 45 0c             	mov    0xc(%ebp),%eax
 324:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 327:	eb 14                	jmp    33d <strchr+0x22>
    if(*s == c)
 329:	8b 45 08             	mov    0x8(%ebp),%eax
 32c:	0f b6 00             	movzbl (%eax),%eax
 32f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 332:	75 05                	jne    339 <strchr+0x1e>
      return (char*)s;
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	eb 13                	jmp    34c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 339:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 33d:	8b 45 08             	mov    0x8(%ebp),%eax
 340:	0f b6 00             	movzbl (%eax),%eax
 343:	84 c0                	test   %al,%al
 345:	75 e2                	jne    329 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 347:	b8 00 00 00 00       	mov    $0x0,%eax
}
 34c:	c9                   	leave  
 34d:	c3                   	ret    

0000034e <gets>:

char*
gets(char *buf, int max)
{
 34e:	55                   	push   %ebp
 34f:	89 e5                	mov    %esp,%ebp
 351:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 354:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 35b:	eb 42                	jmp    39f <gets+0x51>
    cc = read(0, &c, 1);
 35d:	83 ec 04             	sub    $0x4,%esp
 360:	6a 01                	push   $0x1
 362:	8d 45 ef             	lea    -0x11(%ebp),%eax
 365:	50                   	push   %eax
 366:	6a 00                	push   $0x0
 368:	e8 47 01 00 00       	call   4b4 <read>
 36d:	83 c4 10             	add    $0x10,%esp
 370:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 373:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 377:	7e 33                	jle    3ac <gets+0x5e>
      break;
    buf[i++] = c;
 379:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37c:	8d 50 01             	lea    0x1(%eax),%edx
 37f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 382:	89 c2                	mov    %eax,%edx
 384:	8b 45 08             	mov    0x8(%ebp),%eax
 387:	01 c2                	add    %eax,%edx
 389:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 38d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 38f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 393:	3c 0a                	cmp    $0xa,%al
 395:	74 16                	je     3ad <gets+0x5f>
 397:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 39b:	3c 0d                	cmp    $0xd,%al
 39d:	74 0e                	je     3ad <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 39f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a2:	83 c0 01             	add    $0x1,%eax
 3a5:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3a8:	7c b3                	jl     35d <gets+0xf>
 3aa:	eb 01                	jmp    3ad <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 3ac:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3b0:	8b 45 08             	mov    0x8(%ebp),%eax
 3b3:	01 d0                	add    %edx,%eax
 3b5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3bb:	c9                   	leave  
 3bc:	c3                   	ret    

000003bd <stat>:

int
stat(char *n, struct stat *st)
{
 3bd:	55                   	push   %ebp
 3be:	89 e5                	mov    %esp,%ebp
 3c0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3c3:	83 ec 08             	sub    $0x8,%esp
 3c6:	6a 00                	push   $0x0
 3c8:	ff 75 08             	pushl  0x8(%ebp)
 3cb:	e8 0c 01 00 00       	call   4dc <open>
 3d0:	83 c4 10             	add    $0x10,%esp
 3d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3da:	79 07                	jns    3e3 <stat+0x26>
    return -1;
 3dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3e1:	eb 25                	jmp    408 <stat+0x4b>
  r = fstat(fd, st);
 3e3:	83 ec 08             	sub    $0x8,%esp
 3e6:	ff 75 0c             	pushl  0xc(%ebp)
 3e9:	ff 75 f4             	pushl  -0xc(%ebp)
 3ec:	e8 03 01 00 00       	call   4f4 <fstat>
 3f1:	83 c4 10             	add    $0x10,%esp
 3f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3f7:	83 ec 0c             	sub    $0xc,%esp
 3fa:	ff 75 f4             	pushl  -0xc(%ebp)
 3fd:	e8 c2 00 00 00       	call   4c4 <close>
 402:	83 c4 10             	add    $0x10,%esp
  return r;
 405:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 408:	c9                   	leave  
 409:	c3                   	ret    

0000040a <atoi>:

int
atoi(const char *s)
{
 40a:	55                   	push   %ebp
 40b:	89 e5                	mov    %esp,%ebp
 40d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 410:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 417:	eb 25                	jmp    43e <atoi+0x34>
    n = n*10 + *s++ - '0';
 419:	8b 55 fc             	mov    -0x4(%ebp),%edx
 41c:	89 d0                	mov    %edx,%eax
 41e:	c1 e0 02             	shl    $0x2,%eax
 421:	01 d0                	add    %edx,%eax
 423:	01 c0                	add    %eax,%eax
 425:	89 c1                	mov    %eax,%ecx
 427:	8b 45 08             	mov    0x8(%ebp),%eax
 42a:	8d 50 01             	lea    0x1(%eax),%edx
 42d:	89 55 08             	mov    %edx,0x8(%ebp)
 430:	0f b6 00             	movzbl (%eax),%eax
 433:	0f be c0             	movsbl %al,%eax
 436:	01 c8                	add    %ecx,%eax
 438:	83 e8 30             	sub    $0x30,%eax
 43b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 43e:	8b 45 08             	mov    0x8(%ebp),%eax
 441:	0f b6 00             	movzbl (%eax),%eax
 444:	3c 2f                	cmp    $0x2f,%al
 446:	7e 0a                	jle    452 <atoi+0x48>
 448:	8b 45 08             	mov    0x8(%ebp),%eax
 44b:	0f b6 00             	movzbl (%eax),%eax
 44e:	3c 39                	cmp    $0x39,%al
 450:	7e c7                	jle    419 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 452:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 455:	c9                   	leave  
 456:	c3                   	ret    

00000457 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 457:	55                   	push   %ebp
 458:	89 e5                	mov    %esp,%ebp
 45a:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 45d:	8b 45 08             	mov    0x8(%ebp),%eax
 460:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 463:	8b 45 0c             	mov    0xc(%ebp),%eax
 466:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 469:	eb 17                	jmp    482 <memmove+0x2b>
    *dst++ = *src++;
 46b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 46e:	8d 50 01             	lea    0x1(%eax),%edx
 471:	89 55 fc             	mov    %edx,-0x4(%ebp)
 474:	8b 55 f8             	mov    -0x8(%ebp),%edx
 477:	8d 4a 01             	lea    0x1(%edx),%ecx
 47a:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 47d:	0f b6 12             	movzbl (%edx),%edx
 480:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 482:	8b 45 10             	mov    0x10(%ebp),%eax
 485:	8d 50 ff             	lea    -0x1(%eax),%edx
 488:	89 55 10             	mov    %edx,0x10(%ebp)
 48b:	85 c0                	test   %eax,%eax
 48d:	7f dc                	jg     46b <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 48f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 492:	c9                   	leave  
 493:	c3                   	ret    

00000494 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 494:	b8 01 00 00 00       	mov    $0x1,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <exit>:
SYSCALL(exit)
 49c:	b8 02 00 00 00       	mov    $0x2,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <wait>:
SYSCALL(wait)
 4a4:	b8 03 00 00 00       	mov    $0x3,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <pipe>:
SYSCALL(pipe)
 4ac:	b8 04 00 00 00       	mov    $0x4,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <read>:
SYSCALL(read)
 4b4:	b8 05 00 00 00       	mov    $0x5,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <write>:
SYSCALL(write)
 4bc:	b8 10 00 00 00       	mov    $0x10,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <close>:
SYSCALL(close)
 4c4:	b8 15 00 00 00       	mov    $0x15,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <kill>:
SYSCALL(kill)
 4cc:	b8 06 00 00 00       	mov    $0x6,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <exec>:
SYSCALL(exec)
 4d4:	b8 07 00 00 00       	mov    $0x7,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <open>:
SYSCALL(open)
 4dc:	b8 0f 00 00 00       	mov    $0xf,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <mknod>:
SYSCALL(mknod)
 4e4:	b8 11 00 00 00       	mov    $0x11,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <unlink>:
SYSCALL(unlink)
 4ec:	b8 12 00 00 00       	mov    $0x12,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <fstat>:
SYSCALL(fstat)
 4f4:	b8 08 00 00 00       	mov    $0x8,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <link>:
SYSCALL(link)
 4fc:	b8 13 00 00 00       	mov    $0x13,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <mkdir>:
SYSCALL(mkdir)
 504:	b8 14 00 00 00       	mov    $0x14,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <chdir>:
SYSCALL(chdir)
 50c:	b8 09 00 00 00       	mov    $0x9,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <dup>:
SYSCALL(dup)
 514:	b8 0a 00 00 00       	mov    $0xa,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <getpid>:
SYSCALL(getpid)
 51c:	b8 0b 00 00 00       	mov    $0xb,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <sbrk>:
SYSCALL(sbrk)
 524:	b8 0c 00 00 00       	mov    $0xc,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <sleep>:
SYSCALL(sleep)
 52c:	b8 0d 00 00 00       	mov    $0xd,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <uptime>:
SYSCALL(uptime)
 534:	b8 0e 00 00 00       	mov    $0xe,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <procstat>:
SYSCALL(procstat)
 53c:	b8 16 00 00 00       	mov    $0x16,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <setpriority>:
SYSCALL(setpriority)
 544:	b8 17 00 00 00       	mov    $0x17,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <semget>:
SYSCALL(semget)
 54c:	b8 18 00 00 00       	mov    $0x18,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <semfree>:
SYSCALL(semfree)
 554:	b8 19 00 00 00       	mov    $0x19,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <semdown>:
SYSCALL(semdown)
 55c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <semup>:
SYSCALL(semup)
 564:	b8 1b 00 00 00       	mov    $0x1b,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    
