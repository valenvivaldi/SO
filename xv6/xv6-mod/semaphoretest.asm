
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
   c:	e8 90 03 00 00       	call   3a1 <strlen>
  11:	83 c4 10             	add    $0x10,%esp
  14:	83 ec 04             	sub    $0x4,%esp
  17:	50                   	push   %eax
  18:	ff 75 0c             	pushl  0xc(%ebp)
  1b:	ff 75 08             	pushl  0x8(%ebp)
  1e:	e8 60 05 00 00       	call   583 <write>
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
  printf(1,"antes semdownql de encolar\n" );
  2f:	83 ec 08             	sub    $0x8,%esp
  32:	68 34 06 00 00       	push   $0x634
  37:	6a 01                	push   $0x1
  39:	e8 c2 ff ff ff       	call   0 <printf>
  3e:	83 c4 10             	add    $0x10,%esp
  semdown(ql);
  41:	a1 28 0a 00 00       	mov    0xa28,%eax
  46:	83 ec 0c             	sub    $0xc,%esp
  49:	50                   	push   %eax
  4a:	e8 d4 05 00 00       	call   623 <semdown>
  4f:	83 c4 10             	add    $0x10,%esp
  printf(1,"despues semdownql de encolar\n" );
  52:	83 ec 08             	sub    $0x8,%esp
  55:	68 50 06 00 00       	push   $0x650
  5a:	6a 01                	push   $0x1
  5c:	e8 9f ff ff ff       	call   0 <printf>
  61:	83 c4 10             	add    $0x10,%esp
  cola[cantcola]=nuevo;
  64:	a1 24 0a 00 00       	mov    0xa24,%eax
  69:	8b 55 08             	mov    0x8(%ebp),%edx
  6c:	89 14 85 40 0a 00 00 	mov    %edx,0xa40(,%eax,4)

  cantcola++;
  73:	a1 24 0a 00 00       	mov    0xa24,%eax
  78:	83 c0 01             	add    $0x1,%eax
  7b:	a3 24 0a 00 00       	mov    %eax,0xa24
  printf(1,"antes semupql de encolar\n" );
  80:	83 ec 08             	sub    $0x8,%esp
  83:	68 6e 06 00 00       	push   $0x66e
  88:	6a 01                	push   $0x1
  8a:	e8 71 ff ff ff       	call   0 <printf>
  8f:	83 c4 10             	add    $0x10,%esp
  semup(ql);
  92:	a1 28 0a 00 00       	mov    0xa28,%eax
  97:	83 ec 0c             	sub    $0xc,%esp
  9a:	50                   	push   %eax
  9b:	e8 8b 05 00 00       	call   62b <semup>
  a0:	83 c4 10             	add    $0x10,%esp
  printf(1,"depsues semupql de encolar\n" );
  a3:	83 ec 08             	sub    $0x8,%esp
  a6:	68 88 06 00 00       	push   $0x688
  ab:	6a 01                	push   $0x1
  ad:	e8 4e ff ff ff       	call   0 <printf>
  b2:	83 c4 10             	add    $0x10,%esp
}
  b5:	90                   	nop
  b6:	c9                   	leave  
  b7:	c3                   	ret    

000000b8 <desencolar>:

int
desencolar()
{
  b8:	55                   	push   %ebp
  b9:	89 e5                	mov    %esp,%ebp
  bb:	83 ec 18             	sub    $0x18,%esp
  int res;
  int i;
  printf(1,"antes semdownql de desencolar\n" );
  be:	83 ec 08             	sub    $0x8,%esp
  c1:	68 a4 06 00 00       	push   $0x6a4
  c6:	6a 01                	push   $0x1
  c8:	e8 33 ff ff ff       	call   0 <printf>
  cd:	83 c4 10             	add    $0x10,%esp
  semdown(ql);
  d0:	a1 28 0a 00 00       	mov    0xa28,%eax
  d5:	83 ec 0c             	sub    $0xc,%esp
  d8:	50                   	push   %eax
  d9:	e8 45 05 00 00       	call   623 <semdown>
  de:	83 c4 10             	add    $0x10,%esp
  printf(1,"despues semdownql de desencolar\n" );
  e1:	83 ec 08             	sub    $0x8,%esp
  e4:	68 c4 06 00 00       	push   $0x6c4
  e9:	6a 01                	push   $0x1
  eb:	e8 10 ff ff ff       	call   0 <printf>
  f0:	83 c4 10             	add    $0x10,%esp
  res =cola[0];
  f3:	a1 40 0a 00 00       	mov    0xa40,%eax
  f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i=0;i<cantcola-1;i++){
  fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 102:	eb 1b                	jmp    11f <desencolar+0x67>
    cola[i]=cola[i+1];
 104:	8b 45 f4             	mov    -0xc(%ebp),%eax
 107:	83 c0 01             	add    $0x1,%eax
 10a:	8b 14 85 40 0a 00 00 	mov    0xa40(,%eax,4),%edx
 111:	8b 45 f4             	mov    -0xc(%ebp),%eax
 114:	89 14 85 40 0a 00 00 	mov    %edx,0xa40(,%eax,4)
  int i;
  printf(1,"antes semdownql de desencolar\n" );
  semdown(ql);
  printf(1,"despues semdownql de desencolar\n" );
  res =cola[0];
  for(i=0;i<cantcola-1;i++){
 11b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 11f:	a1 24 0a 00 00       	mov    0xa24,%eax
 124:	83 e8 01             	sub    $0x1,%eax
 127:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 12a:	7f d8                	jg     104 <desencolar+0x4c>
    cola[i]=cola[i+1];
  }
  printf(1,"antes semupql de desencolar\n" );
 12c:	83 ec 08             	sub    $0x8,%esp
 12f:	68 e5 06 00 00       	push   $0x6e5
 134:	6a 01                	push   $0x1
 136:	e8 c5 fe ff ff       	call   0 <printf>
 13b:	83 c4 10             	add    $0x10,%esp
  semup(ql);
 13e:	a1 28 0a 00 00       	mov    0xa28,%eax
 143:	83 ec 0c             	sub    $0xc,%esp
 146:	50                   	push   %eax
 147:	e8 df 04 00 00       	call   62b <semup>
 14c:	83 c4 10             	add    $0x10,%esp
  printf(1,"depsues semupql de desencolar\n" );
 14f:	83 ec 08             	sub    $0x8,%esp
 152:	68 04 07 00 00       	push   $0x704
 157:	6a 01                	push   $0x1
 159:	e8 a2 fe ff ff       	call   0 <printf>
 15e:	83 c4 10             	add    $0x10,%esp
  return res;
 161:	8b 45 f0             	mov    -0x10(%ebp),%eax
  printf(1,"fin del desencolar\n" );
}
 164:	c9                   	leave  
 165:	c3                   	ret    

00000166 <consumidor>:


void
consumidor(void)
{
 166:	55                   	push   %ebp
 167:	89 e5                	mov    %esp,%ebp
 169:	83 ec 08             	sub    $0x8,%esp
  while (1) {
    printf(1,"antes semudownempty de consumidor\n" );
 16c:	83 ec 08             	sub    $0x8,%esp
 16f:	68 24 07 00 00       	push   $0x724
 174:	6a 01                	push   $0x1
 176:	e8 85 fe ff ff       	call   0 <printf>
 17b:	83 c4 10             	add    $0x10,%esp
    semdown(empty);
 17e:	a1 d0 0b 00 00       	mov    0xbd0,%eax
 183:	83 ec 0c             	sub    $0xc,%esp
 186:	50                   	push   %eax
 187:	e8 97 04 00 00       	call   623 <semdown>
 18c:	83 c4 10             	add    $0x10,%esp
    printf(1,"depsues semudownempty de consumidor\n" );
 18f:	83 ec 08             	sub    $0x8,%esp
 192:	68 48 07 00 00       	push   $0x748
 197:	6a 01                	push   $0x1
 199:	e8 62 fe ff ff       	call   0 <printf>
 19e:	83 c4 10             	add    $0x10,%esp
    //printf(1,"%d\n",desencolar() );
    printf(1,"antes semupfull de consumidor\n" );
 1a1:	83 ec 08             	sub    $0x8,%esp
 1a4:	68 70 07 00 00       	push   $0x770
 1a9:	6a 01                	push   $0x1
 1ab:	e8 50 fe ff ff       	call   0 <printf>
 1b0:	83 c4 10             	add    $0x10,%esp
    semup(full);
 1b3:	a1 20 0a 00 00       	mov    0xa20,%eax
 1b8:	83 ec 0c             	sub    $0xc,%esp
 1bb:	50                   	push   %eax
 1bc:	e8 6a 04 00 00       	call   62b <semup>
 1c1:	83 c4 10             	add    $0x10,%esp
    printf(1,"depsues semupfull de consumidor\n" );
 1c4:	83 ec 08             	sub    $0x8,%esp
 1c7:	68 90 07 00 00       	push   $0x790
 1cc:	6a 01                	push   $0x1
 1ce:	e8 2d fe ff ff       	call   0 <printf>
 1d3:	83 c4 10             	add    $0x10,%esp
  }
 1d6:	eb 94                	jmp    16c <consumidor+0x6>

000001d8 <productor>:
}

void
productor(void)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	83 ec 18             	sub    $0x18,%esp
  int item=0;
 1de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for(;;) {
    item=item+1;
 1e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    printf(1,"produje %i \n",item );
 1e9:	83 ec 04             	sub    $0x4,%esp
 1ec:	ff 75 f4             	pushl  -0xc(%ebp)
 1ef:	68 b1 07 00 00       	push   $0x7b1
 1f4:	6a 01                	push   $0x1
 1f6:	e8 05 fe ff ff       	call   0 <printf>
 1fb:	83 c4 10             	add    $0x10,%esp
    semdown(full);
 1fe:	a1 20 0a 00 00       	mov    0xa20,%eax
 203:	83 ec 0c             	sub    $0xc,%esp
 206:	50                   	push   %eax
 207:	e8 17 04 00 00       	call   623 <semdown>
 20c:	83 c4 10             	add    $0x10,%esp
    // encolar(item);
    semup(empty);
 20f:	a1 d0 0b 00 00       	mov    0xbd0,%eax
 214:	83 ec 0c             	sub    $0xc,%esp
 217:	50                   	push   %eax
 218:	e8 0e 04 00 00       	call   62b <semup>
 21d:	83 c4 10             	add    $0x10,%esp
  }
 220:	eb c3                	jmp    1e5 <productor+0xd>

00000222 <semtest>:
}

void
semtest(void)
{
 222:	55                   	push   %ebp
 223:	89 e5                	mov    %esp,%ebp
 225:	83 ec 18             	sub    $0x18,%esp
  int i;
  int pid;
  for(i=0;i<CANTPRODUCTORES;i++){
 228:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 22f:	eb 26                	jmp    257 <semtest+0x35>

    pid=fork();
 231:	e8 25 03 00 00       	call   55b <fork>
 236:	89 45 f0             	mov    %eax,-0x10(%ebp)

    if(pid==0){
 239:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 23d:	75 14                	jne    253 <semtest+0x31>
      printf(1,"SOY PRODUCTOR\n" );
 23f:	83 ec 08             	sub    $0x8,%esp
 242:	68 be 07 00 00       	push   $0x7be
 247:	6a 01                	push   $0x1
 249:	e8 b2 fd ff ff       	call   0 <printf>
 24e:	83 c4 10             	add    $0x10,%esp
      break;
 251:	eb 0a                	jmp    25d <semtest+0x3b>
void
semtest(void)
{
  int i;
  int pid;
  for(i=0;i<CANTPRODUCTORES;i++){
 253:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 257:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 25b:	7e d4                	jle    231 <semtest+0xf>
      printf(1,"SOY PRODUCTOR\n" );
      break;
    }

  }
  if(pid==0){
 25d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 261:	75 05                	jne    268 <semtest+0x46>
    productor();
 263:	e8 70 ff ff ff       	call   1d8 <productor>
  }
  for(i=0;i<CANTCONSUMIDORES;i++){
 268:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 26f:	eb 26                	jmp    297 <semtest+0x75>
    pid=fork();
 271:	e8 e5 02 00 00       	call   55b <fork>
 276:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid==0){
 279:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 27d:	75 14                	jne    293 <semtest+0x71>
      printf(1,"SOY CONSUMIDOR\n" );
 27f:	83 ec 08             	sub    $0x8,%esp
 282:	68 cd 07 00 00       	push   $0x7cd
 287:	6a 01                	push   $0x1
 289:	e8 72 fd ff ff       	call   0 <printf>
 28e:	83 c4 10             	add    $0x10,%esp
      break;
 291:	eb 0a                	jmp    29d <semtest+0x7b>

  }
  if(pid==0){
    productor();
  }
  for(i=0;i<CANTCONSUMIDORES;i++){
 293:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 297:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 29b:	7e d4                	jle    271 <semtest+0x4f>
      printf(1,"SOY CONSUMIDOR\n" );
      break;
    }

  }
  if(pid==0){
 29d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2a1:	75 05                	jne    2a8 <semtest+0x86>
    consumidor();
 2a3:	e8 be fe ff ff       	call   166 <consumidor>
  }


}
 2a8:	90                   	nop
 2a9:	c9                   	leave  
 2aa:	c3                   	ret    

000002ab <main>:


int
main(void)
{
 2ab:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 2af:	83 e4 f0             	and    $0xfffffff0,%esp
 2b2:	ff 71 fc             	pushl  -0x4(%ecx)
 2b5:	55                   	push   %ebp
 2b6:	89 e5                	mov    %esp,%ebp
 2b8:	51                   	push   %ecx
 2b9:	83 ec 04             	sub    $0x4,%esp
  cantcola=0;
 2bc:	c7 05 24 0a 00 00 00 	movl   $0x0,0xa24
 2c3:	00 00 00 
  ql = semget(-1,1);
 2c6:	83 ec 08             	sub    $0x8,%esp
 2c9:	6a 01                	push   $0x1
 2cb:	6a ff                	push   $0xffffffff
 2cd:	e8 41 03 00 00       	call   613 <semget>
 2d2:	83 c4 10             	add    $0x10,%esp
 2d5:	a3 28 0a 00 00       	mov    %eax,0xa28
  empty= semget(-1,0);
 2da:	83 ec 08             	sub    $0x8,%esp
 2dd:	6a 00                	push   $0x0
 2df:	6a ff                	push   $0xffffffff
 2e1:	e8 2d 03 00 00       	call   613 <semget>
 2e6:	83 c4 10             	add    $0x10,%esp
 2e9:	a3 d0 0b 00 00       	mov    %eax,0xbd0
  full= semget(-1,N);
 2ee:	83 ec 08             	sub    $0x8,%esp
 2f1:	6a 64                	push   $0x64
 2f3:	6a ff                	push   $0xffffffff
 2f5:	e8 19 03 00 00       	call   613 <semget>
 2fa:	83 c4 10             	add    $0x10,%esp
 2fd:	a3 20 0a 00 00       	mov    %eax,0xa20
  semtest();
 302:	e8 1b ff ff ff       	call   222 <semtest>
  exit();
 307:	e8 57 02 00 00       	call   563 <exit>

0000030c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 30c:	55                   	push   %ebp
 30d:	89 e5                	mov    %esp,%ebp
 30f:	57                   	push   %edi
 310:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 311:	8b 4d 08             	mov    0x8(%ebp),%ecx
 314:	8b 55 10             	mov    0x10(%ebp),%edx
 317:	8b 45 0c             	mov    0xc(%ebp),%eax
 31a:	89 cb                	mov    %ecx,%ebx
 31c:	89 df                	mov    %ebx,%edi
 31e:	89 d1                	mov    %edx,%ecx
 320:	fc                   	cld    
 321:	f3 aa                	rep stos %al,%es:(%edi)
 323:	89 ca                	mov    %ecx,%edx
 325:	89 fb                	mov    %edi,%ebx
 327:	89 5d 08             	mov    %ebx,0x8(%ebp)
 32a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 32d:	90                   	nop
 32e:	5b                   	pop    %ebx
 32f:	5f                   	pop    %edi
 330:	5d                   	pop    %ebp
 331:	c3                   	ret    

00000332 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 33e:	90                   	nop
 33f:	8b 45 08             	mov    0x8(%ebp),%eax
 342:	8d 50 01             	lea    0x1(%eax),%edx
 345:	89 55 08             	mov    %edx,0x8(%ebp)
 348:	8b 55 0c             	mov    0xc(%ebp),%edx
 34b:	8d 4a 01             	lea    0x1(%edx),%ecx
 34e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 351:	0f b6 12             	movzbl (%edx),%edx
 354:	88 10                	mov    %dl,(%eax)
 356:	0f b6 00             	movzbl (%eax),%eax
 359:	84 c0                	test   %al,%al
 35b:	75 e2                	jne    33f <strcpy+0xd>
    ;
  return os;
 35d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 360:	c9                   	leave  
 361:	c3                   	ret    

00000362 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 362:	55                   	push   %ebp
 363:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 365:	eb 08                	jmp    36f <strcmp+0xd>
    p++, q++;
 367:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 36b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 36f:	8b 45 08             	mov    0x8(%ebp),%eax
 372:	0f b6 00             	movzbl (%eax),%eax
 375:	84 c0                	test   %al,%al
 377:	74 10                	je     389 <strcmp+0x27>
 379:	8b 45 08             	mov    0x8(%ebp),%eax
 37c:	0f b6 10             	movzbl (%eax),%edx
 37f:	8b 45 0c             	mov    0xc(%ebp),%eax
 382:	0f b6 00             	movzbl (%eax),%eax
 385:	38 c2                	cmp    %al,%dl
 387:	74 de                	je     367 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 389:	8b 45 08             	mov    0x8(%ebp),%eax
 38c:	0f b6 00             	movzbl (%eax),%eax
 38f:	0f b6 d0             	movzbl %al,%edx
 392:	8b 45 0c             	mov    0xc(%ebp),%eax
 395:	0f b6 00             	movzbl (%eax),%eax
 398:	0f b6 c0             	movzbl %al,%eax
 39b:	29 c2                	sub    %eax,%edx
 39d:	89 d0                	mov    %edx,%eax
}
 39f:	5d                   	pop    %ebp
 3a0:	c3                   	ret    

000003a1 <strlen>:

uint
strlen(char *s)
{
 3a1:	55                   	push   %ebp
 3a2:	89 e5                	mov    %esp,%ebp
 3a4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3a7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3ae:	eb 04                	jmp    3b4 <strlen+0x13>
 3b0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3b7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ba:	01 d0                	add    %edx,%eax
 3bc:	0f b6 00             	movzbl (%eax),%eax
 3bf:	84 c0                	test   %al,%al
 3c1:	75 ed                	jne    3b0 <strlen+0xf>
    ;
  return n;
 3c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3c6:	c9                   	leave  
 3c7:	c3                   	ret    

000003c8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3c8:	55                   	push   %ebp
 3c9:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3cb:	8b 45 10             	mov    0x10(%ebp),%eax
 3ce:	50                   	push   %eax
 3cf:	ff 75 0c             	pushl  0xc(%ebp)
 3d2:	ff 75 08             	pushl  0x8(%ebp)
 3d5:	e8 32 ff ff ff       	call   30c <stosb>
 3da:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3dd:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3e0:	c9                   	leave  
 3e1:	c3                   	ret    

000003e2 <strchr>:

char*
strchr(const char *s, char c)
{
 3e2:	55                   	push   %ebp
 3e3:	89 e5                	mov    %esp,%ebp
 3e5:	83 ec 04             	sub    $0x4,%esp
 3e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3eb:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3ee:	eb 14                	jmp    404 <strchr+0x22>
    if(*s == c)
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
 3f3:	0f b6 00             	movzbl (%eax),%eax
 3f6:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3f9:	75 05                	jne    400 <strchr+0x1e>
      return (char*)s;
 3fb:	8b 45 08             	mov    0x8(%ebp),%eax
 3fe:	eb 13                	jmp    413 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 400:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 404:	8b 45 08             	mov    0x8(%ebp),%eax
 407:	0f b6 00             	movzbl (%eax),%eax
 40a:	84 c0                	test   %al,%al
 40c:	75 e2                	jne    3f0 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 40e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 413:	c9                   	leave  
 414:	c3                   	ret    

00000415 <gets>:

char*
gets(char *buf, int max)
{
 415:	55                   	push   %ebp
 416:	89 e5                	mov    %esp,%ebp
 418:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 41b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 422:	eb 42                	jmp    466 <gets+0x51>
    cc = read(0, &c, 1);
 424:	83 ec 04             	sub    $0x4,%esp
 427:	6a 01                	push   $0x1
 429:	8d 45 ef             	lea    -0x11(%ebp),%eax
 42c:	50                   	push   %eax
 42d:	6a 00                	push   $0x0
 42f:	e8 47 01 00 00       	call   57b <read>
 434:	83 c4 10             	add    $0x10,%esp
 437:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 43a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 43e:	7e 33                	jle    473 <gets+0x5e>
      break;
    buf[i++] = c;
 440:	8b 45 f4             	mov    -0xc(%ebp),%eax
 443:	8d 50 01             	lea    0x1(%eax),%edx
 446:	89 55 f4             	mov    %edx,-0xc(%ebp)
 449:	89 c2                	mov    %eax,%edx
 44b:	8b 45 08             	mov    0x8(%ebp),%eax
 44e:	01 c2                	add    %eax,%edx
 450:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 454:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 456:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 45a:	3c 0a                	cmp    $0xa,%al
 45c:	74 16                	je     474 <gets+0x5f>
 45e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 462:	3c 0d                	cmp    $0xd,%al
 464:	74 0e                	je     474 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 466:	8b 45 f4             	mov    -0xc(%ebp),%eax
 469:	83 c0 01             	add    $0x1,%eax
 46c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 46f:	7c b3                	jl     424 <gets+0xf>
 471:	eb 01                	jmp    474 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 473:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 474:	8b 55 f4             	mov    -0xc(%ebp),%edx
 477:	8b 45 08             	mov    0x8(%ebp),%eax
 47a:	01 d0                	add    %edx,%eax
 47c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 47f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 482:	c9                   	leave  
 483:	c3                   	ret    

00000484 <stat>:

int
stat(char *n, struct stat *st)
{
 484:	55                   	push   %ebp
 485:	89 e5                	mov    %esp,%ebp
 487:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 48a:	83 ec 08             	sub    $0x8,%esp
 48d:	6a 00                	push   $0x0
 48f:	ff 75 08             	pushl  0x8(%ebp)
 492:	e8 0c 01 00 00       	call   5a3 <open>
 497:	83 c4 10             	add    $0x10,%esp
 49a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 49d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4a1:	79 07                	jns    4aa <stat+0x26>
    return -1;
 4a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4a8:	eb 25                	jmp    4cf <stat+0x4b>
  r = fstat(fd, st);
 4aa:	83 ec 08             	sub    $0x8,%esp
 4ad:	ff 75 0c             	pushl  0xc(%ebp)
 4b0:	ff 75 f4             	pushl  -0xc(%ebp)
 4b3:	e8 03 01 00 00       	call   5bb <fstat>
 4b8:	83 c4 10             	add    $0x10,%esp
 4bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4be:	83 ec 0c             	sub    $0xc,%esp
 4c1:	ff 75 f4             	pushl  -0xc(%ebp)
 4c4:	e8 c2 00 00 00       	call   58b <close>
 4c9:	83 c4 10             	add    $0x10,%esp
  return r;
 4cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4cf:	c9                   	leave  
 4d0:	c3                   	ret    

000004d1 <atoi>:

int
atoi(const char *s)
{
 4d1:	55                   	push   %ebp
 4d2:	89 e5                	mov    %esp,%ebp
 4d4:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4d7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4de:	eb 25                	jmp    505 <atoi+0x34>
    n = n*10 + *s++ - '0';
 4e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4e3:	89 d0                	mov    %edx,%eax
 4e5:	c1 e0 02             	shl    $0x2,%eax
 4e8:	01 d0                	add    %edx,%eax
 4ea:	01 c0                	add    %eax,%eax
 4ec:	89 c1                	mov    %eax,%ecx
 4ee:	8b 45 08             	mov    0x8(%ebp),%eax
 4f1:	8d 50 01             	lea    0x1(%eax),%edx
 4f4:	89 55 08             	mov    %edx,0x8(%ebp)
 4f7:	0f b6 00             	movzbl (%eax),%eax
 4fa:	0f be c0             	movsbl %al,%eax
 4fd:	01 c8                	add    %ecx,%eax
 4ff:	83 e8 30             	sub    $0x30,%eax
 502:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 505:	8b 45 08             	mov    0x8(%ebp),%eax
 508:	0f b6 00             	movzbl (%eax),%eax
 50b:	3c 2f                	cmp    $0x2f,%al
 50d:	7e 0a                	jle    519 <atoi+0x48>
 50f:	8b 45 08             	mov    0x8(%ebp),%eax
 512:	0f b6 00             	movzbl (%eax),%eax
 515:	3c 39                	cmp    $0x39,%al
 517:	7e c7                	jle    4e0 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 519:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 51c:	c9                   	leave  
 51d:	c3                   	ret    

0000051e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 51e:	55                   	push   %ebp
 51f:	89 e5                	mov    %esp,%ebp
 521:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 52a:	8b 45 0c             	mov    0xc(%ebp),%eax
 52d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 530:	eb 17                	jmp    549 <memmove+0x2b>
    *dst++ = *src++;
 532:	8b 45 fc             	mov    -0x4(%ebp),%eax
 535:	8d 50 01             	lea    0x1(%eax),%edx
 538:	89 55 fc             	mov    %edx,-0x4(%ebp)
 53b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 53e:	8d 4a 01             	lea    0x1(%edx),%ecx
 541:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 544:	0f b6 12             	movzbl (%edx),%edx
 547:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 549:	8b 45 10             	mov    0x10(%ebp),%eax
 54c:	8d 50 ff             	lea    -0x1(%eax),%edx
 54f:	89 55 10             	mov    %edx,0x10(%ebp)
 552:	85 c0                	test   %eax,%eax
 554:	7f dc                	jg     532 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 556:	8b 45 08             	mov    0x8(%ebp),%eax
}
 559:	c9                   	leave  
 55a:	c3                   	ret    

0000055b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 55b:	b8 01 00 00 00       	mov    $0x1,%eax
 560:	cd 40                	int    $0x40
 562:	c3                   	ret    

00000563 <exit>:
SYSCALL(exit)
 563:	b8 02 00 00 00       	mov    $0x2,%eax
 568:	cd 40                	int    $0x40
 56a:	c3                   	ret    

0000056b <wait>:
SYSCALL(wait)
 56b:	b8 03 00 00 00       	mov    $0x3,%eax
 570:	cd 40                	int    $0x40
 572:	c3                   	ret    

00000573 <pipe>:
SYSCALL(pipe)
 573:	b8 04 00 00 00       	mov    $0x4,%eax
 578:	cd 40                	int    $0x40
 57a:	c3                   	ret    

0000057b <read>:
SYSCALL(read)
 57b:	b8 05 00 00 00       	mov    $0x5,%eax
 580:	cd 40                	int    $0x40
 582:	c3                   	ret    

00000583 <write>:
SYSCALL(write)
 583:	b8 10 00 00 00       	mov    $0x10,%eax
 588:	cd 40                	int    $0x40
 58a:	c3                   	ret    

0000058b <close>:
SYSCALL(close)
 58b:	b8 15 00 00 00       	mov    $0x15,%eax
 590:	cd 40                	int    $0x40
 592:	c3                   	ret    

00000593 <kill>:
SYSCALL(kill)
 593:	b8 06 00 00 00       	mov    $0x6,%eax
 598:	cd 40                	int    $0x40
 59a:	c3                   	ret    

0000059b <exec>:
SYSCALL(exec)
 59b:	b8 07 00 00 00       	mov    $0x7,%eax
 5a0:	cd 40                	int    $0x40
 5a2:	c3                   	ret    

000005a3 <open>:
SYSCALL(open)
 5a3:	b8 0f 00 00 00       	mov    $0xf,%eax
 5a8:	cd 40                	int    $0x40
 5aa:	c3                   	ret    

000005ab <mknod>:
SYSCALL(mknod)
 5ab:	b8 11 00 00 00       	mov    $0x11,%eax
 5b0:	cd 40                	int    $0x40
 5b2:	c3                   	ret    

000005b3 <unlink>:
SYSCALL(unlink)
 5b3:	b8 12 00 00 00       	mov    $0x12,%eax
 5b8:	cd 40                	int    $0x40
 5ba:	c3                   	ret    

000005bb <fstat>:
SYSCALL(fstat)
 5bb:	b8 08 00 00 00       	mov    $0x8,%eax
 5c0:	cd 40                	int    $0x40
 5c2:	c3                   	ret    

000005c3 <link>:
SYSCALL(link)
 5c3:	b8 13 00 00 00       	mov    $0x13,%eax
 5c8:	cd 40                	int    $0x40
 5ca:	c3                   	ret    

000005cb <mkdir>:
SYSCALL(mkdir)
 5cb:	b8 14 00 00 00       	mov    $0x14,%eax
 5d0:	cd 40                	int    $0x40
 5d2:	c3                   	ret    

000005d3 <chdir>:
SYSCALL(chdir)
 5d3:	b8 09 00 00 00       	mov    $0x9,%eax
 5d8:	cd 40                	int    $0x40
 5da:	c3                   	ret    

000005db <dup>:
SYSCALL(dup)
 5db:	b8 0a 00 00 00       	mov    $0xa,%eax
 5e0:	cd 40                	int    $0x40
 5e2:	c3                   	ret    

000005e3 <getpid>:
SYSCALL(getpid)
 5e3:	b8 0b 00 00 00       	mov    $0xb,%eax
 5e8:	cd 40                	int    $0x40
 5ea:	c3                   	ret    

000005eb <sbrk>:
SYSCALL(sbrk)
 5eb:	b8 0c 00 00 00       	mov    $0xc,%eax
 5f0:	cd 40                	int    $0x40
 5f2:	c3                   	ret    

000005f3 <sleep>:
SYSCALL(sleep)
 5f3:	b8 0d 00 00 00       	mov    $0xd,%eax
 5f8:	cd 40                	int    $0x40
 5fa:	c3                   	ret    

000005fb <uptime>:
SYSCALL(uptime)
 5fb:	b8 0e 00 00 00       	mov    $0xe,%eax
 600:	cd 40                	int    $0x40
 602:	c3                   	ret    

00000603 <procstat>:
SYSCALL(procstat)
 603:	b8 16 00 00 00       	mov    $0x16,%eax
 608:	cd 40                	int    $0x40
 60a:	c3                   	ret    

0000060b <setpriority>:
SYSCALL(setpriority)
 60b:	b8 17 00 00 00       	mov    $0x17,%eax
 610:	cd 40                	int    $0x40
 612:	c3                   	ret    

00000613 <semget>:
SYSCALL(semget)
 613:	b8 18 00 00 00       	mov    $0x18,%eax
 618:	cd 40                	int    $0x40
 61a:	c3                   	ret    

0000061b <semfree>:
SYSCALL(semfree)
 61b:	b8 19 00 00 00       	mov    $0x19,%eax
 620:	cd 40                	int    $0x40
 622:	c3                   	ret    

00000623 <semdown>:
SYSCALL(semdown)
 623:	b8 1a 00 00 00       	mov    $0x1a,%eax
 628:	cd 40                	int    $0x40
 62a:	c3                   	ret    

0000062b <semup>:
SYSCALL(semup)
 62b:	b8 1b 00 00 00       	mov    $0x1b,%eax
 630:	cd 40                	int    $0x40
 632:	c3                   	ret    
