
kernel:     formato del fichero elf32-i386


Desensamblado de la sección .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 04 38 10 80       	mov    $0x80103804,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 68 8f 10 80       	push   $0x80108f68
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 6e 57 00 00       	call   801057ba <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 15 11 80       	mov    0x80111594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 15 11 80       	mov    $0x80111584,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 80 d6 10 80       	push   $0x8010d680
801000c1:	e8 16 57 00 00       	call   801057dc <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 15 11 80       	mov    0x80111594,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->sector == sector){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 80 d6 10 80       	push   $0x8010d680
8010010c:	e8 32 57 00 00       	call   80105843 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 59 4d 00 00       	call   80104e85 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 15 11 80       	mov    0x80111590,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 80 d6 10 80       	push   $0x8010d680
80100188:	e8 b6 56 00 00       	call   80105843 <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 6f 8f 10 80       	push   $0x80108f6f
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, sector);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 93 26 00 00       	call   8010287a <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 80 8f 10 80       	push   $0x80108f80
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 52 26 00 00       	call   8010287a <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 87 8f 10 80       	push   $0x80108f87
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 82 55 00 00       	call   801057dc <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 15 11 80       	mov    0x80111594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 15 11 80       	mov    %eax,0x80111594

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 dc 4c 00 00       	call   80104f9a <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 75 55 00 00       	call   80105843 <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 c3 03 00 00       	call   80100776 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 c5 10 80       	push   $0x8010c5e0
801003e2:	e8 f5 53 00 00       	call   801057dc <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 8e 8f 10 80       	push   $0x80108f8e
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 55 03 00 00       	call   80100776 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec 97 8f 10 80 	movl   $0x80108f97,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 8e 02 00 00       	call   80100776 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 71 02 00 00       	call   80100776 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 62 02 00 00       	call   80100776 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 54 02 00 00       	call   80100776 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 e0 c5 10 80       	push   $0x8010c5e0
8010055b:	e8 e3 52 00 00       	call   80105843 <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 9e 8f 10 80       	push   $0x80108f9e
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 ad 8f 10 80       	push   $0x80108fad
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 ce 52 00 00       	call   80105895 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 af 8f 10 80       	push   $0x80108faf
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)
  
  if((pos/80) >= 24){  // Scroll up.
801006b8:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006bf:	7e 4c                	jle    8010070d <cgaputc+0x10c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006c1:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006c6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006cc:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006d1:	83 ec 04             	sub    $0x4,%esp
801006d4:	68 60 0e 00 00       	push   $0xe60
801006d9:	52                   	push   %edx
801006da:	50                   	push   %eax
801006db:	e8 1e 54 00 00       	call   80105afe <memmove>
801006e0:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006e3:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e7:	b8 80 07 00 00       	mov    $0x780,%eax
801006ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ef:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006f2:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006f7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fa:	01 c9                	add    %ecx,%ecx
801006fc:	01 c8                	add    %ecx,%eax
801006fe:	83 ec 04             	sub    $0x4,%esp
80100701:	52                   	push   %edx
80100702:	6a 00                	push   $0x0
80100704:	50                   	push   %eax
80100705:	e8 35 53 00 00       	call   80105a3f <memset>
8010070a:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
8010070d:	83 ec 08             	sub    $0x8,%esp
80100710:	6a 0e                	push   $0xe
80100712:	68 d4 03 00 00       	push   $0x3d4
80100717:	e8 d5 fb ff ff       	call   801002f1 <outb>
8010071c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100722:	c1 f8 08             	sar    $0x8,%eax
80100725:	0f b6 c0             	movzbl %al,%eax
80100728:	83 ec 08             	sub    $0x8,%esp
8010072b:	50                   	push   %eax
8010072c:	68 d5 03 00 00       	push   $0x3d5
80100731:	e8 bb fb ff ff       	call   801002f1 <outb>
80100736:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100739:	83 ec 08             	sub    $0x8,%esp
8010073c:	6a 0f                	push   $0xf
8010073e:	68 d4 03 00 00       	push   $0x3d4
80100743:	e8 a9 fb ff ff       	call   801002f1 <outb>
80100748:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010074e:	0f b6 c0             	movzbl %al,%eax
80100751:	83 ec 08             	sub    $0x8,%esp
80100754:	50                   	push   %eax
80100755:	68 d5 03 00 00       	push   $0x3d5
8010075a:	e8 92 fb ff ff       	call   801002f1 <outb>
8010075f:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100762:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100767:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010076a:	01 d2                	add    %edx,%edx
8010076c:	01 d0                	add    %edx,%eax
8010076e:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100773:	90                   	nop
80100774:	c9                   	leave  
80100775:	c3                   	ret    

80100776 <consputc>:

void
consputc(int c)
{
80100776:	55                   	push   %ebp
80100777:	89 e5                	mov    %esp,%ebp
80100779:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010077c:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
80100781:	85 c0                	test   %eax,%eax
80100783:	74 07                	je     8010078c <consputc+0x16>
    cli();
80100785:	e8 86 fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
8010078a:	eb fe                	jmp    8010078a <consputc+0x14>
  }

  if(c == BACKSPACE){
8010078c:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100793:	75 29                	jne    801007be <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100795:	83 ec 0c             	sub    $0xc,%esp
80100798:	6a 08                	push   $0x8
8010079a:	e8 5b 6e 00 00       	call   801075fa <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 4e 6e 00 00       	call   801075fa <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 41 6e 00 00       	call   801075fa <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 31 6e 00 00       	call   801075fa <uartputc>
801007c9:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007cc:	83 ec 0c             	sub    $0xc,%esp
801007cf:	ff 75 08             	pushl  0x8(%ebp)
801007d2:	e8 2a fe ff ff       	call   80100601 <cgaputc>
801007d7:	83 c4 10             	add    $0x10,%esp
}
801007da:	90                   	nop
801007db:	c9                   	leave  
801007dc:	c3                   	ret    

801007dd <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007dd:	55                   	push   %ebp
801007de:	89 e5                	mov    %esp,%ebp
801007e0:	83 ec 18             	sub    $0x18,%esp
  int c;

  acquire(&input.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 a0 17 11 80       	push   $0x801117a0
801007eb:	e8 ec 4f 00 00       	call   801057dc <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 42 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    switch(c){
801007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007fb:	83 f8 10             	cmp    $0x10,%eax
801007fe:	74 1e                	je     8010081e <consoleintr+0x41>
80100800:	83 f8 10             	cmp    $0x10,%eax
80100803:	7f 0a                	jg     8010080f <consoleintr+0x32>
80100805:	83 f8 08             	cmp    $0x8,%eax
80100808:	74 69                	je     80100873 <consoleintr+0x96>
8010080a:	e9 99 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
8010080f:	83 f8 15             	cmp    $0x15,%eax
80100812:	74 31                	je     80100845 <consoleintr+0x68>
80100814:	83 f8 7f             	cmp    $0x7f,%eax
80100817:	74 5a                	je     80100873 <consoleintr+0x96>
80100819:	e9 8a 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
    case C('P'):  // Process listing.
      procdump();
8010081e:	e8 39 48 00 00       	call   8010505c <procdump>
      break;
80100823:	e9 12 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100828:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010082d:	83 e8 01             	sub    $0x1,%eax
80100830:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
80100835:	83 ec 0c             	sub    $0xc,%esp
80100838:	68 00 01 00 00       	push   $0x100
8010083d:	e8 34 ff ff ff       	call   80100776 <consputc>
80100842:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100845:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
8010084b:	a1 58 18 11 80       	mov    0x80111858,%eax
80100850:	39 c2                	cmp    %eax,%edx
80100852:	0f 84 e2 00 00 00    	je     8010093a <consoleintr+0x15d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100858:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010085d:	83 e8 01             	sub    $0x1,%eax
80100860:	83 e0 7f             	and    $0x7f,%eax
80100863:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	3c 0a                	cmp    $0xa,%al
8010086c:	75 ba                	jne    80100828 <consoleintr+0x4b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010086e:	e9 c7 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100873:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100879:	a1 58 18 11 80       	mov    0x80111858,%eax
8010087e:	39 c2                	cmp    %eax,%edx
80100880:	0f 84 b4 00 00 00    	je     8010093a <consoleintr+0x15d>
        input.e--;
80100886:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010088b:	83 e8 01             	sub    $0x1,%eax
8010088e:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
80100893:	83 ec 0c             	sub    $0xc,%esp
80100896:	68 00 01 00 00       	push   $0x100
8010089b:	e8 d6 fe ff ff       	call   80100776 <consputc>
801008a0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008a3:	e9 92 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801008ac:	0f 84 87 00 00 00    	je     80100939 <consoleintr+0x15c>
801008b2:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
801008b8:	a1 54 18 11 80       	mov    0x80111854,%eax
801008bd:	29 c2                	sub    %eax,%edx
801008bf:	89 d0                	mov    %edx,%eax
801008c1:	83 f8 7f             	cmp    $0x7f,%eax
801008c4:	77 73                	ja     80100939 <consoleintr+0x15c>
        c = (c == '\r') ? '\n' : c;
801008c6:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008ca:	74 05                	je     801008d1 <consoleintr+0xf4>
801008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008cf:	eb 05                	jmp    801008d6 <consoleintr+0xf9>
801008d1:	b8 0a 00 00 00       	mov    $0xa,%eax
801008d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008d9:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008de:	8d 50 01             	lea    0x1(%eax),%edx
801008e1:	89 15 5c 18 11 80    	mov    %edx,0x8011185c
801008e7:	83 e0 7f             	and    $0x7f,%eax
801008ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008ed:	88 90 d4 17 11 80    	mov    %dl,-0x7feee82c(%eax)
        consputc(c);
801008f3:	83 ec 0c             	sub    $0xc,%esp
801008f6:	ff 75 f4             	pushl  -0xc(%ebp)
801008f9:	e8 78 fe ff ff       	call   80100776 <consputc>
801008fe:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100901:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80100905:	74 18                	je     8010091f <consoleintr+0x142>
80100907:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010090b:	74 12                	je     8010091f <consoleintr+0x142>
8010090d:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100912:	8b 15 54 18 11 80    	mov    0x80111854,%edx
80100918:	83 ea 80             	sub    $0xffffff80,%edx
8010091b:	39 d0                	cmp    %edx,%eax
8010091d:	75 1a                	jne    80100939 <consoleintr+0x15c>
          input.w = input.e;
8010091f:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100924:	a3 58 18 11 80       	mov    %eax,0x80111858
          wakeup(&input.r);
80100929:	83 ec 0c             	sub    $0xc,%esp
8010092c:	68 54 18 11 80       	push   $0x80111854
80100931:	e8 64 46 00 00       	call   80104f9a <wakeup>
80100936:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100939:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
8010093a:	8b 45 08             	mov    0x8(%ebp),%eax
8010093d:	ff d0                	call   *%eax
8010093f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100942:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100946:	0f 89 ac fe ff ff    	jns    801007f8 <consoleintr+0x1b>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010094c:	83 ec 0c             	sub    $0xc,%esp
8010094f:	68 a0 17 11 80       	push   $0x801117a0
80100954:	e8 ea 4e 00 00       	call   80105843 <release>
80100959:	83 c4 10             	add    $0x10,%esp
}
8010095c:	90                   	nop
8010095d:	c9                   	leave  
8010095e:	c3                   	ret    

8010095f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010095f:	55                   	push   %ebp
80100960:	89 e5                	mov    %esp,%ebp
80100962:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100965:	83 ec 0c             	sub    $0xc,%esp
80100968:	ff 75 08             	pushl  0x8(%ebp)
8010096b:	e8 01 11 00 00       	call   80101a71 <iunlock>
80100970:	83 c4 10             	add    $0x10,%esp
  target = n;
80100973:	8b 45 10             	mov    0x10(%ebp),%eax
80100976:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 a0 17 11 80       	push   $0x801117a0
80100981:	e8 56 4e 00 00       	call   801057dc <acquire>
80100986:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100989:	e9 ac 00 00 00       	jmp    80100a3a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
8010098e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100994:	8b 40 24             	mov    0x24(%eax),%eax
80100997:	85 c0                	test   %eax,%eax
80100999:	74 28                	je     801009c3 <consoleread+0x64>
        release(&input.lock);
8010099b:	83 ec 0c             	sub    $0xc,%esp
8010099e:	68 a0 17 11 80       	push   $0x801117a0
801009a3:	e8 9b 4e 00 00       	call   80105843 <release>
801009a8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009ab:	83 ec 0c             	sub    $0xc,%esp
801009ae:	ff 75 08             	pushl  0x8(%ebp)
801009b1:	e8 63 0f 00 00       	call   80101919 <ilock>
801009b6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009be:	e9 ab 00 00 00       	jmp    80100a6e <consoleread+0x10f>
      }
      sleep(&input.r, &input.lock);
801009c3:	83 ec 08             	sub    $0x8,%esp
801009c6:	68 a0 17 11 80       	push   $0x801117a0
801009cb:	68 54 18 11 80       	push   $0x80111854
801009d0:	e8 b0 44 00 00       	call   80104e85 <sleep>
801009d5:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009d8:	8b 15 54 18 11 80    	mov    0x80111854,%edx
801009de:	a1 58 18 11 80       	mov    0x80111858,%eax
801009e3:	39 c2                	cmp    %eax,%edx
801009e5:	74 a7                	je     8010098e <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009e7:	a1 54 18 11 80       	mov    0x80111854,%eax
801009ec:	8d 50 01             	lea    0x1(%eax),%edx
801009ef:	89 15 54 18 11 80    	mov    %edx,0x80111854
801009f5:	83 e0 7f             	and    $0x7f,%eax
801009f8:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
801009ff:	0f be c0             	movsbl %al,%eax
80100a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a05:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a09:	75 17                	jne    80100a22 <consoleread+0xc3>
      if(n < target){
80100a0b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a0e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a11:	73 2f                	jae    80100a42 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a13:	a1 54 18 11 80       	mov    0x80111854,%eax
80100a18:	83 e8 01             	sub    $0x1,%eax
80100a1b:	a3 54 18 11 80       	mov    %eax,0x80111854
      }
      break;
80100a20:	eb 20                	jmp    80100a42 <consoleread+0xe3>
    }
    *dst++ = c;
80100a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a25:	8d 50 01             	lea    0x1(%eax),%edx
80100a28:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a2e:	88 10                	mov    %dl,(%eax)
    --n;
80100a30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a34:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a38:	74 0b                	je     80100a45 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a3e:	7f 98                	jg     801009d8 <consoleread+0x79>
80100a40:	eb 04                	jmp    80100a46 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a42:	90                   	nop
80100a43:	eb 01                	jmp    80100a46 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a45:	90                   	nop
  }
  release(&input.lock);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	68 a0 17 11 80       	push   $0x801117a0
80100a4e:	e8 f0 4d 00 00       	call   80105843 <release>
80100a53:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a56:	83 ec 0c             	sub    $0xc,%esp
80100a59:	ff 75 08             	pushl  0x8(%ebp)
80100a5c:	e8 b8 0e 00 00       	call   80101919 <ilock>
80100a61:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a64:	8b 45 10             	mov    0x10(%ebp),%eax
80100a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a6a:	29 c2                	sub    %eax,%edx
80100a6c:	89 d0                	mov    %edx,%eax
}
80100a6e:	c9                   	leave  
80100a6f:	c3                   	ret    

80100a70 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a70:	55                   	push   %ebp
80100a71:	89 e5                	mov    %esp,%ebp
80100a73:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	pushl  0x8(%ebp)
80100a7c:	e8 f0 0f 00 00       	call   80101a71 <iunlock>
80100a81:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a84:	83 ec 0c             	sub    $0xc,%esp
80100a87:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a8c:	e8 4b 4d 00 00       	call   801057dc <acquire>
80100a91:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a9b:	eb 21                	jmp    80100abe <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aa3:	01 d0                	add    %edx,%eax
80100aa5:	0f b6 00             	movzbl (%eax),%eax
80100aa8:	0f be c0             	movsbl %al,%eax
80100aab:	0f b6 c0             	movzbl %al,%eax
80100aae:	83 ec 0c             	sub    $0xc,%esp
80100ab1:	50                   	push   %eax
80100ab2:	e8 bf fc ff ff       	call   80100776 <consputc>
80100ab7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ac1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ac4:	7c d7                	jl     80100a9d <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	68 e0 c5 10 80       	push   $0x8010c5e0
80100ace:	e8 70 4d 00 00       	call   80105843 <release>
80100ad3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad6:	83 ec 0c             	sub    $0xc,%esp
80100ad9:	ff 75 08             	pushl  0x8(%ebp)
80100adc:	e8 38 0e 00 00       	call   80101919 <ilock>
80100ae1:	83 c4 10             	add    $0x10,%esp

  return n;
80100ae4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ae7:	c9                   	leave  
80100ae8:	c3                   	ret    

80100ae9 <consoleinit>:

void
consoleinit(void)
{
80100ae9:	55                   	push   %ebp
80100aea:	89 e5                	mov    %esp,%ebp
80100aec:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100aef:	83 ec 08             	sub    $0x8,%esp
80100af2:	68 b3 8f 10 80       	push   $0x80108fb3
80100af7:	68 e0 c5 10 80       	push   $0x8010c5e0
80100afc:	e8 b9 4c 00 00       	call   801057ba <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 bb 8f 10 80       	push   $0x80108fbb
80100b0c:	68 a0 17 11 80       	push   $0x801117a0
80100b11:	e8 a4 4c 00 00       	call   801057ba <initlock>
80100b16:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b19:	c7 05 0c 22 11 80 70 	movl   $0x80100a70,0x8011220c
80100b20:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b23:	c7 05 08 22 11 80 5f 	movl   $0x8010095f,0x80112208
80100b2a:	09 10 80 
  cons.locking = 1;
80100b2d:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100b34:	00 00 00 

  picenable(IRQ_KBD);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	6a 01                	push   $0x1
80100b3c:	e8 69 33 00 00       	call   80103eaa <picenable>
80100b41:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b44:	83 ec 08             	sub    $0x8,%esp
80100b47:	6a 00                	push   $0x0
80100b49:	6a 01                	push   $0x1
80100b4b:	e8 f7 1e 00 00       	call   80102a47 <ioapicenable>
80100b50:	83 c4 10             	add    $0x10,%esp
}
80100b53:	90                   	nop
80100b54:	c9                   	leave  
80100b55:	c3                   	ret    

80100b56 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b56:	55                   	push   %ebp
80100b57:	89 e5                	mov    %esp,%ebp
80100b59:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b5f:	e8 5e 29 00 00       	call   801034c2 <begin_op>
  if((ip = namei(path)) == 0){
80100b64:	83 ec 0c             	sub    $0xc,%esp
80100b67:	ff 75 08             	pushl  0x8(%ebp)
80100b6a:	e8 62 19 00 00       	call   801024d1 <namei>
80100b6f:	83 c4 10             	add    $0x10,%esp
80100b72:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b75:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b79:	75 0f                	jne    80100b8a <exec+0x34>
    end_op();
80100b7b:	e8 ce 29 00 00       	call   8010354e <end_op>
    return -1;
80100b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b85:	e9 dc 03 00 00       	jmp    80100f66 <exec+0x410>
  }
  ilock(ip);
80100b8a:	83 ec 0c             	sub    $0xc,%esp
80100b8d:	ff 75 d8             	pushl  -0x28(%ebp)
80100b90:	e8 84 0d 00 00       	call   80101919 <ilock>
80100b95:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100b98:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b9f:	6a 34                	push   $0x34
80100ba1:	6a 00                	push   $0x0
80100ba3:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100ba9:	50                   	push   %eax
80100baa:	ff 75 d8             	pushl  -0x28(%ebp)
80100bad:	e8 cf 12 00 00       	call   80101e81 <readi>
80100bb2:	83 c4 10             	add    $0x10,%esp
80100bb5:	83 f8 33             	cmp    $0x33,%eax
80100bb8:	0f 86 57 03 00 00    	jbe    80100f15 <exec+0x3bf>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bbe:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100bc4:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bc9:	0f 85 49 03 00 00    	jne    80100f18 <exec+0x3c2>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bcf:	e8 7b 7b 00 00       	call   8010874f <setupkvm>
80100bd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bd7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bdb:	0f 84 3a 03 00 00    	je     80100f1b <exec+0x3c5>
    goto bad;

  // Load program into memory.
  sz = 0;
80100be1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100be8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bef:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100bf5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bf8:	e9 ab 00 00 00       	jmp    80100ca8 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c00:	6a 20                	push   $0x20
80100c02:	50                   	push   %eax
80100c03:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c09:	50                   	push   %eax
80100c0a:	ff 75 d8             	pushl  -0x28(%ebp)
80100c0d:	e8 6f 12 00 00       	call   80101e81 <readi>
80100c12:	83 c4 10             	add    $0x10,%esp
80100c15:	83 f8 20             	cmp    $0x20,%eax
80100c18:	0f 85 00 03 00 00    	jne    80100f1e <exec+0x3c8>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c1e:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c24:	83 f8 01             	cmp    $0x1,%eax
80100c27:	75 71                	jne    80100c9a <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c29:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c2f:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c35:	39 c2                	cmp    %eax,%edx
80100c37:	0f 82 e4 02 00 00    	jb     80100f21 <exec+0x3cb>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c3d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c43:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c49:	01 d0                	add    %edx,%eax
80100c4b:	83 ec 04             	sub    $0x4,%esp
80100c4e:	50                   	push   %eax
80100c4f:	ff 75 e0             	pushl  -0x20(%ebp)
80100c52:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c55:	e8 9c 7e 00 00       	call   80108af6 <allocuvm>
80100c5a:	83 c4 10             	add    $0x10,%esp
80100c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c64:	0f 84 ba 02 00 00    	je     80100f24 <exec+0x3ce>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c6a:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100c70:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c76:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100c7c:	83 ec 0c             	sub    $0xc,%esp
80100c7f:	52                   	push   %edx
80100c80:	50                   	push   %eax
80100c81:	ff 75 d8             	pushl  -0x28(%ebp)
80100c84:	51                   	push   %ecx
80100c85:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c88:	e8 92 7d 00 00       	call   80108a1f <loaduvm>
80100c8d:	83 c4 20             	add    $0x20,%esp
80100c90:	85 c0                	test   %eax,%eax
80100c92:	0f 88 8f 02 00 00    	js     80100f27 <exec+0x3d1>
80100c98:	eb 01                	jmp    80100c9b <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c9a:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c9b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ca2:	83 c0 20             	add    $0x20,%eax
80100ca5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ca8:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100caf:	0f b7 c0             	movzwl %ax,%eax
80100cb2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cb5:	0f 8f 42 ff ff ff    	jg     80100bfd <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cbb:	83 ec 0c             	sub    $0xc,%esp
80100cbe:	ff 75 d8             	pushl  -0x28(%ebp)
80100cc1:	e8 0d 0f 00 00       	call   80101bd3 <iunlockput>
80100cc6:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cc9:	e8 80 28 00 00       	call   8010354e <end_op>
  ip = 0;
80100cce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz+PGSIZE);
80100cd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd8:	05 ff 1f 00 00       	add    $0x1fff,%eax
80100cdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ce2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  topstack=sz;
80100ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ce8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  sz = PGROUNDUP(sz+(MAXSTACKPAGES-1)*PGSIZE);
80100ceb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cee:	05 ff 4f 00 00       	add    $0x4fff,%eax
80100cf3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cf8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
80100cfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cfe:	05 00 10 00 00       	add    $0x1000,%eax
80100d03:	83 ec 04             	sub    $0x4,%esp
80100d06:	50                   	push   %eax
80100d07:	ff 75 e0             	pushl  -0x20(%ebp)
80100d0a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d0d:	e8 e4 7d 00 00       	call   80108af6 <allocuvm>
80100d12:	83 c4 10             	add    $0x10,%esp
80100d15:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d18:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d1c:	0f 84 08 02 00 00    	je     80100f2a <exec+0x3d4>
    goto bad;
  //clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;
80100d22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d25:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d28:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d2f:	e9 96 00 00 00       	jmp    80100dca <exec+0x274>
    if(argc >= MAXARG)
80100d34:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d38:	0f 87 ef 01 00 00    	ja     80100f2d <exec+0x3d7>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d48:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d4b:	01 d0                	add    %edx,%eax
80100d4d:	8b 00                	mov    (%eax),%eax
80100d4f:	83 ec 0c             	sub    $0xc,%esp
80100d52:	50                   	push   %eax
80100d53:	e8 34 4f 00 00       	call   80105c8c <strlen>
80100d58:	83 c4 10             	add    $0x10,%esp
80100d5b:	89 c2                	mov    %eax,%edx
80100d5d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d60:	29 d0                	sub    %edx,%eax
80100d62:	83 e8 01             	sub    $0x1,%eax
80100d65:	83 e0 fc             	and    $0xfffffffc,%eax
80100d68:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d75:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d78:	01 d0                	add    %edx,%eax
80100d7a:	8b 00                	mov    (%eax),%eax
80100d7c:	83 ec 0c             	sub    $0xc,%esp
80100d7f:	50                   	push   %eax
80100d80:	e8 07 4f 00 00       	call   80105c8c <strlen>
80100d85:	83 c4 10             	add    $0x10,%esp
80100d88:	83 c0 01             	add    $0x1,%eax
80100d8b:	89 c1                	mov    %eax,%ecx
80100d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d97:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d9a:	01 d0                	add    %edx,%eax
80100d9c:	8b 00                	mov    (%eax),%eax
80100d9e:	51                   	push   %ecx
80100d9f:	50                   	push   %eax
80100da0:	ff 75 dc             	pushl  -0x24(%ebp)
80100da3:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da6:	e8 1e 81 00 00       	call   80108ec9 <copyout>
80100dab:	83 c4 10             	add    $0x10,%esp
80100dae:	85 c0                	test   %eax,%eax
80100db0:	0f 88 7a 01 00 00    	js     80100f30 <exec+0x3da>
      goto bad;
    ustack[3+argc] = sp;
80100db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db9:	8d 50 03             	lea    0x3(%eax),%edx
80100dbc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dbf:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  //clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dc6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dd7:	01 d0                	add    %edx,%eax
80100dd9:	8b 00                	mov    (%eax),%eax
80100ddb:	85 c0                	test   %eax,%eax
80100ddd:	0f 85 51 ff ff ff    	jne    80100d34 <exec+0x1de>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100de3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de6:	83 c0 03             	add    $0x3,%eax
80100de9:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100df0:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100df4:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100dfb:	ff ff ff 
  ustack[1] = argc;
80100dfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e01:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0a:	83 c0 01             	add    $0x1,%eax
80100e0d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e14:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e17:	29 d0                	sub    %edx,%eax
80100e19:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e22:	83 c0 04             	add    $0x4,%eax
80100e25:	c1 e0 02             	shl    $0x2,%eax
80100e28:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2e:	83 c0 04             	add    $0x4,%eax
80100e31:	c1 e0 02             	shl    $0x2,%eax
80100e34:	50                   	push   %eax
80100e35:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100e3b:	50                   	push   %eax
80100e3c:	ff 75 dc             	pushl  -0x24(%ebp)
80100e3f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e42:	e8 82 80 00 00       	call   80108ec9 <copyout>
80100e47:	83 c4 10             	add    $0x10,%esp
80100e4a:	85 c0                	test   %eax,%eax
80100e4c:	0f 88 e1 00 00 00    	js     80100f33 <exec+0x3dd>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e52:	8b 45 08             	mov    0x8(%ebp),%eax
80100e55:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e5e:	eb 17                	jmp    80100e77 <exec+0x321>
    if(*s == '/')
80100e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e63:	0f b6 00             	movzbl (%eax),%eax
80100e66:	3c 2f                	cmp    $0x2f,%al
80100e68:	75 09                	jne    80100e73 <exec+0x31d>
      last = s+1;
80100e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6d:	83 c0 01             	add    $0x1,%eax
80100e70:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e73:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7a:	0f b6 00             	movzbl (%eax),%eax
80100e7d:	84 c0                	test   %al,%al
80100e7f:	75 df                	jne    80100e60 <exec+0x30a>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e87:	83 c0 6c             	add    $0x6c,%eax
80100e8a:	83 ec 04             	sub    $0x4,%esp
80100e8d:	6a 10                	push   $0x10
80100e8f:	ff 75 f0             	pushl  -0x10(%ebp)
80100e92:	50                   	push   %eax
80100e93:	e8 aa 4d 00 00       	call   80105c42 <safestrcpy>
80100e98:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea1:	8b 40 04             	mov    0x4(%eax),%eax
80100ea4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  proc->pgdir = pgdir;
80100ea7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ead:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100eb0:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eb3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb9:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ebc:	89 10                	mov    %edx,(%eax)
  proc->topstack =topstack;
80100ebe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec4:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100ec7:	89 90 a0 00 00 00    	mov    %edx,0xa0(%eax)
  proc->tf->eip = elf.entry;  // main
80100ecd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed3:	8b 40 18             	mov    0x18(%eax),%eax
80100ed6:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100edc:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100edf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee5:	8b 40 18             	mov    0x18(%eax),%eax
80100ee8:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eeb:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100eee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef4:	83 ec 0c             	sub    $0xc,%esp
80100ef7:	50                   	push   %eax
80100ef8:	e8 39 79 00 00       	call   80108836 <switchuvm>
80100efd:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f00:	83 ec 0c             	sub    $0xc,%esp
80100f03:	ff 75 cc             	pushl  -0x34(%ebp)
80100f06:	e8 71 7d 00 00       	call   80108c7c <freevm>
80100f0b:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f0e:	b8 00 00 00 00       	mov    $0x0,%eax
80100f13:	eb 51                	jmp    80100f66 <exec+0x410>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f15:	90                   	nop
80100f16:	eb 1c                	jmp    80100f34 <exec+0x3de>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f18:	90                   	nop
80100f19:	eb 19                	jmp    80100f34 <exec+0x3de>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f1b:	90                   	nop
80100f1c:	eb 16                	jmp    80100f34 <exec+0x3de>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f1e:	90                   	nop
80100f1f:	eb 13                	jmp    80100f34 <exec+0x3de>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f21:	90                   	nop
80100f22:	eb 10                	jmp    80100f34 <exec+0x3de>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f24:	90                   	nop
80100f25:	eb 0d                	jmp    80100f34 <exec+0x3de>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f27:	90                   	nop
80100f28:	eb 0a                	jmp    80100f34 <exec+0x3de>
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz+PGSIZE);
  topstack=sz;
  sz = PGROUNDUP(sz+(MAXSTACKPAGES-1)*PGSIZE);
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;
80100f2a:	90                   	nop
80100f2b:	eb 07                	jmp    80100f34 <exec+0x3de>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f2d:	90                   	nop
80100f2e:	eb 04                	jmp    80100f34 <exec+0x3de>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f30:	90                   	nop
80100f31:	eb 01                	jmp    80100f34 <exec+0x3de>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f33:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f34:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f38:	74 0e                	je     80100f48 <exec+0x3f2>
    freevm(pgdir);
80100f3a:	83 ec 0c             	sub    $0xc,%esp
80100f3d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f40:	e8 37 7d 00 00       	call   80108c7c <freevm>
80100f45:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f48:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f4c:	74 13                	je     80100f61 <exec+0x40b>
    iunlockput(ip);
80100f4e:	83 ec 0c             	sub    $0xc,%esp
80100f51:	ff 75 d8             	pushl  -0x28(%ebp)
80100f54:	e8 7a 0c 00 00       	call   80101bd3 <iunlockput>
80100f59:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f5c:	e8 ed 25 00 00       	call   8010354e <end_op>
  }
  return -1;
80100f61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f66:	c9                   	leave  
80100f67:	c3                   	ret    

80100f68 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f68:	55                   	push   %ebp
80100f69:	89 e5                	mov    %esp,%ebp
80100f6b:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f6e:	83 ec 08             	sub    $0x8,%esp
80100f71:	68 c1 8f 10 80       	push   $0x80108fc1
80100f76:	68 60 18 11 80       	push   $0x80111860
80100f7b:	e8 3a 48 00 00       	call   801057ba <initlock>
80100f80:	83 c4 10             	add    $0x10,%esp
}
80100f83:	90                   	nop
80100f84:	c9                   	leave  
80100f85:	c3                   	ret    

80100f86 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f86:	55                   	push   %ebp
80100f87:	89 e5                	mov    %esp,%ebp
80100f89:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f8c:	83 ec 0c             	sub    $0xc,%esp
80100f8f:	68 60 18 11 80       	push   $0x80111860
80100f94:	e8 43 48 00 00       	call   801057dc <acquire>
80100f99:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f9c:	c7 45 f4 94 18 11 80 	movl   $0x80111894,-0xc(%ebp)
80100fa3:	eb 2d                	jmp    80100fd2 <filealloc+0x4c>
    if(f->ref == 0){
80100fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa8:	8b 40 04             	mov    0x4(%eax),%eax
80100fab:	85 c0                	test   %eax,%eax
80100fad:	75 1f                	jne    80100fce <filealloc+0x48>
      f->ref = 1;
80100faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb2:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fb9:	83 ec 0c             	sub    $0xc,%esp
80100fbc:	68 60 18 11 80       	push   $0x80111860
80100fc1:	e8 7d 48 00 00       	call   80105843 <release>
80100fc6:	83 c4 10             	add    $0x10,%esp
      return f;
80100fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fcc:	eb 23                	jmp    80100ff1 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fce:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fd2:	b8 f4 21 11 80       	mov    $0x801121f4,%eax
80100fd7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fda:	72 c9                	jb     80100fa5 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fdc:	83 ec 0c             	sub    $0xc,%esp
80100fdf:	68 60 18 11 80       	push   $0x80111860
80100fe4:	e8 5a 48 00 00       	call   80105843 <release>
80100fe9:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fec:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100ff1:	c9                   	leave  
80100ff2:	c3                   	ret    

80100ff3 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100ff3:	55                   	push   %ebp
80100ff4:	89 e5                	mov    %esp,%ebp
80100ff6:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80100ff9:	83 ec 0c             	sub    $0xc,%esp
80100ffc:	68 60 18 11 80       	push   $0x80111860
80101001:	e8 d6 47 00 00       	call   801057dc <acquire>
80101006:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101009:	8b 45 08             	mov    0x8(%ebp),%eax
8010100c:	8b 40 04             	mov    0x4(%eax),%eax
8010100f:	85 c0                	test   %eax,%eax
80101011:	7f 0d                	jg     80101020 <filedup+0x2d>
    panic("filedup");
80101013:	83 ec 0c             	sub    $0xc,%esp
80101016:	68 c8 8f 10 80       	push   $0x80108fc8
8010101b:	e8 46 f5 ff ff       	call   80100566 <panic>
  f->ref++;
80101020:	8b 45 08             	mov    0x8(%ebp),%eax
80101023:	8b 40 04             	mov    0x4(%eax),%eax
80101026:	8d 50 01             	lea    0x1(%eax),%edx
80101029:	8b 45 08             	mov    0x8(%ebp),%eax
8010102c:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010102f:	83 ec 0c             	sub    $0xc,%esp
80101032:	68 60 18 11 80       	push   $0x80111860
80101037:	e8 07 48 00 00       	call   80105843 <release>
8010103c:	83 c4 10             	add    $0x10,%esp
  return f;
8010103f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101042:	c9                   	leave  
80101043:	c3                   	ret    

80101044 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101044:	55                   	push   %ebp
80101045:	89 e5                	mov    %esp,%ebp
80101047:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010104a:	83 ec 0c             	sub    $0xc,%esp
8010104d:	68 60 18 11 80       	push   $0x80111860
80101052:	e8 85 47 00 00       	call   801057dc <acquire>
80101057:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010105a:	8b 45 08             	mov    0x8(%ebp),%eax
8010105d:	8b 40 04             	mov    0x4(%eax),%eax
80101060:	85 c0                	test   %eax,%eax
80101062:	7f 0d                	jg     80101071 <fileclose+0x2d>
    panic("fileclose");
80101064:	83 ec 0c             	sub    $0xc,%esp
80101067:	68 d0 8f 10 80       	push   $0x80108fd0
8010106c:	e8 f5 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101071:	8b 45 08             	mov    0x8(%ebp),%eax
80101074:	8b 40 04             	mov    0x4(%eax),%eax
80101077:	8d 50 ff             	lea    -0x1(%eax),%edx
8010107a:	8b 45 08             	mov    0x8(%ebp),%eax
8010107d:	89 50 04             	mov    %edx,0x4(%eax)
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	8b 40 04             	mov    0x4(%eax),%eax
80101086:	85 c0                	test   %eax,%eax
80101088:	7e 15                	jle    8010109f <fileclose+0x5b>
    release(&ftable.lock);
8010108a:	83 ec 0c             	sub    $0xc,%esp
8010108d:	68 60 18 11 80       	push   $0x80111860
80101092:	e8 ac 47 00 00       	call   80105843 <release>
80101097:	83 c4 10             	add    $0x10,%esp
8010109a:	e9 8b 00 00 00       	jmp    8010112a <fileclose+0xe6>
    return;
  }
  ff = *f;
8010109f:	8b 45 08             	mov    0x8(%ebp),%eax
801010a2:	8b 10                	mov    (%eax),%edx
801010a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010a7:	8b 50 04             	mov    0x4(%eax),%edx
801010aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010ad:	8b 50 08             	mov    0x8(%eax),%edx
801010b0:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010b3:	8b 50 0c             	mov    0xc(%eax),%edx
801010b6:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010b9:	8b 50 10             	mov    0x10(%eax),%edx
801010bc:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010bf:	8b 40 14             	mov    0x14(%eax),%eax
801010c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010cf:	8b 45 08             	mov    0x8(%ebp),%eax
801010d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010d8:	83 ec 0c             	sub    $0xc,%esp
801010db:	68 60 18 11 80       	push   $0x80111860
801010e0:	e8 5e 47 00 00       	call   80105843 <release>
801010e5:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010eb:	83 f8 01             	cmp    $0x1,%eax
801010ee:	75 19                	jne    80101109 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010f0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010f4:	0f be d0             	movsbl %al,%edx
801010f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010fa:	83 ec 08             	sub    $0x8,%esp
801010fd:	52                   	push   %edx
801010fe:	50                   	push   %eax
801010ff:	e8 0f 30 00 00       	call   80104113 <pipeclose>
80101104:	83 c4 10             	add    $0x10,%esp
80101107:	eb 21                	jmp    8010112a <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101109:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010110c:	83 f8 02             	cmp    $0x2,%eax
8010110f:	75 19                	jne    8010112a <fileclose+0xe6>
    begin_op();
80101111:	e8 ac 23 00 00       	call   801034c2 <begin_op>
    iput(ff.ip);
80101116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101119:	83 ec 0c             	sub    $0xc,%esp
8010111c:	50                   	push   %eax
8010111d:	e8 c1 09 00 00       	call   80101ae3 <iput>
80101122:	83 c4 10             	add    $0x10,%esp
    end_op();
80101125:	e8 24 24 00 00       	call   8010354e <end_op>
  }
}
8010112a:	c9                   	leave  
8010112b:	c3                   	ret    

8010112c <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010112c:	55                   	push   %ebp
8010112d:	89 e5                	mov    %esp,%ebp
8010112f:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101132:	8b 45 08             	mov    0x8(%ebp),%eax
80101135:	8b 00                	mov    (%eax),%eax
80101137:	83 f8 02             	cmp    $0x2,%eax
8010113a:	75 40                	jne    8010117c <filestat+0x50>
    ilock(f->ip);
8010113c:	8b 45 08             	mov    0x8(%ebp),%eax
8010113f:	8b 40 10             	mov    0x10(%eax),%eax
80101142:	83 ec 0c             	sub    $0xc,%esp
80101145:	50                   	push   %eax
80101146:	e8 ce 07 00 00       	call   80101919 <ilock>
8010114b:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010114e:	8b 45 08             	mov    0x8(%ebp),%eax
80101151:	8b 40 10             	mov    0x10(%eax),%eax
80101154:	83 ec 08             	sub    $0x8,%esp
80101157:	ff 75 0c             	pushl  0xc(%ebp)
8010115a:	50                   	push   %eax
8010115b:	e8 db 0c 00 00       	call   80101e3b <stati>
80101160:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101163:	8b 45 08             	mov    0x8(%ebp),%eax
80101166:	8b 40 10             	mov    0x10(%eax),%eax
80101169:	83 ec 0c             	sub    $0xc,%esp
8010116c:	50                   	push   %eax
8010116d:	e8 ff 08 00 00       	call   80101a71 <iunlock>
80101172:	83 c4 10             	add    $0x10,%esp
    return 0;
80101175:	b8 00 00 00 00       	mov    $0x0,%eax
8010117a:	eb 05                	jmp    80101181 <filestat+0x55>
  }
  return -1;
8010117c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101190:	84 c0                	test   %al,%al
80101192:	75 0a                	jne    8010119e <fileread+0x1b>
    return -1;
80101194:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101199:	e9 9b 00 00 00       	jmp    80101239 <fileread+0xb6>
  if(f->type == FD_PIPE)
8010119e:	8b 45 08             	mov    0x8(%ebp),%eax
801011a1:	8b 00                	mov    (%eax),%eax
801011a3:	83 f8 01             	cmp    $0x1,%eax
801011a6:	75 1a                	jne    801011c2 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011a8:	8b 45 08             	mov    0x8(%ebp),%eax
801011ab:	8b 40 0c             	mov    0xc(%eax),%eax
801011ae:	83 ec 04             	sub    $0x4,%esp
801011b1:	ff 75 10             	pushl  0x10(%ebp)
801011b4:	ff 75 0c             	pushl  0xc(%ebp)
801011b7:	50                   	push   %eax
801011b8:	e8 fe 30 00 00       	call   801042bb <piperead>
801011bd:	83 c4 10             	add    $0x10,%esp
801011c0:	eb 77                	jmp    80101239 <fileread+0xb6>
  if(f->type == FD_INODE){
801011c2:	8b 45 08             	mov    0x8(%ebp),%eax
801011c5:	8b 00                	mov    (%eax),%eax
801011c7:	83 f8 02             	cmp    $0x2,%eax
801011ca:	75 60                	jne    8010122c <fileread+0xa9>
    ilock(f->ip);
801011cc:	8b 45 08             	mov    0x8(%ebp),%eax
801011cf:	8b 40 10             	mov    0x10(%eax),%eax
801011d2:	83 ec 0c             	sub    $0xc,%esp
801011d5:	50                   	push   %eax
801011d6:	e8 3e 07 00 00       	call   80101919 <ilock>
801011db:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011de:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011e1:	8b 45 08             	mov    0x8(%ebp),%eax
801011e4:	8b 50 14             	mov    0x14(%eax),%edx
801011e7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ea:	8b 40 10             	mov    0x10(%eax),%eax
801011ed:	51                   	push   %ecx
801011ee:	52                   	push   %edx
801011ef:	ff 75 0c             	pushl  0xc(%ebp)
801011f2:	50                   	push   %eax
801011f3:	e8 89 0c 00 00       	call   80101e81 <readi>
801011f8:	83 c4 10             	add    $0x10,%esp
801011fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101202:	7e 11                	jle    80101215 <fileread+0x92>
      f->off += r;
80101204:	8b 45 08             	mov    0x8(%ebp),%eax
80101207:	8b 50 14             	mov    0x14(%eax),%edx
8010120a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010120d:	01 c2                	add    %eax,%edx
8010120f:	8b 45 08             	mov    0x8(%ebp),%eax
80101212:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101215:	8b 45 08             	mov    0x8(%ebp),%eax
80101218:	8b 40 10             	mov    0x10(%eax),%eax
8010121b:	83 ec 0c             	sub    $0xc,%esp
8010121e:	50                   	push   %eax
8010121f:	e8 4d 08 00 00       	call   80101a71 <iunlock>
80101224:	83 c4 10             	add    $0x10,%esp
    return r;
80101227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010122a:	eb 0d                	jmp    80101239 <fileread+0xb6>
  }
  panic("fileread");
8010122c:	83 ec 0c             	sub    $0xc,%esp
8010122f:	68 da 8f 10 80       	push   $0x80108fda
80101234:	e8 2d f3 ff ff       	call   80100566 <panic>
}
80101239:	c9                   	leave  
8010123a:	c3                   	ret    

8010123b <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010123b:	55                   	push   %ebp
8010123c:	89 e5                	mov    %esp,%ebp
8010123e:	53                   	push   %ebx
8010123f:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101249:	84 c0                	test   %al,%al
8010124b:	75 0a                	jne    80101257 <filewrite+0x1c>
    return -1;
8010124d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101252:	e9 1b 01 00 00       	jmp    80101372 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101257:	8b 45 08             	mov    0x8(%ebp),%eax
8010125a:	8b 00                	mov    (%eax),%eax
8010125c:	83 f8 01             	cmp    $0x1,%eax
8010125f:	75 1d                	jne    8010127e <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101261:	8b 45 08             	mov    0x8(%ebp),%eax
80101264:	8b 40 0c             	mov    0xc(%eax),%eax
80101267:	83 ec 04             	sub    $0x4,%esp
8010126a:	ff 75 10             	pushl  0x10(%ebp)
8010126d:	ff 75 0c             	pushl  0xc(%ebp)
80101270:	50                   	push   %eax
80101271:	e8 47 2f 00 00       	call   801041bd <pipewrite>
80101276:	83 c4 10             	add    $0x10,%esp
80101279:	e9 f4 00 00 00       	jmp    80101372 <filewrite+0x137>
  if(f->type == FD_INODE){
8010127e:	8b 45 08             	mov    0x8(%ebp),%eax
80101281:	8b 00                	mov    (%eax),%eax
80101283:	83 f8 02             	cmp    $0x2,%eax
80101286:	0f 85 d9 00 00 00    	jne    80101365 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010128c:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101293:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010129a:	e9 a3 00 00 00       	jmp    80101342 <filewrite+0x107>
      int n1 = n - i;
8010129f:	8b 45 10             	mov    0x10(%ebp),%eax
801012a2:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012ab:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012ae:	7e 06                	jle    801012b6 <filewrite+0x7b>
        n1 = max;
801012b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012b3:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012b6:	e8 07 22 00 00       	call   801034c2 <begin_op>
      ilock(f->ip);
801012bb:	8b 45 08             	mov    0x8(%ebp),%eax
801012be:	8b 40 10             	mov    0x10(%eax),%eax
801012c1:	83 ec 0c             	sub    $0xc,%esp
801012c4:	50                   	push   %eax
801012c5:	e8 4f 06 00 00       	call   80101919 <ilock>
801012ca:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012cd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012d0:	8b 45 08             	mov    0x8(%ebp),%eax
801012d3:	8b 50 14             	mov    0x14(%eax),%edx
801012d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801012dc:	01 c3                	add    %eax,%ebx
801012de:	8b 45 08             	mov    0x8(%ebp),%eax
801012e1:	8b 40 10             	mov    0x10(%eax),%eax
801012e4:	51                   	push   %ecx
801012e5:	52                   	push   %edx
801012e6:	53                   	push   %ebx
801012e7:	50                   	push   %eax
801012e8:	e8 eb 0c 00 00       	call   80101fd8 <writei>
801012ed:	83 c4 10             	add    $0x10,%esp
801012f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012f3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012f7:	7e 11                	jle    8010130a <filewrite+0xcf>
        f->off += r;
801012f9:	8b 45 08             	mov    0x8(%ebp),%eax
801012fc:	8b 50 14             	mov    0x14(%eax),%edx
801012ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101302:	01 c2                	add    %eax,%edx
80101304:	8b 45 08             	mov    0x8(%ebp),%eax
80101307:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010130a:	8b 45 08             	mov    0x8(%ebp),%eax
8010130d:	8b 40 10             	mov    0x10(%eax),%eax
80101310:	83 ec 0c             	sub    $0xc,%esp
80101313:	50                   	push   %eax
80101314:	e8 58 07 00 00       	call   80101a71 <iunlock>
80101319:	83 c4 10             	add    $0x10,%esp
      end_op();
8010131c:	e8 2d 22 00 00       	call   8010354e <end_op>

      if(r < 0)
80101321:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101325:	78 29                	js     80101350 <filewrite+0x115>
        break;
      if(r != n1)
80101327:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010132a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010132d:	74 0d                	je     8010133c <filewrite+0x101>
        panic("short filewrite");
8010132f:	83 ec 0c             	sub    $0xc,%esp
80101332:	68 e3 8f 10 80       	push   $0x80108fe3
80101337:	e8 2a f2 ff ff       	call   80100566 <panic>
      i += r;
8010133c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010133f:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101345:	3b 45 10             	cmp    0x10(%ebp),%eax
80101348:	0f 8c 51 ff ff ff    	jl     8010129f <filewrite+0x64>
8010134e:	eb 01                	jmp    80101351 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101350:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101354:	3b 45 10             	cmp    0x10(%ebp),%eax
80101357:	75 05                	jne    8010135e <filewrite+0x123>
80101359:	8b 45 10             	mov    0x10(%ebp),%eax
8010135c:	eb 14                	jmp    80101372 <filewrite+0x137>
8010135e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101363:	eb 0d                	jmp    80101372 <filewrite+0x137>
  }
  panic("filewrite");
80101365:	83 ec 0c             	sub    $0xc,%esp
80101368:	68 f3 8f 10 80       	push   $0x80108ff3
8010136d:	e8 f4 f1 ff ff       	call   80100566 <panic>
}
80101372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101375:	c9                   	leave  
80101376:	c3                   	ret    

80101377 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101377:	55                   	push   %ebp
80101378:	89 e5                	mov    %esp,%ebp
8010137a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010137d:	8b 45 08             	mov    0x8(%ebp),%eax
80101380:	83 ec 08             	sub    $0x8,%esp
80101383:	6a 01                	push   $0x1
80101385:	50                   	push   %eax
80101386:	e8 2b ee ff ff       	call   801001b6 <bread>
8010138b:	83 c4 10             	add    $0x10,%esp
8010138e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101394:	83 c0 18             	add    $0x18,%eax
80101397:	83 ec 04             	sub    $0x4,%esp
8010139a:	6a 10                	push   $0x10
8010139c:	50                   	push   %eax
8010139d:	ff 75 0c             	pushl  0xc(%ebp)
801013a0:	e8 59 47 00 00       	call   80105afe <memmove>
801013a5:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013a8:	83 ec 0c             	sub    $0xc,%esp
801013ab:	ff 75 f4             	pushl  -0xc(%ebp)
801013ae:	e8 7b ee ff ff       	call   8010022e <brelse>
801013b3:	83 c4 10             	add    $0x10,%esp
}
801013b6:	90                   	nop
801013b7:	c9                   	leave  
801013b8:	c3                   	ret    

801013b9 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013b9:	55                   	push   %ebp
801013ba:	89 e5                	mov    %esp,%ebp
801013bc:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801013c2:	8b 45 08             	mov    0x8(%ebp),%eax
801013c5:	83 ec 08             	sub    $0x8,%esp
801013c8:	52                   	push   %edx
801013c9:	50                   	push   %eax
801013ca:	e8 e7 ed ff ff       	call   801001b6 <bread>
801013cf:	83 c4 10             	add    $0x10,%esp
801013d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d8:	83 c0 18             	add    $0x18,%eax
801013db:	83 ec 04             	sub    $0x4,%esp
801013de:	68 00 02 00 00       	push   $0x200
801013e3:	6a 00                	push   $0x0
801013e5:	50                   	push   %eax
801013e6:	e8 54 46 00 00       	call   80105a3f <memset>
801013eb:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013ee:	83 ec 0c             	sub    $0xc,%esp
801013f1:	ff 75 f4             	pushl  -0xc(%ebp)
801013f4:	e8 01 23 00 00       	call   801036fa <log_write>
801013f9:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013fc:	83 ec 0c             	sub    $0xc,%esp
801013ff:	ff 75 f4             	pushl  -0xc(%ebp)
80101402:	e8 27 ee ff ff       	call   8010022e <brelse>
80101407:	83 c4 10             	add    $0x10,%esp
}
8010140a:	90                   	nop
8010140b:	c9                   	leave  
8010140c:	c3                   	ret    

8010140d <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010140d:	55                   	push   %ebp
8010140e:	89 e5                	mov    %esp,%ebp
80101410:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101413:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
8010141a:	8b 45 08             	mov    0x8(%ebp),%eax
8010141d:	83 ec 08             	sub    $0x8,%esp
80101420:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101423:	52                   	push   %edx
80101424:	50                   	push   %eax
80101425:	e8 4d ff ff ff       	call   80101377 <readsb>
8010142a:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010142d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101434:	e9 15 01 00 00       	jmp    8010154e <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010143c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101442:	85 c0                	test   %eax,%eax
80101444:	0f 48 c2             	cmovs  %edx,%eax
80101447:	c1 f8 0c             	sar    $0xc,%eax
8010144a:	89 c2                	mov    %eax,%edx
8010144c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010144f:	c1 e8 03             	shr    $0x3,%eax
80101452:	01 d0                	add    %edx,%eax
80101454:	83 c0 03             	add    $0x3,%eax
80101457:	83 ec 08             	sub    $0x8,%esp
8010145a:	50                   	push   %eax
8010145b:	ff 75 08             	pushl  0x8(%ebp)
8010145e:	e8 53 ed ff ff       	call   801001b6 <bread>
80101463:	83 c4 10             	add    $0x10,%esp
80101466:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101469:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101470:	e9 a6 00 00 00       	jmp    8010151b <balloc+0x10e>
      m = 1 << (bi % 8);
80101475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101478:	99                   	cltd   
80101479:	c1 ea 1d             	shr    $0x1d,%edx
8010147c:	01 d0                	add    %edx,%eax
8010147e:	83 e0 07             	and    $0x7,%eax
80101481:	29 d0                	sub    %edx,%eax
80101483:	ba 01 00 00 00       	mov    $0x1,%edx
80101488:	89 c1                	mov    %eax,%ecx
8010148a:	d3 e2                	shl    %cl,%edx
8010148c:	89 d0                	mov    %edx,%eax
8010148e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101494:	8d 50 07             	lea    0x7(%eax),%edx
80101497:	85 c0                	test   %eax,%eax
80101499:	0f 48 c2             	cmovs  %edx,%eax
8010149c:	c1 f8 03             	sar    $0x3,%eax
8010149f:	89 c2                	mov    %eax,%edx
801014a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014a4:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014a9:	0f b6 c0             	movzbl %al,%eax
801014ac:	23 45 e8             	and    -0x18(%ebp),%eax
801014af:	85 c0                	test   %eax,%eax
801014b1:	75 64                	jne    80101517 <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
801014b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b6:	8d 50 07             	lea    0x7(%eax),%edx
801014b9:	85 c0                	test   %eax,%eax
801014bb:	0f 48 c2             	cmovs  %edx,%eax
801014be:	c1 f8 03             	sar    $0x3,%eax
801014c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014c4:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014c9:	89 d1                	mov    %edx,%ecx
801014cb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014ce:	09 ca                	or     %ecx,%edx
801014d0:	89 d1                	mov    %edx,%ecx
801014d2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014d5:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014d9:	83 ec 0c             	sub    $0xc,%esp
801014dc:	ff 75 ec             	pushl  -0x14(%ebp)
801014df:	e8 16 22 00 00       	call   801036fa <log_write>
801014e4:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014e7:	83 ec 0c             	sub    $0xc,%esp
801014ea:	ff 75 ec             	pushl  -0x14(%ebp)
801014ed:	e8 3c ed ff ff       	call   8010022e <brelse>
801014f2:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014fb:	01 c2                	add    %eax,%edx
801014fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101500:	83 ec 08             	sub    $0x8,%esp
80101503:	52                   	push   %edx
80101504:	50                   	push   %eax
80101505:	e8 af fe ff ff       	call   801013b9 <bzero>
8010150a:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010150d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101510:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101513:	01 d0                	add    %edx,%eax
80101515:	eb 52                	jmp    80101569 <balloc+0x15c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101517:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010151b:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101522:	7f 15                	jg     80101539 <balloc+0x12c>
80101524:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101527:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152a:	01 d0                	add    %edx,%eax
8010152c:	89 c2                	mov    %eax,%edx
8010152e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101531:	39 c2                	cmp    %eax,%edx
80101533:	0f 82 3c ff ff ff    	jb     80101475 <balloc+0x68>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101539:	83 ec 0c             	sub    $0xc,%esp
8010153c:	ff 75 ec             	pushl  -0x14(%ebp)
8010153f:	e8 ea ec ff ff       	call   8010022e <brelse>
80101544:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101547:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010154e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101554:	39 c2                	cmp    %eax,%edx
80101556:	0f 87 dd fe ff ff    	ja     80101439 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010155c:	83 ec 0c             	sub    $0xc,%esp
8010155f:	68 fd 8f 10 80       	push   $0x80108ffd
80101564:	e8 fd ef ff ff       	call   80100566 <panic>
}
80101569:	c9                   	leave  
8010156a:	c3                   	ret    

8010156b <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010156b:	55                   	push   %ebp
8010156c:	89 e5                	mov    %esp,%ebp
8010156e:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101571:	83 ec 08             	sub    $0x8,%esp
80101574:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101577:	50                   	push   %eax
80101578:	ff 75 08             	pushl  0x8(%ebp)
8010157b:	e8 f7 fd ff ff       	call   80101377 <readsb>
80101580:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101583:	8b 45 0c             	mov    0xc(%ebp),%eax
80101586:	c1 e8 0c             	shr    $0xc,%eax
80101589:	89 c2                	mov    %eax,%edx
8010158b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010158e:	c1 e8 03             	shr    $0x3,%eax
80101591:	01 d0                	add    %edx,%eax
80101593:	8d 50 03             	lea    0x3(%eax),%edx
80101596:	8b 45 08             	mov    0x8(%ebp),%eax
80101599:	83 ec 08             	sub    $0x8,%esp
8010159c:	52                   	push   %edx
8010159d:	50                   	push   %eax
8010159e:	e8 13 ec ff ff       	call   801001b6 <bread>
801015a3:	83 c4 10             	add    $0x10,%esp
801015a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ac:	25 ff 0f 00 00       	and    $0xfff,%eax
801015b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b7:	99                   	cltd   
801015b8:	c1 ea 1d             	shr    $0x1d,%edx
801015bb:	01 d0                	add    %edx,%eax
801015bd:	83 e0 07             	and    $0x7,%eax
801015c0:	29 d0                	sub    %edx,%eax
801015c2:	ba 01 00 00 00       	mov    $0x1,%edx
801015c7:	89 c1                	mov    %eax,%ecx
801015c9:	d3 e2                	shl    %cl,%edx
801015cb:	89 d0                	mov    %edx,%eax
801015cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d3:	8d 50 07             	lea    0x7(%eax),%edx
801015d6:	85 c0                	test   %eax,%eax
801015d8:	0f 48 c2             	cmovs  %edx,%eax
801015db:	c1 f8 03             	sar    $0x3,%eax
801015de:	89 c2                	mov    %eax,%edx
801015e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e3:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015e8:	0f b6 c0             	movzbl %al,%eax
801015eb:	23 45 ec             	and    -0x14(%ebp),%eax
801015ee:	85 c0                	test   %eax,%eax
801015f0:	75 0d                	jne    801015ff <bfree+0x94>
    panic("freeing free block");
801015f2:	83 ec 0c             	sub    $0xc,%esp
801015f5:	68 13 90 10 80       	push   $0x80109013
801015fa:	e8 67 ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101602:	8d 50 07             	lea    0x7(%eax),%edx
80101605:	85 c0                	test   %eax,%eax
80101607:	0f 48 c2             	cmovs  %edx,%eax
8010160a:	c1 f8 03             	sar    $0x3,%eax
8010160d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101610:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101615:	89 d1                	mov    %edx,%ecx
80101617:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010161a:	f7 d2                	not    %edx
8010161c:	21 ca                	and    %ecx,%edx
8010161e:	89 d1                	mov    %edx,%ecx
80101620:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101623:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101627:	83 ec 0c             	sub    $0xc,%esp
8010162a:	ff 75 f4             	pushl  -0xc(%ebp)
8010162d:	e8 c8 20 00 00       	call   801036fa <log_write>
80101632:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101635:	83 ec 0c             	sub    $0xc,%esp
80101638:	ff 75 f4             	pushl  -0xc(%ebp)
8010163b:	e8 ee eb ff ff       	call   8010022e <brelse>
80101640:	83 c4 10             	add    $0x10,%esp
}
80101643:	90                   	nop
80101644:	c9                   	leave  
80101645:	c3                   	ret    

80101646 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101646:	55                   	push   %ebp
80101647:	89 e5                	mov    %esp,%ebp
80101649:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
8010164c:	83 ec 08             	sub    $0x8,%esp
8010164f:	68 26 90 10 80       	push   $0x80109026
80101654:	68 60 22 11 80       	push   $0x80112260
80101659:	e8 5c 41 00 00       	call   801057ba <initlock>
8010165e:	83 c4 10             	add    $0x10,%esp
}
80101661:	90                   	nop
80101662:	c9                   	leave  
80101663:	c3                   	ret    

80101664 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101664:	55                   	push   %ebp
80101665:	89 e5                	mov    %esp,%ebp
80101667:	83 ec 38             	sub    $0x38,%esp
8010166a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010166d:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101671:	8b 45 08             	mov    0x8(%ebp),%eax
80101674:	83 ec 08             	sub    $0x8,%esp
80101677:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010167a:	52                   	push   %edx
8010167b:	50                   	push   %eax
8010167c:	e8 f6 fc ff ff       	call   80101377 <readsb>
80101681:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
80101684:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010168b:	e9 98 00 00 00       	jmp    80101728 <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
80101690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101693:	c1 e8 03             	shr    $0x3,%eax
80101696:	83 c0 02             	add    $0x2,%eax
80101699:	83 ec 08             	sub    $0x8,%esp
8010169c:	50                   	push   %eax
8010169d:	ff 75 08             	pushl  0x8(%ebp)
801016a0:	e8 11 eb ff ff       	call   801001b6 <bread>
801016a5:	83 c4 10             	add    $0x10,%esp
801016a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ae:	8d 50 18             	lea    0x18(%eax),%edx
801016b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016b4:	83 e0 07             	and    $0x7,%eax
801016b7:	c1 e0 06             	shl    $0x6,%eax
801016ba:	01 d0                	add    %edx,%eax
801016bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801016bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016c2:	0f b7 00             	movzwl (%eax),%eax
801016c5:	66 85 c0             	test   %ax,%ax
801016c8:	75 4c                	jne    80101716 <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
801016ca:	83 ec 04             	sub    $0x4,%esp
801016cd:	6a 40                	push   $0x40
801016cf:	6a 00                	push   $0x0
801016d1:	ff 75 ec             	pushl  -0x14(%ebp)
801016d4:	e8 66 43 00 00       	call   80105a3f <memset>
801016d9:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801016dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016df:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801016e3:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016e6:	83 ec 0c             	sub    $0xc,%esp
801016e9:	ff 75 f0             	pushl  -0x10(%ebp)
801016ec:	e8 09 20 00 00       	call   801036fa <log_write>
801016f1:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801016f4:	83 ec 0c             	sub    $0xc,%esp
801016f7:	ff 75 f0             	pushl  -0x10(%ebp)
801016fa:	e8 2f eb ff ff       	call   8010022e <brelse>
801016ff:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101705:	83 ec 08             	sub    $0x8,%esp
80101708:	50                   	push   %eax
80101709:	ff 75 08             	pushl  0x8(%ebp)
8010170c:	e8 ef 00 00 00       	call   80101800 <iget>
80101711:	83 c4 10             	add    $0x10,%esp
80101714:	eb 2d                	jmp    80101743 <ialloc+0xdf>
    }
    brelse(bp);
80101716:	83 ec 0c             	sub    $0xc,%esp
80101719:	ff 75 f0             	pushl  -0x10(%ebp)
8010171c:	e8 0d eb ff ff       	call   8010022e <brelse>
80101721:	83 c4 10             	add    $0x10,%esp
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101724:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101728:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010172b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010172e:	39 c2                	cmp    %eax,%edx
80101730:	0f 87 5a ff ff ff    	ja     80101690 <ialloc+0x2c>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101736:	83 ec 0c             	sub    $0xc,%esp
80101739:	68 2d 90 10 80       	push   $0x8010902d
8010173e:	e8 23 ee ff ff       	call   80100566 <panic>
}
80101743:	c9                   	leave  
80101744:	c3                   	ret    

80101745 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101745:	55                   	push   %ebp
80101746:	89 e5                	mov    %esp,%ebp
80101748:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010174b:	8b 45 08             	mov    0x8(%ebp),%eax
8010174e:	8b 40 04             	mov    0x4(%eax),%eax
80101751:	c1 e8 03             	shr    $0x3,%eax
80101754:	8d 50 02             	lea    0x2(%eax),%edx
80101757:	8b 45 08             	mov    0x8(%ebp),%eax
8010175a:	8b 00                	mov    (%eax),%eax
8010175c:	83 ec 08             	sub    $0x8,%esp
8010175f:	52                   	push   %edx
80101760:	50                   	push   %eax
80101761:	e8 50 ea ff ff       	call   801001b6 <bread>
80101766:	83 c4 10             	add    $0x10,%esp
80101769:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010176c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176f:	8d 50 18             	lea    0x18(%eax),%edx
80101772:	8b 45 08             	mov    0x8(%ebp),%eax
80101775:	8b 40 04             	mov    0x4(%eax),%eax
80101778:	83 e0 07             	and    $0x7,%eax
8010177b:	c1 e0 06             	shl    $0x6,%eax
8010177e:	01 d0                	add    %edx,%eax
80101780:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101783:	8b 45 08             	mov    0x8(%ebp),%eax
80101786:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010178a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010178d:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101790:	8b 45 08             	mov    0x8(%ebp),%eax
80101793:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010179a:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010179e:	8b 45 08             	mov    0x8(%ebp),%eax
801017a1:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a8:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017ac:	8b 45 08             	mov    0x8(%ebp),%eax
801017af:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801017b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017b6:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801017ba:	8b 45 08             	mov    0x8(%ebp),%eax
801017bd:	8b 50 18             	mov    0x18(%eax),%edx
801017c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017c3:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017c6:	8b 45 08             	mov    0x8(%ebp),%eax
801017c9:	8d 50 1c             	lea    0x1c(%eax),%edx
801017cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017cf:	83 c0 0c             	add    $0xc,%eax
801017d2:	83 ec 04             	sub    $0x4,%esp
801017d5:	6a 34                	push   $0x34
801017d7:	52                   	push   %edx
801017d8:	50                   	push   %eax
801017d9:	e8 20 43 00 00       	call   80105afe <memmove>
801017de:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801017e1:	83 ec 0c             	sub    $0xc,%esp
801017e4:	ff 75 f4             	pushl  -0xc(%ebp)
801017e7:	e8 0e 1f 00 00       	call   801036fa <log_write>
801017ec:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017ef:	83 ec 0c             	sub    $0xc,%esp
801017f2:	ff 75 f4             	pushl  -0xc(%ebp)
801017f5:	e8 34 ea ff ff       	call   8010022e <brelse>
801017fa:	83 c4 10             	add    $0x10,%esp
}
801017fd:	90                   	nop
801017fe:	c9                   	leave  
801017ff:	c3                   	ret    

80101800 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101800:	55                   	push   %ebp
80101801:	89 e5                	mov    %esp,%ebp
80101803:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101806:	83 ec 0c             	sub    $0xc,%esp
80101809:	68 60 22 11 80       	push   $0x80112260
8010180e:	e8 c9 3f 00 00       	call   801057dc <acquire>
80101813:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101816:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010181d:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101824:	eb 5d                	jmp    80101883 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101829:	8b 40 08             	mov    0x8(%eax),%eax
8010182c:	85 c0                	test   %eax,%eax
8010182e:	7e 39                	jle    80101869 <iget+0x69>
80101830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101833:	8b 00                	mov    (%eax),%eax
80101835:	3b 45 08             	cmp    0x8(%ebp),%eax
80101838:	75 2f                	jne    80101869 <iget+0x69>
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	8b 40 04             	mov    0x4(%eax),%eax
80101840:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101843:	75 24                	jne    80101869 <iget+0x69>
      ip->ref++;
80101845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101848:	8b 40 08             	mov    0x8(%eax),%eax
8010184b:	8d 50 01             	lea    0x1(%eax),%edx
8010184e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101851:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101854:	83 ec 0c             	sub    $0xc,%esp
80101857:	68 60 22 11 80       	push   $0x80112260
8010185c:	e8 e2 3f 00 00       	call   80105843 <release>
80101861:	83 c4 10             	add    $0x10,%esp
      return ip;
80101864:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101867:	eb 74                	jmp    801018dd <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101869:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010186d:	75 10                	jne    8010187f <iget+0x7f>
8010186f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101872:	8b 40 08             	mov    0x8(%eax),%eax
80101875:	85 c0                	test   %eax,%eax
80101877:	75 06                	jne    8010187f <iget+0x7f>
      empty = ip;
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010187f:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101883:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
8010188a:	72 9a                	jb     80101826 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010188c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101890:	75 0d                	jne    8010189f <iget+0x9f>
    panic("iget: no inodes");
80101892:	83 ec 0c             	sub    $0xc,%esp
80101895:	68 3f 90 10 80       	push   $0x8010903f
8010189a:	e8 c7 ec ff ff       	call   80100566 <panic>

  ip = empty;
8010189f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a8:	8b 55 08             	mov    0x8(%ebp),%edx
801018ab:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801018b3:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801018b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801018c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801018ca:	83 ec 0c             	sub    $0xc,%esp
801018cd:	68 60 22 11 80       	push   $0x80112260
801018d2:	e8 6c 3f 00 00       	call   80105843 <release>
801018d7:	83 c4 10             	add    $0x10,%esp

  return ip;
801018da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018dd:	c9                   	leave  
801018de:	c3                   	ret    

801018df <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018df:	55                   	push   %ebp
801018e0:	89 e5                	mov    %esp,%ebp
801018e2:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801018e5:	83 ec 0c             	sub    $0xc,%esp
801018e8:	68 60 22 11 80       	push   $0x80112260
801018ed:	e8 ea 3e 00 00       	call   801057dc <acquire>
801018f2:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801018f5:	8b 45 08             	mov    0x8(%ebp),%eax
801018f8:	8b 40 08             	mov    0x8(%eax),%eax
801018fb:	8d 50 01             	lea    0x1(%eax),%edx
801018fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101901:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101904:	83 ec 0c             	sub    $0xc,%esp
80101907:	68 60 22 11 80       	push   $0x80112260
8010190c:	e8 32 3f 00 00       	call   80105843 <release>
80101911:	83 c4 10             	add    $0x10,%esp
  return ip;
80101914:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101917:	c9                   	leave  
80101918:	c3                   	ret    

80101919 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101919:	55                   	push   %ebp
8010191a:	89 e5                	mov    %esp,%ebp
8010191c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010191f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101923:	74 0a                	je     8010192f <ilock+0x16>
80101925:	8b 45 08             	mov    0x8(%ebp),%eax
80101928:	8b 40 08             	mov    0x8(%eax),%eax
8010192b:	85 c0                	test   %eax,%eax
8010192d:	7f 0d                	jg     8010193c <ilock+0x23>
    panic("ilock");
8010192f:	83 ec 0c             	sub    $0xc,%esp
80101932:	68 4f 90 10 80       	push   $0x8010904f
80101937:	e8 2a ec ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
8010193c:	83 ec 0c             	sub    $0xc,%esp
8010193f:	68 60 22 11 80       	push   $0x80112260
80101944:	e8 93 3e 00 00       	call   801057dc <acquire>
80101949:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010194c:	eb 13                	jmp    80101961 <ilock+0x48>
    sleep(ip, &icache.lock);
8010194e:	83 ec 08             	sub    $0x8,%esp
80101951:	68 60 22 11 80       	push   $0x80112260
80101956:	ff 75 08             	pushl  0x8(%ebp)
80101959:	e8 27 35 00 00       	call   80104e85 <sleep>
8010195e:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101961:	8b 45 08             	mov    0x8(%ebp),%eax
80101964:	8b 40 0c             	mov    0xc(%eax),%eax
80101967:	83 e0 01             	and    $0x1,%eax
8010196a:	85 c0                	test   %eax,%eax
8010196c:	75 e0                	jne    8010194e <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
8010196e:	8b 45 08             	mov    0x8(%ebp),%eax
80101971:	8b 40 0c             	mov    0xc(%eax),%eax
80101974:	83 c8 01             	or     $0x1,%eax
80101977:	89 c2                	mov    %eax,%edx
80101979:	8b 45 08             	mov    0x8(%ebp),%eax
8010197c:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
8010197f:	83 ec 0c             	sub    $0xc,%esp
80101982:	68 60 22 11 80       	push   $0x80112260
80101987:	e8 b7 3e 00 00       	call   80105843 <release>
8010198c:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
8010198f:	8b 45 08             	mov    0x8(%ebp),%eax
80101992:	8b 40 0c             	mov    0xc(%eax),%eax
80101995:	83 e0 02             	and    $0x2,%eax
80101998:	85 c0                	test   %eax,%eax
8010199a:	0f 85 ce 00 00 00    	jne    80101a6e <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801019a0:	8b 45 08             	mov    0x8(%ebp),%eax
801019a3:	8b 40 04             	mov    0x4(%eax),%eax
801019a6:	c1 e8 03             	shr    $0x3,%eax
801019a9:	8d 50 02             	lea    0x2(%eax),%edx
801019ac:	8b 45 08             	mov    0x8(%ebp),%eax
801019af:	8b 00                	mov    (%eax),%eax
801019b1:	83 ec 08             	sub    $0x8,%esp
801019b4:	52                   	push   %edx
801019b5:	50                   	push   %eax
801019b6:	e8 fb e7 ff ff       	call   801001b6 <bread>
801019bb:	83 c4 10             	add    $0x10,%esp
801019be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801019c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c4:	8d 50 18             	lea    0x18(%eax),%edx
801019c7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ca:	8b 40 04             	mov    0x4(%eax),%eax
801019cd:	83 e0 07             	and    $0x7,%eax
801019d0:	c1 e0 06             	shl    $0x6,%eax
801019d3:	01 d0                	add    %edx,%eax
801019d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801019d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019db:	0f b7 10             	movzwl (%eax),%edx
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801019e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e8:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019ec:	8b 45 08             	mov    0x8(%ebp),%eax
801019ef:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f6:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019fa:	8b 45 08             	mov    0x8(%ebp),%eax
801019fd:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a04:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a12:	8b 50 08             	mov    0x8(%eax),%edx
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a1e:	8d 50 0c             	lea    0xc(%eax),%edx
80101a21:	8b 45 08             	mov    0x8(%ebp),%eax
80101a24:	83 c0 1c             	add    $0x1c,%eax
80101a27:	83 ec 04             	sub    $0x4,%esp
80101a2a:	6a 34                	push   $0x34
80101a2c:	52                   	push   %edx
80101a2d:	50                   	push   %eax
80101a2e:	e8 cb 40 00 00       	call   80105afe <memmove>
80101a33:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a36:	83 ec 0c             	sub    $0xc,%esp
80101a39:	ff 75 f4             	pushl  -0xc(%ebp)
80101a3c:	e8 ed e7 ff ff       	call   8010022e <brelse>
80101a41:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a44:	8b 45 08             	mov    0x8(%ebp),%eax
80101a47:	8b 40 0c             	mov    0xc(%eax),%eax
80101a4a:	83 c8 02             	or     $0x2,%eax
80101a4d:	89 c2                	mov    %eax,%edx
80101a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a52:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a55:	8b 45 08             	mov    0x8(%ebp),%eax
80101a58:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a5c:	66 85 c0             	test   %ax,%ax
80101a5f:	75 0d                	jne    80101a6e <ilock+0x155>
      panic("ilock: no type");
80101a61:	83 ec 0c             	sub    $0xc,%esp
80101a64:	68 55 90 10 80       	push   $0x80109055
80101a69:	e8 f8 ea ff ff       	call   80100566 <panic>
  }
}
80101a6e:	90                   	nop
80101a6f:	c9                   	leave  
80101a70:	c3                   	ret    

80101a71 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a71:	55                   	push   %ebp
80101a72:	89 e5                	mov    %esp,%ebp
80101a74:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a77:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a7b:	74 17                	je     80101a94 <iunlock+0x23>
80101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a80:	8b 40 0c             	mov    0xc(%eax),%eax
80101a83:	83 e0 01             	and    $0x1,%eax
80101a86:	85 c0                	test   %eax,%eax
80101a88:	74 0a                	je     80101a94 <iunlock+0x23>
80101a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8d:	8b 40 08             	mov    0x8(%eax),%eax
80101a90:	85 c0                	test   %eax,%eax
80101a92:	7f 0d                	jg     80101aa1 <iunlock+0x30>
    panic("iunlock");
80101a94:	83 ec 0c             	sub    $0xc,%esp
80101a97:	68 64 90 10 80       	push   $0x80109064
80101a9c:	e8 c5 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101aa1:	83 ec 0c             	sub    $0xc,%esp
80101aa4:	68 60 22 11 80       	push   $0x80112260
80101aa9:	e8 2e 3d 00 00       	call   801057dc <acquire>
80101aae:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab4:	8b 40 0c             	mov    0xc(%eax),%eax
80101ab7:	83 e0 fe             	and    $0xfffffffe,%eax
80101aba:	89 c2                	mov    %eax,%edx
80101abc:	8b 45 08             	mov    0x8(%ebp),%eax
80101abf:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101ac2:	83 ec 0c             	sub    $0xc,%esp
80101ac5:	ff 75 08             	pushl  0x8(%ebp)
80101ac8:	e8 cd 34 00 00       	call   80104f9a <wakeup>
80101acd:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101ad0:	83 ec 0c             	sub    $0xc,%esp
80101ad3:	68 60 22 11 80       	push   $0x80112260
80101ad8:	e8 66 3d 00 00       	call   80105843 <release>
80101add:	83 c4 10             	add    $0x10,%esp
}
80101ae0:	90                   	nop
80101ae1:	c9                   	leave  
80101ae2:	c3                   	ret    

80101ae3 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101ae3:	55                   	push   %ebp
80101ae4:	89 e5                	mov    %esp,%ebp
80101ae6:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ae9:	83 ec 0c             	sub    $0xc,%esp
80101aec:	68 60 22 11 80       	push   $0x80112260
80101af1:	e8 e6 3c 00 00       	call   801057dc <acquire>
80101af6:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101af9:	8b 45 08             	mov    0x8(%ebp),%eax
80101afc:	8b 40 08             	mov    0x8(%eax),%eax
80101aff:	83 f8 01             	cmp    $0x1,%eax
80101b02:	0f 85 a9 00 00 00    	jne    80101bb1 <iput+0xce>
80101b08:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0b:	8b 40 0c             	mov    0xc(%eax),%eax
80101b0e:	83 e0 02             	and    $0x2,%eax
80101b11:	85 c0                	test   %eax,%eax
80101b13:	0f 84 98 00 00 00    	je     80101bb1 <iput+0xce>
80101b19:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b20:	66 85 c0             	test   %ax,%ax
80101b23:	0f 85 88 00 00 00    	jne    80101bb1 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b29:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2c:	8b 40 0c             	mov    0xc(%eax),%eax
80101b2f:	83 e0 01             	and    $0x1,%eax
80101b32:	85 c0                	test   %eax,%eax
80101b34:	74 0d                	je     80101b43 <iput+0x60>
      panic("iput busy");
80101b36:	83 ec 0c             	sub    $0xc,%esp
80101b39:	68 6c 90 10 80       	push   $0x8010906c
80101b3e:	e8 23 ea ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b43:	8b 45 08             	mov    0x8(%ebp),%eax
80101b46:	8b 40 0c             	mov    0xc(%eax),%eax
80101b49:	83 c8 01             	or     $0x1,%eax
80101b4c:	89 c2                	mov    %eax,%edx
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b54:	83 ec 0c             	sub    $0xc,%esp
80101b57:	68 60 22 11 80       	push   $0x80112260
80101b5c:	e8 e2 3c 00 00       	call   80105843 <release>
80101b61:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101b64:	83 ec 0c             	sub    $0xc,%esp
80101b67:	ff 75 08             	pushl  0x8(%ebp)
80101b6a:	e8 a8 01 00 00       	call   80101d17 <itrunc>
80101b6f:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101b72:	8b 45 08             	mov    0x8(%ebp),%eax
80101b75:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b7b:	83 ec 0c             	sub    $0xc,%esp
80101b7e:	ff 75 08             	pushl  0x8(%ebp)
80101b81:	e8 bf fb ff ff       	call   80101745 <iupdate>
80101b86:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101b89:	83 ec 0c             	sub    $0xc,%esp
80101b8c:	68 60 22 11 80       	push   $0x80112260
80101b91:	e8 46 3c 00 00       	call   801057dc <acquire>
80101b96:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101b99:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ba3:	83 ec 0c             	sub    $0xc,%esp
80101ba6:	ff 75 08             	pushl  0x8(%ebp)
80101ba9:	e8 ec 33 00 00       	call   80104f9a <wakeup>
80101bae:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb4:	8b 40 08             	mov    0x8(%eax),%eax
80101bb7:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bba:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbd:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bc0:	83 ec 0c             	sub    $0xc,%esp
80101bc3:	68 60 22 11 80       	push   $0x80112260
80101bc8:	e8 76 3c 00 00       	call   80105843 <release>
80101bcd:	83 c4 10             	add    $0x10,%esp
}
80101bd0:	90                   	nop
80101bd1:	c9                   	leave  
80101bd2:	c3                   	ret    

80101bd3 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101bd3:	55                   	push   %ebp
80101bd4:	89 e5                	mov    %esp,%ebp
80101bd6:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101bd9:	83 ec 0c             	sub    $0xc,%esp
80101bdc:	ff 75 08             	pushl  0x8(%ebp)
80101bdf:	e8 8d fe ff ff       	call   80101a71 <iunlock>
80101be4:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101be7:	83 ec 0c             	sub    $0xc,%esp
80101bea:	ff 75 08             	pushl  0x8(%ebp)
80101bed:	e8 f1 fe ff ff       	call   80101ae3 <iput>
80101bf2:	83 c4 10             	add    $0x10,%esp
}
80101bf5:	90                   	nop
80101bf6:	c9                   	leave  
80101bf7:	c3                   	ret    

80101bf8 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101bf8:	55                   	push   %ebp
80101bf9:	89 e5                	mov    %esp,%ebp
80101bfb:	53                   	push   %ebx
80101bfc:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101bff:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c03:	77 42                	ja     80101c47 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c05:	8b 45 08             	mov    0x8(%ebp),%eax
80101c08:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c0b:	83 c2 04             	add    $0x4,%edx
80101c0e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c12:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c19:	75 24                	jne    80101c3f <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	8b 00                	mov    (%eax),%eax
80101c20:	83 ec 0c             	sub    $0xc,%esp
80101c23:	50                   	push   %eax
80101c24:	e8 e4 f7 ff ff       	call   8010140d <balloc>
80101c29:	83 c4 10             	add    $0x10,%esp
80101c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c32:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c35:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c3b:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c42:	e9 cb 00 00 00       	jmp    80101d12 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c47:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c4b:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c4f:	0f 87 b0 00 00 00    	ja     80101d05 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c55:	8b 45 08             	mov    0x8(%ebp),%eax
80101c58:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c62:	75 1d                	jne    80101c81 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c64:	8b 45 08             	mov    0x8(%ebp),%eax
80101c67:	8b 00                	mov    (%eax),%eax
80101c69:	83 ec 0c             	sub    $0xc,%esp
80101c6c:	50                   	push   %eax
80101c6d:	e8 9b f7 ff ff       	call   8010140d <balloc>
80101c72:	83 c4 10             	add    $0x10,%esp
80101c75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c78:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c7e:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c81:	8b 45 08             	mov    0x8(%ebp),%eax
80101c84:	8b 00                	mov    (%eax),%eax
80101c86:	83 ec 08             	sub    $0x8,%esp
80101c89:	ff 75 f4             	pushl  -0xc(%ebp)
80101c8c:	50                   	push   %eax
80101c8d:	e8 24 e5 ff ff       	call   801001b6 <bread>
80101c92:	83 c4 10             	add    $0x10,%esp
80101c95:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c9b:	83 c0 18             	add    $0x18,%eax
80101c9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ca4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cae:	01 d0                	add    %edx,%eax
80101cb0:	8b 00                	mov    (%eax),%eax
80101cb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb9:	75 37                	jne    80101cf2 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cbe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cc8:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cce:	8b 00                	mov    (%eax),%eax
80101cd0:	83 ec 0c             	sub    $0xc,%esp
80101cd3:	50                   	push   %eax
80101cd4:	e8 34 f7 ff ff       	call   8010140d <balloc>
80101cd9:	83 c4 10             	add    $0x10,%esp
80101cdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ce2:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ce4:	83 ec 0c             	sub    $0xc,%esp
80101ce7:	ff 75 f0             	pushl  -0x10(%ebp)
80101cea:	e8 0b 1a 00 00       	call   801036fa <log_write>
80101cef:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101cf2:	83 ec 0c             	sub    $0xc,%esp
80101cf5:	ff 75 f0             	pushl  -0x10(%ebp)
80101cf8:	e8 31 e5 ff ff       	call   8010022e <brelse>
80101cfd:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d03:	eb 0d                	jmp    80101d12 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d05:	83 ec 0c             	sub    $0xc,%esp
80101d08:	68 76 90 10 80       	push   $0x80109076
80101d0d:	e8 54 e8 ff ff       	call   80100566 <panic>
}
80101d12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d15:	c9                   	leave  
80101d16:	c3                   	ret    

80101d17 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d17:	55                   	push   %ebp
80101d18:	89 e5                	mov    %esp,%ebp
80101d1a:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d1d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d24:	eb 45                	jmp    80101d6b <itrunc+0x54>
    if(ip->addrs[i]){
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d2c:	83 c2 04             	add    $0x4,%edx
80101d2f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d33:	85 c0                	test   %eax,%eax
80101d35:	74 30                	je     80101d67 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d37:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d3d:	83 c2 04             	add    $0x4,%edx
80101d40:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d44:	8b 55 08             	mov    0x8(%ebp),%edx
80101d47:	8b 12                	mov    (%edx),%edx
80101d49:	83 ec 08             	sub    $0x8,%esp
80101d4c:	50                   	push   %eax
80101d4d:	52                   	push   %edx
80101d4e:	e8 18 f8 ff ff       	call   8010156b <bfree>
80101d53:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d56:	8b 45 08             	mov    0x8(%ebp),%eax
80101d59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d5c:	83 c2 04             	add    $0x4,%edx
80101d5f:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d66:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d6b:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d6f:	7e b5                	jle    80101d26 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d71:	8b 45 08             	mov    0x8(%ebp),%eax
80101d74:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d77:	85 c0                	test   %eax,%eax
80101d79:	0f 84 a1 00 00 00    	je     80101e20 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d82:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d85:	8b 45 08             	mov    0x8(%ebp),%eax
80101d88:	8b 00                	mov    (%eax),%eax
80101d8a:	83 ec 08             	sub    $0x8,%esp
80101d8d:	52                   	push   %edx
80101d8e:	50                   	push   %eax
80101d8f:	e8 22 e4 ff ff       	call   801001b6 <bread>
80101d94:	83 c4 10             	add    $0x10,%esp
80101d97:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d9d:	83 c0 18             	add    $0x18,%eax
80101da0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101da3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101daa:	eb 3c                	jmp    80101de8 <itrunc+0xd1>
      if(a[j])
80101dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101daf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101db6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101db9:	01 d0                	add    %edx,%eax
80101dbb:	8b 00                	mov    (%eax),%eax
80101dbd:	85 c0                	test   %eax,%eax
80101dbf:	74 23                	je     80101de4 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dc4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dce:	01 d0                	add    %edx,%eax
80101dd0:	8b 00                	mov    (%eax),%eax
80101dd2:	8b 55 08             	mov    0x8(%ebp),%edx
80101dd5:	8b 12                	mov    (%edx),%edx
80101dd7:	83 ec 08             	sub    $0x8,%esp
80101dda:	50                   	push   %eax
80101ddb:	52                   	push   %edx
80101ddc:	e8 8a f7 ff ff       	call   8010156b <bfree>
80101de1:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101de4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101deb:	83 f8 7f             	cmp    $0x7f,%eax
80101dee:	76 bc                	jbe    80101dac <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101df0:	83 ec 0c             	sub    $0xc,%esp
80101df3:	ff 75 ec             	pushl  -0x14(%ebp)
80101df6:	e8 33 e4 ff ff       	call   8010022e <brelse>
80101dfb:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e04:	8b 55 08             	mov    0x8(%ebp),%edx
80101e07:	8b 12                	mov    (%edx),%edx
80101e09:	83 ec 08             	sub    $0x8,%esp
80101e0c:	50                   	push   %eax
80101e0d:	52                   	push   %edx
80101e0e:	e8 58 f7 ff ff       	call   8010156b <bfree>
80101e13:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e16:	8b 45 08             	mov    0x8(%ebp),%eax
80101e19:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e20:	8b 45 08             	mov    0x8(%ebp),%eax
80101e23:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e2a:	83 ec 0c             	sub    $0xc,%esp
80101e2d:	ff 75 08             	pushl  0x8(%ebp)
80101e30:	e8 10 f9 ff ff       	call   80101745 <iupdate>
80101e35:	83 c4 10             	add    $0x10,%esp
}
80101e38:	90                   	nop
80101e39:	c9                   	leave  
80101e3a:	c3                   	ret    

80101e3b <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e3b:	55                   	push   %ebp
80101e3c:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e41:	8b 00                	mov    (%eax),%eax
80101e43:	89 c2                	mov    %eax,%edx
80101e45:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e48:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4e:	8b 50 04             	mov    0x4(%eax),%edx
80101e51:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e54:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e57:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5a:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e61:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e6e:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101e72:	8b 45 08             	mov    0x8(%ebp),%eax
80101e75:	8b 50 18             	mov    0x18(%eax),%edx
80101e78:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e7b:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e7e:	90                   	nop
80101e7f:	5d                   	pop    %ebp
80101e80:	c3                   	ret    

80101e81 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e81:	55                   	push   %ebp
80101e82:	89 e5                	mov    %esp,%ebp
80101e84:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e87:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101e8e:	66 83 f8 03          	cmp    $0x3,%ax
80101e92:	75 5c                	jne    80101ef0 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e94:	8b 45 08             	mov    0x8(%ebp),%eax
80101e97:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e9b:	66 85 c0             	test   %ax,%ax
80101e9e:	78 20                	js     80101ec0 <readi+0x3f>
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ea7:	66 83 f8 09          	cmp    $0x9,%ax
80101eab:	7f 13                	jg     80101ec0 <readi+0x3f>
80101ead:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eb4:	98                   	cwtl   
80101eb5:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101ebc:	85 c0                	test   %eax,%eax
80101ebe:	75 0a                	jne    80101eca <readi+0x49>
      return -1;
80101ec0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ec5:	e9 0c 01 00 00       	jmp    80101fd6 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101eca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecd:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ed1:	98                   	cwtl   
80101ed2:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101ed9:	8b 55 14             	mov    0x14(%ebp),%edx
80101edc:	83 ec 04             	sub    $0x4,%esp
80101edf:	52                   	push   %edx
80101ee0:	ff 75 0c             	pushl  0xc(%ebp)
80101ee3:	ff 75 08             	pushl  0x8(%ebp)
80101ee6:	ff d0                	call   *%eax
80101ee8:	83 c4 10             	add    $0x10,%esp
80101eeb:	e9 e6 00 00 00       	jmp    80101fd6 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101ef0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef3:	8b 40 18             	mov    0x18(%eax),%eax
80101ef6:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ef9:	72 0d                	jb     80101f08 <readi+0x87>
80101efb:	8b 55 10             	mov    0x10(%ebp),%edx
80101efe:	8b 45 14             	mov    0x14(%ebp),%eax
80101f01:	01 d0                	add    %edx,%eax
80101f03:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f06:	73 0a                	jae    80101f12 <readi+0x91>
    return -1;
80101f08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f0d:	e9 c4 00 00 00       	jmp    80101fd6 <readi+0x155>
  if(off + n > ip->size)
80101f12:	8b 55 10             	mov    0x10(%ebp),%edx
80101f15:	8b 45 14             	mov    0x14(%ebp),%eax
80101f18:	01 c2                	add    %eax,%edx
80101f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1d:	8b 40 18             	mov    0x18(%eax),%eax
80101f20:	39 c2                	cmp    %eax,%edx
80101f22:	76 0c                	jbe    80101f30 <readi+0xaf>
    n = ip->size - off;
80101f24:	8b 45 08             	mov    0x8(%ebp),%eax
80101f27:	8b 40 18             	mov    0x18(%eax),%eax
80101f2a:	2b 45 10             	sub    0x10(%ebp),%eax
80101f2d:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f30:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f37:	e9 8b 00 00 00       	jmp    80101fc7 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f3c:	8b 45 10             	mov    0x10(%ebp),%eax
80101f3f:	c1 e8 09             	shr    $0x9,%eax
80101f42:	83 ec 08             	sub    $0x8,%esp
80101f45:	50                   	push   %eax
80101f46:	ff 75 08             	pushl  0x8(%ebp)
80101f49:	e8 aa fc ff ff       	call   80101bf8 <bmap>
80101f4e:	83 c4 10             	add    $0x10,%esp
80101f51:	89 c2                	mov    %eax,%edx
80101f53:	8b 45 08             	mov    0x8(%ebp),%eax
80101f56:	8b 00                	mov    (%eax),%eax
80101f58:	83 ec 08             	sub    $0x8,%esp
80101f5b:	52                   	push   %edx
80101f5c:	50                   	push   %eax
80101f5d:	e8 54 e2 ff ff       	call   801001b6 <bread>
80101f62:	83 c4 10             	add    $0x10,%esp
80101f65:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f68:	8b 45 10             	mov    0x10(%ebp),%eax
80101f6b:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f70:	ba 00 02 00 00       	mov    $0x200,%edx
80101f75:	29 c2                	sub    %eax,%edx
80101f77:	8b 45 14             	mov    0x14(%ebp),%eax
80101f7a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101f7d:	39 c2                	cmp    %eax,%edx
80101f7f:	0f 46 c2             	cmovbe %edx,%eax
80101f82:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f88:	8d 50 18             	lea    0x18(%eax),%edx
80101f8b:	8b 45 10             	mov    0x10(%ebp),%eax
80101f8e:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f93:	01 d0                	add    %edx,%eax
80101f95:	83 ec 04             	sub    $0x4,%esp
80101f98:	ff 75 ec             	pushl  -0x14(%ebp)
80101f9b:	50                   	push   %eax
80101f9c:	ff 75 0c             	pushl  0xc(%ebp)
80101f9f:	e8 5a 3b 00 00       	call   80105afe <memmove>
80101fa4:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101fa7:	83 ec 0c             	sub    $0xc,%esp
80101faa:	ff 75 f0             	pushl  -0x10(%ebp)
80101fad:	e8 7c e2 ff ff       	call   8010022e <brelse>
80101fb2:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fb8:	01 45 f4             	add    %eax,-0xc(%ebp)
80101fbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fbe:	01 45 10             	add    %eax,0x10(%ebp)
80101fc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fc4:	01 45 0c             	add    %eax,0xc(%ebp)
80101fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fca:	3b 45 14             	cmp    0x14(%ebp),%eax
80101fcd:	0f 82 69 ff ff ff    	jb     80101f3c <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101fd3:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101fd6:	c9                   	leave  
80101fd7:	c3                   	ret    

80101fd8 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101fd8:	55                   	push   %ebp
80101fd9:	89 e5                	mov    %esp,%ebp
80101fdb:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fde:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fe5:	66 83 f8 03          	cmp    $0x3,%ax
80101fe9:	75 5c                	jne    80102047 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101feb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fee:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ff2:	66 85 c0             	test   %ax,%ax
80101ff5:	78 20                	js     80102017 <writei+0x3f>
80101ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffa:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ffe:	66 83 f8 09          	cmp    $0x9,%ax
80102002:	7f 13                	jg     80102017 <writei+0x3f>
80102004:	8b 45 08             	mov    0x8(%ebp),%eax
80102007:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010200b:	98                   	cwtl   
8010200c:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80102013:	85 c0                	test   %eax,%eax
80102015:	75 0a                	jne    80102021 <writei+0x49>
      return -1;
80102017:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010201c:	e9 3d 01 00 00       	jmp    8010215e <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102028:	98                   	cwtl   
80102029:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80102030:	8b 55 14             	mov    0x14(%ebp),%edx
80102033:	83 ec 04             	sub    $0x4,%esp
80102036:	52                   	push   %edx
80102037:	ff 75 0c             	pushl  0xc(%ebp)
8010203a:	ff 75 08             	pushl  0x8(%ebp)
8010203d:	ff d0                	call   *%eax
8010203f:	83 c4 10             	add    $0x10,%esp
80102042:	e9 17 01 00 00       	jmp    8010215e <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102047:	8b 45 08             	mov    0x8(%ebp),%eax
8010204a:	8b 40 18             	mov    0x18(%eax),%eax
8010204d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102050:	72 0d                	jb     8010205f <writei+0x87>
80102052:	8b 55 10             	mov    0x10(%ebp),%edx
80102055:	8b 45 14             	mov    0x14(%ebp),%eax
80102058:	01 d0                	add    %edx,%eax
8010205a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010205d:	73 0a                	jae    80102069 <writei+0x91>
    return -1;
8010205f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102064:	e9 f5 00 00 00       	jmp    8010215e <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102069:	8b 55 10             	mov    0x10(%ebp),%edx
8010206c:	8b 45 14             	mov    0x14(%ebp),%eax
8010206f:	01 d0                	add    %edx,%eax
80102071:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102076:	76 0a                	jbe    80102082 <writei+0xaa>
    return -1;
80102078:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010207d:	e9 dc 00 00 00       	jmp    8010215e <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102082:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102089:	e9 99 00 00 00       	jmp    80102127 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010208e:	8b 45 10             	mov    0x10(%ebp),%eax
80102091:	c1 e8 09             	shr    $0x9,%eax
80102094:	83 ec 08             	sub    $0x8,%esp
80102097:	50                   	push   %eax
80102098:	ff 75 08             	pushl  0x8(%ebp)
8010209b:	e8 58 fb ff ff       	call   80101bf8 <bmap>
801020a0:	83 c4 10             	add    $0x10,%esp
801020a3:	89 c2                	mov    %eax,%edx
801020a5:	8b 45 08             	mov    0x8(%ebp),%eax
801020a8:	8b 00                	mov    (%eax),%eax
801020aa:	83 ec 08             	sub    $0x8,%esp
801020ad:	52                   	push   %edx
801020ae:	50                   	push   %eax
801020af:	e8 02 e1 ff ff       	call   801001b6 <bread>
801020b4:	83 c4 10             	add    $0x10,%esp
801020b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020ba:	8b 45 10             	mov    0x10(%ebp),%eax
801020bd:	25 ff 01 00 00       	and    $0x1ff,%eax
801020c2:	ba 00 02 00 00       	mov    $0x200,%edx
801020c7:	29 c2                	sub    %eax,%edx
801020c9:	8b 45 14             	mov    0x14(%ebp),%eax
801020cc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020cf:	39 c2                	cmp    %eax,%edx
801020d1:	0f 46 c2             	cmovbe %edx,%eax
801020d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801020d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020da:	8d 50 18             	lea    0x18(%eax),%edx
801020dd:	8b 45 10             	mov    0x10(%ebp),%eax
801020e0:	25 ff 01 00 00       	and    $0x1ff,%eax
801020e5:	01 d0                	add    %edx,%eax
801020e7:	83 ec 04             	sub    $0x4,%esp
801020ea:	ff 75 ec             	pushl  -0x14(%ebp)
801020ed:	ff 75 0c             	pushl  0xc(%ebp)
801020f0:	50                   	push   %eax
801020f1:	e8 08 3a 00 00       	call   80105afe <memmove>
801020f6:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801020f9:	83 ec 0c             	sub    $0xc,%esp
801020fc:	ff 75 f0             	pushl  -0x10(%ebp)
801020ff:	e8 f6 15 00 00       	call   801036fa <log_write>
80102104:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102107:	83 ec 0c             	sub    $0xc,%esp
8010210a:	ff 75 f0             	pushl  -0x10(%ebp)
8010210d:	e8 1c e1 ff ff       	call   8010022e <brelse>
80102112:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102115:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102118:	01 45 f4             	add    %eax,-0xc(%ebp)
8010211b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010211e:	01 45 10             	add    %eax,0x10(%ebp)
80102121:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102124:	01 45 0c             	add    %eax,0xc(%ebp)
80102127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010212a:	3b 45 14             	cmp    0x14(%ebp),%eax
8010212d:	0f 82 5b ff ff ff    	jb     8010208e <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102133:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102137:	74 22                	je     8010215b <writei+0x183>
80102139:	8b 45 08             	mov    0x8(%ebp),%eax
8010213c:	8b 40 18             	mov    0x18(%eax),%eax
8010213f:	3b 45 10             	cmp    0x10(%ebp),%eax
80102142:	73 17                	jae    8010215b <writei+0x183>
    ip->size = off;
80102144:	8b 45 08             	mov    0x8(%ebp),%eax
80102147:	8b 55 10             	mov    0x10(%ebp),%edx
8010214a:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010214d:	83 ec 0c             	sub    $0xc,%esp
80102150:	ff 75 08             	pushl  0x8(%ebp)
80102153:	e8 ed f5 ff ff       	call   80101745 <iupdate>
80102158:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010215b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010215e:	c9                   	leave  
8010215f:	c3                   	ret    

80102160 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102160:	55                   	push   %ebp
80102161:	89 e5                	mov    %esp,%ebp
80102163:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102166:	83 ec 04             	sub    $0x4,%esp
80102169:	6a 0e                	push   $0xe
8010216b:	ff 75 0c             	pushl  0xc(%ebp)
8010216e:	ff 75 08             	pushl  0x8(%ebp)
80102171:	e8 1e 3a 00 00       	call   80105b94 <strncmp>
80102176:	83 c4 10             	add    $0x10,%esp
}
80102179:	c9                   	leave  
8010217a:	c3                   	ret    

8010217b <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010217b:	55                   	push   %ebp
8010217c:	89 e5                	mov    %esp,%ebp
8010217e:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102181:	8b 45 08             	mov    0x8(%ebp),%eax
80102184:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102188:	66 83 f8 01          	cmp    $0x1,%ax
8010218c:	74 0d                	je     8010219b <dirlookup+0x20>
    panic("dirlookup not DIR");
8010218e:	83 ec 0c             	sub    $0xc,%esp
80102191:	68 89 90 10 80       	push   $0x80109089
80102196:	e8 cb e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010219b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021a2:	eb 7b                	jmp    8010221f <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021a4:	6a 10                	push   $0x10
801021a6:	ff 75 f4             	pushl  -0xc(%ebp)
801021a9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021ac:	50                   	push   %eax
801021ad:	ff 75 08             	pushl  0x8(%ebp)
801021b0:	e8 cc fc ff ff       	call   80101e81 <readi>
801021b5:	83 c4 10             	add    $0x10,%esp
801021b8:	83 f8 10             	cmp    $0x10,%eax
801021bb:	74 0d                	je     801021ca <dirlookup+0x4f>
      panic("dirlink read");
801021bd:	83 ec 0c             	sub    $0xc,%esp
801021c0:	68 9b 90 10 80       	push   $0x8010909b
801021c5:	e8 9c e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801021ca:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021ce:	66 85 c0             	test   %ax,%ax
801021d1:	74 47                	je     8010221a <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801021d3:	83 ec 08             	sub    $0x8,%esp
801021d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021d9:	83 c0 02             	add    $0x2,%eax
801021dc:	50                   	push   %eax
801021dd:	ff 75 0c             	pushl  0xc(%ebp)
801021e0:	e8 7b ff ff ff       	call   80102160 <namecmp>
801021e5:	83 c4 10             	add    $0x10,%esp
801021e8:	85 c0                	test   %eax,%eax
801021ea:	75 2f                	jne    8010221b <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801021ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801021f0:	74 08                	je     801021fa <dirlookup+0x7f>
        *poff = off;
801021f2:	8b 45 10             	mov    0x10(%ebp),%eax
801021f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021f8:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801021fa:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021fe:	0f b7 c0             	movzwl %ax,%eax
80102201:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102204:	8b 45 08             	mov    0x8(%ebp),%eax
80102207:	8b 00                	mov    (%eax),%eax
80102209:	83 ec 08             	sub    $0x8,%esp
8010220c:	ff 75 f0             	pushl  -0x10(%ebp)
8010220f:	50                   	push   %eax
80102210:	e8 eb f5 ff ff       	call   80101800 <iget>
80102215:	83 c4 10             	add    $0x10,%esp
80102218:	eb 19                	jmp    80102233 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010221a:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010221b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010221f:	8b 45 08             	mov    0x8(%ebp),%eax
80102222:	8b 40 18             	mov    0x18(%eax),%eax
80102225:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102228:	0f 87 76 ff ff ff    	ja     801021a4 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010222e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102233:	c9                   	leave  
80102234:	c3                   	ret    

80102235 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102235:	55                   	push   %ebp
80102236:	89 e5                	mov    %esp,%ebp
80102238:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010223b:	83 ec 04             	sub    $0x4,%esp
8010223e:	6a 00                	push   $0x0
80102240:	ff 75 0c             	pushl  0xc(%ebp)
80102243:	ff 75 08             	pushl  0x8(%ebp)
80102246:	e8 30 ff ff ff       	call   8010217b <dirlookup>
8010224b:	83 c4 10             	add    $0x10,%esp
8010224e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102251:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102255:	74 18                	je     8010226f <dirlink+0x3a>
    iput(ip);
80102257:	83 ec 0c             	sub    $0xc,%esp
8010225a:	ff 75 f0             	pushl  -0x10(%ebp)
8010225d:	e8 81 f8 ff ff       	call   80101ae3 <iput>
80102262:	83 c4 10             	add    $0x10,%esp
    return -1;
80102265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010226a:	e9 9c 00 00 00       	jmp    8010230b <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102276:	eb 39                	jmp    801022b1 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010227b:	6a 10                	push   $0x10
8010227d:	50                   	push   %eax
8010227e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102281:	50                   	push   %eax
80102282:	ff 75 08             	pushl  0x8(%ebp)
80102285:	e8 f7 fb ff ff       	call   80101e81 <readi>
8010228a:	83 c4 10             	add    $0x10,%esp
8010228d:	83 f8 10             	cmp    $0x10,%eax
80102290:	74 0d                	je     8010229f <dirlink+0x6a>
      panic("dirlink read");
80102292:	83 ec 0c             	sub    $0xc,%esp
80102295:	68 9b 90 10 80       	push   $0x8010909b
8010229a:	e8 c7 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
8010229f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022a3:	66 85 c0             	test   %ax,%ax
801022a6:	74 18                	je     801022c0 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ab:	83 c0 10             	add    $0x10,%eax
801022ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022b1:	8b 45 08             	mov    0x8(%ebp),%eax
801022b4:	8b 50 18             	mov    0x18(%eax),%edx
801022b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ba:	39 c2                	cmp    %eax,%edx
801022bc:	77 ba                	ja     80102278 <dirlink+0x43>
801022be:	eb 01                	jmp    801022c1 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801022c0:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801022c1:	83 ec 04             	sub    $0x4,%esp
801022c4:	6a 0e                	push   $0xe
801022c6:	ff 75 0c             	pushl  0xc(%ebp)
801022c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022cc:	83 c0 02             	add    $0x2,%eax
801022cf:	50                   	push   %eax
801022d0:	e8 15 39 00 00       	call   80105bea <strncpy>
801022d5:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801022d8:	8b 45 10             	mov    0x10(%ebp),%eax
801022db:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e2:	6a 10                	push   $0x10
801022e4:	50                   	push   %eax
801022e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e8:	50                   	push   %eax
801022e9:	ff 75 08             	pushl  0x8(%ebp)
801022ec:	e8 e7 fc ff ff       	call   80101fd8 <writei>
801022f1:	83 c4 10             	add    $0x10,%esp
801022f4:	83 f8 10             	cmp    $0x10,%eax
801022f7:	74 0d                	je     80102306 <dirlink+0xd1>
    panic("dirlink");
801022f9:	83 ec 0c             	sub    $0xc,%esp
801022fc:	68 a8 90 10 80       	push   $0x801090a8
80102301:	e8 60 e2 ff ff       	call   80100566 <panic>
  
  return 0;
80102306:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010230b:	c9                   	leave  
8010230c:	c3                   	ret    

8010230d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010230d:	55                   	push   %ebp
8010230e:	89 e5                	mov    %esp,%ebp
80102310:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102313:	eb 04                	jmp    80102319 <skipelem+0xc>
    path++;
80102315:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102319:	8b 45 08             	mov    0x8(%ebp),%eax
8010231c:	0f b6 00             	movzbl (%eax),%eax
8010231f:	3c 2f                	cmp    $0x2f,%al
80102321:	74 f2                	je     80102315 <skipelem+0x8>
    path++;
  if(*path == 0)
80102323:	8b 45 08             	mov    0x8(%ebp),%eax
80102326:	0f b6 00             	movzbl (%eax),%eax
80102329:	84 c0                	test   %al,%al
8010232b:	75 07                	jne    80102334 <skipelem+0x27>
    return 0;
8010232d:	b8 00 00 00 00       	mov    $0x0,%eax
80102332:	eb 7b                	jmp    801023af <skipelem+0xa2>
  s = path;
80102334:	8b 45 08             	mov    0x8(%ebp),%eax
80102337:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010233a:	eb 04                	jmp    80102340 <skipelem+0x33>
    path++;
8010233c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102340:	8b 45 08             	mov    0x8(%ebp),%eax
80102343:	0f b6 00             	movzbl (%eax),%eax
80102346:	3c 2f                	cmp    $0x2f,%al
80102348:	74 0a                	je     80102354 <skipelem+0x47>
8010234a:	8b 45 08             	mov    0x8(%ebp),%eax
8010234d:	0f b6 00             	movzbl (%eax),%eax
80102350:	84 c0                	test   %al,%al
80102352:	75 e8                	jne    8010233c <skipelem+0x2f>
    path++;
  len = path - s;
80102354:	8b 55 08             	mov    0x8(%ebp),%edx
80102357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235a:	29 c2                	sub    %eax,%edx
8010235c:	89 d0                	mov    %edx,%eax
8010235e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102361:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102365:	7e 15                	jle    8010237c <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102367:	83 ec 04             	sub    $0x4,%esp
8010236a:	6a 0e                	push   $0xe
8010236c:	ff 75 f4             	pushl  -0xc(%ebp)
8010236f:	ff 75 0c             	pushl  0xc(%ebp)
80102372:	e8 87 37 00 00       	call   80105afe <memmove>
80102377:	83 c4 10             	add    $0x10,%esp
8010237a:	eb 26                	jmp    801023a2 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010237c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010237f:	83 ec 04             	sub    $0x4,%esp
80102382:	50                   	push   %eax
80102383:	ff 75 f4             	pushl  -0xc(%ebp)
80102386:	ff 75 0c             	pushl  0xc(%ebp)
80102389:	e8 70 37 00 00       	call   80105afe <memmove>
8010238e:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102391:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102394:	8b 45 0c             	mov    0xc(%ebp),%eax
80102397:	01 d0                	add    %edx,%eax
80102399:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010239c:	eb 04                	jmp    801023a2 <skipelem+0x95>
    path++;
8010239e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023a2:	8b 45 08             	mov    0x8(%ebp),%eax
801023a5:	0f b6 00             	movzbl (%eax),%eax
801023a8:	3c 2f                	cmp    $0x2f,%al
801023aa:	74 f2                	je     8010239e <skipelem+0x91>
    path++;
  return path;
801023ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023af:	c9                   	leave  
801023b0:	c3                   	ret    

801023b1 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023b1:	55                   	push   %ebp
801023b2:	89 e5                	mov    %esp,%ebp
801023b4:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023b7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ba:	0f b6 00             	movzbl (%eax),%eax
801023bd:	3c 2f                	cmp    $0x2f,%al
801023bf:	75 17                	jne    801023d8 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801023c1:	83 ec 08             	sub    $0x8,%esp
801023c4:	6a 01                	push   $0x1
801023c6:	6a 01                	push   $0x1
801023c8:	e8 33 f4 ff ff       	call   80101800 <iget>
801023cd:	83 c4 10             	add    $0x10,%esp
801023d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023d3:	e9 bb 00 00 00       	jmp    80102493 <namex+0xe2>
  else
    ip = idup(proc->cwd);
801023d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023de:	8b 40 68             	mov    0x68(%eax),%eax
801023e1:	83 ec 0c             	sub    $0xc,%esp
801023e4:	50                   	push   %eax
801023e5:	e8 f5 f4 ff ff       	call   801018df <idup>
801023ea:	83 c4 10             	add    $0x10,%esp
801023ed:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023f0:	e9 9e 00 00 00       	jmp    80102493 <namex+0xe2>
    ilock(ip);
801023f5:	83 ec 0c             	sub    $0xc,%esp
801023f8:	ff 75 f4             	pushl  -0xc(%ebp)
801023fb:	e8 19 f5 ff ff       	call   80101919 <ilock>
80102400:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102406:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010240a:	66 83 f8 01          	cmp    $0x1,%ax
8010240e:	74 18                	je     80102428 <namex+0x77>
      iunlockput(ip);
80102410:	83 ec 0c             	sub    $0xc,%esp
80102413:	ff 75 f4             	pushl  -0xc(%ebp)
80102416:	e8 b8 f7 ff ff       	call   80101bd3 <iunlockput>
8010241b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010241e:	b8 00 00 00 00       	mov    $0x0,%eax
80102423:	e9 a7 00 00 00       	jmp    801024cf <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102428:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010242c:	74 20                	je     8010244e <namex+0x9d>
8010242e:	8b 45 08             	mov    0x8(%ebp),%eax
80102431:	0f b6 00             	movzbl (%eax),%eax
80102434:	84 c0                	test   %al,%al
80102436:	75 16                	jne    8010244e <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102438:	83 ec 0c             	sub    $0xc,%esp
8010243b:	ff 75 f4             	pushl  -0xc(%ebp)
8010243e:	e8 2e f6 ff ff       	call   80101a71 <iunlock>
80102443:	83 c4 10             	add    $0x10,%esp
      return ip;
80102446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102449:	e9 81 00 00 00       	jmp    801024cf <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010244e:	83 ec 04             	sub    $0x4,%esp
80102451:	6a 00                	push   $0x0
80102453:	ff 75 10             	pushl  0x10(%ebp)
80102456:	ff 75 f4             	pushl  -0xc(%ebp)
80102459:	e8 1d fd ff ff       	call   8010217b <dirlookup>
8010245e:	83 c4 10             	add    $0x10,%esp
80102461:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102464:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102468:	75 15                	jne    8010247f <namex+0xce>
      iunlockput(ip);
8010246a:	83 ec 0c             	sub    $0xc,%esp
8010246d:	ff 75 f4             	pushl  -0xc(%ebp)
80102470:	e8 5e f7 ff ff       	call   80101bd3 <iunlockput>
80102475:	83 c4 10             	add    $0x10,%esp
      return 0;
80102478:	b8 00 00 00 00       	mov    $0x0,%eax
8010247d:	eb 50                	jmp    801024cf <namex+0x11e>
    }
    iunlockput(ip);
8010247f:	83 ec 0c             	sub    $0xc,%esp
80102482:	ff 75 f4             	pushl  -0xc(%ebp)
80102485:	e8 49 f7 ff ff       	call   80101bd3 <iunlockput>
8010248a:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010248d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102490:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102493:	83 ec 08             	sub    $0x8,%esp
80102496:	ff 75 10             	pushl  0x10(%ebp)
80102499:	ff 75 08             	pushl  0x8(%ebp)
8010249c:	e8 6c fe ff ff       	call   8010230d <skipelem>
801024a1:	83 c4 10             	add    $0x10,%esp
801024a4:	89 45 08             	mov    %eax,0x8(%ebp)
801024a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024ab:	0f 85 44 ff ff ff    	jne    801023f5 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801024b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024b5:	74 15                	je     801024cc <namex+0x11b>
    iput(ip);
801024b7:	83 ec 0c             	sub    $0xc,%esp
801024ba:	ff 75 f4             	pushl  -0xc(%ebp)
801024bd:	e8 21 f6 ff ff       	call   80101ae3 <iput>
801024c2:	83 c4 10             	add    $0x10,%esp
    return 0;
801024c5:	b8 00 00 00 00       	mov    $0x0,%eax
801024ca:	eb 03                	jmp    801024cf <namex+0x11e>
  }
  return ip;
801024cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801024cf:	c9                   	leave  
801024d0:	c3                   	ret    

801024d1 <namei>:

struct inode*
namei(char *path)
{
801024d1:	55                   	push   %ebp
801024d2:	89 e5                	mov    %esp,%ebp
801024d4:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801024d7:	83 ec 04             	sub    $0x4,%esp
801024da:	8d 45 ea             	lea    -0x16(%ebp),%eax
801024dd:	50                   	push   %eax
801024de:	6a 00                	push   $0x0
801024e0:	ff 75 08             	pushl  0x8(%ebp)
801024e3:	e8 c9 fe ff ff       	call   801023b1 <namex>
801024e8:	83 c4 10             	add    $0x10,%esp
}
801024eb:	c9                   	leave  
801024ec:	c3                   	ret    

801024ed <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024ed:	55                   	push   %ebp
801024ee:	89 e5                	mov    %esp,%ebp
801024f0:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801024f3:	83 ec 04             	sub    $0x4,%esp
801024f6:	ff 75 0c             	pushl  0xc(%ebp)
801024f9:	6a 01                	push   $0x1
801024fb:	ff 75 08             	pushl  0x8(%ebp)
801024fe:	e8 ae fe ff ff       	call   801023b1 <namex>
80102503:	83 c4 10             	add    $0x10,%esp
}
80102506:	c9                   	leave  
80102507:	c3                   	ret    

80102508 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102508:	55                   	push   %ebp
80102509:	89 e5                	mov    %esp,%ebp
8010250b:	83 ec 14             	sub    $0x14,%esp
8010250e:	8b 45 08             	mov    0x8(%ebp),%eax
80102511:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102515:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102519:	89 c2                	mov    %eax,%edx
8010251b:	ec                   	in     (%dx),%al
8010251c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010251f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102523:	c9                   	leave  
80102524:	c3                   	ret    

80102525 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102525:	55                   	push   %ebp
80102526:	89 e5                	mov    %esp,%ebp
80102528:	57                   	push   %edi
80102529:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010252a:	8b 55 08             	mov    0x8(%ebp),%edx
8010252d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102530:	8b 45 10             	mov    0x10(%ebp),%eax
80102533:	89 cb                	mov    %ecx,%ebx
80102535:	89 df                	mov    %ebx,%edi
80102537:	89 c1                	mov    %eax,%ecx
80102539:	fc                   	cld    
8010253a:	f3 6d                	rep insl (%dx),%es:(%edi)
8010253c:	89 c8                	mov    %ecx,%eax
8010253e:	89 fb                	mov    %edi,%ebx
80102540:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102543:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102546:	90                   	nop
80102547:	5b                   	pop    %ebx
80102548:	5f                   	pop    %edi
80102549:	5d                   	pop    %ebp
8010254a:	c3                   	ret    

8010254b <outb>:

static inline void
outb(ushort port, uchar data)
{
8010254b:	55                   	push   %ebp
8010254c:	89 e5                	mov    %esp,%ebp
8010254e:	83 ec 08             	sub    $0x8,%esp
80102551:	8b 55 08             	mov    0x8(%ebp),%edx
80102554:	8b 45 0c             	mov    0xc(%ebp),%eax
80102557:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010255b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010255e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102562:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102566:	ee                   	out    %al,(%dx)
}
80102567:	90                   	nop
80102568:	c9                   	leave  
80102569:	c3                   	ret    

8010256a <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010256a:	55                   	push   %ebp
8010256b:	89 e5                	mov    %esp,%ebp
8010256d:	56                   	push   %esi
8010256e:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010256f:	8b 55 08             	mov    0x8(%ebp),%edx
80102572:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102575:	8b 45 10             	mov    0x10(%ebp),%eax
80102578:	89 cb                	mov    %ecx,%ebx
8010257a:	89 de                	mov    %ebx,%esi
8010257c:	89 c1                	mov    %eax,%ecx
8010257e:	fc                   	cld    
8010257f:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102581:	89 c8                	mov    %ecx,%eax
80102583:	89 f3                	mov    %esi,%ebx
80102585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102588:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010258b:	90                   	nop
8010258c:	5b                   	pop    %ebx
8010258d:	5e                   	pop    %esi
8010258e:	5d                   	pop    %ebp
8010258f:	c3                   	ret    

80102590 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102590:	55                   	push   %ebp
80102591:	89 e5                	mov    %esp,%ebp
80102593:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102596:	90                   	nop
80102597:	68 f7 01 00 00       	push   $0x1f7
8010259c:	e8 67 ff ff ff       	call   80102508 <inb>
801025a1:	83 c4 04             	add    $0x4,%esp
801025a4:	0f b6 c0             	movzbl %al,%eax
801025a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025ad:	25 c0 00 00 00       	and    $0xc0,%eax
801025b2:	83 f8 40             	cmp    $0x40,%eax
801025b5:	75 e0                	jne    80102597 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801025b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025bb:	74 11                	je     801025ce <idewait+0x3e>
801025bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025c0:	83 e0 21             	and    $0x21,%eax
801025c3:	85 c0                	test   %eax,%eax
801025c5:	74 07                	je     801025ce <idewait+0x3e>
    return -1;
801025c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025cc:	eb 05                	jmp    801025d3 <idewait+0x43>
  return 0;
801025ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025d3:	c9                   	leave  
801025d4:	c3                   	ret    

801025d5 <ideinit>:

void
ideinit(void)
{
801025d5:	55                   	push   %ebp
801025d6:	89 e5                	mov    %esp,%ebp
801025d8:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801025db:	83 ec 08             	sub    $0x8,%esp
801025de:	68 b0 90 10 80       	push   $0x801090b0
801025e3:	68 20 c6 10 80       	push   $0x8010c620
801025e8:	e8 cd 31 00 00       	call   801057ba <initlock>
801025ed:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801025f0:	83 ec 0c             	sub    $0xc,%esp
801025f3:	6a 0e                	push   $0xe
801025f5:	e8 b0 18 00 00       	call   80103eaa <picenable>
801025fa:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801025fd:	a1 60 39 11 80       	mov    0x80113960,%eax
80102602:	83 e8 01             	sub    $0x1,%eax
80102605:	83 ec 08             	sub    $0x8,%esp
80102608:	50                   	push   %eax
80102609:	6a 0e                	push   $0xe
8010260b:	e8 37 04 00 00       	call   80102a47 <ioapicenable>
80102610:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102613:	83 ec 0c             	sub    $0xc,%esp
80102616:	6a 00                	push   $0x0
80102618:	e8 73 ff ff ff       	call   80102590 <idewait>
8010261d:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102620:	83 ec 08             	sub    $0x8,%esp
80102623:	68 f0 00 00 00       	push   $0xf0
80102628:	68 f6 01 00 00       	push   $0x1f6
8010262d:	e8 19 ff ff ff       	call   8010254b <outb>
80102632:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102635:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010263c:	eb 24                	jmp    80102662 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
8010263e:	83 ec 0c             	sub    $0xc,%esp
80102641:	68 f7 01 00 00       	push   $0x1f7
80102646:	e8 bd fe ff ff       	call   80102508 <inb>
8010264b:	83 c4 10             	add    $0x10,%esp
8010264e:	84 c0                	test   %al,%al
80102650:	74 0c                	je     8010265e <ideinit+0x89>
      havedisk1 = 1;
80102652:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
80102659:	00 00 00 
      break;
8010265c:	eb 0d                	jmp    8010266b <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010265e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102662:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102669:	7e d3                	jle    8010263e <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010266b:	83 ec 08             	sub    $0x8,%esp
8010266e:	68 e0 00 00 00       	push   $0xe0
80102673:	68 f6 01 00 00       	push   $0x1f6
80102678:	e8 ce fe ff ff       	call   8010254b <outb>
8010267d:	83 c4 10             	add    $0x10,%esp
}
80102680:	90                   	nop
80102681:	c9                   	leave  
80102682:	c3                   	ret    

80102683 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102683:	55                   	push   %ebp
80102684:	89 e5                	mov    %esp,%ebp
80102686:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
80102689:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010268d:	75 0d                	jne    8010269c <idestart+0x19>
    panic("idestart");
8010268f:	83 ec 0c             	sub    $0xc,%esp
80102692:	68 b4 90 10 80       	push   $0x801090b4
80102697:	e8 ca de ff ff       	call   80100566 <panic>

  idewait(0);
8010269c:	83 ec 0c             	sub    $0xc,%esp
8010269f:	6a 00                	push   $0x0
801026a1:	e8 ea fe ff ff       	call   80102590 <idewait>
801026a6:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801026a9:	83 ec 08             	sub    $0x8,%esp
801026ac:	6a 00                	push   $0x0
801026ae:	68 f6 03 00 00       	push   $0x3f6
801026b3:	e8 93 fe ff ff       	call   8010254b <outb>
801026b8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
801026bb:	83 ec 08             	sub    $0x8,%esp
801026be:	6a 01                	push   $0x1
801026c0:	68 f2 01 00 00       	push   $0x1f2
801026c5:	e8 81 fe ff ff       	call   8010254b <outb>
801026ca:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
801026cd:	8b 45 08             	mov    0x8(%ebp),%eax
801026d0:	8b 40 08             	mov    0x8(%eax),%eax
801026d3:	0f b6 c0             	movzbl %al,%eax
801026d6:	83 ec 08             	sub    $0x8,%esp
801026d9:	50                   	push   %eax
801026da:	68 f3 01 00 00       	push   $0x1f3
801026df:	e8 67 fe ff ff       	call   8010254b <outb>
801026e4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
801026e7:	8b 45 08             	mov    0x8(%ebp),%eax
801026ea:	8b 40 08             	mov    0x8(%eax),%eax
801026ed:	c1 e8 08             	shr    $0x8,%eax
801026f0:	0f b6 c0             	movzbl %al,%eax
801026f3:	83 ec 08             	sub    $0x8,%esp
801026f6:	50                   	push   %eax
801026f7:	68 f4 01 00 00       	push   $0x1f4
801026fc:	e8 4a fe ff ff       	call   8010254b <outb>
80102701:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102704:	8b 45 08             	mov    0x8(%ebp),%eax
80102707:	8b 40 08             	mov    0x8(%eax),%eax
8010270a:	c1 e8 10             	shr    $0x10,%eax
8010270d:	0f b6 c0             	movzbl %al,%eax
80102710:	83 ec 08             	sub    $0x8,%esp
80102713:	50                   	push   %eax
80102714:	68 f5 01 00 00       	push   $0x1f5
80102719:	e8 2d fe ff ff       	call   8010254b <outb>
8010271e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102721:	8b 45 08             	mov    0x8(%ebp),%eax
80102724:	8b 40 04             	mov    0x4(%eax),%eax
80102727:	83 e0 01             	and    $0x1,%eax
8010272a:	c1 e0 04             	shl    $0x4,%eax
8010272d:	89 c2                	mov    %eax,%edx
8010272f:	8b 45 08             	mov    0x8(%ebp),%eax
80102732:	8b 40 08             	mov    0x8(%eax),%eax
80102735:	c1 e8 18             	shr    $0x18,%eax
80102738:	83 e0 0f             	and    $0xf,%eax
8010273b:	09 d0                	or     %edx,%eax
8010273d:	83 c8 e0             	or     $0xffffffe0,%eax
80102740:	0f b6 c0             	movzbl %al,%eax
80102743:	83 ec 08             	sub    $0x8,%esp
80102746:	50                   	push   %eax
80102747:	68 f6 01 00 00       	push   $0x1f6
8010274c:	e8 fa fd ff ff       	call   8010254b <outb>
80102751:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102754:	8b 45 08             	mov    0x8(%ebp),%eax
80102757:	8b 00                	mov    (%eax),%eax
80102759:	83 e0 04             	and    $0x4,%eax
8010275c:	85 c0                	test   %eax,%eax
8010275e:	74 30                	je     80102790 <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
80102760:	83 ec 08             	sub    $0x8,%esp
80102763:	6a 30                	push   $0x30
80102765:	68 f7 01 00 00       	push   $0x1f7
8010276a:	e8 dc fd ff ff       	call   8010254b <outb>
8010276f:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
80102772:	8b 45 08             	mov    0x8(%ebp),%eax
80102775:	83 c0 18             	add    $0x18,%eax
80102778:	83 ec 04             	sub    $0x4,%esp
8010277b:	68 80 00 00 00       	push   $0x80
80102780:	50                   	push   %eax
80102781:	68 f0 01 00 00       	push   $0x1f0
80102786:	e8 df fd ff ff       	call   8010256a <outsl>
8010278b:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
8010278e:	eb 12                	jmp    801027a2 <idestart+0x11f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102790:	83 ec 08             	sub    $0x8,%esp
80102793:	6a 20                	push   $0x20
80102795:	68 f7 01 00 00       	push   $0x1f7
8010279a:	e8 ac fd ff ff       	call   8010254b <outb>
8010279f:	83 c4 10             	add    $0x10,%esp
  }
}
801027a2:	90                   	nop
801027a3:	c9                   	leave  
801027a4:	c3                   	ret    

801027a5 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801027a5:	55                   	push   %ebp
801027a6:	89 e5                	mov    %esp,%ebp
801027a8:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801027ab:	83 ec 0c             	sub    $0xc,%esp
801027ae:	68 20 c6 10 80       	push   $0x8010c620
801027b3:	e8 24 30 00 00       	call   801057dc <acquire>
801027b8:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801027bb:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801027c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027c7:	75 15                	jne    801027de <ideintr+0x39>
    release(&idelock);
801027c9:	83 ec 0c             	sub    $0xc,%esp
801027cc:	68 20 c6 10 80       	push   $0x8010c620
801027d1:	e8 6d 30 00 00       	call   80105843 <release>
801027d6:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
801027d9:	e9 9a 00 00 00       	jmp    80102878 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801027de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e1:	8b 40 14             	mov    0x14(%eax),%eax
801027e4:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ec:	8b 00                	mov    (%eax),%eax
801027ee:	83 e0 04             	and    $0x4,%eax
801027f1:	85 c0                	test   %eax,%eax
801027f3:	75 2d                	jne    80102822 <ideintr+0x7d>
801027f5:	83 ec 0c             	sub    $0xc,%esp
801027f8:	6a 01                	push   $0x1
801027fa:	e8 91 fd ff ff       	call   80102590 <idewait>
801027ff:	83 c4 10             	add    $0x10,%esp
80102802:	85 c0                	test   %eax,%eax
80102804:	78 1c                	js     80102822 <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
80102806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102809:	83 c0 18             	add    $0x18,%eax
8010280c:	83 ec 04             	sub    $0x4,%esp
8010280f:	68 80 00 00 00       	push   $0x80
80102814:	50                   	push   %eax
80102815:	68 f0 01 00 00       	push   $0x1f0
8010281a:	e8 06 fd ff ff       	call   80102525 <insl>
8010281f:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102825:	8b 00                	mov    (%eax),%eax
80102827:	83 c8 02             	or     $0x2,%eax
8010282a:	89 c2                	mov    %eax,%edx
8010282c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282f:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102834:	8b 00                	mov    (%eax),%eax
80102836:	83 e0 fb             	and    $0xfffffffb,%eax
80102839:	89 c2                	mov    %eax,%edx
8010283b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010283e:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102840:	83 ec 0c             	sub    $0xc,%esp
80102843:	ff 75 f4             	pushl  -0xc(%ebp)
80102846:	e8 4f 27 00 00       	call   80104f9a <wakeup>
8010284b:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010284e:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102853:	85 c0                	test   %eax,%eax
80102855:	74 11                	je     80102868 <ideintr+0xc3>
    idestart(idequeue);
80102857:	a1 54 c6 10 80       	mov    0x8010c654,%eax
8010285c:	83 ec 0c             	sub    $0xc,%esp
8010285f:	50                   	push   %eax
80102860:	e8 1e fe ff ff       	call   80102683 <idestart>
80102865:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102868:	83 ec 0c             	sub    $0xc,%esp
8010286b:	68 20 c6 10 80       	push   $0x8010c620
80102870:	e8 ce 2f 00 00       	call   80105843 <release>
80102875:	83 c4 10             	add    $0x10,%esp
}
80102878:	c9                   	leave  
80102879:	c3                   	ret    

8010287a <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010287a:	55                   	push   %ebp
8010287b:	89 e5                	mov    %esp,%ebp
8010287d:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102880:	8b 45 08             	mov    0x8(%ebp),%eax
80102883:	8b 00                	mov    (%eax),%eax
80102885:	83 e0 01             	and    $0x1,%eax
80102888:	85 c0                	test   %eax,%eax
8010288a:	75 0d                	jne    80102899 <iderw+0x1f>
    panic("iderw: buf not busy");
8010288c:	83 ec 0c             	sub    $0xc,%esp
8010288f:	68 bd 90 10 80       	push   $0x801090bd
80102894:	e8 cd dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102899:	8b 45 08             	mov    0x8(%ebp),%eax
8010289c:	8b 00                	mov    (%eax),%eax
8010289e:	83 e0 06             	and    $0x6,%eax
801028a1:	83 f8 02             	cmp    $0x2,%eax
801028a4:	75 0d                	jne    801028b3 <iderw+0x39>
    panic("iderw: nothing to do");
801028a6:	83 ec 0c             	sub    $0xc,%esp
801028a9:	68 d1 90 10 80       	push   $0x801090d1
801028ae:	e8 b3 dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801028b3:	8b 45 08             	mov    0x8(%ebp),%eax
801028b6:	8b 40 04             	mov    0x4(%eax),%eax
801028b9:	85 c0                	test   %eax,%eax
801028bb:	74 16                	je     801028d3 <iderw+0x59>
801028bd:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801028c2:	85 c0                	test   %eax,%eax
801028c4:	75 0d                	jne    801028d3 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801028c6:	83 ec 0c             	sub    $0xc,%esp
801028c9:	68 e6 90 10 80       	push   $0x801090e6
801028ce:	e8 93 dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028d3:	83 ec 0c             	sub    $0xc,%esp
801028d6:	68 20 c6 10 80       	push   $0x8010c620
801028db:	e8 fc 2e 00 00       	call   801057dc <acquire>
801028e0:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801028e3:	8b 45 08             	mov    0x8(%ebp),%eax
801028e6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028ed:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
801028f4:	eb 0b                	jmp    80102901 <iderw+0x87>
801028f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f9:	8b 00                	mov    (%eax),%eax
801028fb:	83 c0 14             	add    $0x14,%eax
801028fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102904:	8b 00                	mov    (%eax),%eax
80102906:	85 c0                	test   %eax,%eax
80102908:	75 ec                	jne    801028f6 <iderw+0x7c>
    ;
  *pp = b;
8010290a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010290d:	8b 55 08             	mov    0x8(%ebp),%edx
80102910:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102912:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102917:	3b 45 08             	cmp    0x8(%ebp),%eax
8010291a:	75 23                	jne    8010293f <iderw+0xc5>
    idestart(b);
8010291c:	83 ec 0c             	sub    $0xc,%esp
8010291f:	ff 75 08             	pushl  0x8(%ebp)
80102922:	e8 5c fd ff ff       	call   80102683 <idestart>
80102927:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010292a:	eb 13                	jmp    8010293f <iderw+0xc5>
    sleep(b, &idelock);
8010292c:	83 ec 08             	sub    $0x8,%esp
8010292f:	68 20 c6 10 80       	push   $0x8010c620
80102934:	ff 75 08             	pushl  0x8(%ebp)
80102937:	e8 49 25 00 00       	call   80104e85 <sleep>
8010293c:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010293f:	8b 45 08             	mov    0x8(%ebp),%eax
80102942:	8b 00                	mov    (%eax),%eax
80102944:	83 e0 06             	and    $0x6,%eax
80102947:	83 f8 02             	cmp    $0x2,%eax
8010294a:	75 e0                	jne    8010292c <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
8010294c:	83 ec 0c             	sub    $0xc,%esp
8010294f:	68 20 c6 10 80       	push   $0x8010c620
80102954:	e8 ea 2e 00 00       	call   80105843 <release>
80102959:	83 c4 10             	add    $0x10,%esp
}
8010295c:	90                   	nop
8010295d:	c9                   	leave  
8010295e:	c3                   	ret    

8010295f <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010295f:	55                   	push   %ebp
80102960:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102962:	a1 34 32 11 80       	mov    0x80113234,%eax
80102967:	8b 55 08             	mov    0x8(%ebp),%edx
8010296a:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010296c:	a1 34 32 11 80       	mov    0x80113234,%eax
80102971:	8b 40 10             	mov    0x10(%eax),%eax
}
80102974:	5d                   	pop    %ebp
80102975:	c3                   	ret    

80102976 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102976:	55                   	push   %ebp
80102977:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102979:	a1 34 32 11 80       	mov    0x80113234,%eax
8010297e:	8b 55 08             	mov    0x8(%ebp),%edx
80102981:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102983:	a1 34 32 11 80       	mov    0x80113234,%eax
80102988:	8b 55 0c             	mov    0xc(%ebp),%edx
8010298b:	89 50 10             	mov    %edx,0x10(%eax)
}
8010298e:	90                   	nop
8010298f:	5d                   	pop    %ebp
80102990:	c3                   	ret    

80102991 <ioapicinit>:

void
ioapicinit(void)
{
80102991:	55                   	push   %ebp
80102992:	89 e5                	mov    %esp,%ebp
80102994:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102997:	a1 64 33 11 80       	mov    0x80113364,%eax
8010299c:	85 c0                	test   %eax,%eax
8010299e:	0f 84 a0 00 00 00    	je     80102a44 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801029a4:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
801029ab:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801029ae:	6a 01                	push   $0x1
801029b0:	e8 aa ff ff ff       	call   8010295f <ioapicread>
801029b5:	83 c4 04             	add    $0x4,%esp
801029b8:	c1 e8 10             	shr    $0x10,%eax
801029bb:	25 ff 00 00 00       	and    $0xff,%eax
801029c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801029c3:	6a 00                	push   $0x0
801029c5:	e8 95 ff ff ff       	call   8010295f <ioapicread>
801029ca:	83 c4 04             	add    $0x4,%esp
801029cd:	c1 e8 18             	shr    $0x18,%eax
801029d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029d3:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
801029da:	0f b6 c0             	movzbl %al,%eax
801029dd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029e0:	74 10                	je     801029f2 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029e2:	83 ec 0c             	sub    $0xc,%esp
801029e5:	68 04 91 10 80       	push   $0x80109104
801029ea:	e8 d7 d9 ff ff       	call   801003c6 <cprintf>
801029ef:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029f9:	eb 3f                	jmp    80102a3a <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fe:	83 c0 20             	add    $0x20,%eax
80102a01:	0d 00 00 01 00       	or     $0x10000,%eax
80102a06:	89 c2                	mov    %eax,%edx
80102a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0b:	83 c0 08             	add    $0x8,%eax
80102a0e:	01 c0                	add    %eax,%eax
80102a10:	83 ec 08             	sub    $0x8,%esp
80102a13:	52                   	push   %edx
80102a14:	50                   	push   %eax
80102a15:	e8 5c ff ff ff       	call   80102976 <ioapicwrite>
80102a1a:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a20:	83 c0 08             	add    $0x8,%eax
80102a23:	01 c0                	add    %eax,%eax
80102a25:	83 c0 01             	add    $0x1,%eax
80102a28:	83 ec 08             	sub    $0x8,%esp
80102a2b:	6a 00                	push   $0x0
80102a2d:	50                   	push   %eax
80102a2e:	e8 43 ff ff ff       	call   80102976 <ioapicwrite>
80102a33:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a36:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a40:	7e b9                	jle    801029fb <ioapicinit+0x6a>
80102a42:	eb 01                	jmp    80102a45 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102a44:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a45:	c9                   	leave  
80102a46:	c3                   	ret    

80102a47 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a47:	55                   	push   %ebp
80102a48:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102a4a:	a1 64 33 11 80       	mov    0x80113364,%eax
80102a4f:	85 c0                	test   %eax,%eax
80102a51:	74 39                	je     80102a8c <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a53:	8b 45 08             	mov    0x8(%ebp),%eax
80102a56:	83 c0 20             	add    $0x20,%eax
80102a59:	89 c2                	mov    %eax,%edx
80102a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5e:	83 c0 08             	add    $0x8,%eax
80102a61:	01 c0                	add    %eax,%eax
80102a63:	52                   	push   %edx
80102a64:	50                   	push   %eax
80102a65:	e8 0c ff ff ff       	call   80102976 <ioapicwrite>
80102a6a:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a70:	c1 e0 18             	shl    $0x18,%eax
80102a73:	89 c2                	mov    %eax,%edx
80102a75:	8b 45 08             	mov    0x8(%ebp),%eax
80102a78:	83 c0 08             	add    $0x8,%eax
80102a7b:	01 c0                	add    %eax,%eax
80102a7d:	83 c0 01             	add    $0x1,%eax
80102a80:	52                   	push   %edx
80102a81:	50                   	push   %eax
80102a82:	e8 ef fe ff ff       	call   80102976 <ioapicwrite>
80102a87:	83 c4 08             	add    $0x8,%esp
80102a8a:	eb 01                	jmp    80102a8d <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102a8c:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102a8d:	c9                   	leave  
80102a8e:	c3                   	ret    

80102a8f <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a8f:	55                   	push   %ebp
80102a90:	89 e5                	mov    %esp,%ebp
80102a92:	8b 45 08             	mov    0x8(%ebp),%eax
80102a95:	05 00 00 00 80       	add    $0x80000000,%eax
80102a9a:	5d                   	pop    %ebp
80102a9b:	c3                   	ret    

80102a9c <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a9c:	55                   	push   %ebp
80102a9d:	89 e5                	mov    %esp,%ebp
80102a9f:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102aa2:	83 ec 08             	sub    $0x8,%esp
80102aa5:	68 36 91 10 80       	push   $0x80109136
80102aaa:	68 40 32 11 80       	push   $0x80113240
80102aaf:	e8 06 2d 00 00       	call   801057ba <initlock>
80102ab4:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102ab7:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102abe:	00 00 00 
  freerange(vstart, vend);
80102ac1:	83 ec 08             	sub    $0x8,%esp
80102ac4:	ff 75 0c             	pushl  0xc(%ebp)
80102ac7:	ff 75 08             	pushl  0x8(%ebp)
80102aca:	e8 2a 00 00 00       	call   80102af9 <freerange>
80102acf:	83 c4 10             	add    $0x10,%esp
}
80102ad2:	90                   	nop
80102ad3:	c9                   	leave  
80102ad4:	c3                   	ret    

80102ad5 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102ad5:	55                   	push   %ebp
80102ad6:	89 e5                	mov    %esp,%ebp
80102ad8:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102adb:	83 ec 08             	sub    $0x8,%esp
80102ade:	ff 75 0c             	pushl  0xc(%ebp)
80102ae1:	ff 75 08             	pushl  0x8(%ebp)
80102ae4:	e8 10 00 00 00       	call   80102af9 <freerange>
80102ae9:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102aec:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102af3:	00 00 00 
}
80102af6:	90                   	nop
80102af7:	c9                   	leave  
80102af8:	c3                   	ret    

80102af9 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102af9:	55                   	push   %ebp
80102afa:	89 e5                	mov    %esp,%ebp
80102afc:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102aff:	8b 45 08             	mov    0x8(%ebp),%eax
80102b02:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b0f:	eb 15                	jmp    80102b26 <freerange+0x2d>
    kfree(p);
80102b11:	83 ec 0c             	sub    $0xc,%esp
80102b14:	ff 75 f4             	pushl  -0xc(%ebp)
80102b17:	e8 1a 00 00 00       	call   80102b36 <kfree>
80102b1c:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b1f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b29:	05 00 10 00 00       	add    $0x1000,%eax
80102b2e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b31:	76 de                	jbe    80102b11 <freerange+0x18>
    kfree(p);
}
80102b33:	90                   	nop
80102b34:	c9                   	leave  
80102b35:	c3                   	ret    

80102b36 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b36:	55                   	push   %ebp
80102b37:	89 e5                	mov    %esp,%ebp
80102b39:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b44:	85 c0                	test   %eax,%eax
80102b46:	75 1b                	jne    80102b63 <kfree+0x2d>
80102b48:	81 7d 08 1c 6d 11 80 	cmpl   $0x80116d1c,0x8(%ebp)
80102b4f:	72 12                	jb     80102b63 <kfree+0x2d>
80102b51:	ff 75 08             	pushl  0x8(%ebp)
80102b54:	e8 36 ff ff ff       	call   80102a8f <v2p>
80102b59:	83 c4 04             	add    $0x4,%esp
80102b5c:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b61:	76 0d                	jbe    80102b70 <kfree+0x3a>
    panic("kfree");
80102b63:	83 ec 0c             	sub    $0xc,%esp
80102b66:	68 3b 91 10 80       	push   $0x8010913b
80102b6b:	e8 f6 d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b70:	83 ec 04             	sub    $0x4,%esp
80102b73:	68 00 10 00 00       	push   $0x1000
80102b78:	6a 01                	push   $0x1
80102b7a:	ff 75 08             	pushl  0x8(%ebp)
80102b7d:	e8 bd 2e 00 00       	call   80105a3f <memset>
80102b82:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102b85:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b8a:	85 c0                	test   %eax,%eax
80102b8c:	74 10                	je     80102b9e <kfree+0x68>
    acquire(&kmem.lock);
80102b8e:	83 ec 0c             	sub    $0xc,%esp
80102b91:	68 40 32 11 80       	push   $0x80113240
80102b96:	e8 41 2c 00 00       	call   801057dc <acquire>
80102b9b:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ba4:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bad:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb2:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102bb7:	a1 74 32 11 80       	mov    0x80113274,%eax
80102bbc:	85 c0                	test   %eax,%eax
80102bbe:	74 10                	je     80102bd0 <kfree+0x9a>
    release(&kmem.lock);
80102bc0:	83 ec 0c             	sub    $0xc,%esp
80102bc3:	68 40 32 11 80       	push   $0x80113240
80102bc8:	e8 76 2c 00 00       	call   80105843 <release>
80102bcd:	83 c4 10             	add    $0x10,%esp
}
80102bd0:	90                   	nop
80102bd1:	c9                   	leave  
80102bd2:	c3                   	ret    

80102bd3 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102bd3:	55                   	push   %ebp
80102bd4:	89 e5                	mov    %esp,%ebp
80102bd6:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102bd9:	a1 74 32 11 80       	mov    0x80113274,%eax
80102bde:	85 c0                	test   %eax,%eax
80102be0:	74 10                	je     80102bf2 <kalloc+0x1f>
    acquire(&kmem.lock);
80102be2:	83 ec 0c             	sub    $0xc,%esp
80102be5:	68 40 32 11 80       	push   $0x80113240
80102bea:	e8 ed 2b 00 00       	call   801057dc <acquire>
80102bef:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102bf2:	a1 78 32 11 80       	mov    0x80113278,%eax
80102bf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bfa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bfe:	74 0a                	je     80102c0a <kalloc+0x37>
    kmem.freelist = r->next;
80102c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c03:	8b 00                	mov    (%eax),%eax
80102c05:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102c0a:	a1 74 32 11 80       	mov    0x80113274,%eax
80102c0f:	85 c0                	test   %eax,%eax
80102c11:	74 10                	je     80102c23 <kalloc+0x50>
    release(&kmem.lock);
80102c13:	83 ec 0c             	sub    $0xc,%esp
80102c16:	68 40 32 11 80       	push   $0x80113240
80102c1b:	e8 23 2c 00 00       	call   80105843 <release>
80102c20:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c26:	c9                   	leave  
80102c27:	c3                   	ret    

80102c28 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c28:	55                   	push   %ebp
80102c29:	89 e5                	mov    %esp,%ebp
80102c2b:	83 ec 14             	sub    $0x14,%esp
80102c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80102c31:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c35:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c39:	89 c2                	mov    %eax,%edx
80102c3b:	ec                   	in     (%dx),%al
80102c3c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c3f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c43:	c9                   	leave  
80102c44:	c3                   	ret    

80102c45 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c45:	55                   	push   %ebp
80102c46:	89 e5                	mov    %esp,%ebp
80102c48:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c4b:	6a 64                	push   $0x64
80102c4d:	e8 d6 ff ff ff       	call   80102c28 <inb>
80102c52:	83 c4 04             	add    $0x4,%esp
80102c55:	0f b6 c0             	movzbl %al,%eax
80102c58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5e:	83 e0 01             	and    $0x1,%eax
80102c61:	85 c0                	test   %eax,%eax
80102c63:	75 0a                	jne    80102c6f <kbdgetc+0x2a>
    return -1;
80102c65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c6a:	e9 23 01 00 00       	jmp    80102d92 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102c6f:	6a 60                	push   $0x60
80102c71:	e8 b2 ff ff ff       	call   80102c28 <inb>
80102c76:	83 c4 04             	add    $0x4,%esp
80102c79:	0f b6 c0             	movzbl %al,%eax
80102c7c:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c7f:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c86:	75 17                	jne    80102c9f <kbdgetc+0x5a>
    shift |= E0ESC;
80102c88:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c8d:	83 c8 40             	or     $0x40,%eax
80102c90:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102c95:	b8 00 00 00 00       	mov    $0x0,%eax
80102c9a:	e9 f3 00 00 00       	jmp    80102d92 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102c9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ca2:	25 80 00 00 00       	and    $0x80,%eax
80102ca7:	85 c0                	test   %eax,%eax
80102ca9:	74 45                	je     80102cf0 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102cab:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102cb0:	83 e0 40             	and    $0x40,%eax
80102cb3:	85 c0                	test   %eax,%eax
80102cb5:	75 08                	jne    80102cbf <kbdgetc+0x7a>
80102cb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cba:	83 e0 7f             	and    $0x7f,%eax
80102cbd:	eb 03                	jmp    80102cc2 <kbdgetc+0x7d>
80102cbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cc2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102cc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cc8:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102ccd:	0f b6 00             	movzbl (%eax),%eax
80102cd0:	83 c8 40             	or     $0x40,%eax
80102cd3:	0f b6 c0             	movzbl %al,%eax
80102cd6:	f7 d0                	not    %eax
80102cd8:	89 c2                	mov    %eax,%edx
80102cda:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102cdf:	21 d0                	and    %edx,%eax
80102ce1:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102ce6:	b8 00 00 00 00       	mov    $0x0,%eax
80102ceb:	e9 a2 00 00 00       	jmp    80102d92 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102cf0:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102cf5:	83 e0 40             	and    $0x40,%eax
80102cf8:	85 c0                	test   %eax,%eax
80102cfa:	74 14                	je     80102d10 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cfc:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d03:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d08:	83 e0 bf             	and    $0xffffffbf,%eax
80102d0b:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102d10:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d13:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d18:	0f b6 00             	movzbl (%eax),%eax
80102d1b:	0f b6 d0             	movzbl %al,%edx
80102d1e:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d23:	09 d0                	or     %edx,%eax
80102d25:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102d2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d2d:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102d32:	0f b6 00             	movzbl (%eax),%eax
80102d35:	0f b6 d0             	movzbl %al,%edx
80102d38:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d3d:	31 d0                	xor    %edx,%eax
80102d3f:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d44:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d49:	83 e0 03             	and    $0x3,%eax
80102d4c:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102d53:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d56:	01 d0                	add    %edx,%eax
80102d58:	0f b6 00             	movzbl (%eax),%eax
80102d5b:	0f b6 c0             	movzbl %al,%eax
80102d5e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d61:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d66:	83 e0 08             	and    $0x8,%eax
80102d69:	85 c0                	test   %eax,%eax
80102d6b:	74 22                	je     80102d8f <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102d6d:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d71:	76 0c                	jbe    80102d7f <kbdgetc+0x13a>
80102d73:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d77:	77 06                	ja     80102d7f <kbdgetc+0x13a>
      c += 'A' - 'a';
80102d79:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d7d:	eb 10                	jmp    80102d8f <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102d7f:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d83:	76 0a                	jbe    80102d8f <kbdgetc+0x14a>
80102d85:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d89:	77 04                	ja     80102d8f <kbdgetc+0x14a>
      c += 'a' - 'A';
80102d8b:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d8f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d92:	c9                   	leave  
80102d93:	c3                   	ret    

80102d94 <kbdintr>:

void
kbdintr(void)
{
80102d94:	55                   	push   %ebp
80102d95:	89 e5                	mov    %esp,%ebp
80102d97:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102d9a:	83 ec 0c             	sub    $0xc,%esp
80102d9d:	68 45 2c 10 80       	push   $0x80102c45
80102da2:	e8 36 da ff ff       	call   801007dd <consoleintr>
80102da7:	83 c4 10             	add    $0x10,%esp
}
80102daa:	90                   	nop
80102dab:	c9                   	leave  
80102dac:	c3                   	ret    

80102dad <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102dad:	55                   	push   %ebp
80102dae:	89 e5                	mov    %esp,%ebp
80102db0:	83 ec 14             	sub    $0x14,%esp
80102db3:	8b 45 08             	mov    0x8(%ebp),%eax
80102db6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dba:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102dbe:	89 c2                	mov    %eax,%edx
80102dc0:	ec                   	in     (%dx),%al
80102dc1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102dc4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102dc8:	c9                   	leave  
80102dc9:	c3                   	ret    

80102dca <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102dca:	55                   	push   %ebp
80102dcb:	89 e5                	mov    %esp,%ebp
80102dcd:	83 ec 08             	sub    $0x8,%esp
80102dd0:	8b 55 08             	mov    0x8(%ebp),%edx
80102dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dd6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102dda:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ddd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102de1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102de5:	ee                   	out    %al,(%dx)
}
80102de6:	90                   	nop
80102de7:	c9                   	leave  
80102de8:	c3                   	ret    

80102de9 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102de9:	55                   	push   %ebp
80102dea:	89 e5                	mov    %esp,%ebp
80102dec:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102def:	9c                   	pushf  
80102df0:	58                   	pop    %eax
80102df1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102df4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102df7:	c9                   	leave  
80102df8:	c3                   	ret    

80102df9 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102df9:	55                   	push   %ebp
80102dfa:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102dfc:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e01:	8b 55 08             	mov    0x8(%ebp),%edx
80102e04:	c1 e2 02             	shl    $0x2,%edx
80102e07:	01 c2                	add    %eax,%edx
80102e09:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e0c:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e0e:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e13:	83 c0 20             	add    $0x20,%eax
80102e16:	8b 00                	mov    (%eax),%eax
}
80102e18:	90                   	nop
80102e19:	5d                   	pop    %ebp
80102e1a:	c3                   	ret    

80102e1b <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102e1b:	55                   	push   %ebp
80102e1c:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102e1e:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e23:	85 c0                	test   %eax,%eax
80102e25:	0f 84 0b 01 00 00    	je     80102f36 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102e2b:	68 3f 01 00 00       	push   $0x13f
80102e30:	6a 3c                	push   $0x3c
80102e32:	e8 c2 ff ff ff       	call   80102df9 <lapicw>
80102e37:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102e3a:	6a 0b                	push   $0xb
80102e3c:	68 f8 00 00 00       	push   $0xf8
80102e41:	e8 b3 ff ff ff       	call   80102df9 <lapicw>
80102e46:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e49:	68 20 00 02 00       	push   $0x20020
80102e4e:	68 c8 00 00 00       	push   $0xc8
80102e53:	e8 a1 ff ff ff       	call   80102df9 <lapicw>
80102e58:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102e5b:	68 80 96 98 00       	push   $0x989680
80102e60:	68 e0 00 00 00       	push   $0xe0
80102e65:	e8 8f ff ff ff       	call   80102df9 <lapicw>
80102e6a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e6d:	68 00 00 01 00       	push   $0x10000
80102e72:	68 d4 00 00 00       	push   $0xd4
80102e77:	e8 7d ff ff ff       	call   80102df9 <lapicw>
80102e7c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102e7f:	68 00 00 01 00       	push   $0x10000
80102e84:	68 d8 00 00 00       	push   $0xd8
80102e89:	e8 6b ff ff ff       	call   80102df9 <lapicw>
80102e8e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e91:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e96:	83 c0 30             	add    $0x30,%eax
80102e99:	8b 00                	mov    (%eax),%eax
80102e9b:	c1 e8 10             	shr    $0x10,%eax
80102e9e:	0f b6 c0             	movzbl %al,%eax
80102ea1:	83 f8 03             	cmp    $0x3,%eax
80102ea4:	76 12                	jbe    80102eb8 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102ea6:	68 00 00 01 00       	push   $0x10000
80102eab:	68 d0 00 00 00       	push   $0xd0
80102eb0:	e8 44 ff ff ff       	call   80102df9 <lapicw>
80102eb5:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102eb8:	6a 33                	push   $0x33
80102eba:	68 dc 00 00 00       	push   $0xdc
80102ebf:	e8 35 ff ff ff       	call   80102df9 <lapicw>
80102ec4:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102ec7:	6a 00                	push   $0x0
80102ec9:	68 a0 00 00 00       	push   $0xa0
80102ece:	e8 26 ff ff ff       	call   80102df9 <lapicw>
80102ed3:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102ed6:	6a 00                	push   $0x0
80102ed8:	68 a0 00 00 00       	push   $0xa0
80102edd:	e8 17 ff ff ff       	call   80102df9 <lapicw>
80102ee2:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ee5:	6a 00                	push   $0x0
80102ee7:	6a 2c                	push   $0x2c
80102ee9:	e8 0b ff ff ff       	call   80102df9 <lapicw>
80102eee:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ef1:	6a 00                	push   $0x0
80102ef3:	68 c4 00 00 00       	push   $0xc4
80102ef8:	e8 fc fe ff ff       	call   80102df9 <lapicw>
80102efd:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f00:	68 00 85 08 00       	push   $0x88500
80102f05:	68 c0 00 00 00       	push   $0xc0
80102f0a:	e8 ea fe ff ff       	call   80102df9 <lapicw>
80102f0f:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102f12:	90                   	nop
80102f13:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f18:	05 00 03 00 00       	add    $0x300,%eax
80102f1d:	8b 00                	mov    (%eax),%eax
80102f1f:	25 00 10 00 00       	and    $0x1000,%eax
80102f24:	85 c0                	test   %eax,%eax
80102f26:	75 eb                	jne    80102f13 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f28:	6a 00                	push   $0x0
80102f2a:	6a 20                	push   $0x20
80102f2c:	e8 c8 fe ff ff       	call   80102df9 <lapicw>
80102f31:	83 c4 08             	add    $0x8,%esp
80102f34:	eb 01                	jmp    80102f37 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102f36:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102f37:	c9                   	leave  
80102f38:	c3                   	ret    

80102f39 <cpunum>:

int
cpunum(void)
{
80102f39:	55                   	push   %ebp
80102f3a:	89 e5                	mov    %esp,%ebp
80102f3c:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f3f:	e8 a5 fe ff ff       	call   80102de9 <readeflags>
80102f44:	25 00 02 00 00       	and    $0x200,%eax
80102f49:	85 c0                	test   %eax,%eax
80102f4b:	74 26                	je     80102f73 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102f4d:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102f52:	8d 50 01             	lea    0x1(%eax),%edx
80102f55:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80102f5b:	85 c0                	test   %eax,%eax
80102f5d:	75 14                	jne    80102f73 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f5f:	8b 45 04             	mov    0x4(%ebp),%eax
80102f62:	83 ec 08             	sub    $0x8,%esp
80102f65:	50                   	push   %eax
80102f66:	68 44 91 10 80       	push   $0x80109144
80102f6b:	e8 56 d4 ff ff       	call   801003c6 <cprintf>
80102f70:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80102f73:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f78:	85 c0                	test   %eax,%eax
80102f7a:	74 0f                	je     80102f8b <cpunum+0x52>
    return lapic[ID]>>24;
80102f7c:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f81:	83 c0 20             	add    $0x20,%eax
80102f84:	8b 00                	mov    (%eax),%eax
80102f86:	c1 e8 18             	shr    $0x18,%eax
80102f89:	eb 05                	jmp    80102f90 <cpunum+0x57>
  return 0;
80102f8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f90:	c9                   	leave  
80102f91:	c3                   	ret    

80102f92 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f92:	55                   	push   %ebp
80102f93:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102f95:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f9a:	85 c0                	test   %eax,%eax
80102f9c:	74 0c                	je     80102faa <lapiceoi+0x18>
    lapicw(EOI, 0);
80102f9e:	6a 00                	push   $0x0
80102fa0:	6a 2c                	push   $0x2c
80102fa2:	e8 52 fe ff ff       	call   80102df9 <lapicw>
80102fa7:	83 c4 08             	add    $0x8,%esp
}
80102faa:	90                   	nop
80102fab:	c9                   	leave  
80102fac:	c3                   	ret    

80102fad <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fad:	55                   	push   %ebp
80102fae:	89 e5                	mov    %esp,%ebp
}
80102fb0:	90                   	nop
80102fb1:	5d                   	pop    %ebp
80102fb2:	c3                   	ret    

80102fb3 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fb3:	55                   	push   %ebp
80102fb4:	89 e5                	mov    %esp,%ebp
80102fb6:	83 ec 14             	sub    $0x14,%esp
80102fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80102fbc:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fbf:	6a 0f                	push   $0xf
80102fc1:	6a 70                	push   $0x70
80102fc3:	e8 02 fe ff ff       	call   80102dca <outb>
80102fc8:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102fcb:	6a 0a                	push   $0xa
80102fcd:	6a 71                	push   $0x71
80102fcf:	e8 f6 fd ff ff       	call   80102dca <outb>
80102fd4:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102fd7:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102fde:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fe1:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102fe6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fe9:	83 c0 02             	add    $0x2,%eax
80102fec:	8b 55 0c             	mov    0xc(%ebp),%edx
80102fef:	c1 ea 04             	shr    $0x4,%edx
80102ff2:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102ff5:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102ff9:	c1 e0 18             	shl    $0x18,%eax
80102ffc:	50                   	push   %eax
80102ffd:	68 c4 00 00 00       	push   $0xc4
80103002:	e8 f2 fd ff ff       	call   80102df9 <lapicw>
80103007:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010300a:	68 00 c5 00 00       	push   $0xc500
8010300f:	68 c0 00 00 00       	push   $0xc0
80103014:	e8 e0 fd ff ff       	call   80102df9 <lapicw>
80103019:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010301c:	68 c8 00 00 00       	push   $0xc8
80103021:	e8 87 ff ff ff       	call   80102fad <microdelay>
80103026:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103029:	68 00 85 00 00       	push   $0x8500
8010302e:	68 c0 00 00 00       	push   $0xc0
80103033:	e8 c1 fd ff ff       	call   80102df9 <lapicw>
80103038:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010303b:	6a 64                	push   $0x64
8010303d:	e8 6b ff ff ff       	call   80102fad <microdelay>
80103042:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103045:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010304c:	eb 3d                	jmp    8010308b <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
8010304e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103052:	c1 e0 18             	shl    $0x18,%eax
80103055:	50                   	push   %eax
80103056:	68 c4 00 00 00       	push   $0xc4
8010305b:	e8 99 fd ff ff       	call   80102df9 <lapicw>
80103060:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103063:	8b 45 0c             	mov    0xc(%ebp),%eax
80103066:	c1 e8 0c             	shr    $0xc,%eax
80103069:	80 cc 06             	or     $0x6,%ah
8010306c:	50                   	push   %eax
8010306d:	68 c0 00 00 00       	push   $0xc0
80103072:	e8 82 fd ff ff       	call   80102df9 <lapicw>
80103077:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010307a:	68 c8 00 00 00       	push   $0xc8
8010307f:	e8 29 ff ff ff       	call   80102fad <microdelay>
80103084:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103087:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010308b:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010308f:	7e bd                	jle    8010304e <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103091:	90                   	nop
80103092:	c9                   	leave  
80103093:	c3                   	ret    

80103094 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103094:	55                   	push   %ebp
80103095:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103097:	8b 45 08             	mov    0x8(%ebp),%eax
8010309a:	0f b6 c0             	movzbl %al,%eax
8010309d:	50                   	push   %eax
8010309e:	6a 70                	push   $0x70
801030a0:	e8 25 fd ff ff       	call   80102dca <outb>
801030a5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030a8:	68 c8 00 00 00       	push   $0xc8
801030ad:	e8 fb fe ff ff       	call   80102fad <microdelay>
801030b2:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801030b5:	6a 71                	push   $0x71
801030b7:	e8 f1 fc ff ff       	call   80102dad <inb>
801030bc:	83 c4 04             	add    $0x4,%esp
801030bf:	0f b6 c0             	movzbl %al,%eax
}
801030c2:	c9                   	leave  
801030c3:	c3                   	ret    

801030c4 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030c4:	55                   	push   %ebp
801030c5:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801030c7:	6a 00                	push   $0x0
801030c9:	e8 c6 ff ff ff       	call   80103094 <cmos_read>
801030ce:	83 c4 04             	add    $0x4,%esp
801030d1:	89 c2                	mov    %eax,%edx
801030d3:	8b 45 08             	mov    0x8(%ebp),%eax
801030d6:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801030d8:	6a 02                	push   $0x2
801030da:	e8 b5 ff ff ff       	call   80103094 <cmos_read>
801030df:	83 c4 04             	add    $0x4,%esp
801030e2:	89 c2                	mov    %eax,%edx
801030e4:	8b 45 08             	mov    0x8(%ebp),%eax
801030e7:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801030ea:	6a 04                	push   $0x4
801030ec:	e8 a3 ff ff ff       	call   80103094 <cmos_read>
801030f1:	83 c4 04             	add    $0x4,%esp
801030f4:	89 c2                	mov    %eax,%edx
801030f6:	8b 45 08             	mov    0x8(%ebp),%eax
801030f9:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801030fc:	6a 07                	push   $0x7
801030fe:	e8 91 ff ff ff       	call   80103094 <cmos_read>
80103103:	83 c4 04             	add    $0x4,%esp
80103106:	89 c2                	mov    %eax,%edx
80103108:	8b 45 08             	mov    0x8(%ebp),%eax
8010310b:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
8010310e:	6a 08                	push   $0x8
80103110:	e8 7f ff ff ff       	call   80103094 <cmos_read>
80103115:	83 c4 04             	add    $0x4,%esp
80103118:	89 c2                	mov    %eax,%edx
8010311a:	8b 45 08             	mov    0x8(%ebp),%eax
8010311d:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103120:	6a 09                	push   $0x9
80103122:	e8 6d ff ff ff       	call   80103094 <cmos_read>
80103127:	83 c4 04             	add    $0x4,%esp
8010312a:	89 c2                	mov    %eax,%edx
8010312c:	8b 45 08             	mov    0x8(%ebp),%eax
8010312f:	89 50 14             	mov    %edx,0x14(%eax)
}
80103132:	90                   	nop
80103133:	c9                   	leave  
80103134:	c3                   	ret    

80103135 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103135:	55                   	push   %ebp
80103136:	89 e5                	mov    %esp,%ebp
80103138:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010313b:	6a 0b                	push   $0xb
8010313d:	e8 52 ff ff ff       	call   80103094 <cmos_read>
80103142:	83 c4 04             	add    $0x4,%esp
80103145:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010314b:	83 e0 04             	and    $0x4,%eax
8010314e:	85 c0                	test   %eax,%eax
80103150:	0f 94 c0             	sete   %al
80103153:	0f b6 c0             	movzbl %al,%eax
80103156:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103159:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010315c:	50                   	push   %eax
8010315d:	e8 62 ff ff ff       	call   801030c4 <fill_rtcdate>
80103162:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103165:	6a 0a                	push   $0xa
80103167:	e8 28 ff ff ff       	call   80103094 <cmos_read>
8010316c:	83 c4 04             	add    $0x4,%esp
8010316f:	25 80 00 00 00       	and    $0x80,%eax
80103174:	85 c0                	test   %eax,%eax
80103176:	75 27                	jne    8010319f <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103178:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010317b:	50                   	push   %eax
8010317c:	e8 43 ff ff ff       	call   801030c4 <fill_rtcdate>
80103181:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103184:	83 ec 04             	sub    $0x4,%esp
80103187:	6a 18                	push   $0x18
80103189:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010318c:	50                   	push   %eax
8010318d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103190:	50                   	push   %eax
80103191:	e8 10 29 00 00       	call   80105aa6 <memcmp>
80103196:	83 c4 10             	add    $0x10,%esp
80103199:	85 c0                	test   %eax,%eax
8010319b:	74 05                	je     801031a2 <cmostime+0x6d>
8010319d:	eb ba                	jmp    80103159 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
8010319f:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031a0:	eb b7                	jmp    80103159 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801031a2:	90                   	nop
  }

  // convert
  if (bcd) {
801031a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801031a7:	0f 84 b4 00 00 00    	je     80103261 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031b0:	c1 e8 04             	shr    $0x4,%eax
801031b3:	89 c2                	mov    %eax,%edx
801031b5:	89 d0                	mov    %edx,%eax
801031b7:	c1 e0 02             	shl    $0x2,%eax
801031ba:	01 d0                	add    %edx,%eax
801031bc:	01 c0                	add    %eax,%eax
801031be:	89 c2                	mov    %eax,%edx
801031c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031c3:	83 e0 0f             	and    $0xf,%eax
801031c6:	01 d0                	add    %edx,%eax
801031c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031ce:	c1 e8 04             	shr    $0x4,%eax
801031d1:	89 c2                	mov    %eax,%edx
801031d3:	89 d0                	mov    %edx,%eax
801031d5:	c1 e0 02             	shl    $0x2,%eax
801031d8:	01 d0                	add    %edx,%eax
801031da:	01 c0                	add    %eax,%eax
801031dc:	89 c2                	mov    %eax,%edx
801031de:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031e1:	83 e0 0f             	and    $0xf,%eax
801031e4:	01 d0                	add    %edx,%eax
801031e6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801031e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031ec:	c1 e8 04             	shr    $0x4,%eax
801031ef:	89 c2                	mov    %eax,%edx
801031f1:	89 d0                	mov    %edx,%eax
801031f3:	c1 e0 02             	shl    $0x2,%eax
801031f6:	01 d0                	add    %edx,%eax
801031f8:	01 c0                	add    %eax,%eax
801031fa:	89 c2                	mov    %eax,%edx
801031fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031ff:	83 e0 0f             	and    $0xf,%eax
80103202:	01 d0                	add    %edx,%eax
80103204:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010320a:	c1 e8 04             	shr    $0x4,%eax
8010320d:	89 c2                	mov    %eax,%edx
8010320f:	89 d0                	mov    %edx,%eax
80103211:	c1 e0 02             	shl    $0x2,%eax
80103214:	01 d0                	add    %edx,%eax
80103216:	01 c0                	add    %eax,%eax
80103218:	89 c2                	mov    %eax,%edx
8010321a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010321d:	83 e0 0f             	and    $0xf,%eax
80103220:	01 d0                	add    %edx,%eax
80103222:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103225:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103228:	c1 e8 04             	shr    $0x4,%eax
8010322b:	89 c2                	mov    %eax,%edx
8010322d:	89 d0                	mov    %edx,%eax
8010322f:	c1 e0 02             	shl    $0x2,%eax
80103232:	01 d0                	add    %edx,%eax
80103234:	01 c0                	add    %eax,%eax
80103236:	89 c2                	mov    %eax,%edx
80103238:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010323b:	83 e0 0f             	and    $0xf,%eax
8010323e:	01 d0                	add    %edx,%eax
80103240:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103243:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103246:	c1 e8 04             	shr    $0x4,%eax
80103249:	89 c2                	mov    %eax,%edx
8010324b:	89 d0                	mov    %edx,%eax
8010324d:	c1 e0 02             	shl    $0x2,%eax
80103250:	01 d0                	add    %edx,%eax
80103252:	01 c0                	add    %eax,%eax
80103254:	89 c2                	mov    %eax,%edx
80103256:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103259:	83 e0 0f             	and    $0xf,%eax
8010325c:	01 d0                	add    %edx,%eax
8010325e:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103261:	8b 45 08             	mov    0x8(%ebp),%eax
80103264:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103267:	89 10                	mov    %edx,(%eax)
80103269:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010326c:	89 50 04             	mov    %edx,0x4(%eax)
8010326f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103272:	89 50 08             	mov    %edx,0x8(%eax)
80103275:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103278:	89 50 0c             	mov    %edx,0xc(%eax)
8010327b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010327e:	89 50 10             	mov    %edx,0x10(%eax)
80103281:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103284:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103287:	8b 45 08             	mov    0x8(%ebp),%eax
8010328a:	8b 40 14             	mov    0x14(%eax),%eax
8010328d:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103293:	8b 45 08             	mov    0x8(%ebp),%eax
80103296:	89 50 14             	mov    %edx,0x14(%eax)
}
80103299:	90                   	nop
8010329a:	c9                   	leave  
8010329b:	c3                   	ret    

8010329c <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
8010329c:	55                   	push   %ebp
8010329d:	89 e5                	mov    %esp,%ebp
8010329f:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032a2:	83 ec 08             	sub    $0x8,%esp
801032a5:	68 70 91 10 80       	push   $0x80109170
801032aa:	68 80 32 11 80       	push   $0x80113280
801032af:	e8 06 25 00 00       	call   801057ba <initlock>
801032b4:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
801032b7:	83 ec 08             	sub    $0x8,%esp
801032ba:	8d 45 e8             	lea    -0x18(%ebp),%eax
801032bd:	50                   	push   %eax
801032be:	6a 01                	push   $0x1
801032c0:	e8 b2 e0 ff ff       	call   80101377 <readsb>
801032c5:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
801032c8:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ce:	29 c2                	sub    %eax,%edx
801032d0:	89 d0                	mov    %edx,%eax
801032d2:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
801032d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032da:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = ROOTDEV;
801032df:	c7 05 c4 32 11 80 01 	movl   $0x1,0x801132c4
801032e6:	00 00 00 
  recover_from_log();
801032e9:	e8 b2 01 00 00       	call   801034a0 <recover_from_log>
}
801032ee:	90                   	nop
801032ef:	c9                   	leave  
801032f0:	c3                   	ret    

801032f1 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801032f1:	55                   	push   %ebp
801032f2:	89 e5                	mov    %esp,%ebp
801032f4:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032fe:	e9 95 00 00 00       	jmp    80103398 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103303:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010330c:	01 d0                	add    %edx,%eax
8010330e:	83 c0 01             	add    $0x1,%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103318:	83 ec 08             	sub    $0x8,%esp
8010331b:	52                   	push   %edx
8010331c:	50                   	push   %eax
8010331d:	e8 94 ce ff ff       	call   801001b6 <bread>
80103322:	83 c4 10             	add    $0x10,%esp
80103325:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
80103328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010332b:	83 c0 10             	add    $0x10,%eax
8010332e:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103335:	89 c2                	mov    %eax,%edx
80103337:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010333c:	83 ec 08             	sub    $0x8,%esp
8010333f:	52                   	push   %edx
80103340:	50                   	push   %eax
80103341:	e8 70 ce ff ff       	call   801001b6 <bread>
80103346:	83 c4 10             	add    $0x10,%esp
80103349:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010334c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010334f:	8d 50 18             	lea    0x18(%eax),%edx
80103352:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103355:	83 c0 18             	add    $0x18,%eax
80103358:	83 ec 04             	sub    $0x4,%esp
8010335b:	68 00 02 00 00       	push   $0x200
80103360:	52                   	push   %edx
80103361:	50                   	push   %eax
80103362:	e8 97 27 00 00       	call   80105afe <memmove>
80103367:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010336a:	83 ec 0c             	sub    $0xc,%esp
8010336d:	ff 75 ec             	pushl  -0x14(%ebp)
80103370:	e8 7a ce ff ff       	call   801001ef <bwrite>
80103375:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103378:	83 ec 0c             	sub    $0xc,%esp
8010337b:	ff 75 f0             	pushl  -0x10(%ebp)
8010337e:	e8 ab ce ff ff       	call   8010022e <brelse>
80103383:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103386:	83 ec 0c             	sub    $0xc,%esp
80103389:	ff 75 ec             	pushl  -0x14(%ebp)
8010338c:	e8 9d ce ff ff       	call   8010022e <brelse>
80103391:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103394:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103398:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010339d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033a0:	0f 8f 5d ff ff ff    	jg     80103303 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033a6:	90                   	nop
801033a7:	c9                   	leave  
801033a8:	c3                   	ret    

801033a9 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033a9:	55                   	push   %ebp
801033aa:	89 e5                	mov    %esp,%ebp
801033ac:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801033af:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801033b4:	89 c2                	mov    %eax,%edx
801033b6:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801033bb:	83 ec 08             	sub    $0x8,%esp
801033be:	52                   	push   %edx
801033bf:	50                   	push   %eax
801033c0:	e8 f1 cd ff ff       	call   801001b6 <bread>
801033c5:	83 c4 10             	add    $0x10,%esp
801033c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ce:	83 c0 18             	add    $0x18,%eax
801033d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033d7:	8b 00                	mov    (%eax),%eax
801033d9:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
801033de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033e5:	eb 1b                	jmp    80103402 <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
801033e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033ed:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033f4:	83 c2 10             	add    $0x10,%edx
801033f7:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103402:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103407:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010340a:	7f db                	jg     801033e7 <read_head+0x3e>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
8010340c:	83 ec 0c             	sub    $0xc,%esp
8010340f:	ff 75 f0             	pushl  -0x10(%ebp)
80103412:	e8 17 ce ff ff       	call   8010022e <brelse>
80103417:	83 c4 10             	add    $0x10,%esp
}
8010341a:	90                   	nop
8010341b:	c9                   	leave  
8010341c:	c3                   	ret    

8010341d <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010341d:	55                   	push   %ebp
8010341e:	89 e5                	mov    %esp,%ebp
80103420:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103423:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80103428:	89 c2                	mov    %eax,%edx
8010342a:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010342f:	83 ec 08             	sub    $0x8,%esp
80103432:	52                   	push   %edx
80103433:	50                   	push   %eax
80103434:	e8 7d cd ff ff       	call   801001b6 <bread>
80103439:	83 c4 10             	add    $0x10,%esp
8010343c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010343f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103442:	83 c0 18             	add    $0x18,%eax
80103445:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103448:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
8010344e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103451:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103453:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010345a:	eb 1b                	jmp    80103477 <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
8010345c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010345f:	83 c0 10             	add    $0x10,%eax
80103462:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
80103469:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010346f:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103473:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103477:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010347c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010347f:	7f db                	jg     8010345c <write_head+0x3f>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103481:	83 ec 0c             	sub    $0xc,%esp
80103484:	ff 75 f0             	pushl  -0x10(%ebp)
80103487:	e8 63 cd ff ff       	call   801001ef <bwrite>
8010348c:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010348f:	83 ec 0c             	sub    $0xc,%esp
80103492:	ff 75 f0             	pushl  -0x10(%ebp)
80103495:	e8 94 cd ff ff       	call   8010022e <brelse>
8010349a:	83 c4 10             	add    $0x10,%esp
}
8010349d:	90                   	nop
8010349e:	c9                   	leave  
8010349f:	c3                   	ret    

801034a0 <recover_from_log>:

static void
recover_from_log(void)
{
801034a0:	55                   	push   %ebp
801034a1:	89 e5                	mov    %esp,%ebp
801034a3:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034a6:	e8 fe fe ff ff       	call   801033a9 <read_head>
  install_trans(); // if committed, copy from log to disk
801034ab:	e8 41 fe ff ff       	call   801032f1 <install_trans>
  log.lh.n = 0;
801034b0:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801034b7:	00 00 00 
  write_head(); // clear the log
801034ba:	e8 5e ff ff ff       	call   8010341d <write_head>
}
801034bf:	90                   	nop
801034c0:	c9                   	leave  
801034c1:	c3                   	ret    

801034c2 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034c2:	55                   	push   %ebp
801034c3:	89 e5                	mov    %esp,%ebp
801034c5:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801034c8:	83 ec 0c             	sub    $0xc,%esp
801034cb:	68 80 32 11 80       	push   $0x80113280
801034d0:	e8 07 23 00 00       	call   801057dc <acquire>
801034d5:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801034d8:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801034dd:	85 c0                	test   %eax,%eax
801034df:	74 17                	je     801034f8 <begin_op+0x36>
      sleep(&log, &log.lock);
801034e1:	83 ec 08             	sub    $0x8,%esp
801034e4:	68 80 32 11 80       	push   $0x80113280
801034e9:	68 80 32 11 80       	push   $0x80113280
801034ee:	e8 92 19 00 00       	call   80104e85 <sleep>
801034f3:	83 c4 10             	add    $0x10,%esp
801034f6:	eb e0                	jmp    801034d8 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034f8:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
801034fe:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103503:	8d 50 01             	lea    0x1(%eax),%edx
80103506:	89 d0                	mov    %edx,%eax
80103508:	c1 e0 02             	shl    $0x2,%eax
8010350b:	01 d0                	add    %edx,%eax
8010350d:	01 c0                	add    %eax,%eax
8010350f:	01 c8                	add    %ecx,%eax
80103511:	83 f8 1e             	cmp    $0x1e,%eax
80103514:	7e 17                	jle    8010352d <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103516:	83 ec 08             	sub    $0x8,%esp
80103519:	68 80 32 11 80       	push   $0x80113280
8010351e:	68 80 32 11 80       	push   $0x80113280
80103523:	e8 5d 19 00 00       	call   80104e85 <sleep>
80103528:	83 c4 10             	add    $0x10,%esp
8010352b:	eb ab                	jmp    801034d8 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010352d:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103532:	83 c0 01             	add    $0x1,%eax
80103535:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
8010353a:	83 ec 0c             	sub    $0xc,%esp
8010353d:	68 80 32 11 80       	push   $0x80113280
80103542:	e8 fc 22 00 00       	call   80105843 <release>
80103547:	83 c4 10             	add    $0x10,%esp
      break;
8010354a:	90                   	nop
    }
  }
}
8010354b:	90                   	nop
8010354c:	c9                   	leave  
8010354d:	c3                   	ret    

8010354e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010354e:	55                   	push   %ebp
8010354f:	89 e5                	mov    %esp,%ebp
80103551:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103554:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010355b:	83 ec 0c             	sub    $0xc,%esp
8010355e:	68 80 32 11 80       	push   $0x80113280
80103563:	e8 74 22 00 00       	call   801057dc <acquire>
80103568:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010356b:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103570:	83 e8 01             	sub    $0x1,%eax
80103573:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
80103578:	a1 c0 32 11 80       	mov    0x801132c0,%eax
8010357d:	85 c0                	test   %eax,%eax
8010357f:	74 0d                	je     8010358e <end_op+0x40>
    panic("log.committing");
80103581:	83 ec 0c             	sub    $0xc,%esp
80103584:	68 74 91 10 80       	push   $0x80109174
80103589:	e8 d8 cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
8010358e:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103593:	85 c0                	test   %eax,%eax
80103595:	75 13                	jne    801035aa <end_op+0x5c>
    do_commit = 1;
80103597:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010359e:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
801035a5:	00 00 00 
801035a8:	eb 10                	jmp    801035ba <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801035aa:	83 ec 0c             	sub    $0xc,%esp
801035ad:	68 80 32 11 80       	push   $0x80113280
801035b2:	e8 e3 19 00 00       	call   80104f9a <wakeup>
801035b7:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801035ba:	83 ec 0c             	sub    $0xc,%esp
801035bd:	68 80 32 11 80       	push   $0x80113280
801035c2:	e8 7c 22 00 00       	call   80105843 <release>
801035c7:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801035ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035ce:	74 3f                	je     8010360f <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035d0:	e8 f5 00 00 00       	call   801036ca <commit>
    acquire(&log.lock);
801035d5:	83 ec 0c             	sub    $0xc,%esp
801035d8:	68 80 32 11 80       	push   $0x80113280
801035dd:	e8 fa 21 00 00       	call   801057dc <acquire>
801035e2:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801035e5:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
801035ec:	00 00 00 
    wakeup(&log);
801035ef:	83 ec 0c             	sub    $0xc,%esp
801035f2:	68 80 32 11 80       	push   $0x80113280
801035f7:	e8 9e 19 00 00       	call   80104f9a <wakeup>
801035fc:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801035ff:	83 ec 0c             	sub    $0xc,%esp
80103602:	68 80 32 11 80       	push   $0x80113280
80103607:	e8 37 22 00 00       	call   80105843 <release>
8010360c:	83 c4 10             	add    $0x10,%esp
  }
}
8010360f:	90                   	nop
80103610:	c9                   	leave  
80103611:	c3                   	ret    

80103612 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103612:	55                   	push   %ebp
80103613:	89 e5                	mov    %esp,%ebp
80103615:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103618:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010361f:	e9 95 00 00 00       	jmp    801036b9 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103624:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
8010362a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010362d:	01 d0                	add    %edx,%eax
8010362f:	83 c0 01             	add    $0x1,%eax
80103632:	89 c2                	mov    %eax,%edx
80103634:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103639:	83 ec 08             	sub    $0x8,%esp
8010363c:	52                   	push   %edx
8010363d:	50                   	push   %eax
8010363e:	e8 73 cb ff ff       	call   801001b6 <bread>
80103643:	83 c4 10             	add    $0x10,%esp
80103646:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103649:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010364c:	83 c0 10             	add    $0x10,%eax
8010364f:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103656:	89 c2                	mov    %eax,%edx
80103658:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010365d:	83 ec 08             	sub    $0x8,%esp
80103660:	52                   	push   %edx
80103661:	50                   	push   %eax
80103662:	e8 4f cb ff ff       	call   801001b6 <bread>
80103667:	83 c4 10             	add    $0x10,%esp
8010366a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010366d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103670:	8d 50 18             	lea    0x18(%eax),%edx
80103673:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103676:	83 c0 18             	add    $0x18,%eax
80103679:	83 ec 04             	sub    $0x4,%esp
8010367c:	68 00 02 00 00       	push   $0x200
80103681:	52                   	push   %edx
80103682:	50                   	push   %eax
80103683:	e8 76 24 00 00       	call   80105afe <memmove>
80103688:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010368b:	83 ec 0c             	sub    $0xc,%esp
8010368e:	ff 75 f0             	pushl  -0x10(%ebp)
80103691:	e8 59 cb ff ff       	call   801001ef <bwrite>
80103696:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103699:	83 ec 0c             	sub    $0xc,%esp
8010369c:	ff 75 ec             	pushl  -0x14(%ebp)
8010369f:	e8 8a cb ff ff       	call   8010022e <brelse>
801036a4:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801036a7:	83 ec 0c             	sub    $0xc,%esp
801036aa:	ff 75 f0             	pushl  -0x10(%ebp)
801036ad:	e8 7c cb ff ff       	call   8010022e <brelse>
801036b2:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036b9:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036be:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036c1:	0f 8f 5d ff ff ff    	jg     80103624 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801036c7:	90                   	nop
801036c8:	c9                   	leave  
801036c9:	c3                   	ret    

801036ca <commit>:

static void
commit()
{
801036ca:	55                   	push   %ebp
801036cb:	89 e5                	mov    %esp,%ebp
801036cd:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801036d0:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036d5:	85 c0                	test   %eax,%eax
801036d7:	7e 1e                	jle    801036f7 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801036d9:	e8 34 ff ff ff       	call   80103612 <write_log>
    write_head();    // Write header to disk -- the real commit
801036de:	e8 3a fd ff ff       	call   8010341d <write_head>
    install_trans(); // Now install writes to home locations
801036e3:	e8 09 fc ff ff       	call   801032f1 <install_trans>
    log.lh.n = 0; 
801036e8:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801036ef:	00 00 00 
    write_head();    // Erase the transaction from the log
801036f2:	e8 26 fd ff ff       	call   8010341d <write_head>
  }
}
801036f7:	90                   	nop
801036f8:	c9                   	leave  
801036f9:	c3                   	ret    

801036fa <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036fa:	55                   	push   %ebp
801036fb:	89 e5                	mov    %esp,%ebp
801036fd:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103700:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103705:	83 f8 1d             	cmp    $0x1d,%eax
80103708:	7f 12                	jg     8010371c <log_write+0x22>
8010370a:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010370f:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
80103715:	83 ea 01             	sub    $0x1,%edx
80103718:	39 d0                	cmp    %edx,%eax
8010371a:	7c 0d                	jl     80103729 <log_write+0x2f>
    panic("too big a transaction");
8010371c:	83 ec 0c             	sub    $0xc,%esp
8010371f:	68 83 91 10 80       	push   $0x80109183
80103724:	e8 3d ce ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103729:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010372e:	85 c0                	test   %eax,%eax
80103730:	7f 0d                	jg     8010373f <log_write+0x45>
    panic("log_write outside of trans");
80103732:	83 ec 0c             	sub    $0xc,%esp
80103735:	68 99 91 10 80       	push   $0x80109199
8010373a:	e8 27 ce ff ff       	call   80100566 <panic>

  acquire(&log.lock);
8010373f:	83 ec 0c             	sub    $0xc,%esp
80103742:	68 80 32 11 80       	push   $0x80113280
80103747:	e8 90 20 00 00       	call   801057dc <acquire>
8010374c:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
8010374f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103756:	eb 1d                	jmp    80103775 <log_write+0x7b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010375b:	83 c0 10             	add    $0x10,%eax
8010375e:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103765:	89 c2                	mov    %eax,%edx
80103767:	8b 45 08             	mov    0x8(%ebp),%eax
8010376a:	8b 40 08             	mov    0x8(%eax),%eax
8010376d:	39 c2                	cmp    %eax,%edx
8010376f:	74 10                	je     80103781 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103771:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103775:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010377a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010377d:	7f d9                	jg     80103758 <log_write+0x5e>
8010377f:	eb 01                	jmp    80103782 <log_write+0x88>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
80103781:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103782:	8b 45 08             	mov    0x8(%ebp),%eax
80103785:	8b 40 08             	mov    0x8(%eax),%eax
80103788:	89 c2                	mov    %eax,%edx
8010378a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010378d:	83 c0 10             	add    $0x10,%eax
80103790:	89 14 85 8c 32 11 80 	mov    %edx,-0x7feecd74(,%eax,4)
  if (i == log.lh.n)
80103797:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010379c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010379f:	75 0d                	jne    801037ae <log_write+0xb4>
    log.lh.n++;
801037a1:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037a6:	83 c0 01             	add    $0x1,%eax
801037a9:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801037ae:	8b 45 08             	mov    0x8(%ebp),%eax
801037b1:	8b 00                	mov    (%eax),%eax
801037b3:	83 c8 04             	or     $0x4,%eax
801037b6:	89 c2                	mov    %eax,%edx
801037b8:	8b 45 08             	mov    0x8(%ebp),%eax
801037bb:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801037bd:	83 ec 0c             	sub    $0xc,%esp
801037c0:	68 80 32 11 80       	push   $0x80113280
801037c5:	e8 79 20 00 00       	call   80105843 <release>
801037ca:	83 c4 10             	add    $0x10,%esp
}
801037cd:	90                   	nop
801037ce:	c9                   	leave  
801037cf:	c3                   	ret    

801037d0 <v2p>:
801037d0:	55                   	push   %ebp
801037d1:	89 e5                	mov    %esp,%ebp
801037d3:	8b 45 08             	mov    0x8(%ebp),%eax
801037d6:	05 00 00 00 80       	add    $0x80000000,%eax
801037db:	5d                   	pop    %ebp
801037dc:	c3                   	ret    

801037dd <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801037dd:	55                   	push   %ebp
801037de:	89 e5                	mov    %esp,%ebp
801037e0:	8b 45 08             	mov    0x8(%ebp),%eax
801037e3:	05 00 00 00 80       	add    $0x80000000,%eax
801037e8:	5d                   	pop    %ebp
801037e9:	c3                   	ret    

801037ea <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801037ea:	55                   	push   %ebp
801037eb:	89 e5                	mov    %esp,%ebp
801037ed:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801037f0:	8b 55 08             	mov    0x8(%ebp),%edx
801037f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801037f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801037f9:	f0 87 02             	lock xchg %eax,(%edx)
801037fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103802:	c9                   	leave  
80103803:	c3                   	ret    

80103804 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103804:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103808:	83 e4 f0             	and    $0xfffffff0,%esp
8010380b:	ff 71 fc             	pushl  -0x4(%ecx)
8010380e:	55                   	push   %ebp
8010380f:	89 e5                	mov    %esp,%ebp
80103811:	51                   	push   %ecx
80103812:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103815:	83 ec 08             	sub    $0x8,%esp
80103818:	68 00 00 40 80       	push   $0x80400000
8010381d:	68 1c 6d 11 80       	push   $0x80116d1c
80103822:	e8 75 f2 ff ff       	call   80102a9c <kinit1>
80103827:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010382a:	e8 d2 4f 00 00       	call   80108801 <kvmalloc>
  mpinit();        // collect info about this machine
8010382f:	e8 4d 04 00 00       	call   80103c81 <mpinit>
  lapicinit();
80103834:	e8 e2 f5 ff ff       	call   80102e1b <lapicinit>
  seginit();       // set up segments
80103839:	e8 6c 49 00 00       	call   801081aa <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
8010383e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103844:	0f b6 00             	movzbl (%eax),%eax
80103847:	0f b6 c0             	movzbl %al,%eax
8010384a:	83 ec 08             	sub    $0x8,%esp
8010384d:	50                   	push   %eax
8010384e:	68 b4 91 10 80       	push   $0x801091b4
80103853:	e8 6e cb ff ff       	call   801003c6 <cprintf>
80103858:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
8010385b:	e8 77 06 00 00       	call   80103ed7 <picinit>
  ioapicinit();    // another interrupt controller
80103860:	e8 2c f1 ff ff       	call   80102991 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103865:	e8 7f d2 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
8010386a:	e8 97 3c 00 00       	call   80107506 <uartinit>
  pinit();         // process table
8010386f:	e8 67 0b 00 00       	call   801043db <pinit>
  tvinit();        // trap vectors
80103874:	e8 fc 36 00 00       	call   80106f75 <tvinit>
  binit();         // buffer cache
80103879:	e8 b6 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010387e:	e8 e5 d6 ff ff       	call   80100f68 <fileinit>
  semtableinit();  // semaphore table
80103883:	e8 4b 1a 00 00       	call   801052d3 <semtableinit>
  iinit();         // inode cache
80103888:	e8 b9 dd ff ff       	call   80101646 <iinit>
  ideinit();       // disk
8010388d:	e8 43 ed ff ff       	call   801025d5 <ideinit>
  if(!ismp)
80103892:	a1 64 33 11 80       	mov    0x80113364,%eax
80103897:	85 c0                	test   %eax,%eax
80103899:	75 05                	jne    801038a0 <main+0x9c>
    timerinit();   // uniprocessor timer
8010389b:	e8 32 36 00 00       	call   80106ed2 <timerinit>
  startothers();   // start other processors
801038a0:	e8 7f 00 00 00       	call   80103924 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038a5:	83 ec 08             	sub    $0x8,%esp
801038a8:	68 00 00 00 8e       	push   $0x8e000000
801038ad:	68 00 00 40 80       	push   $0x80400000
801038b2:	e8 1e f2 ff ff       	call   80102ad5 <kinit2>
801038b7:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801038ba:	e8 46 0d 00 00       	call   80104605 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801038bf:	e8 1a 00 00 00       	call   801038de <mpmain>

801038c4 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038c4:	55                   	push   %ebp
801038c5:	89 e5                	mov    %esp,%ebp
801038c7:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038ca:	e8 4a 4f 00 00       	call   80108819 <switchkvm>
  seginit();
801038cf:	e8 d6 48 00 00       	call   801081aa <seginit>
  lapicinit();
801038d4:	e8 42 f5 ff ff       	call   80102e1b <lapicinit>
  mpmain();
801038d9:	e8 00 00 00 00       	call   801038de <mpmain>

801038de <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038de:	55                   	push   %ebp
801038df:	89 e5                	mov    %esp,%ebp
801038e1:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801038e4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038ea:	0f b6 00             	movzbl (%eax),%eax
801038ed:	0f b6 c0             	movzbl %al,%eax
801038f0:	83 ec 08             	sub    $0x8,%esp
801038f3:	50                   	push   %eax
801038f4:	68 cb 91 10 80       	push   $0x801091cb
801038f9:	e8 c8 ca ff ff       	call   801003c6 <cprintf>
801038fe:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103901:	e8 e5 37 00 00       	call   801070eb <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103906:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010390c:	05 a8 00 00 00       	add    $0xa8,%eax
80103911:	83 ec 08             	sub    $0x8,%esp
80103914:	6a 01                	push   $0x1
80103916:	50                   	push   %eax
80103917:	e8 ce fe ff ff       	call   801037ea <xchg>
8010391c:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010391f:	e8 01 13 00 00       	call   80104c25 <scheduler>

80103924 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103924:	55                   	push   %ebp
80103925:	89 e5                	mov    %esp,%ebp
80103927:	53                   	push   %ebx
80103928:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010392b:	68 00 70 00 00       	push   $0x7000
80103930:	e8 a8 fe ff ff       	call   801037dd <p2v>
80103935:	83 c4 04             	add    $0x4,%esp
80103938:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010393b:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103940:	83 ec 04             	sub    $0x4,%esp
80103943:	50                   	push   %eax
80103944:	68 2c c5 10 80       	push   $0x8010c52c
80103949:	ff 75 f0             	pushl  -0x10(%ebp)
8010394c:	e8 ad 21 00 00       	call   80105afe <memmove>
80103951:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103954:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
8010395b:	e9 90 00 00 00       	jmp    801039f0 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103960:	e8 d4 f5 ff ff       	call   80102f39 <cpunum>
80103965:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010396b:	05 80 33 11 80       	add    $0x80113380,%eax
80103970:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103973:	74 73                	je     801039e8 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103975:	e8 59 f2 ff ff       	call   80102bd3 <kalloc>
8010397a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010397d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103980:	83 e8 04             	sub    $0x4,%eax
80103983:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103986:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010398c:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010398e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103991:	83 e8 08             	sub    $0x8,%eax
80103994:	c7 00 c4 38 10 80    	movl   $0x801038c4,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010399a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010399d:	8d 58 f4             	lea    -0xc(%eax),%ebx
801039a0:	83 ec 0c             	sub    $0xc,%esp
801039a3:	68 00 b0 10 80       	push   $0x8010b000
801039a8:	e8 23 fe ff ff       	call   801037d0 <v2p>
801039ad:	83 c4 10             	add    $0x10,%esp
801039b0:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801039b2:	83 ec 0c             	sub    $0xc,%esp
801039b5:	ff 75 f0             	pushl  -0x10(%ebp)
801039b8:	e8 13 fe ff ff       	call   801037d0 <v2p>
801039bd:	83 c4 10             	add    $0x10,%esp
801039c0:	89 c2                	mov    %eax,%edx
801039c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c5:	0f b6 00             	movzbl (%eax),%eax
801039c8:	0f b6 c0             	movzbl %al,%eax
801039cb:	83 ec 08             	sub    $0x8,%esp
801039ce:	52                   	push   %edx
801039cf:	50                   	push   %eax
801039d0:	e8 de f5 ff ff       	call   80102fb3 <lapicstartap>
801039d5:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d8:	90                   	nop
801039d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039dc:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801039e2:	85 c0                	test   %eax,%eax
801039e4:	74 f3                	je     801039d9 <startothers+0xb5>
801039e6:	eb 01                	jmp    801039e9 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801039e8:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801039e9:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801039f0:	a1 60 39 11 80       	mov    0x80113960,%eax
801039f5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039fb:	05 80 33 11 80       	add    $0x80113380,%eax
80103a00:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a03:	0f 87 57 ff ff ff    	ja     80103960 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a09:	90                   	nop
80103a0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a0d:	c9                   	leave  
80103a0e:	c3                   	ret    

80103a0f <p2v>:
80103a0f:	55                   	push   %ebp
80103a10:	89 e5                	mov    %esp,%ebp
80103a12:	8b 45 08             	mov    0x8(%ebp),%eax
80103a15:	05 00 00 00 80       	add    $0x80000000,%eax
80103a1a:	5d                   	pop    %ebp
80103a1b:	c3                   	ret    

80103a1c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a1c:	55                   	push   %ebp
80103a1d:	89 e5                	mov    %esp,%ebp
80103a1f:	83 ec 14             	sub    $0x14,%esp
80103a22:	8b 45 08             	mov    0x8(%ebp),%eax
80103a25:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a29:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a2d:	89 c2                	mov    %eax,%edx
80103a2f:	ec                   	in     (%dx),%al
80103a30:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a33:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a37:	c9                   	leave  
80103a38:	c3                   	ret    

80103a39 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a39:	55                   	push   %ebp
80103a3a:	89 e5                	mov    %esp,%ebp
80103a3c:	83 ec 08             	sub    $0x8,%esp
80103a3f:	8b 55 08             	mov    0x8(%ebp),%edx
80103a42:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a45:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a49:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a4c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a50:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a54:	ee                   	out    %al,(%dx)
}
80103a55:	90                   	nop
80103a56:	c9                   	leave  
80103a57:	c3                   	ret    

80103a58 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103a58:	55                   	push   %ebp
80103a59:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103a5b:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103a60:	89 c2                	mov    %eax,%edx
80103a62:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103a67:	29 c2                	sub    %eax,%edx
80103a69:	89 d0                	mov    %edx,%eax
80103a6b:	c1 f8 02             	sar    $0x2,%eax
80103a6e:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103a74:	5d                   	pop    %ebp
80103a75:	c3                   	ret    

80103a76 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103a76:	55                   	push   %ebp
80103a77:	89 e5                	mov    %esp,%ebp
80103a79:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103a7c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a83:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a8a:	eb 15                	jmp    80103aa1 <sum+0x2b>
    sum += addr[i];
80103a8c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a92:	01 d0                	add    %edx,%eax
80103a94:	0f b6 00             	movzbl (%eax),%eax
80103a97:	0f b6 c0             	movzbl %al,%eax
80103a9a:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a9d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103aa1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103aa4:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103aa7:	7c e3                	jl     80103a8c <sum+0x16>
    sum += addr[i];
  return sum;
80103aa9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103aac:	c9                   	leave  
80103aad:	c3                   	ret    

80103aae <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103aae:	55                   	push   %ebp
80103aaf:	89 e5                	mov    %esp,%ebp
80103ab1:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103ab4:	ff 75 08             	pushl  0x8(%ebp)
80103ab7:	e8 53 ff ff ff       	call   80103a0f <p2v>
80103abc:	83 c4 04             	add    $0x4,%esp
80103abf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac8:	01 d0                	add    %edx,%eax
80103aca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ad3:	eb 36                	jmp    80103b0b <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103ad5:	83 ec 04             	sub    $0x4,%esp
80103ad8:	6a 04                	push   $0x4
80103ada:	68 dc 91 10 80       	push   $0x801091dc
80103adf:	ff 75 f4             	pushl  -0xc(%ebp)
80103ae2:	e8 bf 1f 00 00       	call   80105aa6 <memcmp>
80103ae7:	83 c4 10             	add    $0x10,%esp
80103aea:	85 c0                	test   %eax,%eax
80103aec:	75 19                	jne    80103b07 <mpsearch1+0x59>
80103aee:	83 ec 08             	sub    $0x8,%esp
80103af1:	6a 10                	push   $0x10
80103af3:	ff 75 f4             	pushl  -0xc(%ebp)
80103af6:	e8 7b ff ff ff       	call   80103a76 <sum>
80103afb:	83 c4 10             	add    $0x10,%esp
80103afe:	84 c0                	test   %al,%al
80103b00:	75 05                	jne    80103b07 <mpsearch1+0x59>
      return (struct mp*)p;
80103b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b05:	eb 11                	jmp    80103b18 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b07:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b11:	72 c2                	jb     80103ad5 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b13:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b18:	c9                   	leave  
80103b19:	c3                   	ret    

80103b1a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b1a:	55                   	push   %ebp
80103b1b:	89 e5                	mov    %esp,%ebp
80103b1d:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b20:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2a:	83 c0 0f             	add    $0xf,%eax
80103b2d:	0f b6 00             	movzbl (%eax),%eax
80103b30:	0f b6 c0             	movzbl %al,%eax
80103b33:	c1 e0 08             	shl    $0x8,%eax
80103b36:	89 c2                	mov    %eax,%edx
80103b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3b:	83 c0 0e             	add    $0xe,%eax
80103b3e:	0f b6 00             	movzbl (%eax),%eax
80103b41:	0f b6 c0             	movzbl %al,%eax
80103b44:	09 d0                	or     %edx,%eax
80103b46:	c1 e0 04             	shl    $0x4,%eax
80103b49:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b4c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b50:	74 21                	je     80103b73 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b52:	83 ec 08             	sub    $0x8,%esp
80103b55:	68 00 04 00 00       	push   $0x400
80103b5a:	ff 75 f0             	pushl  -0x10(%ebp)
80103b5d:	e8 4c ff ff ff       	call   80103aae <mpsearch1>
80103b62:	83 c4 10             	add    $0x10,%esp
80103b65:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b68:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b6c:	74 51                	je     80103bbf <mpsearch+0xa5>
      return mp;
80103b6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b71:	eb 61                	jmp    80103bd4 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b76:	83 c0 14             	add    $0x14,%eax
80103b79:	0f b6 00             	movzbl (%eax),%eax
80103b7c:	0f b6 c0             	movzbl %al,%eax
80103b7f:	c1 e0 08             	shl    $0x8,%eax
80103b82:	89 c2                	mov    %eax,%edx
80103b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b87:	83 c0 13             	add    $0x13,%eax
80103b8a:	0f b6 00             	movzbl (%eax),%eax
80103b8d:	0f b6 c0             	movzbl %al,%eax
80103b90:	09 d0                	or     %edx,%eax
80103b92:	c1 e0 0a             	shl    $0xa,%eax
80103b95:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b9b:	2d 00 04 00 00       	sub    $0x400,%eax
80103ba0:	83 ec 08             	sub    $0x8,%esp
80103ba3:	68 00 04 00 00       	push   $0x400
80103ba8:	50                   	push   %eax
80103ba9:	e8 00 ff ff ff       	call   80103aae <mpsearch1>
80103bae:	83 c4 10             	add    $0x10,%esp
80103bb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bb4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bb8:	74 05                	je     80103bbf <mpsearch+0xa5>
      return mp;
80103bba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bbd:	eb 15                	jmp    80103bd4 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103bbf:	83 ec 08             	sub    $0x8,%esp
80103bc2:	68 00 00 01 00       	push   $0x10000
80103bc7:	68 00 00 0f 00       	push   $0xf0000
80103bcc:	e8 dd fe ff ff       	call   80103aae <mpsearch1>
80103bd1:	83 c4 10             	add    $0x10,%esp
}
80103bd4:	c9                   	leave  
80103bd5:	c3                   	ret    

80103bd6 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103bd6:	55                   	push   %ebp
80103bd7:	89 e5                	mov    %esp,%ebp
80103bd9:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103bdc:	e8 39 ff ff ff       	call   80103b1a <mpsearch>
80103be1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103be4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103be8:	74 0a                	je     80103bf4 <mpconfig+0x1e>
80103bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bed:	8b 40 04             	mov    0x4(%eax),%eax
80103bf0:	85 c0                	test   %eax,%eax
80103bf2:	75 0a                	jne    80103bfe <mpconfig+0x28>
    return 0;
80103bf4:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf9:	e9 81 00 00 00       	jmp    80103c7f <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c01:	8b 40 04             	mov    0x4(%eax),%eax
80103c04:	83 ec 0c             	sub    $0xc,%esp
80103c07:	50                   	push   %eax
80103c08:	e8 02 fe ff ff       	call   80103a0f <p2v>
80103c0d:	83 c4 10             	add    $0x10,%esp
80103c10:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c13:	83 ec 04             	sub    $0x4,%esp
80103c16:	6a 04                	push   $0x4
80103c18:	68 e1 91 10 80       	push   $0x801091e1
80103c1d:	ff 75 f0             	pushl  -0x10(%ebp)
80103c20:	e8 81 1e 00 00       	call   80105aa6 <memcmp>
80103c25:	83 c4 10             	add    $0x10,%esp
80103c28:	85 c0                	test   %eax,%eax
80103c2a:	74 07                	je     80103c33 <mpconfig+0x5d>
    return 0;
80103c2c:	b8 00 00 00 00       	mov    $0x0,%eax
80103c31:	eb 4c                	jmp    80103c7f <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c36:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c3a:	3c 01                	cmp    $0x1,%al
80103c3c:	74 12                	je     80103c50 <mpconfig+0x7a>
80103c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c41:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c45:	3c 04                	cmp    $0x4,%al
80103c47:	74 07                	je     80103c50 <mpconfig+0x7a>
    return 0;
80103c49:	b8 00 00 00 00       	mov    $0x0,%eax
80103c4e:	eb 2f                	jmp    80103c7f <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103c50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c53:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c57:	0f b7 c0             	movzwl %ax,%eax
80103c5a:	83 ec 08             	sub    $0x8,%esp
80103c5d:	50                   	push   %eax
80103c5e:	ff 75 f0             	pushl  -0x10(%ebp)
80103c61:	e8 10 fe ff ff       	call   80103a76 <sum>
80103c66:	83 c4 10             	add    $0x10,%esp
80103c69:	84 c0                	test   %al,%al
80103c6b:	74 07                	je     80103c74 <mpconfig+0x9e>
    return 0;
80103c6d:	b8 00 00 00 00       	mov    $0x0,%eax
80103c72:	eb 0b                	jmp    80103c7f <mpconfig+0xa9>
  *pmp = mp;
80103c74:	8b 45 08             	mov    0x8(%ebp),%eax
80103c77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c7a:	89 10                	mov    %edx,(%eax)
  return conf;
80103c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c7f:	c9                   	leave  
80103c80:	c3                   	ret    

80103c81 <mpinit>:

void
mpinit(void)
{
80103c81:	55                   	push   %ebp
80103c82:	89 e5                	mov    %esp,%ebp
80103c84:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c87:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103c8e:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c91:	83 ec 0c             	sub    $0xc,%esp
80103c94:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c97:	50                   	push   %eax
80103c98:	e8 39 ff ff ff       	call   80103bd6 <mpconfig>
80103c9d:	83 c4 10             	add    $0x10,%esp
80103ca0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ca3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ca7:	0f 84 96 01 00 00    	je     80103e43 <mpinit+0x1c2>
    return;
  ismp = 1;
80103cad:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103cb4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cba:	8b 40 24             	mov    0x24(%eax),%eax
80103cbd:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc5:	83 c0 2c             	add    $0x2c,%eax
80103cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cce:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cd2:	0f b7 d0             	movzwl %ax,%edx
80103cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd8:	01 d0                	add    %edx,%eax
80103cda:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cdd:	e9 f2 00 00 00       	jmp    80103dd4 <mpinit+0x153>
    switch(*p){
80103ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce5:	0f b6 00             	movzbl (%eax),%eax
80103ce8:	0f b6 c0             	movzbl %al,%eax
80103ceb:	83 f8 04             	cmp    $0x4,%eax
80103cee:	0f 87 bc 00 00 00    	ja     80103db0 <mpinit+0x12f>
80103cf4:	8b 04 85 24 92 10 80 	mov    -0x7fef6ddc(,%eax,4),%eax
80103cfb:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d00:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103d03:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d06:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d0a:	0f b6 d0             	movzbl %al,%edx
80103d0d:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d12:	39 c2                	cmp    %eax,%edx
80103d14:	74 2b                	je     80103d41 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103d16:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d19:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d1d:	0f b6 d0             	movzbl %al,%edx
80103d20:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d25:	83 ec 04             	sub    $0x4,%esp
80103d28:	52                   	push   %edx
80103d29:	50                   	push   %eax
80103d2a:	68 e6 91 10 80       	push   $0x801091e6
80103d2f:	e8 92 c6 ff ff       	call   801003c6 <cprintf>
80103d34:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103d37:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103d3e:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103d41:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d44:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103d48:	0f b6 c0             	movzbl %al,%eax
80103d4b:	83 e0 02             	and    $0x2,%eax
80103d4e:	85 c0                	test   %eax,%eax
80103d50:	74 15                	je     80103d67 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103d52:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d57:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d5d:	05 80 33 11 80       	add    $0x80113380,%eax
80103d62:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103d67:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d6c:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103d72:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d78:	05 80 33 11 80       	add    $0x80113380,%eax
80103d7d:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103d7f:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d84:	83 c0 01             	add    $0x1,%eax
80103d87:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103d8c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d90:	eb 42                	jmp    80103dd4 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d9b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d9f:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103da4:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103da8:	eb 2a                	jmp    80103dd4 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103daa:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103dae:	eb 24                	jmp    80103dd4 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db3:	0f b6 00             	movzbl (%eax),%eax
80103db6:	0f b6 c0             	movzbl %al,%eax
80103db9:	83 ec 08             	sub    $0x8,%esp
80103dbc:	50                   	push   %eax
80103dbd:	68 04 92 10 80       	push   $0x80109204
80103dc2:	e8 ff c5 ff ff       	call   801003c6 <cprintf>
80103dc7:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103dca:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103dd1:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103dda:	0f 82 02 ff ff ff    	jb     80103ce2 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103de0:	a1 64 33 11 80       	mov    0x80113364,%eax
80103de5:	85 c0                	test   %eax,%eax
80103de7:	75 1d                	jne    80103e06 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103de9:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103df0:	00 00 00 
    lapic = 0;
80103df3:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103dfa:	00 00 00 
    ioapicid = 0;
80103dfd:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103e04:	eb 3e                	jmp    80103e44 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103e06:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e09:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103e0d:	84 c0                	test   %al,%al
80103e0f:	74 33                	je     80103e44 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e11:	83 ec 08             	sub    $0x8,%esp
80103e14:	6a 70                	push   $0x70
80103e16:	6a 22                	push   $0x22
80103e18:	e8 1c fc ff ff       	call   80103a39 <outb>
80103e1d:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e20:	83 ec 0c             	sub    $0xc,%esp
80103e23:	6a 23                	push   $0x23
80103e25:	e8 f2 fb ff ff       	call   80103a1c <inb>
80103e2a:	83 c4 10             	add    $0x10,%esp
80103e2d:	83 c8 01             	or     $0x1,%eax
80103e30:	0f b6 c0             	movzbl %al,%eax
80103e33:	83 ec 08             	sub    $0x8,%esp
80103e36:	50                   	push   %eax
80103e37:	6a 23                	push   $0x23
80103e39:	e8 fb fb ff ff       	call   80103a39 <outb>
80103e3e:	83 c4 10             	add    $0x10,%esp
80103e41:	eb 01                	jmp    80103e44 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103e43:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103e44:	c9                   	leave  
80103e45:	c3                   	ret    

80103e46 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e46:	55                   	push   %ebp
80103e47:	89 e5                	mov    %esp,%ebp
80103e49:	83 ec 08             	sub    $0x8,%esp
80103e4c:	8b 55 08             	mov    0x8(%ebp),%edx
80103e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e52:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e56:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e59:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e5d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e61:	ee                   	out    %al,(%dx)
}
80103e62:	90                   	nop
80103e63:	c9                   	leave  
80103e64:	c3                   	ret    

80103e65 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103e65:	55                   	push   %ebp
80103e66:	89 e5                	mov    %esp,%ebp
80103e68:	83 ec 04             	sub    $0x4,%esp
80103e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103e72:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e76:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103e7c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e80:	0f b6 c0             	movzbl %al,%eax
80103e83:	50                   	push   %eax
80103e84:	6a 21                	push   $0x21
80103e86:	e8 bb ff ff ff       	call   80103e46 <outb>
80103e8b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103e8e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e92:	66 c1 e8 08          	shr    $0x8,%ax
80103e96:	0f b6 c0             	movzbl %al,%eax
80103e99:	50                   	push   %eax
80103e9a:	68 a1 00 00 00       	push   $0xa1
80103e9f:	e8 a2 ff ff ff       	call   80103e46 <outb>
80103ea4:	83 c4 08             	add    $0x8,%esp
}
80103ea7:	90                   	nop
80103ea8:	c9                   	leave  
80103ea9:	c3                   	ret    

80103eaa <picenable>:

void
picenable(int irq)
{
80103eaa:	55                   	push   %ebp
80103eab:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103ead:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb0:	ba 01 00 00 00       	mov    $0x1,%edx
80103eb5:	89 c1                	mov    %eax,%ecx
80103eb7:	d3 e2                	shl    %cl,%edx
80103eb9:	89 d0                	mov    %edx,%eax
80103ebb:	f7 d0                	not    %eax
80103ebd:	89 c2                	mov    %eax,%edx
80103ebf:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103ec6:	21 d0                	and    %edx,%eax
80103ec8:	0f b7 c0             	movzwl %ax,%eax
80103ecb:	50                   	push   %eax
80103ecc:	e8 94 ff ff ff       	call   80103e65 <picsetmask>
80103ed1:	83 c4 04             	add    $0x4,%esp
}
80103ed4:	90                   	nop
80103ed5:	c9                   	leave  
80103ed6:	c3                   	ret    

80103ed7 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103ed7:	55                   	push   %ebp
80103ed8:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103eda:	68 ff 00 00 00       	push   $0xff
80103edf:	6a 21                	push   $0x21
80103ee1:	e8 60 ff ff ff       	call   80103e46 <outb>
80103ee6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103ee9:	68 ff 00 00 00       	push   $0xff
80103eee:	68 a1 00 00 00       	push   $0xa1
80103ef3:	e8 4e ff ff ff       	call   80103e46 <outb>
80103ef8:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103efb:	6a 11                	push   $0x11
80103efd:	6a 20                	push   $0x20
80103eff:	e8 42 ff ff ff       	call   80103e46 <outb>
80103f04:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103f07:	6a 20                	push   $0x20
80103f09:	6a 21                	push   $0x21
80103f0b:	e8 36 ff ff ff       	call   80103e46 <outb>
80103f10:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f13:	6a 04                	push   $0x4
80103f15:	6a 21                	push   $0x21
80103f17:	e8 2a ff ff ff       	call   80103e46 <outb>
80103f1c:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103f1f:	6a 03                	push   $0x3
80103f21:	6a 21                	push   $0x21
80103f23:	e8 1e ff ff ff       	call   80103e46 <outb>
80103f28:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f2b:	6a 11                	push   $0x11
80103f2d:	68 a0 00 00 00       	push   $0xa0
80103f32:	e8 0f ff ff ff       	call   80103e46 <outb>
80103f37:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103f3a:	6a 28                	push   $0x28
80103f3c:	68 a1 00 00 00       	push   $0xa1
80103f41:	e8 00 ff ff ff       	call   80103e46 <outb>
80103f46:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f49:	6a 02                	push   $0x2
80103f4b:	68 a1 00 00 00       	push   $0xa1
80103f50:	e8 f1 fe ff ff       	call   80103e46 <outb>
80103f55:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f58:	6a 03                	push   $0x3
80103f5a:	68 a1 00 00 00       	push   $0xa1
80103f5f:	e8 e2 fe ff ff       	call   80103e46 <outb>
80103f64:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f67:	6a 68                	push   $0x68
80103f69:	6a 20                	push   $0x20
80103f6b:	e8 d6 fe ff ff       	call   80103e46 <outb>
80103f70:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f73:	6a 0a                	push   $0xa
80103f75:	6a 20                	push   $0x20
80103f77:	e8 ca fe ff ff       	call   80103e46 <outb>
80103f7c:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80103f7f:	6a 68                	push   $0x68
80103f81:	68 a0 00 00 00       	push   $0xa0
80103f86:	e8 bb fe ff ff       	call   80103e46 <outb>
80103f8b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80103f8e:	6a 0a                	push   $0xa
80103f90:	68 a0 00 00 00       	push   $0xa0
80103f95:	e8 ac fe ff ff       	call   80103e46 <outb>
80103f9a:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80103f9d:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103fa4:	66 83 f8 ff          	cmp    $0xffff,%ax
80103fa8:	74 13                	je     80103fbd <picinit+0xe6>
    picsetmask(irqmask);
80103faa:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103fb1:	0f b7 c0             	movzwl %ax,%eax
80103fb4:	50                   	push   %eax
80103fb5:	e8 ab fe ff ff       	call   80103e65 <picsetmask>
80103fba:	83 c4 04             	add    $0x4,%esp
}
80103fbd:	90                   	nop
80103fbe:	c9                   	leave  
80103fbf:	c3                   	ret    

80103fc0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fc0:	55                   	push   %ebp
80103fc1:	89 e5                	mov    %esp,%ebp
80103fc3:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103fc6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd9:	8b 10                	mov    (%eax),%edx
80103fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fde:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fe0:	e8 a1 cf ff ff       	call   80100f86 <filealloc>
80103fe5:	89 c2                	mov    %eax,%edx
80103fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80103fea:	89 10                	mov    %edx,(%eax)
80103fec:	8b 45 08             	mov    0x8(%ebp),%eax
80103fef:	8b 00                	mov    (%eax),%eax
80103ff1:	85 c0                	test   %eax,%eax
80103ff3:	0f 84 cb 00 00 00    	je     801040c4 <pipealloc+0x104>
80103ff9:	e8 88 cf ff ff       	call   80100f86 <filealloc>
80103ffe:	89 c2                	mov    %eax,%edx
80104000:	8b 45 0c             	mov    0xc(%ebp),%eax
80104003:	89 10                	mov    %edx,(%eax)
80104005:	8b 45 0c             	mov    0xc(%ebp),%eax
80104008:	8b 00                	mov    (%eax),%eax
8010400a:	85 c0                	test   %eax,%eax
8010400c:	0f 84 b2 00 00 00    	je     801040c4 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104012:	e8 bc eb ff ff       	call   80102bd3 <kalloc>
80104017:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010401a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010401e:	0f 84 9f 00 00 00    	je     801040c3 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104027:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010402e:	00 00 00 
  p->writeopen = 1;
80104031:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104034:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010403b:	00 00 00 
  p->nwrite = 0;
8010403e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104041:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104048:	00 00 00 
  p->nread = 0;
8010404b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404e:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104055:	00 00 00 
  initlock(&p->lock, "pipe");
80104058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405b:	83 ec 08             	sub    $0x8,%esp
8010405e:	68 38 92 10 80       	push   $0x80109238
80104063:	50                   	push   %eax
80104064:	e8 51 17 00 00       	call   801057ba <initlock>
80104069:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010406c:	8b 45 08             	mov    0x8(%ebp),%eax
8010406f:	8b 00                	mov    (%eax),%eax
80104071:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104077:	8b 45 08             	mov    0x8(%ebp),%eax
8010407a:	8b 00                	mov    (%eax),%eax
8010407c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104080:	8b 45 08             	mov    0x8(%ebp),%eax
80104083:	8b 00                	mov    (%eax),%eax
80104085:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104089:	8b 45 08             	mov    0x8(%ebp),%eax
8010408c:	8b 00                	mov    (%eax),%eax
8010408e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104091:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104094:	8b 45 0c             	mov    0xc(%ebp),%eax
80104097:	8b 00                	mov    (%eax),%eax
80104099:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010409f:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a2:	8b 00                	mov    (%eax),%eax
801040a4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ab:	8b 00                	mov    (%eax),%eax
801040ad:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b4:	8b 00                	mov    (%eax),%eax
801040b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040b9:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040bc:	b8 00 00 00 00       	mov    $0x0,%eax
801040c1:	eb 4e                	jmp    80104111 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801040c3:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801040c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040c8:	74 0e                	je     801040d8 <pipealloc+0x118>
    kfree((char*)p);
801040ca:	83 ec 0c             	sub    $0xc,%esp
801040cd:	ff 75 f4             	pushl  -0xc(%ebp)
801040d0:	e8 61 ea ff ff       	call   80102b36 <kfree>
801040d5:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801040d8:	8b 45 08             	mov    0x8(%ebp),%eax
801040db:	8b 00                	mov    (%eax),%eax
801040dd:	85 c0                	test   %eax,%eax
801040df:	74 11                	je     801040f2 <pipealloc+0x132>
    fileclose(*f0);
801040e1:	8b 45 08             	mov    0x8(%ebp),%eax
801040e4:	8b 00                	mov    (%eax),%eax
801040e6:	83 ec 0c             	sub    $0xc,%esp
801040e9:	50                   	push   %eax
801040ea:	e8 55 cf ff ff       	call   80101044 <fileclose>
801040ef:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801040f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f5:	8b 00                	mov    (%eax),%eax
801040f7:	85 c0                	test   %eax,%eax
801040f9:	74 11                	je     8010410c <pipealloc+0x14c>
    fileclose(*f1);
801040fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801040fe:	8b 00                	mov    (%eax),%eax
80104100:	83 ec 0c             	sub    $0xc,%esp
80104103:	50                   	push   %eax
80104104:	e8 3b cf ff ff       	call   80101044 <fileclose>
80104109:	83 c4 10             	add    $0x10,%esp
  return -1;
8010410c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104111:	c9                   	leave  
80104112:	c3                   	ret    

80104113 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104113:	55                   	push   %ebp
80104114:	89 e5                	mov    %esp,%ebp
80104116:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104119:	8b 45 08             	mov    0x8(%ebp),%eax
8010411c:	83 ec 0c             	sub    $0xc,%esp
8010411f:	50                   	push   %eax
80104120:	e8 b7 16 00 00       	call   801057dc <acquire>
80104125:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104128:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010412c:	74 23                	je     80104151 <pipeclose+0x3e>
    p->writeopen = 0;
8010412e:	8b 45 08             	mov    0x8(%ebp),%eax
80104131:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104138:	00 00 00 
    wakeup(&p->nread);
8010413b:	8b 45 08             	mov    0x8(%ebp),%eax
8010413e:	05 34 02 00 00       	add    $0x234,%eax
80104143:	83 ec 0c             	sub    $0xc,%esp
80104146:	50                   	push   %eax
80104147:	e8 4e 0e 00 00       	call   80104f9a <wakeup>
8010414c:	83 c4 10             	add    $0x10,%esp
8010414f:	eb 21                	jmp    80104172 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104151:	8b 45 08             	mov    0x8(%ebp),%eax
80104154:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010415b:	00 00 00 
    wakeup(&p->nwrite);
8010415e:	8b 45 08             	mov    0x8(%ebp),%eax
80104161:	05 38 02 00 00       	add    $0x238,%eax
80104166:	83 ec 0c             	sub    $0xc,%esp
80104169:	50                   	push   %eax
8010416a:	e8 2b 0e 00 00       	call   80104f9a <wakeup>
8010416f:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104172:	8b 45 08             	mov    0x8(%ebp),%eax
80104175:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010417b:	85 c0                	test   %eax,%eax
8010417d:	75 2c                	jne    801041ab <pipeclose+0x98>
8010417f:	8b 45 08             	mov    0x8(%ebp),%eax
80104182:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104188:	85 c0                	test   %eax,%eax
8010418a:	75 1f                	jne    801041ab <pipeclose+0x98>
    release(&p->lock);
8010418c:	8b 45 08             	mov    0x8(%ebp),%eax
8010418f:	83 ec 0c             	sub    $0xc,%esp
80104192:	50                   	push   %eax
80104193:	e8 ab 16 00 00       	call   80105843 <release>
80104198:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010419b:	83 ec 0c             	sub    $0xc,%esp
8010419e:	ff 75 08             	pushl  0x8(%ebp)
801041a1:	e8 90 e9 ff ff       	call   80102b36 <kfree>
801041a6:	83 c4 10             	add    $0x10,%esp
801041a9:	eb 0f                	jmp    801041ba <pipeclose+0xa7>
  } else
    release(&p->lock);
801041ab:	8b 45 08             	mov    0x8(%ebp),%eax
801041ae:	83 ec 0c             	sub    $0xc,%esp
801041b1:	50                   	push   %eax
801041b2:	e8 8c 16 00 00       	call   80105843 <release>
801041b7:	83 c4 10             	add    $0x10,%esp
}
801041ba:	90                   	nop
801041bb:	c9                   	leave  
801041bc:	c3                   	ret    

801041bd <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041bd:	55                   	push   %ebp
801041be:	89 e5                	mov    %esp,%ebp
801041c0:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801041c3:	8b 45 08             	mov    0x8(%ebp),%eax
801041c6:	83 ec 0c             	sub    $0xc,%esp
801041c9:	50                   	push   %eax
801041ca:	e8 0d 16 00 00       	call   801057dc <acquire>
801041cf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801041d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041d9:	e9 ad 00 00 00       	jmp    8010428b <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801041de:	8b 45 08             	mov    0x8(%ebp),%eax
801041e1:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041e7:	85 c0                	test   %eax,%eax
801041e9:	74 0d                	je     801041f8 <pipewrite+0x3b>
801041eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041f1:	8b 40 24             	mov    0x24(%eax),%eax
801041f4:	85 c0                	test   %eax,%eax
801041f6:	74 19                	je     80104211 <pipewrite+0x54>
        release(&p->lock);
801041f8:	8b 45 08             	mov    0x8(%ebp),%eax
801041fb:	83 ec 0c             	sub    $0xc,%esp
801041fe:	50                   	push   %eax
801041ff:	e8 3f 16 00 00       	call   80105843 <release>
80104204:	83 c4 10             	add    $0x10,%esp
        return -1;
80104207:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010420c:	e9 a8 00 00 00       	jmp    801042b9 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104211:	8b 45 08             	mov    0x8(%ebp),%eax
80104214:	05 34 02 00 00       	add    $0x234,%eax
80104219:	83 ec 0c             	sub    $0xc,%esp
8010421c:	50                   	push   %eax
8010421d:	e8 78 0d 00 00       	call   80104f9a <wakeup>
80104222:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104225:	8b 45 08             	mov    0x8(%ebp),%eax
80104228:	8b 55 08             	mov    0x8(%ebp),%edx
8010422b:	81 c2 38 02 00 00    	add    $0x238,%edx
80104231:	83 ec 08             	sub    $0x8,%esp
80104234:	50                   	push   %eax
80104235:	52                   	push   %edx
80104236:	e8 4a 0c 00 00       	call   80104e85 <sleep>
8010423b:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010423e:	8b 45 08             	mov    0x8(%ebp),%eax
80104241:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104247:	8b 45 08             	mov    0x8(%ebp),%eax
8010424a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104250:	05 00 02 00 00       	add    $0x200,%eax
80104255:	39 c2                	cmp    %eax,%edx
80104257:	74 85                	je     801041de <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104259:	8b 45 08             	mov    0x8(%ebp),%eax
8010425c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104262:	8d 48 01             	lea    0x1(%eax),%ecx
80104265:	8b 55 08             	mov    0x8(%ebp),%edx
80104268:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010426e:	25 ff 01 00 00       	and    $0x1ff,%eax
80104273:	89 c1                	mov    %eax,%ecx
80104275:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104278:	8b 45 0c             	mov    0xc(%ebp),%eax
8010427b:	01 d0                	add    %edx,%eax
8010427d:	0f b6 10             	movzbl (%eax),%edx
80104280:	8b 45 08             	mov    0x8(%ebp),%eax
80104283:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104287:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010428b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010428e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104291:	7c ab                	jl     8010423e <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104293:	8b 45 08             	mov    0x8(%ebp),%eax
80104296:	05 34 02 00 00       	add    $0x234,%eax
8010429b:	83 ec 0c             	sub    $0xc,%esp
8010429e:	50                   	push   %eax
8010429f:	e8 f6 0c 00 00       	call   80104f9a <wakeup>
801042a4:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801042a7:	8b 45 08             	mov    0x8(%ebp),%eax
801042aa:	83 ec 0c             	sub    $0xc,%esp
801042ad:	50                   	push   %eax
801042ae:	e8 90 15 00 00       	call   80105843 <release>
801042b3:	83 c4 10             	add    $0x10,%esp
  return n;
801042b6:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042b9:	c9                   	leave  
801042ba:	c3                   	ret    

801042bb <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042bb:	55                   	push   %ebp
801042bc:	89 e5                	mov    %esp,%ebp
801042be:	53                   	push   %ebx
801042bf:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801042c2:	8b 45 08             	mov    0x8(%ebp),%eax
801042c5:	83 ec 0c             	sub    $0xc,%esp
801042c8:	50                   	push   %eax
801042c9:	e8 0e 15 00 00       	call   801057dc <acquire>
801042ce:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042d1:	eb 3f                	jmp    80104312 <piperead+0x57>
    if(proc->killed){
801042d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042d9:	8b 40 24             	mov    0x24(%eax),%eax
801042dc:	85 c0                	test   %eax,%eax
801042de:	74 19                	je     801042f9 <piperead+0x3e>
      release(&p->lock);
801042e0:	8b 45 08             	mov    0x8(%ebp),%eax
801042e3:	83 ec 0c             	sub    $0xc,%esp
801042e6:	50                   	push   %eax
801042e7:	e8 57 15 00 00       	call   80105843 <release>
801042ec:	83 c4 10             	add    $0x10,%esp
      return -1;
801042ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042f4:	e9 bf 00 00 00       	jmp    801043b8 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042f9:	8b 45 08             	mov    0x8(%ebp),%eax
801042fc:	8b 55 08             	mov    0x8(%ebp),%edx
801042ff:	81 c2 34 02 00 00    	add    $0x234,%edx
80104305:	83 ec 08             	sub    $0x8,%esp
80104308:	50                   	push   %eax
80104309:	52                   	push   %edx
8010430a:	e8 76 0b 00 00       	call   80104e85 <sleep>
8010430f:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104312:	8b 45 08             	mov    0x8(%ebp),%eax
80104315:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010431b:	8b 45 08             	mov    0x8(%ebp),%eax
8010431e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104324:	39 c2                	cmp    %eax,%edx
80104326:	75 0d                	jne    80104335 <piperead+0x7a>
80104328:	8b 45 08             	mov    0x8(%ebp),%eax
8010432b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104331:	85 c0                	test   %eax,%eax
80104333:	75 9e                	jne    801042d3 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104335:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010433c:	eb 49                	jmp    80104387 <piperead+0xcc>
    if(p->nread == p->nwrite)
8010433e:	8b 45 08             	mov    0x8(%ebp),%eax
80104341:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104347:	8b 45 08             	mov    0x8(%ebp),%eax
8010434a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104350:	39 c2                	cmp    %eax,%edx
80104352:	74 3d                	je     80104391 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104354:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104357:	8b 45 0c             	mov    0xc(%ebp),%eax
8010435a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010435d:	8b 45 08             	mov    0x8(%ebp),%eax
80104360:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104366:	8d 48 01             	lea    0x1(%eax),%ecx
80104369:	8b 55 08             	mov    0x8(%ebp),%edx
8010436c:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104372:	25 ff 01 00 00       	and    $0x1ff,%eax
80104377:	89 c2                	mov    %eax,%edx
80104379:	8b 45 08             	mov    0x8(%ebp),%eax
8010437c:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104381:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104383:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010438d:	7c af                	jl     8010433e <piperead+0x83>
8010438f:	eb 01                	jmp    80104392 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104391:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104392:	8b 45 08             	mov    0x8(%ebp),%eax
80104395:	05 38 02 00 00       	add    $0x238,%eax
8010439a:	83 ec 0c             	sub    $0xc,%esp
8010439d:	50                   	push   %eax
8010439e:	e8 f7 0b 00 00       	call   80104f9a <wakeup>
801043a3:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043a6:	8b 45 08             	mov    0x8(%ebp),%eax
801043a9:	83 ec 0c             	sub    $0xc,%esp
801043ac:	50                   	push   %eax
801043ad:	e8 91 14 00 00       	call   80105843 <release>
801043b2:	83 c4 10             	add    $0x10,%esp
  return i;
801043b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043bb:	c9                   	leave  
801043bc:	c3                   	ret    

801043bd <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801043bd:	55                   	push   %ebp
801043be:	89 e5                	mov    %esp,%ebp
801043c0:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043c3:	9c                   	pushf  
801043c4:	58                   	pop    %eax
801043c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801043c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043cb:	c9                   	leave  
801043cc:	c3                   	ret    

801043cd <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801043cd:	55                   	push   %ebp
801043ce:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043d0:	fb                   	sti    
}
801043d1:	90                   	nop
801043d2:	5d                   	pop    %ebp
801043d3:	c3                   	ret    

801043d4 <hlt>:
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
}

static inline void
hlt(void) {
801043d4:	55                   	push   %ebp
801043d5:	89 e5                	mov    %esp,%ebp
  asm volatile("hlt");
801043d7:	f4                   	hlt    
}
801043d8:	90                   	nop
801043d9:	5d                   	pop    %ebp
801043da:	c3                   	ret    

801043db <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801043db:	55                   	push   %ebp
801043dc:	89 e5                	mov    %esp,%ebp
801043de:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801043e1:	83 ec 08             	sub    $0x8,%esp
801043e4:	68 40 92 10 80       	push   $0x80109240
801043e9:	68 80 39 11 80       	push   $0x80113980
801043ee:	e8 c7 13 00 00       	call   801057ba <initlock>
801043f3:	83 c4 10             	add    $0x10,%esp
}
801043f6:	90                   	nop
801043f7:	c9                   	leave  
801043f8:	c3                   	ret    

801043f9 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801043f9:	55                   	push   %ebp
801043fa:	89 e5                	mov    %esp,%ebp
801043fc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801043ff:	83 ec 0c             	sub    $0xc,%esp
80104402:	68 80 39 11 80       	push   $0x80113980
80104407:	e8 d0 13 00 00       	call   801057dc <acquire>
8010440c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010440f:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104416:	eb 11                	jmp    80104429 <allocproc+0x30>
    if(p->state == UNUSED)
80104418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441b:	8b 40 0c             	mov    0xc(%eax),%eax
8010441e:	85 c0                	test   %eax,%eax
80104420:	74 2a                	je     8010444c <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104422:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104429:	81 7d f4 b4 62 11 80 	cmpl   $0x801162b4,-0xc(%ebp)
80104430:	72 e6                	jb     80104418 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104432:	83 ec 0c             	sub    $0xc,%esp
80104435:	68 80 39 11 80       	push   $0x80113980
8010443a:	e8 04 14 00 00       	call   80105843 <release>
8010443f:	83 c4 10             	add    $0x10,%esp
  return 0;
80104442:	b8 00 00 00 00       	mov    $0x0,%eax
80104447:	e9 c0 00 00 00       	jmp    8010450c <allocproc+0x113>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010444c:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010444d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104450:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104457:	a1 04 c0 10 80       	mov    0x8010c004,%eax
8010445c:	8d 50 01             	lea    0x1(%eax),%edx
8010445f:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104465:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104468:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
8010446b:	83 ec 0c             	sub    $0xc,%esp
8010446e:	68 80 39 11 80       	push   $0x80113980
80104473:	e8 cb 13 00 00       	call   80105843 <release>
80104478:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010447b:	e8 53 e7 ff ff       	call   80102bd3 <kalloc>
80104480:	89 c2                	mov    %eax,%edx
80104482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104485:	89 50 08             	mov    %edx,0x8(%eax)
80104488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448b:	8b 40 08             	mov    0x8(%eax),%eax
8010448e:	85 c0                	test   %eax,%eax
80104490:	75 11                	jne    801044a3 <allocproc+0xaa>
    p->state = UNUSED;
80104492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104495:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010449c:	b8 00 00 00 00       	mov    $0x0,%eax
801044a1:	eb 69                	jmp    8010450c <allocproc+0x113>
  }
  sp = p->kstack + KSTACKSIZE;
801044a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a6:	8b 40 08             	mov    0x8(%eax),%eax
801044a9:	05 00 10 00 00       	add    $0x1000,%eax
801044ae:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801044b1:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801044b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044bb:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801044be:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801044c2:	ba 2f 6f 10 80       	mov    $0x80106f2f,%edx
801044c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ca:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801044cc:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801044d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044d6:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801044d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dc:	8b 40 1c             	mov    0x1c(%eax),%eax
801044df:	83 ec 04             	sub    $0x4,%esp
801044e2:	6a 14                	push   $0x14
801044e4:	6a 00                	push   $0x0
801044e6:	50                   	push   %eax
801044e7:	e8 53 15 00 00       	call   80105a3f <memset>
801044ec:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801044ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f2:	8b 40 1c             	mov    0x1c(%eax),%eax
801044f5:	ba 54 4e 10 80       	mov    $0x80104e54,%edx
801044fa:	89 50 10             	mov    %edx,0x10(%eax)

  //set priority 0 by default
  p->priority = 0;
801044fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104500:	66 c7 80 84 00 00 00 	movw   $0x0,0x84(%eax)
80104507:	00 00 

  return p;
80104509:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010450c:	c9                   	leave  
8010450d:	c3                   	ret    

8010450e <makerunnable>:

//PAGEBREAK: 32

void
makerunnable (struct proc* p)
{
8010450e:	55                   	push   %ebp
8010450f:	89 e5                	mov    %esp,%ebp
80104511:	83 ec 10             	sub    $0x10,%esp
  int priority;
  struct proc* lastOfLevel ;
  p->state = RUNNABLE;
80104514:	8b 45 08             	mov    0x8(%ebp),%eax
80104517:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  p->next=0;
8010451e:	8b 45 08             	mov    0x8(%ebp),%eax
80104521:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104528:	00 00 00 
  p->age=0;
8010452b:	8b 45 08             	mov    0x8(%ebp),%eax
8010452e:	66 c7 80 86 00 00 00 	movw   $0x0,0x86(%eax)
80104535:	00 00 
  priority=p->priority;
80104537:	8b 45 08             	mov    0x8(%ebp),%eax
8010453a:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80104541:	0f b7 c0             	movzwl %ax,%eax
80104544:	89 45 f8             	mov    %eax,-0x8(%ebp)
  lastOfLevel = ptable.mlf[priority];
80104547:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010454a:	05 4c 0a 00 00       	add    $0xa4c,%eax
8010454f:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
80104556:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(lastOfLevel ==0){   //If the level does not have processes, it saves the process as the first
80104559:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010455d:	75 21                	jne    80104580 <makerunnable+0x72>
    ptable.mlf[priority]=p;
8010455f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104562:	8d 90 4c 0a 00 00    	lea    0xa4c(%eax),%edx
80104568:	8b 45 08             	mov    0x8(%ebp),%eax
8010456b:	89 04 95 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,4)
    while(lastOfLevel->next != 0){ // if not, I take the first and advance until I reach the last
      lastOfLevel=lastOfLevel->next;
    }
    lastOfLevel->next=p;  //and I keep it as the last
  }
}
80104572:	eb 25                	jmp    80104599 <makerunnable+0x8b>

  if(lastOfLevel ==0){   //If the level does not have processes, it saves the process as the first
    ptable.mlf[priority]=p;
  }else{
    while(lastOfLevel->next != 0){ // if not, I take the first and advance until I reach the last
      lastOfLevel=lastOfLevel->next;
80104574:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104577:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010457d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  lastOfLevel = ptable.mlf[priority];

  if(lastOfLevel ==0){   //If the level does not have processes, it saves the process as the first
    ptable.mlf[priority]=p;
  }else{
    while(lastOfLevel->next != 0){ // if not, I take the first and advance until I reach the last
80104580:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104583:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104589:	85 c0                	test   %eax,%eax
8010458b:	75 e7                	jne    80104574 <makerunnable+0x66>
      lastOfLevel=lastOfLevel->next;
    }
    lastOfLevel->next=p;  //and I keep it as the last
8010458d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104590:	8b 55 08             	mov    0x8(%ebp),%edx
80104593:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  }
}
80104599:	90                   	nop
8010459a:	c9                   	leave  
8010459b:	c3                   	ret    

8010459c <unqueue>:

struct proc*
unqueue(int level)
{
8010459c:	55                   	push   %ebp
8010459d:	89 e5                	mov    %esp,%ebp
8010459f:	83 ec 10             	sub    $0x10,%esp
  struct proc* res;
  res=0;
801045a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  if(ptable.mlf[level]!=0){
801045a9:	8b 45 08             	mov    0x8(%ebp),%eax
801045ac:	05 4c 0a 00 00       	add    $0xa4c,%eax
801045b1:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
801045b8:	85 c0                	test   %eax,%eax
801045ba:	74 44                	je     80104600 <unqueue+0x64>
    res =ptable.mlf[level];
801045bc:	8b 45 08             	mov    0x8(%ebp),%eax
801045bf:	05 4c 0a 00 00       	add    $0xa4c,%eax
801045c4:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
801045cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    ptable.mlf[level]=ptable.mlf[level]->next;
801045ce:	8b 45 08             	mov    0x8(%ebp),%eax
801045d1:	05 4c 0a 00 00       	add    $0xa4c,%eax
801045d6:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
801045dd:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801045e3:	8b 55 08             	mov    0x8(%ebp),%edx
801045e6:	81 c2 4c 0a 00 00    	add    $0xa4c,%edx
801045ec:	89 04 95 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,4)
    res->next=0;
801045f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045f6:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801045fd:	00 00 00 
  }
  return res;
80104600:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104603:	c9                   	leave  
80104604:	c3                   	ret    

80104605 <userinit>:


// Set up first user process.
void
userinit(void)
{
80104605:	55                   	push   %ebp
80104606:	89 e5                	mov    %esp,%ebp
80104608:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010460b:	e8 e9 fd ff ff       	call   801043f9 <allocproc>
80104610:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104616:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
8010461b:	e8 2f 41 00 00       	call   8010874f <setupkvm>
80104620:	89 c2                	mov    %eax,%edx
80104622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104625:	89 50 04             	mov    %edx,0x4(%eax)
80104628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462b:	8b 40 04             	mov    0x4(%eax),%eax
8010462e:	85 c0                	test   %eax,%eax
80104630:	75 0d                	jne    8010463f <userinit+0x3a>
    panic("userinit: out of memory?");
80104632:	83 ec 0c             	sub    $0xc,%esp
80104635:	68 47 92 10 80       	push   $0x80109247
8010463a:	e8 27 bf ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010463f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104647:	8b 40 04             	mov    0x4(%eax),%eax
8010464a:	83 ec 04             	sub    $0x4,%esp
8010464d:	52                   	push   %edx
8010464e:	68 00 c5 10 80       	push   $0x8010c500
80104653:	50                   	push   %eax
80104654:	e8 50 43 00 00       	call   801089a9 <inituvm>
80104659:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010465c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104668:	8b 40 18             	mov    0x18(%eax),%eax
8010466b:	83 ec 04             	sub    $0x4,%esp
8010466e:	6a 4c                	push   $0x4c
80104670:	6a 00                	push   $0x0
80104672:	50                   	push   %eax
80104673:	e8 c7 13 00 00       	call   80105a3f <memset>
80104678:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010467b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467e:	8b 40 18             	mov    0x18(%eax),%eax
80104681:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468a:	8b 40 18             	mov    0x18(%eax),%eax
8010468d:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104696:	8b 40 18             	mov    0x18(%eax),%eax
80104699:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010469c:	8b 52 18             	mov    0x18(%edx),%edx
8010469f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046a3:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801046a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046aa:	8b 40 18             	mov    0x18(%eax),%eax
801046ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046b0:	8b 52 18             	mov    0x18(%edx),%edx
801046b3:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046b7:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801046bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046be:	8b 40 18             	mov    0x18(%eax),%eax
801046c1:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801046c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cb:	8b 40 18             	mov    0x18(%eax),%eax
801046ce:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801046d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d8:	8b 40 18             	mov    0x18(%eax),%eax
801046db:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801046e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e5:	83 c0 6c             	add    $0x6c,%eax
801046e8:	83 ec 04             	sub    $0x4,%esp
801046eb:	6a 10                	push   $0x10
801046ed:	68 60 92 10 80       	push   $0x80109260
801046f2:	50                   	push   %eax
801046f3:	e8 4a 15 00 00       	call   80105c42 <safestrcpy>
801046f8:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046fb:	83 ec 0c             	sub    $0xc,%esp
801046fe:	68 69 92 10 80       	push   $0x80109269
80104703:	e8 c9 dd ff ff       	call   801024d1 <namei>
80104708:	83 c4 10             	add    $0x10,%esp
8010470b:	89 c2                	mov    %eax,%edx
8010470d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104710:	89 50 68             	mov    %edx,0x68(%eax)

  //cprintf(" antes make runabbele de userinit \n");
  makerunnable(p);
80104713:	83 ec 0c             	sub    $0xc,%esp
80104716:	ff 75 f4             	pushl  -0xc(%ebp)
80104719:	e8 f0 fd ff ff       	call   8010450e <makerunnable>
8010471e:	83 c4 10             	add    $0x10,%esp
  //cprintf("despues make runabbele de userinit \n");
}
80104721:	90                   	nop
80104722:	c9                   	leave  
80104723:	c3                   	ret    

80104724 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104724:	55                   	push   %ebp
80104725:	89 e5                	mov    %esp,%ebp
80104727:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
8010472a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104730:	8b 00                	mov    (%eax),%eax
80104732:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104735:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104739:	7e 31                	jle    8010476c <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010473b:	8b 55 08             	mov    0x8(%ebp),%edx
8010473e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104741:	01 c2                	add    %eax,%edx
80104743:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104749:	8b 40 04             	mov    0x4(%eax),%eax
8010474c:	83 ec 04             	sub    $0x4,%esp
8010474f:	52                   	push   %edx
80104750:	ff 75 f4             	pushl  -0xc(%ebp)
80104753:	50                   	push   %eax
80104754:	e8 9d 43 00 00       	call   80108af6 <allocuvm>
80104759:	83 c4 10             	add    $0x10,%esp
8010475c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010475f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104763:	75 3e                	jne    801047a3 <growproc+0x7f>
      return -1;
80104765:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010476a:	eb 59                	jmp    801047c5 <growproc+0xa1>
  } else if(n < 0){
8010476c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104770:	79 31                	jns    801047a3 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104772:	8b 55 08             	mov    0x8(%ebp),%edx
80104775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104778:	01 c2                	add    %eax,%edx
8010477a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104780:	8b 40 04             	mov    0x4(%eax),%eax
80104783:	83 ec 04             	sub    $0x4,%esp
80104786:	52                   	push   %edx
80104787:	ff 75 f4             	pushl  -0xc(%ebp)
8010478a:	50                   	push   %eax
8010478b:	e8 2f 44 00 00       	call   80108bbf <deallocuvm>
80104790:	83 c4 10             	add    $0x10,%esp
80104793:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104796:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010479a:	75 07                	jne    801047a3 <growproc+0x7f>
      return -1;
8010479c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a1:	eb 22                	jmp    801047c5 <growproc+0xa1>
  }
  proc->sz = sz;
801047a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047ac:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801047ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b4:	83 ec 0c             	sub    $0xc,%esp
801047b7:	50                   	push   %eax
801047b8:	e8 79 40 00 00       	call   80108836 <switchuvm>
801047bd:	83 c4 10             	add    $0x10,%esp
  return 0;
801047c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801047c5:	c9                   	leave  
801047c6:	c3                   	ret    

801047c7 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801047c7:	55                   	push   %ebp
801047c8:	89 e5                	mov    %esp,%ebp
801047ca:	57                   	push   %edi
801047cb:	56                   	push   %esi
801047cc:	53                   	push   %ebx
801047cd:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801047d0:	e8 24 fc ff ff       	call   801043f9 <allocproc>
801047d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801047d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801047dc:	75 0a                	jne    801047e8 <fork+0x21>
    return -1;
801047de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047e3:	e9 d3 01 00 00       	jmp    801049bb <fork+0x1f4>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801047e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ee:	8b 10                	mov    (%eax),%edx
801047f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f6:	8b 40 04             	mov    0x4(%eax),%eax
801047f9:	83 ec 08             	sub    $0x8,%esp
801047fc:	52                   	push   %edx
801047fd:	50                   	push   %eax
801047fe:	e8 5a 45 00 00       	call   80108d5d <copyuvm>
80104803:	83 c4 10             	add    $0x10,%esp
80104806:	89 c2                	mov    %eax,%edx
80104808:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010480b:	89 50 04             	mov    %edx,0x4(%eax)
8010480e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104811:	8b 40 04             	mov    0x4(%eax),%eax
80104814:	85 c0                	test   %eax,%eax
80104816:	75 30                	jne    80104848 <fork+0x81>
    kfree(np->kstack);
80104818:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010481b:	8b 40 08             	mov    0x8(%eax),%eax
8010481e:	83 ec 0c             	sub    $0xc,%esp
80104821:	50                   	push   %eax
80104822:	e8 0f e3 ff ff       	call   80102b36 <kfree>
80104827:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010482a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010482d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104834:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104837:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010483e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104843:	e9 73 01 00 00       	jmp    801049bb <fork+0x1f4>
  }
  np->sz = proc->sz;
80104848:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010484e:	8b 10                	mov    (%eax),%edx
80104850:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104853:	89 10                	mov    %edx,(%eax)
  np->topstack = proc->topstack;
80104855:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485b:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
80104861:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104864:	89 90 a0 00 00 00    	mov    %edx,0xa0(%eax)
  np->parent = proc;
8010486a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104871:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104874:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104877:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010487a:	8b 50 18             	mov    0x18(%eax),%edx
8010487d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104883:	8b 40 18             	mov    0x18(%eax),%eax
80104886:	89 c3                	mov    %eax,%ebx
80104888:	b8 13 00 00 00       	mov    $0x13,%eax
8010488d:	89 d7                	mov    %edx,%edi
8010488f:	89 de                	mov    %ebx,%esi
80104891:	89 c1                	mov    %eax,%ecx
80104893:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104895:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104898:	8b 40 18             	mov    0x18(%eax),%eax
8010489b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801048a2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801048a9:	eb 43                	jmp    801048ee <fork+0x127>
    if(proc->ofile[i])
801048ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048b4:	83 c2 08             	add    $0x8,%edx
801048b7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048bb:	85 c0                	test   %eax,%eax
801048bd:	74 2b                	je     801048ea <fork+0x123>
      np->ofile[i] = filedup(proc->ofile[i]);
801048bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048c8:	83 c2 08             	add    $0x8,%edx
801048cb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048cf:	83 ec 0c             	sub    $0xc,%esp
801048d2:	50                   	push   %eax
801048d3:	e8 1b c7 ff ff       	call   80100ff3 <filedup>
801048d8:	83 c4 10             	add    $0x10,%esp
801048db:	89 c1                	mov    %eax,%ecx
801048dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048e3:	83 c2 08             	add    $0x8,%edx
801048e6:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801048ea:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801048ee:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801048f2:	7e b7                	jle    801048ab <fork+0xe4>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

//duplicates the semaphore array
  for(i = 0; i < MAXPROCSEM; i++)
801048f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801048fb:	eb 43                	jmp    80104940 <fork+0x179>
    if(proc->osemaphore[i])
801048fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104903:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104906:	83 c2 20             	add    $0x20,%edx
80104909:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010490d:	85 c0                	test   %eax,%eax
8010490f:	74 2b                	je     8010493c <fork+0x175>
      np->osemaphore[i] = semaphoredup(proc->osemaphore[i]);
80104911:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104917:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010491a:	83 c2 20             	add    $0x20,%edx
8010491d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104921:	83 ec 0c             	sub    $0xc,%esp
80104924:	50                   	push   %eax
80104925:	e8 90 0d 00 00       	call   801056ba <semaphoredup>
8010492a:	83 c4 10             	add    $0x10,%esp
8010492d:	89 c1                	mov    %eax,%ecx
8010492f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104932:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104935:	83 c2 20             	add    $0x20,%edx
80104938:	89 4c 90 0c          	mov    %ecx,0xc(%eax,%edx,4)
  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

//duplicates the semaphore array
  for(i = 0; i < MAXPROCSEM; i++)
8010493c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104940:	83 7d e4 04          	cmpl   $0x4,-0x1c(%ebp)
80104944:	7e b7                	jle    801048fd <fork+0x136>
    if(proc->osemaphore[i])
      np->osemaphore[i] = semaphoredup(proc->osemaphore[i]);

  np->cwd = idup(proc->cwd);
80104946:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494c:	8b 40 68             	mov    0x68(%eax),%eax
8010494f:	83 ec 0c             	sub    $0xc,%esp
80104952:	50                   	push   %eax
80104953:	e8 87 cf ff ff       	call   801018df <idup>
80104958:	83 c4 10             	add    $0x10,%esp
8010495b:	89 c2                	mov    %eax,%edx
8010495d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104960:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104963:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104969:	8d 50 6c             	lea    0x6c(%eax),%edx
8010496c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010496f:	83 c0 6c             	add    $0x6c,%eax
80104972:	83 ec 04             	sub    $0x4,%esp
80104975:	6a 10                	push   $0x10
80104977:	52                   	push   %edx
80104978:	50                   	push   %eax
80104979:	e8 c4 12 00 00       	call   80105c42 <safestrcpy>
8010497e:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104981:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104984:	8b 40 10             	mov    0x10(%eax),%eax
80104987:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
8010498a:	83 ec 0c             	sub    $0xc,%esp
8010498d:	68 80 39 11 80       	push   $0x80113980
80104992:	e8 45 0e 00 00       	call   801057dc <acquire>
80104997:	83 c4 10             	add    $0x10,%esp
  makerunnable(np);
8010499a:	83 ec 0c             	sub    $0xc,%esp
8010499d:	ff 75 e0             	pushl  -0x20(%ebp)
801049a0:	e8 69 fb ff ff       	call   8010450e <makerunnable>
801049a5:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801049a8:	83 ec 0c             	sub    $0xc,%esp
801049ab:	68 80 39 11 80       	push   $0x80113980
801049b0:	e8 8e 0e 00 00       	call   80105843 <release>
801049b5:	83 c4 10             	add    $0x10,%esp

  return pid;
801049b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801049bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801049be:	5b                   	pop    %ebx
801049bf:	5e                   	pop    %esi
801049c0:	5f                   	pop    %edi
801049c1:	5d                   	pop    %ebp
801049c2:	c3                   	ret    

801049c3 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801049c3:	55                   	push   %ebp
801049c4:	89 e5                	mov    %esp,%ebp
801049c6:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801049c9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801049d0:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801049d5:	39 c2                	cmp    %eax,%edx
801049d7:	75 0d                	jne    801049e6 <exit+0x23>
    panic("init exiting");
801049d9:	83 ec 0c             	sub    $0xc,%esp
801049dc:	68 6b 92 10 80       	push   $0x8010926b
801049e1:	e8 80 bb ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801049e6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049ed:	eb 48                	jmp    80104a37 <exit+0x74>
    if(proc->ofile[fd]){
801049ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049f8:	83 c2 08             	add    $0x8,%edx
801049fb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049ff:	85 c0                	test   %eax,%eax
80104a01:	74 30                	je     80104a33 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104a03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a09:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a0c:	83 c2 08             	add    $0x8,%edx
80104a0f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a13:	83 ec 0c             	sub    $0xc,%esp
80104a16:	50                   	push   %eax
80104a17:	e8 28 c6 ff ff       	call   80101044 <fileclose>
80104a1c:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104a1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a25:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a28:	83 c2 08             	add    $0x8,%edx
80104a2b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a32:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a37:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a3b:	7e b2                	jle    801049ef <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104a3d:	e8 80 ea ff ff       	call   801034c2 <begin_op>
  iput(proc->cwd);
80104a42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a48:	8b 40 68             	mov    0x68(%eax),%eax
80104a4b:	83 ec 0c             	sub    $0xc,%esp
80104a4e:	50                   	push   %eax
80104a4f:	e8 8f d0 ff ff       	call   80101ae3 <iput>
80104a54:	83 c4 10             	add    $0x10,%esp
  end_op();
80104a57:	e8 f2 ea ff ff       	call   8010354e <end_op>
  proc->cwd = 0;
80104a5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a62:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a69:	83 ec 0c             	sub    $0xc,%esp
80104a6c:	68 80 39 11 80       	push   $0x80113980
80104a71:	e8 66 0d 00 00       	call   801057dc <acquire>
80104a76:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104a79:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a7f:	8b 40 14             	mov    0x14(%eax),%eax
80104a82:	83 ec 0c             	sub    $0xc,%esp
80104a85:	50                   	push   %eax
80104a86:	e8 a6 04 00 00       	call   80104f31 <wakeup1>
80104a8b:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a8e:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104a95:	eb 3f                	jmp    80104ad6 <exit+0x113>
    if(p->parent == proc){
80104a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9a:	8b 50 14             	mov    0x14(%eax),%edx
80104a9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aa3:	39 c2                	cmp    %eax,%edx
80104aa5:	75 28                	jne    80104acf <exit+0x10c>
      p->parent = initproc;
80104aa7:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab0:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab6:	8b 40 0c             	mov    0xc(%eax),%eax
80104ab9:	83 f8 05             	cmp    $0x5,%eax
80104abc:	75 11                	jne    80104acf <exit+0x10c>
        wakeup1(initproc);
80104abe:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104ac3:	83 ec 0c             	sub    $0xc,%esp
80104ac6:	50                   	push   %eax
80104ac7:	e8 65 04 00 00       	call   80104f31 <wakeup1>
80104acc:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104acf:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104ad6:	81 7d f4 b4 62 11 80 	cmpl   $0x801162b4,-0xc(%ebp)
80104add:	72 b8                	jb     80104a97 <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104adf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ae5:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104aec:	e8 36 02 00 00       	call   80104d27 <sched>
  panic("zombie exit");
80104af1:	83 ec 0c             	sub    $0xc,%esp
80104af4:	68 78 92 10 80       	push   $0x80109278
80104af9:	e8 68 ba ff ff       	call   80100566 <panic>

80104afe <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104afe:	55                   	push   %ebp
80104aff:	89 e5                	mov    %esp,%ebp
80104b01:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104b04:	83 ec 0c             	sub    $0xc,%esp
80104b07:	68 80 39 11 80       	push   $0x80113980
80104b0c:	e8 cb 0c 00 00       	call   801057dc <acquire>
80104b11:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104b14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b1b:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104b22:	e9 a9 00 00 00       	jmp    80104bd0 <wait+0xd2>
      if(p->parent != proc)
80104b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2a:	8b 50 14             	mov    0x14(%eax),%edx
80104b2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b33:	39 c2                	cmp    %eax,%edx
80104b35:	0f 85 8d 00 00 00    	jne    80104bc8 <wait+0xca>
        continue;
      havekids = 1;
80104b3b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b45:	8b 40 0c             	mov    0xc(%eax),%eax
80104b48:	83 f8 05             	cmp    $0x5,%eax
80104b4b:	75 7c                	jne    80104bc9 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b50:	8b 40 10             	mov    0x10(%eax),%eax
80104b53:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b59:	8b 40 08             	mov    0x8(%eax),%eax
80104b5c:	83 ec 0c             	sub    $0xc,%esp
80104b5f:	50                   	push   %eax
80104b60:	e8 d1 df ff ff       	call   80102b36 <kfree>
80104b65:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b75:	8b 40 04             	mov    0x4(%eax),%eax
80104b78:	83 ec 0c             	sub    $0xc,%esp
80104b7b:	50                   	push   %eax
80104b7c:	e8 fb 40 00 00       	call   80108c7c <freevm>
80104b81:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b87:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b91:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba5:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bac:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104bb3:	83 ec 0c             	sub    $0xc,%esp
80104bb6:	68 80 39 11 80       	push   $0x80113980
80104bbb:	e8 83 0c 00 00       	call   80105843 <release>
80104bc0:	83 c4 10             	add    $0x10,%esp
        return pid;
80104bc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bc6:	eb 5b                	jmp    80104c23 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104bc8:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bc9:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104bd0:	81 7d f4 b4 62 11 80 	cmpl   $0x801162b4,-0xc(%ebp)
80104bd7:	0f 82 4a ff ff ff    	jb     80104b27 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104bdd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104be1:	74 0d                	je     80104bf0 <wait+0xf2>
80104be3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104be9:	8b 40 24             	mov    0x24(%eax),%eax
80104bec:	85 c0                	test   %eax,%eax
80104bee:	74 17                	je     80104c07 <wait+0x109>
      release(&ptable.lock);
80104bf0:	83 ec 0c             	sub    $0xc,%esp
80104bf3:	68 80 39 11 80       	push   $0x80113980
80104bf8:	e8 46 0c 00 00       	call   80105843 <release>
80104bfd:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c05:	eb 1c                	jmp    80104c23 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104c07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c0d:	83 ec 08             	sub    $0x8,%esp
80104c10:	68 80 39 11 80       	push   $0x80113980
80104c15:	50                   	push   %eax
80104c16:	e8 6a 02 00 00       	call   80104e85 <sleep>
80104c1b:	83 c4 10             	add    $0x10,%esp
  }
80104c1e:	e9 f1 fe ff ff       	jmp    80104b14 <wait+0x16>
}
80104c23:	c9                   	leave  
80104c24:	c3                   	ret    

80104c25 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c25:	55                   	push   %ebp
80104c26:	89 e5                	mov    %esp,%ebp
80104c28:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  unsigned char picked=1;
80104c2b:	c6 45 f7 01          	movb   $0x1,-0x9(%ebp)
  int level;
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c2f:	e8 99 f7 ff ff       	call   801043cd <sti>

    if (!picked){
80104c34:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
80104c38:	75 05                	jne    80104c3f <scheduler+0x1a>
      hlt();
80104c3a:	e8 95 f7 ff ff       	call   801043d4 <hlt>
    }
    picked=0;
80104c3f:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c43:	83 ec 0c             	sub    $0xc,%esp
80104c46:	68 80 39 11 80       	push   $0x80113980
80104c4b:	e8 8c 0b 00 00       	call   801057dc <acquire>
80104c50:	83 c4 10             	add    $0x10,%esp

    for(level = MLFMAXLEVEL; level < MLFLEVELS; level++){
80104c53:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104c5a:	e9 a9 00 00 00       	jmp    80104d08 <scheduler+0xe3>

      if(ptable.mlf[level] != 0){
80104c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c62:	05 4c 0a 00 00       	add    $0xa4c,%eax
80104c67:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
80104c6e:	85 c0                	test   %eax,%eax
80104c70:	0f 84 8e 00 00 00    	je     80104d04 <scheduler+0xdf>
        p = ptable.mlf[level];
80104c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c79:	05 4c 0a 00 00       	add    $0xa4c,%eax
80104c7e:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
80104c85:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        picked=1;
80104c88:	c6 45 f7 01          	movb   $0x1,-0x9(%ebp)
        proc = p;
80104c8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c8f:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
        switchuvm(p);
80104c95:	83 ec 0c             	sub    $0xc,%esp
80104c98:	ff 75 ec             	pushl  -0x14(%ebp)
80104c9b:	e8 96 3b 00 00       	call   80108836 <switchuvm>
80104ca0:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;                       //puts in "RUNNING" the chosen process
80104ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ca6:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        p->timesscheduled++;
80104cad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cb0:	0f b7 80 88 00 00 00 	movzwl 0x88(%eax),%eax
80104cb7:	8d 50 01             	lea    0x1(%eax),%edx
80104cba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cbd:	66 89 90 88 00 00 00 	mov    %dx,0x88(%eax)
        unqueue(level);
80104cc4:	83 ec 0c             	sub    $0xc,%esp
80104cc7:	ff 75 f0             	pushl  -0x10(%ebp)
80104cca:	e8 cd f8 ff ff       	call   8010459c <unqueue>
80104ccf:	83 c4 10             	add    $0x10,%esp


        swtch(&cpu->scheduler, proc->context);
80104cd2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cd8:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cdb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ce2:	83 c2 04             	add    $0x4,%edx
80104ce5:	83 ec 08             	sub    $0x8,%esp
80104ce8:	50                   	push   %eax
80104ce9:	52                   	push   %edx
80104cea:	e8 c4 0f 00 00       	call   80105cb3 <swtch>
80104cef:	83 c4 10             	add    $0x10,%esp
        switchkvm();
80104cf2:	e8 22 3b 00 00       	call   80108819 <switchkvm>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        proc = 0;
80104cf7:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104cfe:	00 00 00 00 
        break;
80104d02:	eb 0e                	jmp    80104d12 <scheduler+0xed>
    }
    picked=0;
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);

    for(level = MLFMAXLEVEL; level < MLFLEVELS; level++){
80104d04:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104d08:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104d0c:	0f 8e 4d ff ff ff    	jle    80104c5f <scheduler+0x3a>
        // It should have changed its p->state before coming back.
        proc = 0;
        break;
      }
    }
    release(&ptable.lock);
80104d12:	83 ec 0c             	sub    $0xc,%esp
80104d15:	68 80 39 11 80       	push   $0x80113980
80104d1a:	e8 24 0b 00 00       	call   80105843 <release>
80104d1f:	83 c4 10             	add    $0x10,%esp

  }
80104d22:	e9 08 ff ff ff       	jmp    80104c2f <scheduler+0xa>

80104d27 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104d27:	55                   	push   %ebp
80104d28:	89 e5                	mov    %esp,%ebp
80104d2a:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104d2d:	83 ec 0c             	sub    $0xc,%esp
80104d30:	68 80 39 11 80       	push   $0x80113980
80104d35:	e8 d5 0b 00 00       	call   8010590f <holding>
80104d3a:	83 c4 10             	add    $0x10,%esp
80104d3d:	85 c0                	test   %eax,%eax
80104d3f:	75 0d                	jne    80104d4e <sched+0x27>
    panic("sched ptable.lock");
80104d41:	83 ec 0c             	sub    $0xc,%esp
80104d44:	68 84 92 10 80       	push   $0x80109284
80104d49:	e8 18 b8 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104d4e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d54:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d5a:	83 f8 01             	cmp    $0x1,%eax
80104d5d:	74 0d                	je     80104d6c <sched+0x45>
    panic("sched locks");
80104d5f:	83 ec 0c             	sub    $0xc,%esp
80104d62:	68 96 92 10 80       	push   $0x80109296
80104d67:	e8 fa b7 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104d6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d72:	8b 40 0c             	mov    0xc(%eax),%eax
80104d75:	83 f8 04             	cmp    $0x4,%eax
80104d78:	75 0d                	jne    80104d87 <sched+0x60>
    panic("sched running");
80104d7a:	83 ec 0c             	sub    $0xc,%esp
80104d7d:	68 a2 92 10 80       	push   $0x801092a2
80104d82:	e8 df b7 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104d87:	e8 31 f6 ff ff       	call   801043bd <readeflags>
80104d8c:	25 00 02 00 00       	and    $0x200,%eax
80104d91:	85 c0                	test   %eax,%eax
80104d93:	74 0d                	je     80104da2 <sched+0x7b>
    panic("sched interruptible");
80104d95:	83 ec 0c             	sub    $0xc,%esp
80104d98:	68 b0 92 10 80       	push   $0x801092b0
80104d9d:	e8 c4 b7 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104da2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104da8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104dae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104db1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104db7:	8b 40 04             	mov    0x4(%eax),%eax
80104dba:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104dc1:	83 c2 1c             	add    $0x1c,%edx
80104dc4:	83 ec 08             	sub    $0x8,%esp
80104dc7:	50                   	push   %eax
80104dc8:	52                   	push   %edx
80104dc9:	e8 e5 0e 00 00       	call   80105cb3 <swtch>
80104dce:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104dd1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dda:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104de0:	90                   	nop
80104de1:	c9                   	leave  
80104de2:	c3                   	ret    

80104de3 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104de3:	55                   	push   %ebp
80104de4:	89 e5                	mov    %esp,%ebp
80104de6:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104de9:	83 ec 0c             	sub    $0xc,%esp
80104dec:	68 80 39 11 80       	push   $0x80113980
80104df1:	e8 e6 09 00 00       	call   801057dc <acquire>
80104df6:	83 c4 10             	add    $0x10,%esp
  if(proc->priority < (MLFLEVELS-1)){
80104df9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dff:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80104e06:	66 83 f8 02          	cmp    $0x2,%ax
80104e0a:	77 1e                	ja     80104e2a <yield+0x47>
    proc->priority=(proc->priority)+1;
80104e0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e12:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e19:	0f b7 92 84 00 00 00 	movzwl 0x84(%edx),%edx
80104e20:	83 c2 01             	add    $0x1,%edx
80104e23:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
  }
  makerunnable(proc);
80104e2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e30:	83 ec 0c             	sub    $0xc,%esp
80104e33:	50                   	push   %eax
80104e34:	e8 d5 f6 ff ff       	call   8010450e <makerunnable>
80104e39:	83 c4 10             	add    $0x10,%esp
  sched();
80104e3c:	e8 e6 fe ff ff       	call   80104d27 <sched>
  release(&ptable.lock);
80104e41:	83 ec 0c             	sub    $0xc,%esp
80104e44:	68 80 39 11 80       	push   $0x80113980
80104e49:	e8 f5 09 00 00       	call   80105843 <release>
80104e4e:	83 c4 10             	add    $0x10,%esp
}
80104e51:	90                   	nop
80104e52:	c9                   	leave  
80104e53:	c3                   	ret    

80104e54 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e54:	55                   	push   %ebp
80104e55:	89 e5                	mov    %esp,%ebp
80104e57:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e5a:	83 ec 0c             	sub    $0xc,%esp
80104e5d:	68 80 39 11 80       	push   $0x80113980
80104e62:	e8 dc 09 00 00       	call   80105843 <release>
80104e67:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104e6a:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80104e6f:	85 c0                	test   %eax,%eax
80104e71:	74 0f                	je     80104e82 <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e73:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80104e7a:	00 00 00 
    initlog();
80104e7d:	e8 1a e4 ff ff       	call   8010329c <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e82:	90                   	nop
80104e83:	c9                   	leave  
80104e84:	c3                   	ret    

80104e85 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e85:	55                   	push   %ebp
80104e86:	89 e5                	mov    %esp,%ebp
80104e88:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104e8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e91:	85 c0                	test   %eax,%eax
80104e93:	75 0d                	jne    80104ea2 <sleep+0x1d>
    panic("sleep");
80104e95:	83 ec 0c             	sub    $0xc,%esp
80104e98:	68 c4 92 10 80       	push   $0x801092c4
80104e9d:	e8 c4 b6 ff ff       	call   80100566 <panic>

  if(lk == 0)
80104ea2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ea6:	75 0d                	jne    80104eb5 <sleep+0x30>
    panic("sleep without lk");
80104ea8:	83 ec 0c             	sub    $0xc,%esp
80104eab:	68 ca 92 10 80       	push   $0x801092ca
80104eb0:	e8 b1 b6 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104eb5:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104ebc:	74 1e                	je     80104edc <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ebe:	83 ec 0c             	sub    $0xc,%esp
80104ec1:	68 80 39 11 80       	push   $0x80113980
80104ec6:	e8 11 09 00 00       	call   801057dc <acquire>
80104ecb:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104ece:	83 ec 0c             	sub    $0xc,%esp
80104ed1:	ff 75 0c             	pushl  0xc(%ebp)
80104ed4:	e8 6a 09 00 00       	call   80105843 <release>
80104ed9:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104edc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee2:	8b 55 08             	mov    0x8(%ebp),%edx
80104ee5:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104ee8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eee:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104ef5:	e8 2d fe ff ff       	call   80104d27 <sched>

  // Tidy up.
  proc->chan = 0;
80104efa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f00:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104f07:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104f0e:	74 1e                	je     80104f2e <sleep+0xa9>
    release(&ptable.lock);
80104f10:	83 ec 0c             	sub    $0xc,%esp
80104f13:	68 80 39 11 80       	push   $0x80113980
80104f18:	e8 26 09 00 00       	call   80105843 <release>
80104f1d:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104f20:	83 ec 0c             	sub    $0xc,%esp
80104f23:	ff 75 0c             	pushl  0xc(%ebp)
80104f26:	e8 b1 08 00 00       	call   801057dc <acquire>
80104f2b:	83 c4 10             	add    $0x10,%esp
  }
}
80104f2e:	90                   	nop
80104f2f:	c9                   	leave  
80104f30:	c3                   	ret    

80104f31 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f31:	55                   	push   %ebp
80104f32:	89 e5                	mov    %esp,%ebp
80104f34:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f37:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
80104f3e:	eb 4e                	jmp    80104f8e <wakeup1+0x5d>
    if(p->state == SLEEPING && p->chan == chan){
80104f40:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f43:	8b 40 0c             	mov    0xc(%eax),%eax
80104f46:	83 f8 02             	cmp    $0x2,%eax
80104f49:	75 3c                	jne    80104f87 <wakeup1+0x56>
80104f4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f4e:	8b 40 20             	mov    0x20(%eax),%eax
80104f51:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f54:	75 31                	jne    80104f87 <wakeup1+0x56>
      if(p->priority>MLFMAXLEVEL){
80104f56:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f59:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80104f60:	66 85 c0             	test   %ax,%ax
80104f63:	74 17                	je     80104f7c <wakeup1+0x4b>
        p->priority--;
80104f65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f68:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80104f6f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f72:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f75:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
      }
      makerunnable(p);
80104f7c:	ff 75 fc             	pushl  -0x4(%ebp)
80104f7f:	e8 8a f5 ff ff       	call   8010450e <makerunnable>
80104f84:	83 c4 04             	add    $0x4,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f87:	81 45 fc a4 00 00 00 	addl   $0xa4,-0x4(%ebp)
80104f8e:	81 7d fc b4 62 11 80 	cmpl   $0x801162b4,-0x4(%ebp)
80104f95:	72 a9                	jb     80104f40 <wakeup1+0xf>
        p->priority--;
      }
      makerunnable(p);
    }

}
80104f97:	90                   	nop
80104f98:	c9                   	leave  
80104f99:	c3                   	ret    

80104f9a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f9a:	55                   	push   %ebp
80104f9b:	89 e5                	mov    %esp,%ebp
80104f9d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104fa0:	83 ec 0c             	sub    $0xc,%esp
80104fa3:	68 80 39 11 80       	push   $0x80113980
80104fa8:	e8 2f 08 00 00       	call   801057dc <acquire>
80104fad:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104fb0:	83 ec 0c             	sub    $0xc,%esp
80104fb3:	ff 75 08             	pushl  0x8(%ebp)
80104fb6:	e8 76 ff ff ff       	call   80104f31 <wakeup1>
80104fbb:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104fbe:	83 ec 0c             	sub    $0xc,%esp
80104fc1:	68 80 39 11 80       	push   $0x80113980
80104fc6:	e8 78 08 00 00       	call   80105843 <release>
80104fcb:	83 c4 10             	add    $0x10,%esp
}
80104fce:	90                   	nop
80104fcf:	c9                   	leave  
80104fd0:	c3                   	ret    

80104fd1 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104fd1:	55                   	push   %ebp
80104fd2:	89 e5                	mov    %esp,%ebp
80104fd4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104fd7:	83 ec 0c             	sub    $0xc,%esp
80104fda:	68 80 39 11 80       	push   $0x80113980
80104fdf:	e8 f8 07 00 00       	call   801057dc <acquire>
80104fe4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fe7:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104fee:	eb 4c                	jmp    8010503c <kill+0x6b>
    if(p->pid == pid){
80104ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff3:	8b 40 10             	mov    0x10(%eax),%eax
80104ff6:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ff9:	75 3a                	jne    80105035 <kill+0x64>
      p->killed = 1;
80104ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ffe:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105005:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105008:	8b 40 0c             	mov    0xc(%eax),%eax
8010500b:	83 f8 02             	cmp    $0x2,%eax
8010500e:	75 0e                	jne    8010501e <kill+0x4d>
        makerunnable(p);
80105010:	83 ec 0c             	sub    $0xc,%esp
80105013:	ff 75 f4             	pushl  -0xc(%ebp)
80105016:	e8 f3 f4 ff ff       	call   8010450e <makerunnable>
8010501b:	83 c4 10             	add    $0x10,%esp
      release(&ptable.lock);
8010501e:	83 ec 0c             	sub    $0xc,%esp
80105021:	68 80 39 11 80       	push   $0x80113980
80105026:	e8 18 08 00 00       	call   80105843 <release>
8010502b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010502e:	b8 00 00 00 00       	mov    $0x0,%eax
80105033:	eb 25                	jmp    8010505a <kill+0x89>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105035:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
8010503c:	81 7d f4 b4 62 11 80 	cmpl   $0x801162b4,-0xc(%ebp)
80105043:	72 ab                	jb     80104ff0 <kill+0x1f>
        makerunnable(p);
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105045:	83 ec 0c             	sub    $0xc,%esp
80105048:	68 80 39 11 80       	push   $0x80113980
8010504d:	e8 f1 07 00 00       	call   80105843 <release>
80105052:	83 c4 10             	add    $0x10,%esp
  return -1;
80105055:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010505a:	c9                   	leave  
8010505b:	c3                   	ret    

8010505c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010505c:	55                   	push   %ebp
8010505d:	89 e5                	mov    %esp,%ebp
8010505f:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105062:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
80105069:	e9 34 01 00 00       	jmp    801051a2 <procdump+0x146>
    if(p->state == UNUSED)
8010506e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105071:	8b 40 0c             	mov    0xc(%eax),%eax
80105074:	85 c0                	test   %eax,%eax
80105076:	0f 84 1e 01 00 00    	je     8010519a <procdump+0x13e>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010507c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010507f:	8b 40 0c             	mov    0xc(%eax),%eax
80105082:	83 f8 05             	cmp    $0x5,%eax
80105085:	77 23                	ja     801050aa <procdump+0x4e>
80105087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010508a:	8b 40 0c             	mov    0xc(%eax),%eax
8010508d:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105094:	85 c0                	test   %eax,%eax
80105096:	74 12                	je     801050aa <procdump+0x4e>
      state = states[p->state];
80105098:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010509b:	8b 40 0c             	mov    0xc(%eax),%eax
8010509e:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801050a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801050a8:	eb 07                	jmp    801050b1 <procdump+0x55>
    else
      state = "???";
801050aa:	c7 45 ec db 92 10 80 	movl   $0x801092db,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801050b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050b4:	8d 50 6c             	lea    0x6c(%eax),%edx
801050b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ba:	8b 40 10             	mov    0x10(%eax),%eax
801050bd:	52                   	push   %edx
801050be:	ff 75 ec             	pushl  -0x14(%ebp)
801050c1:	50                   	push   %eax
801050c2:	68 df 92 10 80       	push   $0x801092df
801050c7:	e8 fa b2 ff ff       	call   801003c6 <cprintf>
801050cc:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801050cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d2:	8b 40 0c             	mov    0xc(%eax),%eax
801050d5:	83 f8 02             	cmp    $0x2,%eax
801050d8:	75 54                	jne    8010512e <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801050da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050dd:	8b 40 1c             	mov    0x1c(%eax),%eax
801050e0:	8b 40 0c             	mov    0xc(%eax),%eax
801050e3:	83 c0 08             	add    $0x8,%eax
801050e6:	89 c2                	mov    %eax,%edx
801050e8:	83 ec 08             	sub    $0x8,%esp
801050eb:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801050ee:	50                   	push   %eax
801050ef:	52                   	push   %edx
801050f0:	e8 a0 07 00 00       	call   80105895 <getcallerpcs>
801050f5:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050ff:	eb 1c                	jmp    8010511d <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105104:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105108:	83 ec 08             	sub    $0x8,%esp
8010510b:	50                   	push   %eax
8010510c:	68 e8 92 10 80       	push   $0x801092e8
80105111:	e8 b0 b2 ff ff       	call   801003c6 <cprintf>
80105116:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105119:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010511d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105121:	7f 0b                	jg     8010512e <procdump+0xd2>
80105123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105126:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010512a:	85 c0                	test   %eax,%eax
8010512c:	75 d3                	jne    80105101 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf(" prioridad: %d",p->priority); //shows the priority of the process
8010512e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105131:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80105138:	0f b7 c0             	movzwl %ax,%eax
8010513b:	83 ec 08             	sub    $0x8,%esp
8010513e:	50                   	push   %eax
8010513f:	68 ec 92 10 80       	push   $0x801092ec
80105144:	e8 7d b2 ff ff       	call   801003c6 <cprintf>
80105149:	83 c4 10             	add    $0x10,%esp
    cprintf(" edad: %d",p->age); //shows the priority of the process
8010514c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010514f:	0f b7 80 86 00 00 00 	movzwl 0x86(%eax),%eax
80105156:	0f b7 c0             	movzwl %ax,%eax
80105159:	83 ec 08             	sub    $0x8,%esp
8010515c:	50                   	push   %eax
8010515d:	68 fb 92 10 80       	push   $0x801092fb
80105162:	e8 5f b2 ff ff       	call   801003c6 <cprintf>
80105167:	83 c4 10             	add    $0x10,%esp
    cprintf(" sch: %d",p->timesscheduled);
8010516a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010516d:	0f b7 80 88 00 00 00 	movzwl 0x88(%eax),%eax
80105174:	0f b7 c0             	movzwl %ax,%eax
80105177:	83 ec 08             	sub    $0x8,%esp
8010517a:	50                   	push   %eax
8010517b:	68 05 93 10 80       	push   $0x80109305
80105180:	e8 41 b2 ff ff       	call   801003c6 <cprintf>
80105185:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
80105188:	83 ec 0c             	sub    $0xc,%esp
8010518b:	68 0e 93 10 80       	push   $0x8010930e
80105190:	e8 31 b2 ff ff       	call   801003c6 <cprintf>
80105195:	83 c4 10             	add    $0x10,%esp
80105198:	eb 01                	jmp    8010519b <procdump+0x13f>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
8010519a:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010519b:	81 45 f0 a4 00 00 00 	addl   $0xa4,-0x10(%ebp)
801051a2:	81 7d f0 b4 62 11 80 	cmpl   $0x801162b4,-0x10(%ebp)
801051a9:	0f 82 bf fe ff ff    	jb     8010506e <procdump+0x12>
    cprintf(" prioridad: %d",p->priority); //shows the priority of the process
    cprintf(" edad: %d",p->age); //shows the priority of the process
    cprintf(" sch: %d",p->timesscheduled);
    cprintf("\n");
  }
}
801051af:	90                   	nop
801051b0:	c9                   	leave  
801051b1:	c3                   	ret    

801051b2 <raisepriority>:



void
raisepriority(int level )         //unqueue, modify the priority and enqueue
{
801051b2:	55                   	push   %ebp
801051b3:	89 e5                	mov    %esp,%ebp
801051b5:	83 ec 10             	sub    $0x10,%esp
    struct proc* oldprocess;
    oldprocess = unqueue(level);
801051b8:	ff 75 08             	pushl  0x8(%ebp)
801051bb:	e8 dc f3 ff ff       	call   8010459c <unqueue>
801051c0:	83 c4 04             	add    $0x4,%esp
801051c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if(oldprocess){
801051c6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801051ca:	74 1b                	je     801051e7 <raisepriority+0x35>
      oldprocess->priority = level-1;
801051cc:	8b 45 08             	mov    0x8(%ebp),%eax
801051cf:	8d 50 ff             	lea    -0x1(%eax),%edx
801051d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051d5:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
      makerunnable(oldprocess);
801051dc:	ff 75 fc             	pushl  -0x4(%ebp)
801051df:	e8 2a f3 ff ff       	call   8010450e <makerunnable>
801051e4:	83 c4 04             	add    $0x4,%esp
    }
}
801051e7:	90                   	nop
801051e8:	c9                   	leave  
801051e9:	c3                   	ret    

801051ea <aging>:


void
aging()
{
801051ea:	55                   	push   %ebp
801051eb:	89 e5                	mov    %esp,%ebp
801051ed:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int level;
  acquire(&ptable.lock);
801051f0:	83 ec 0c             	sub    $0xc,%esp
801051f3:	68 80 39 11 80       	push   $0x80113980
801051f8:	e8 df 05 00 00       	call   801057dc <acquire>
801051fd:	83 c4 10             	add    $0x10,%esp
  for (level=MLFMAXLEVEL; level < MLFLEVELS; level++) { // i go through the levels of the mlf
80105200:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105207:	e9 aa 00 00 00       	jmp    801052b6 <aging+0xcc>
    p =ptable.mlf[level];
8010520c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010520f:	05 4c 0a 00 00       	add    $0xa4c,%eax
80105214:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
8010521b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p){
8010521e:	e9 85 00 00 00       	jmp    801052a8 <aging+0xbe>
      p->age++;                             // increase the age
80105223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105226:	0f b7 80 86 00 00 00 	movzwl 0x86(%eax),%eax
8010522d:	8d 50 01             	lea    0x1(%eax),%edx
80105230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105233:	66 89 90 86 00 00 00 	mov    %dx,0x86(%eax)
      if( (p->age == AGEFORSCALING && level != MLFMAXLEVEL)){ // check if the process deserves a priority increase
8010523a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010523d:	0f b7 80 86 00 00 00 	movzwl 0x86(%eax),%eax
80105244:	66 83 f8 32          	cmp    $0x32,%ax
80105248:	75 52                	jne    8010529c <aging+0xb2>
8010524a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010524e:	74 4c                	je     8010529c <aging+0xb2>
        procdump();                         //prints the processes BEFORE the priority increase
80105250:	e8 07 fe ff ff       	call   8010505c <procdump>
        if(ACTIVATEAGING){                 //ACTIVATEAGING value is in param.h !
          raisepriority(level);
80105255:	83 ec 0c             	sub    $0xc,%esp
80105258:	ff 75 f0             	pushl  -0x10(%ebp)
8010525b:	e8 52 ff ff ff       	call   801051b2 <raisepriority>
80105260:	83 c4 10             	add    $0x10,%esp
          cprintf("---------------------------------\n");
80105263:	83 ec 0c             	sub    $0xc,%esp
80105266:	68 10 93 10 80       	push   $0x80109310
8010526b:	e8 56 b1 ff ff       	call   801003c6 <cprintf>
80105270:	83 c4 10             	add    $0x10,%esp
          procdump();                     //prints the processes AFTER the priority increase
80105273:	e8 e4 fd ff ff       	call   8010505c <procdump>
        }
        cprintf("//////////////////////////////////////\n");
80105278:	83 ec 0c             	sub    $0xc,%esp
8010527b:	68 34 93 10 80       	push   $0x80109334
80105280:	e8 41 b1 ff ff       	call   801003c6 <cprintf>
80105285:	83 c4 10             	add    $0x10,%esp
        p=ptable.mlf[level];              // now will continue with the new first level process
80105288:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010528b:	05 4c 0a 00 00       	add    $0xa4c,%eax
80105290:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
80105297:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010529a:	eb 0c                	jmp    801052a8 <aging+0xbe>
      }else{
        p=p->next;                        //from here only increases the age, because they will be younger
8010529c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801052a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct proc *p;
  int level;
  acquire(&ptable.lock);
  for (level=MLFMAXLEVEL; level < MLFLEVELS; level++) { // i go through the levels of the mlf
    p =ptable.mlf[level];
    while(p){
801052a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052ac:	0f 85 71 ff ff ff    	jne    80105223 <aging+0x39>
aging()
{
  struct proc *p;
  int level;
  acquire(&ptable.lock);
  for (level=MLFMAXLEVEL; level < MLFLEVELS; level++) { // i go through the levels of the mlf
801052b2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801052b6:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
801052ba:	0f 8e 4c ff ff ff    	jle    8010520c <aging+0x22>
      }else{
        p=p->next;                        //from here only increases the age, because they will be younger
      }
    }
  }
  release(&ptable.lock);
801052c0:	83 ec 0c             	sub    $0xc,%esp
801052c3:	68 80 39 11 80       	push   $0x80113980
801052c8:	e8 76 05 00 00       	call   80105843 <release>
801052cd:	83 c4 10             	add    $0x10,%esp
}
801052d0:	90                   	nop
801052d1:	c9                   	leave  
801052d2:	c3                   	ret    

801052d3 <semtableinit>:
} semtable;


void
semtableinit(void)
{
801052d3:	55                   	push   %ebp
801052d4:	89 e5                	mov    %esp,%ebp
801052d6:	83 ec 08             	sub    $0x8,%esp
  initlock(&semtable.lock, "semtable");
801052d9:	83 ec 08             	sub    $0x8,%esp
801052dc:	68 88 93 10 80       	push   $0x80109388
801052e1:	68 e0 62 11 80       	push   $0x801162e0
801052e6:	e8 cf 04 00 00       	call   801057ba <initlock>
801052eb:	83 c4 10             	add    $0x10,%esp
}
801052ee:	90                   	nop
801052ef:	c9                   	leave  
801052f0:	c3                   	ret    

801052f1 <semget>:
int semObtained(int semid);
void printsemaphores();

int
semget(int semid,int initvalue)
{
801052f1:	55                   	push   %ebp
801052f2:	89 e5                	mov    %esp,%ebp
801052f4:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct semaphore* s;
  int res;
  int indexofsem;
  acquire(&semtable.lock);
801052f7:	83 ec 0c             	sub    $0xc,%esp
801052fa:	68 e0 62 11 80       	push   $0x801162e0
801052ff:	e8 d8 04 00 00       	call   801057dc <acquire>
80105304:	83 c4 10             	add    $0x10,%esp

  indexofsem=semsearch(semid);
80105307:	83 ec 0c             	sub    $0xc,%esp
8010530a:	ff 75 08             	pushl  0x8(%ebp)
8010530d:	e8 ec 02 00 00       	call   801055fe <semsearch>
80105312:	83 c4 10             	add    $0x10,%esp
80105315:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(indexofsem==-3){
80105318:	83 7d ec fd          	cmpl   $0xfffffffd,-0x14(%ebp)
8010531c:	75 0c                	jne    8010532a <semget+0x39>
    res=-3;
8010531e:	c7 45 f0 fd ff ff ff 	movl   $0xfffffffd,-0x10(%ebp)
    goto errsemget;
80105325:	e9 d6 00 00 00       	jmp    80105400 <semget+0x10f>
  }
  s = &semtable.sem[indexofsem];
8010532a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010532d:	89 d0                	mov    %edx,%eax
8010532f:	01 c0                	add    %eax,%eax
80105331:	01 d0                	add    %edx,%eax
80105333:	c1 e0 02             	shl    $0x2,%eax
80105336:	83 c0 30             	add    $0x30,%eax
80105339:	05 e0 62 11 80       	add    $0x801162e0,%eax
8010533e:	83 c0 04             	add    $0x4,%eax
80105341:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(semid>=0 && s->counter==0){
80105344:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105348:	78 16                	js     80105360 <semget+0x6f>
8010534a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010534d:	8b 40 04             	mov    0x4(%eax),%eax
80105350:	85 c0                	test   %eax,%eax
80105352:	75 0c                	jne    80105360 <semget+0x6f>
    res= -1;    //el semaforo no esta en uso
80105354:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
    goto errsemget;
8010535b:	e9 a0 00 00 00       	jmp    80105400 <semget+0x10f>
  }



  if(semid == -1){
80105360:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
80105364:	75 3c                	jne    801053a2 <semget+0xb1>
        s->id=s-semtable.sem;
80105366:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105369:	ba 14 63 11 80       	mov    $0x80116314,%edx
8010536e:	29 d0                	sub    %edx,%eax
80105370:	c1 f8 02             	sar    $0x2,%eax
80105373:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
80105379:	89 c2                	mov    %eax,%edx
8010537b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010537e:	89 10                	mov    %edx,(%eax)
        s->counter++;
80105380:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105383:	8b 40 04             	mov    0x4(%eax),%eax
80105386:	8d 50 01             	lea    0x1(%eax),%edx
80105389:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010538c:	89 50 04             	mov    %edx,0x4(%eax)
        s->value = initvalue;
8010538f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105392:	8b 55 0c             	mov    0xc(%ebp),%edx
80105395:	89 50 08             	mov    %edx,0x8(%eax)
        res=s->id;
80105398:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010539b:	8b 00                	mov    (%eax),%eax
8010539d:	89 45 f0             	mov    %eax,-0x10(%ebp)
801053a0:	eb 15                	jmp    801053b7 <semget+0xc6>
  }else{
    s->counter++;
801053a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801053a5:	8b 40 04             	mov    0x4(%eax),%eax
801053a8:	8d 50 01             	lea    0x1(%eax),%edx
801053ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
801053ae:	89 50 04             	mov    %edx,0x4(%eax)
    res=semid;
801053b1:	8b 45 08             	mov    0x8(%ebp),%eax
801053b4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  }

  for(i=0;i<MAXPROCSEM;i++){
801053b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801053be:	eb 2d                	jmp    801053ed <semget+0xfc>
    if(proc->osemaphore[i]==0){
801053c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053c9:	83 c2 20             	add    $0x20,%edx
801053cc:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801053d0:	85 c0                	test   %eax,%eax
801053d2:	75 15                	jne    801053e9 <semget+0xf8>
      proc->osemaphore[i]=s;
801053d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053dd:	8d 4a 20             	lea    0x20(%edx),%ecx
801053e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801053e3:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      break;
801053e7:	eb 0a                	jmp    801053f3 <semget+0x102>
    s->counter++;
    res=semid;

  }

  for(i=0;i<MAXPROCSEM;i++){
801053e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801053ed:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801053f1:	7e cd                	jle    801053c0 <semget+0xcf>
      break;
    }
  }


  if(i==MAXPROCSEM){
801053f3:	83 7d f4 05          	cmpl   $0x5,-0xc(%ebp)
801053f7:	75 07                	jne    80105400 <semget+0x10f>
    res= -2;
801053f9:	c7 45 f0 fe ff ff ff 	movl   $0xfffffffe,-0x10(%ebp)
  }
errsemget:
  release(&semtable.lock);
80105400:	83 ec 0c             	sub    $0xc,%esp
80105403:	68 e0 62 11 80       	push   $0x801162e0
80105408:	e8 36 04 00 00       	call   80105843 <release>
8010540d:	83 c4 10             	add    $0x10,%esp
  return res;
80105410:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105413:	c9                   	leave  
80105414:	c3                   	ret    

80105415 <semfree>:

int
semfree(int semid)
{
80105415:	55                   	push   %ebp
80105416:	89 e5                	mov    %esp,%ebp
80105418:	83 ec 18             	sub    $0x18,%esp

  struct semaphore * s;
  int indexofsem;
  acquire(&semtable.lock);
8010541b:	83 ec 0c             	sub    $0xc,%esp
8010541e:	68 e0 62 11 80       	push   $0x801162e0
80105423:	e8 b4 03 00 00       	call   801057dc <acquire>
80105428:	83 c4 10             	add    $0x10,%esp
  indexofsem = semObtained(semid);
8010542b:	83 ec 0c             	sub    $0xc,%esp
8010542e:	ff 75 08             	pushl  0x8(%ebp)
80105431:	e8 34 02 00 00       	call   8010566a <semObtained>
80105436:	83 c4 10             	add    $0x10,%esp
80105439:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(indexofsem==-1){
8010543c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80105440:	75 17                	jne    80105459 <semfree+0x44>
    release(&semtable.lock);
80105442:	83 ec 0c             	sub    $0xc,%esp
80105445:	68 e0 62 11 80       	push   $0x801162e0
8010544a:	e8 f4 03 00 00       	call   80105843 <release>
8010544f:	83 c4 10             	add    $0x10,%esp
    return -1;
80105452:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105457:	eb 4b                	jmp    801054a4 <semfree+0x8f>
  }
  s=proc->osemaphore[indexofsem];
80105459:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010545f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105462:	83 c2 20             	add    $0x20,%edx
80105465:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105469:	89 45 f0             	mov    %eax,-0x10(%ebp)
  s->counter--;
8010546c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010546f:	8b 40 04             	mov    0x4(%eax),%eax
80105472:	8d 50 ff             	lea    -0x1(%eax),%edx
80105475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105478:	89 50 04             	mov    %edx,0x4(%eax)
  release(&semtable.lock);
8010547b:	83 ec 0c             	sub    $0xc,%esp
8010547e:	68 e0 62 11 80       	push   $0x801162e0
80105483:	e8 bb 03 00 00       	call   80105843 <release>
80105488:	83 c4 10             	add    $0x10,%esp
  proc->osemaphore[indexofsem]=0;
8010548b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105491:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105494:	83 c2 20             	add    $0x20,%edx
80105497:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010549e:	00 


  return 0;
8010549f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054a4:	c9                   	leave  
801054a5:	c3                   	ret    

801054a6 <semdown>:

int
semdown(int semid)
{
801054a6:	55                   	push   %ebp
801054a7:	89 e5                	mov    %esp,%ebp
801054a9:	83 ec 18             	sub    $0x18,%esp
  struct semaphore * s;
  int indexofsem;
  int res;
  acquire(&semtable.lock);
801054ac:	83 ec 0c             	sub    $0xc,%esp
801054af:	68 e0 62 11 80       	push   $0x801162e0
801054b4:	e8 23 03 00 00       	call   801057dc <acquire>
801054b9:	83 c4 10             	add    $0x10,%esp
  indexofsem=semObtained(semid);
801054bc:	83 ec 0c             	sub    $0xc,%esp
801054bf:	ff 75 08             	pushl  0x8(%ebp)
801054c2:	e8 a3 01 00 00       	call   8010566a <semObtained>
801054c7:	83 c4 10             	add    $0x10,%esp
801054ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(indexofsem==-1){
801054cd:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
801054d1:	75 09                	jne    801054dc <semdown+0x36>
    res= -1;
801054d3:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
801054da:	eb 74                	jmp    80105550 <semdown+0xaa>

  }else{
    s=proc->osemaphore[indexofsem];
801054dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054e2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801054e5:	83 c2 20             	add    $0x20,%edx
801054e8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801054ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (s->value==0){
801054ef:	eb 29                	jmp    8010551a <semdown+0x74>
      cprintf("quiero bajar el sem %d y no puedo! me voy a dormir!\n",s->id);
801054f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f4:	8b 00                	mov    (%eax),%eax
801054f6:	83 ec 08             	sub    $0x8,%esp
801054f9:	50                   	push   %eax
801054fa:	68 94 93 10 80       	push   $0x80109394
801054ff:	e8 c2 ae ff ff       	call   801003c6 <cprintf>
80105504:	83 c4 10             	add    $0x10,%esp
      sleep(s,&semtable.lock);
80105507:	83 ec 08             	sub    $0x8,%esp
8010550a:	68 e0 62 11 80       	push   $0x801162e0
8010550f:	ff 75 f4             	pushl  -0xc(%ebp)
80105512:	e8 6e f9 ff ff       	call   80104e85 <sleep>
80105517:	83 c4 10             	add    $0x10,%esp
  if(indexofsem==-1){
    res= -1;

  }else{
    s=proc->osemaphore[indexofsem];
    while (s->value==0){
8010551a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010551d:	8b 40 08             	mov    0x8(%eax),%eax
80105520:	85 c0                	test   %eax,%eax
80105522:	74 cd                	je     801054f1 <semdown+0x4b>
      cprintf("quiero bajar el sem %d y no puedo! me voy a dormir!\n",s->id);
      sleep(s,&semtable.lock);
    }
    cprintf("pude bajar el sem %d\n",s->id);
80105524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105527:	8b 00                	mov    (%eax),%eax
80105529:	83 ec 08             	sub    $0x8,%esp
8010552c:	50                   	push   %eax
8010552d:	68 c9 93 10 80       	push   $0x801093c9
80105532:	e8 8f ae ff ff       	call   801003c6 <cprintf>
80105537:	83 c4 10             	add    $0x10,%esp
    s->value--;
8010553a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553d:	8b 40 08             	mov    0x8(%eax),%eax
80105540:	8d 50 ff             	lea    -0x1(%eax),%edx
80105543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105546:	89 50 08             	mov    %edx,0x8(%eax)
    res= 0;
80105549:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  }
  cprintf("semdown del semaforo! %d\n",s->value);
80105550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105553:	8b 40 08             	mov    0x8(%eax),%eax
80105556:	83 ec 08             	sub    $0x8,%esp
80105559:	50                   	push   %eax
8010555a:	68 df 93 10 80       	push   $0x801093df
8010555f:	e8 62 ae ff ff       	call   801003c6 <cprintf>
80105564:	83 c4 10             	add    $0x10,%esp
  release(&semtable.lock);
80105567:	83 ec 0c             	sub    $0xc,%esp
8010556a:	68 e0 62 11 80       	push   $0x801162e0
8010556f:	e8 cf 02 00 00       	call   80105843 <release>
80105574:	83 c4 10             	add    $0x10,%esp
  return res;
80105577:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010557a:	c9                   	leave  
8010557b:	c3                   	ret    

8010557c <semup>:

int
semup(int semid)
{
8010557c:	55                   	push   %ebp
8010557d:	89 e5                	mov    %esp,%ebp
8010557f:	83 ec 18             	sub    $0x18,%esp
  struct semaphore * s;
  int indexofsem;
  int res;
  acquire(&semtable.lock);
80105582:	83 ec 0c             	sub    $0xc,%esp
80105585:	68 e0 62 11 80       	push   $0x801162e0
8010558a:	e8 4d 02 00 00       	call   801057dc <acquire>
8010558f:	83 c4 10             	add    $0x10,%esp
  indexofsem=semObtained(semid);
80105592:	83 ec 0c             	sub    $0xc,%esp
80105595:	ff 75 08             	pushl  0x8(%ebp)
80105598:	e8 cd 00 00 00       	call   8010566a <semObtained>
8010559d:	83 c4 10             	add    $0x10,%esp
801055a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(indexofsem!=-1){
801055a3:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801055a7:	74 39                	je     801055e2 <semup+0x66>
    s=proc->osemaphore[indexofsem];
801055a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055af:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055b2:	83 c2 20             	add    $0x20,%edx
801055b5:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801055b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    s->value++;
801055bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801055bf:	8b 40 08             	mov    0x8(%eax),%eax
801055c2:	8d 50 01             	lea    0x1(%eax),%edx
801055c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801055c8:	89 50 08             	mov    %edx,0x8(%eax)
    wakeup(s);
801055cb:	83 ec 0c             	sub    $0xc,%esp
801055ce:	ff 75 ec             	pushl  -0x14(%ebp)
801055d1:	e8 c4 f9 ff ff       	call   80104f9a <wakeup>
801055d6:	83 c4 10             	add    $0x10,%esp
    res =0;
801055d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801055e0:	eb 07                	jmp    801055e9 <semup+0x6d>
  }else{
    res= -1;
801055e2:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  }
  //printsemaphores();
  release(&semtable.lock);
801055e9:	83 ec 0c             	sub    $0xc,%esp
801055ec:	68 e0 62 11 80       	push   $0x801162e0
801055f1:	e8 4d 02 00 00       	call   80105843 <release>
801055f6:	83 c4 10             	add    $0x10,%esp
  return res;
801055f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801055fc:	c9                   	leave  
801055fd:	c3                   	ret    

801055fe <semsearch>:

//returns of the semaphore in the table.
// If the id is -1, then it returns a pointer to the first unused semaphoro (counter 0)
//return -2 if there are no more semaphore available
int
semsearch(int semid){
801055fe:	55                   	push   %ebp
801055ff:	89 e5                	mov    %esp,%ebp
80105601:	83 ec 10             	sub    $0x10,%esp

  int i;
  for(i=0; i < MAXSEM; i++){
80105604:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010560b:	eb 43                	jmp    80105650 <semsearch+0x52>
    if(semtable.sem[i].id==semid){
8010560d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105610:	89 d0                	mov    %edx,%eax
80105612:	01 c0                	add    %eax,%eax
80105614:	01 d0                	add    %edx,%eax
80105616:	c1 e0 02             	shl    $0x2,%eax
80105619:	05 14 63 11 80       	add    $0x80116314,%eax
8010561e:	8b 00                	mov    (%eax),%eax
80105620:	3b 45 08             	cmp    0x8(%ebp),%eax
80105623:	75 05                	jne    8010562a <semsearch+0x2c>
      return i;
80105625:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105628:	eb 3e                	jmp    80105668 <semsearch+0x6a>
    }
    if(semid==-1 && semtable.sem[i].counter==0){
8010562a:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
8010562e:	75 1c                	jne    8010564c <semsearch+0x4e>
80105630:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105633:	89 d0                	mov    %edx,%eax
80105635:	01 c0                	add    %eax,%eax
80105637:	01 d0                	add    %edx,%eax
80105639:	c1 e0 02             	shl    $0x2,%eax
8010563c:	05 18 63 11 80       	add    $0x80116318,%eax
80105641:	8b 00                	mov    (%eax),%eax
80105643:	85 c0                	test   %eax,%eax
80105645:	75 05                	jne    8010564c <semsearch+0x4e>
      return i;
80105647:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010564a:	eb 1c                	jmp    80105668 <semsearch+0x6a>
//return -2 if there are no more semaphore available
int
semsearch(int semid){

  int i;
  for(i=0; i < MAXSEM; i++){
8010564c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105650:	83 7d fc 1d          	cmpl   $0x1d,-0x4(%ebp)
80105654:	7e b7                	jle    8010560d <semsearch+0xf>
    }
    if(semid==-1 && semtable.sem[i].counter==0){
      return i;
    }
  }
  if(semid<0){
80105656:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010565a:	79 07                	jns    80105663 <semsearch+0x65>
    return -3;  //not avaible semaphores
8010565c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
80105661:	eb 05                	jmp    80105668 <semsearch+0x6a>
  }
  return -1;
80105663:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105668:	c9                   	leave  
80105669:	c3                   	ret    

8010566a <semObtained>:

//Check if the semaphore belongs to the current process
//returns the position in the semaphore arrangement of the process or -1 if it was not found
int
semObtained(int semid){
8010566a:	55                   	push   %ebp
8010566b:	89 e5                	mov    %esp,%ebp
8010566d:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i=0;i<MAXPROCSEM;i++){
80105670:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105677:	eb 34                	jmp    801056ad <semObtained+0x43>
    if(proc->osemaphore[i]!=0&&proc->osemaphore[i]->id==semid){
80105679:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010567f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105682:	83 c2 20             	add    $0x20,%edx
80105685:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105689:	85 c0                	test   %eax,%eax
8010568b:	74 1c                	je     801056a9 <semObtained+0x3f>
8010568d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105693:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105696:	83 c2 20             	add    $0x20,%edx
80105699:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010569d:	8b 00                	mov    (%eax),%eax
8010569f:	3b 45 08             	cmp    0x8(%ebp),%eax
801056a2:	75 05                	jne    801056a9 <semObtained+0x3f>
      return i;
801056a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056a7:	eb 0f                	jmp    801056b8 <semObtained+0x4e>
//Check if the semaphore belongs to the current process
//returns the position in the semaphore arrangement of the process or -1 if it was not found
int
semObtained(int semid){
  int i;
  for(i=0;i<MAXPROCSEM;i++){
801056a9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056ad:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
801056b1:	7e c6                	jle    80105679 <semObtained+0xf>
      return i;
    }
  }


    return -1;
801056b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
801056b8:	c9                   	leave  
801056b9:	c3                   	ret    

801056ba <semaphoredup>:

struct semaphore*
semaphoredup(struct semaphore* s){
801056ba:	55                   	push   %ebp
801056bb:	89 e5                	mov    %esp,%ebp
801056bd:	83 ec 08             	sub    $0x8,%esp
  acquire(&semtable.lock);
801056c0:	83 ec 0c             	sub    $0xc,%esp
801056c3:	68 e0 62 11 80       	push   $0x801162e0
801056c8:	e8 0f 01 00 00       	call   801057dc <acquire>
801056cd:	83 c4 10             	add    $0x10,%esp
  if(s->counter<0){
801056d0:	8b 45 08             	mov    0x8(%ebp),%eax
801056d3:	8b 40 04             	mov    0x4(%eax),%eax
801056d6:	85 c0                	test   %eax,%eax
801056d8:	79 0d                	jns    801056e7 <semaphoredup+0x2d>
    panic("error al duplicar el semaforo");
801056da:	83 ec 0c             	sub    $0xc,%esp
801056dd:	68 f9 93 10 80       	push   $0x801093f9
801056e2:	e8 7f ae ff ff       	call   80100566 <panic>
  }
  s->counter++;
801056e7:	8b 45 08             	mov    0x8(%ebp),%eax
801056ea:	8b 40 04             	mov    0x4(%eax),%eax
801056ed:	8d 50 01             	lea    0x1(%eax),%edx
801056f0:	8b 45 08             	mov    0x8(%ebp),%eax
801056f3:	89 50 04             	mov    %edx,0x4(%eax)
  release(&semtable.lock);
801056f6:	83 ec 0c             	sub    $0xc,%esp
801056f9:	68 e0 62 11 80       	push   $0x801162e0
801056fe:	e8 40 01 00 00       	call   80105843 <release>
80105703:	83 c4 10             	add    $0x10,%esp
  return s;
80105706:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105709:	c9                   	leave  
8010570a:	c3                   	ret    

8010570b <printsemaphores>:


void
printsemaphores()
{
8010570b:	55                   	push   %ebp
8010570c:	89 e5                	mov    %esp,%ebp
8010570e:	83 ec 18             	sub    $0x18,%esp
  cprintf("SEMAFOROS DEL PROCESO!!!\n");
80105711:	83 ec 0c             	sub    $0xc,%esp
80105714:	68 17 94 10 80       	push   $0x80109417
80105719:	e8 a8 ac ff ff       	call   801003c6 <cprintf>
8010571e:	83 c4 10             	add    $0x10,%esp
  int i;
  for(i=0;i<MAXPROCSEM;i++){
80105721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105728:	eb 4f                	jmp    80105779 <printsemaphores+0x6e>
    if(proc->osemaphore[i]!=0){
8010572a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105730:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105733:	83 c2 20             	add    $0x20,%edx
80105736:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010573a:	85 c0                	test   %eax,%eax
8010573c:	74 37                	je     80105775 <printsemaphores+0x6a>
      cprintf("semaforo id=%d value=%d\n",proc->osemaphore[i]->id,proc->osemaphore[i]->value);
8010573e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105744:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105747:	83 c2 20             	add    $0x20,%edx
8010574a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010574e:	8b 50 08             	mov    0x8(%eax),%edx
80105751:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105757:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010575a:	83 c1 20             	add    $0x20,%ecx
8010575d:	8b 44 88 0c          	mov    0xc(%eax,%ecx,4),%eax
80105761:	8b 00                	mov    (%eax),%eax
80105763:	83 ec 04             	sub    $0x4,%esp
80105766:	52                   	push   %edx
80105767:	50                   	push   %eax
80105768:	68 31 94 10 80       	push   $0x80109431
8010576d:	e8 54 ac ff ff       	call   801003c6 <cprintf>
80105772:	83 c4 10             	add    $0x10,%esp
void
printsemaphores()
{
  cprintf("SEMAFOROS DEL PROCESO!!!\n");
  int i;
  for(i=0;i<MAXPROCSEM;i++){
80105775:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105779:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010577d:	7e ab                	jle    8010572a <printsemaphores+0x1f>
  }




}
8010577f:	90                   	nop
80105780:	c9                   	leave  
80105781:	c3                   	ret    

80105782 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105782:	55                   	push   %ebp
80105783:	89 e5                	mov    %esp,%ebp
80105785:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105788:	9c                   	pushf  
80105789:	58                   	pop    %eax
8010578a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010578d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105790:	c9                   	leave  
80105791:	c3                   	ret    

80105792 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105792:	55                   	push   %ebp
80105793:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105795:	fa                   	cli    
}
80105796:	90                   	nop
80105797:	5d                   	pop    %ebp
80105798:	c3                   	ret    

80105799 <sti>:

static inline void
sti(void)
{
80105799:	55                   	push   %ebp
8010579a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010579c:	fb                   	sti    
}
8010579d:	90                   	nop
8010579e:	5d                   	pop    %ebp
8010579f:	c3                   	ret    

801057a0 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801057a0:	55                   	push   %ebp
801057a1:	89 e5                	mov    %esp,%ebp
801057a3:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801057a6:	8b 55 08             	mov    0x8(%ebp),%edx
801057a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
801057af:	f0 87 02             	lock xchg %eax,(%edx)
801057b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801057b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057b8:	c9                   	leave  
801057b9:	c3                   	ret    

801057ba <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801057ba:	55                   	push   %ebp
801057bb:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801057bd:	8b 45 08             	mov    0x8(%ebp),%eax
801057c0:	8b 55 0c             	mov    0xc(%ebp),%edx
801057c3:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801057c6:	8b 45 08             	mov    0x8(%ebp),%eax
801057c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801057cf:	8b 45 08             	mov    0x8(%ebp),%eax
801057d2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801057d9:	90                   	nop
801057da:	5d                   	pop    %ebp
801057db:	c3                   	ret    

801057dc <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801057dc:	55                   	push   %ebp
801057dd:	89 e5                	mov    %esp,%ebp
801057df:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801057e2:	e8 52 01 00 00       	call   80105939 <pushcli>
  if(holding(lk))
801057e7:	8b 45 08             	mov    0x8(%ebp),%eax
801057ea:	83 ec 0c             	sub    $0xc,%esp
801057ed:	50                   	push   %eax
801057ee:	e8 1c 01 00 00       	call   8010590f <holding>
801057f3:	83 c4 10             	add    $0x10,%esp
801057f6:	85 c0                	test   %eax,%eax
801057f8:	74 0d                	je     80105807 <acquire+0x2b>
    panic("acquire");
801057fa:	83 ec 0c             	sub    $0xc,%esp
801057fd:	68 4a 94 10 80       	push   $0x8010944a
80105802:	e8 5f ad ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105807:	90                   	nop
80105808:	8b 45 08             	mov    0x8(%ebp),%eax
8010580b:	83 ec 08             	sub    $0x8,%esp
8010580e:	6a 01                	push   $0x1
80105810:	50                   	push   %eax
80105811:	e8 8a ff ff ff       	call   801057a0 <xchg>
80105816:	83 c4 10             	add    $0x10,%esp
80105819:	85 c0                	test   %eax,%eax
8010581b:	75 eb                	jne    80105808 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010581d:	8b 45 08             	mov    0x8(%ebp),%eax
80105820:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105827:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010582a:	8b 45 08             	mov    0x8(%ebp),%eax
8010582d:	83 c0 0c             	add    $0xc,%eax
80105830:	83 ec 08             	sub    $0x8,%esp
80105833:	50                   	push   %eax
80105834:	8d 45 08             	lea    0x8(%ebp),%eax
80105837:	50                   	push   %eax
80105838:	e8 58 00 00 00       	call   80105895 <getcallerpcs>
8010583d:	83 c4 10             	add    $0x10,%esp
}
80105840:	90                   	nop
80105841:	c9                   	leave  
80105842:	c3                   	ret    

80105843 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105843:	55                   	push   %ebp
80105844:	89 e5                	mov    %esp,%ebp
80105846:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105849:	83 ec 0c             	sub    $0xc,%esp
8010584c:	ff 75 08             	pushl  0x8(%ebp)
8010584f:	e8 bb 00 00 00       	call   8010590f <holding>
80105854:	83 c4 10             	add    $0x10,%esp
80105857:	85 c0                	test   %eax,%eax
80105859:	75 0d                	jne    80105868 <release+0x25>
    panic("release");
8010585b:	83 ec 0c             	sub    $0xc,%esp
8010585e:	68 52 94 10 80       	push   $0x80109452
80105863:	e8 fe ac ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105868:	8b 45 08             	mov    0x8(%ebp),%eax
8010586b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105872:	8b 45 08             	mov    0x8(%ebp),%eax
80105875:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010587c:	8b 45 08             	mov    0x8(%ebp),%eax
8010587f:	83 ec 08             	sub    $0x8,%esp
80105882:	6a 00                	push   $0x0
80105884:	50                   	push   %eax
80105885:	e8 16 ff ff ff       	call   801057a0 <xchg>
8010588a:	83 c4 10             	add    $0x10,%esp

  popcli();
8010588d:	e8 ec 00 00 00       	call   8010597e <popcli>
}
80105892:	90                   	nop
80105893:	c9                   	leave  
80105894:	c3                   	ret    

80105895 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105895:	55                   	push   %ebp
80105896:	89 e5                	mov    %esp,%ebp
80105898:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
8010589b:	8b 45 08             	mov    0x8(%ebp),%eax
8010589e:	83 e8 08             	sub    $0x8,%eax
801058a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801058a4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801058ab:	eb 38                	jmp    801058e5 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801058ad:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801058b1:	74 53                	je     80105906 <getcallerpcs+0x71>
801058b3:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801058ba:	76 4a                	jbe    80105906 <getcallerpcs+0x71>
801058bc:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801058c0:	74 44                	je     80105906 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801058c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058c5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801058cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801058cf:	01 c2                	add    %eax,%edx
801058d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058d4:	8b 40 04             	mov    0x4(%eax),%eax
801058d7:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801058d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058dc:	8b 00                	mov    (%eax),%eax
801058de:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801058e1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801058e5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801058e9:	7e c2                	jle    801058ad <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801058eb:	eb 19                	jmp    80105906 <getcallerpcs+0x71>
    pcs[i] = 0;
801058ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058f0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801058f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801058fa:	01 d0                	add    %edx,%eax
801058fc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105902:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105906:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010590a:	7e e1                	jle    801058ed <getcallerpcs+0x58>
    pcs[i] = 0;
}
8010590c:	90                   	nop
8010590d:	c9                   	leave  
8010590e:	c3                   	ret    

8010590f <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010590f:	55                   	push   %ebp
80105910:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105912:	8b 45 08             	mov    0x8(%ebp),%eax
80105915:	8b 00                	mov    (%eax),%eax
80105917:	85 c0                	test   %eax,%eax
80105919:	74 17                	je     80105932 <holding+0x23>
8010591b:	8b 45 08             	mov    0x8(%ebp),%eax
8010591e:	8b 50 08             	mov    0x8(%eax),%edx
80105921:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105927:	39 c2                	cmp    %eax,%edx
80105929:	75 07                	jne    80105932 <holding+0x23>
8010592b:	b8 01 00 00 00       	mov    $0x1,%eax
80105930:	eb 05                	jmp    80105937 <holding+0x28>
80105932:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105937:	5d                   	pop    %ebp
80105938:	c3                   	ret    

80105939 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105939:	55                   	push   %ebp
8010593a:	89 e5                	mov    %esp,%ebp
8010593c:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010593f:	e8 3e fe ff ff       	call   80105782 <readeflags>
80105944:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105947:	e8 46 fe ff ff       	call   80105792 <cli>
  if(cpu->ncli++ == 0)
8010594c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105953:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105959:	8d 48 01             	lea    0x1(%eax),%ecx
8010595c:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105962:	85 c0                	test   %eax,%eax
80105964:	75 15                	jne    8010597b <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105966:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010596c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010596f:	81 e2 00 02 00 00    	and    $0x200,%edx
80105975:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010597b:	90                   	nop
8010597c:	c9                   	leave  
8010597d:	c3                   	ret    

8010597e <popcli>:

void
popcli(void)
{
8010597e:	55                   	push   %ebp
8010597f:	89 e5                	mov    %esp,%ebp
80105981:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105984:	e8 f9 fd ff ff       	call   80105782 <readeflags>
80105989:	25 00 02 00 00       	and    $0x200,%eax
8010598e:	85 c0                	test   %eax,%eax
80105990:	74 0d                	je     8010599f <popcli+0x21>
    panic("popcli - interruptible");
80105992:	83 ec 0c             	sub    $0xc,%esp
80105995:	68 5a 94 10 80       	push   $0x8010945a
8010599a:	e8 c7 ab ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
8010599f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801059a5:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801059ab:	83 ea 01             	sub    $0x1,%edx
801059ae:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801059b4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801059ba:	85 c0                	test   %eax,%eax
801059bc:	79 0d                	jns    801059cb <popcli+0x4d>
    panic("popcli");
801059be:	83 ec 0c             	sub    $0xc,%esp
801059c1:	68 71 94 10 80       	push   $0x80109471
801059c6:	e8 9b ab ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
801059cb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801059d1:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801059d7:	85 c0                	test   %eax,%eax
801059d9:	75 15                	jne    801059f0 <popcli+0x72>
801059db:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801059e1:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801059e7:	85 c0                	test   %eax,%eax
801059e9:	74 05                	je     801059f0 <popcli+0x72>
    sti();
801059eb:	e8 a9 fd ff ff       	call   80105799 <sti>
}
801059f0:	90                   	nop
801059f1:	c9                   	leave  
801059f2:	c3                   	ret    

801059f3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801059f3:	55                   	push   %ebp
801059f4:	89 e5                	mov    %esp,%ebp
801059f6:	57                   	push   %edi
801059f7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801059f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801059fb:	8b 55 10             	mov    0x10(%ebp),%edx
801059fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a01:	89 cb                	mov    %ecx,%ebx
80105a03:	89 df                	mov    %ebx,%edi
80105a05:	89 d1                	mov    %edx,%ecx
80105a07:	fc                   	cld    
80105a08:	f3 aa                	rep stos %al,%es:(%edi)
80105a0a:	89 ca                	mov    %ecx,%edx
80105a0c:	89 fb                	mov    %edi,%ebx
80105a0e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105a11:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105a14:	90                   	nop
80105a15:	5b                   	pop    %ebx
80105a16:	5f                   	pop    %edi
80105a17:	5d                   	pop    %ebp
80105a18:	c3                   	ret    

80105a19 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105a19:	55                   	push   %ebp
80105a1a:	89 e5                	mov    %esp,%ebp
80105a1c:	57                   	push   %edi
80105a1d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105a1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105a21:	8b 55 10             	mov    0x10(%ebp),%edx
80105a24:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a27:	89 cb                	mov    %ecx,%ebx
80105a29:	89 df                	mov    %ebx,%edi
80105a2b:	89 d1                	mov    %edx,%ecx
80105a2d:	fc                   	cld    
80105a2e:	f3 ab                	rep stos %eax,%es:(%edi)
80105a30:	89 ca                	mov    %ecx,%edx
80105a32:	89 fb                	mov    %edi,%ebx
80105a34:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105a37:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105a3a:	90                   	nop
80105a3b:	5b                   	pop    %ebx
80105a3c:	5f                   	pop    %edi
80105a3d:	5d                   	pop    %ebp
80105a3e:	c3                   	ret    

80105a3f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105a3f:	55                   	push   %ebp
80105a40:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105a42:	8b 45 08             	mov    0x8(%ebp),%eax
80105a45:	83 e0 03             	and    $0x3,%eax
80105a48:	85 c0                	test   %eax,%eax
80105a4a:	75 43                	jne    80105a8f <memset+0x50>
80105a4c:	8b 45 10             	mov    0x10(%ebp),%eax
80105a4f:	83 e0 03             	and    $0x3,%eax
80105a52:	85 c0                	test   %eax,%eax
80105a54:	75 39                	jne    80105a8f <memset+0x50>
    c &= 0xFF;
80105a56:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105a5d:	8b 45 10             	mov    0x10(%ebp),%eax
80105a60:	c1 e8 02             	shr    $0x2,%eax
80105a63:	89 c1                	mov    %eax,%ecx
80105a65:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a68:	c1 e0 18             	shl    $0x18,%eax
80105a6b:	89 c2                	mov    %eax,%edx
80105a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a70:	c1 e0 10             	shl    $0x10,%eax
80105a73:	09 c2                	or     %eax,%edx
80105a75:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a78:	c1 e0 08             	shl    $0x8,%eax
80105a7b:	09 d0                	or     %edx,%eax
80105a7d:	0b 45 0c             	or     0xc(%ebp),%eax
80105a80:	51                   	push   %ecx
80105a81:	50                   	push   %eax
80105a82:	ff 75 08             	pushl  0x8(%ebp)
80105a85:	e8 8f ff ff ff       	call   80105a19 <stosl>
80105a8a:	83 c4 0c             	add    $0xc,%esp
80105a8d:	eb 12                	jmp    80105aa1 <memset+0x62>
  } else
    stosb(dst, c, n);
80105a8f:	8b 45 10             	mov    0x10(%ebp),%eax
80105a92:	50                   	push   %eax
80105a93:	ff 75 0c             	pushl  0xc(%ebp)
80105a96:	ff 75 08             	pushl  0x8(%ebp)
80105a99:	e8 55 ff ff ff       	call   801059f3 <stosb>
80105a9e:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105aa1:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105aa4:	c9                   	leave  
80105aa5:	c3                   	ret    

80105aa6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105aa6:	55                   	push   %ebp
80105aa7:	89 e5                	mov    %esp,%ebp
80105aa9:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105aac:	8b 45 08             	mov    0x8(%ebp),%eax
80105aaf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105ab2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ab5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105ab8:	eb 30                	jmp    80105aea <memcmp+0x44>
    if(*s1 != *s2)
80105aba:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105abd:	0f b6 10             	movzbl (%eax),%edx
80105ac0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ac3:	0f b6 00             	movzbl (%eax),%eax
80105ac6:	38 c2                	cmp    %al,%dl
80105ac8:	74 18                	je     80105ae2 <memcmp+0x3c>
      return *s1 - *s2;
80105aca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105acd:	0f b6 00             	movzbl (%eax),%eax
80105ad0:	0f b6 d0             	movzbl %al,%edx
80105ad3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ad6:	0f b6 00             	movzbl (%eax),%eax
80105ad9:	0f b6 c0             	movzbl %al,%eax
80105adc:	29 c2                	sub    %eax,%edx
80105ade:	89 d0                	mov    %edx,%eax
80105ae0:	eb 1a                	jmp    80105afc <memcmp+0x56>
    s1++, s2++;
80105ae2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105ae6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105aea:	8b 45 10             	mov    0x10(%ebp),%eax
80105aed:	8d 50 ff             	lea    -0x1(%eax),%edx
80105af0:	89 55 10             	mov    %edx,0x10(%ebp)
80105af3:	85 c0                	test   %eax,%eax
80105af5:	75 c3                	jne    80105aba <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105af7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105afc:	c9                   	leave  
80105afd:	c3                   	ret    

80105afe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105afe:	55                   	push   %ebp
80105aff:	89 e5                	mov    %esp,%ebp
80105b01:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105b04:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b07:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b0d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105b10:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b13:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105b16:	73 54                	jae    80105b6c <memmove+0x6e>
80105b18:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b1b:	8b 45 10             	mov    0x10(%ebp),%eax
80105b1e:	01 d0                	add    %edx,%eax
80105b20:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105b23:	76 47                	jbe    80105b6c <memmove+0x6e>
    s += n;
80105b25:	8b 45 10             	mov    0x10(%ebp),%eax
80105b28:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105b2b:	8b 45 10             	mov    0x10(%ebp),%eax
80105b2e:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105b31:	eb 13                	jmp    80105b46 <memmove+0x48>
      *--d = *--s;
80105b33:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105b37:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105b3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b3e:	0f b6 10             	movzbl (%eax),%edx
80105b41:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b44:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105b46:	8b 45 10             	mov    0x10(%ebp),%eax
80105b49:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b4c:	89 55 10             	mov    %edx,0x10(%ebp)
80105b4f:	85 c0                	test   %eax,%eax
80105b51:	75 e0                	jne    80105b33 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105b53:	eb 24                	jmp    80105b79 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105b55:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b58:	8d 50 01             	lea    0x1(%eax),%edx
80105b5b:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105b5e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b61:	8d 4a 01             	lea    0x1(%edx),%ecx
80105b64:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105b67:	0f b6 12             	movzbl (%edx),%edx
80105b6a:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105b6c:	8b 45 10             	mov    0x10(%ebp),%eax
80105b6f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b72:	89 55 10             	mov    %edx,0x10(%ebp)
80105b75:	85 c0                	test   %eax,%eax
80105b77:	75 dc                	jne    80105b55 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105b79:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105b7c:	c9                   	leave  
80105b7d:	c3                   	ret    

80105b7e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105b7e:	55                   	push   %ebp
80105b7f:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105b81:	ff 75 10             	pushl  0x10(%ebp)
80105b84:	ff 75 0c             	pushl  0xc(%ebp)
80105b87:	ff 75 08             	pushl  0x8(%ebp)
80105b8a:	e8 6f ff ff ff       	call   80105afe <memmove>
80105b8f:	83 c4 0c             	add    $0xc,%esp
}
80105b92:	c9                   	leave  
80105b93:	c3                   	ret    

80105b94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105b94:	55                   	push   %ebp
80105b95:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105b97:	eb 0c                	jmp    80105ba5 <strncmp+0x11>
    n--, p++, q++;
80105b99:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105b9d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105ba1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105ba5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ba9:	74 1a                	je     80105bc5 <strncmp+0x31>
80105bab:	8b 45 08             	mov    0x8(%ebp),%eax
80105bae:	0f b6 00             	movzbl (%eax),%eax
80105bb1:	84 c0                	test   %al,%al
80105bb3:	74 10                	je     80105bc5 <strncmp+0x31>
80105bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb8:	0f b6 10             	movzbl (%eax),%edx
80105bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bbe:	0f b6 00             	movzbl (%eax),%eax
80105bc1:	38 c2                	cmp    %al,%dl
80105bc3:	74 d4                	je     80105b99 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105bc5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105bc9:	75 07                	jne    80105bd2 <strncmp+0x3e>
    return 0;
80105bcb:	b8 00 00 00 00       	mov    $0x0,%eax
80105bd0:	eb 16                	jmp    80105be8 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd5:	0f b6 00             	movzbl (%eax),%eax
80105bd8:	0f b6 d0             	movzbl %al,%edx
80105bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bde:	0f b6 00             	movzbl (%eax),%eax
80105be1:	0f b6 c0             	movzbl %al,%eax
80105be4:	29 c2                	sub    %eax,%edx
80105be6:	89 d0                	mov    %edx,%eax
}
80105be8:	5d                   	pop    %ebp
80105be9:	c3                   	ret    

80105bea <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105bea:	55                   	push   %ebp
80105beb:	89 e5                	mov    %esp,%ebp
80105bed:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80105bf3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105bf6:	90                   	nop
80105bf7:	8b 45 10             	mov    0x10(%ebp),%eax
80105bfa:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bfd:	89 55 10             	mov    %edx,0x10(%ebp)
80105c00:	85 c0                	test   %eax,%eax
80105c02:	7e 2c                	jle    80105c30 <strncpy+0x46>
80105c04:	8b 45 08             	mov    0x8(%ebp),%eax
80105c07:	8d 50 01             	lea    0x1(%eax),%edx
80105c0a:	89 55 08             	mov    %edx,0x8(%ebp)
80105c0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c10:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c13:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105c16:	0f b6 12             	movzbl (%edx),%edx
80105c19:	88 10                	mov    %dl,(%eax)
80105c1b:	0f b6 00             	movzbl (%eax),%eax
80105c1e:	84 c0                	test   %al,%al
80105c20:	75 d5                	jne    80105bf7 <strncpy+0xd>
    ;
  while(n-- > 0)
80105c22:	eb 0c                	jmp    80105c30 <strncpy+0x46>
    *s++ = 0;
80105c24:	8b 45 08             	mov    0x8(%ebp),%eax
80105c27:	8d 50 01             	lea    0x1(%eax),%edx
80105c2a:	89 55 08             	mov    %edx,0x8(%ebp)
80105c2d:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105c30:	8b 45 10             	mov    0x10(%ebp),%eax
80105c33:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c36:	89 55 10             	mov    %edx,0x10(%ebp)
80105c39:	85 c0                	test   %eax,%eax
80105c3b:	7f e7                	jg     80105c24 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105c3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c40:	c9                   	leave  
80105c41:	c3                   	ret    

80105c42 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105c42:	55                   	push   %ebp
80105c43:	89 e5                	mov    %esp,%ebp
80105c45:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105c48:	8b 45 08             	mov    0x8(%ebp),%eax
80105c4b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105c4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c52:	7f 05                	jg     80105c59 <safestrcpy+0x17>
    return os;
80105c54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c57:	eb 31                	jmp    80105c8a <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105c59:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105c5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c61:	7e 1e                	jle    80105c81 <safestrcpy+0x3f>
80105c63:	8b 45 08             	mov    0x8(%ebp),%eax
80105c66:	8d 50 01             	lea    0x1(%eax),%edx
80105c69:	89 55 08             	mov    %edx,0x8(%ebp)
80105c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c6f:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c72:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105c75:	0f b6 12             	movzbl (%edx),%edx
80105c78:	88 10                	mov    %dl,(%eax)
80105c7a:	0f b6 00             	movzbl (%eax),%eax
80105c7d:	84 c0                	test   %al,%al
80105c7f:	75 d8                	jne    80105c59 <safestrcpy+0x17>
    ;
  *s = 0;
80105c81:	8b 45 08             	mov    0x8(%ebp),%eax
80105c84:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105c87:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c8a:	c9                   	leave  
80105c8b:	c3                   	ret    

80105c8c <strlen>:

int
strlen(const char *s)
{
80105c8c:	55                   	push   %ebp
80105c8d:	89 e5                	mov    %esp,%ebp
80105c8f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105c92:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105c99:	eb 04                	jmp    80105c9f <strlen+0x13>
80105c9b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105c9f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca5:	01 d0                	add    %edx,%eax
80105ca7:	0f b6 00             	movzbl (%eax),%eax
80105caa:	84 c0                	test   %al,%al
80105cac:	75 ed                	jne    80105c9b <strlen+0xf>
    ;
  return n;
80105cae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105cb1:	c9                   	leave  
80105cb2:	c3                   	ret    

80105cb3 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105cb3:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105cb7:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105cbb:	55                   	push   %ebp
  pushl %ebx
80105cbc:	53                   	push   %ebx
  pushl %esi
80105cbd:	56                   	push   %esi
  pushl %edi
80105cbe:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105cbf:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105cc1:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105cc3:	5f                   	pop    %edi
  popl %esi
80105cc4:	5e                   	pop    %esi
  popl %ebx
80105cc5:	5b                   	pop    %ebx
  popl %ebp
80105cc6:	5d                   	pop    %ebp
  ret
80105cc7:	c3                   	ret    

80105cc8 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105cc8:	55                   	push   %ebp
80105cc9:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105ccb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105cd1:	8b 00                	mov    (%eax),%eax
80105cd3:	3b 45 08             	cmp    0x8(%ebp),%eax
80105cd6:	76 12                	jbe    80105cea <fetchint+0x22>
80105cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80105cdb:	8d 50 04             	lea    0x4(%eax),%edx
80105cde:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ce4:	8b 00                	mov    (%eax),%eax
80105ce6:	39 c2                	cmp    %eax,%edx
80105ce8:	76 07                	jbe    80105cf1 <fetchint+0x29>
    return -1;
80105cea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cef:	eb 0f                	jmp    80105d00 <fetchint+0x38>
  *ip = *(int*)(addr);
80105cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80105cf4:	8b 10                	mov    (%eax),%edx
80105cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cf9:	89 10                	mov    %edx,(%eax)
  return 0;
80105cfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d00:	5d                   	pop    %ebp
80105d01:	c3                   	ret    

80105d02 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105d02:	55                   	push   %ebp
80105d03:	89 e5                	mov    %esp,%ebp
80105d05:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105d08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d0e:	8b 00                	mov    (%eax),%eax
80105d10:	3b 45 08             	cmp    0x8(%ebp),%eax
80105d13:	77 07                	ja     80105d1c <fetchstr+0x1a>
    return -1;
80105d15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1a:	eb 46                	jmp    80105d62 <fetchstr+0x60>
  *pp = (char*)addr;
80105d1c:	8b 55 08             	mov    0x8(%ebp),%edx
80105d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d22:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105d24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d2a:	8b 00                	mov    (%eax),%eax
80105d2c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d32:	8b 00                	mov    (%eax),%eax
80105d34:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105d37:	eb 1c                	jmp    80105d55 <fetchstr+0x53>
    if(*s == 0)
80105d39:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d3c:	0f b6 00             	movzbl (%eax),%eax
80105d3f:	84 c0                	test   %al,%al
80105d41:	75 0e                	jne    80105d51 <fetchstr+0x4f>
      return s - *pp;
80105d43:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d46:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d49:	8b 00                	mov    (%eax),%eax
80105d4b:	29 c2                	sub    %eax,%edx
80105d4d:	89 d0                	mov    %edx,%eax
80105d4f:	eb 11                	jmp    80105d62 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105d51:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105d55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d58:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105d5b:	72 dc                	jb     80105d39 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105d5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d62:	c9                   	leave  
80105d63:	c3                   	ret    

80105d64 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105d64:	55                   	push   %ebp
80105d65:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105d67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d6d:	8b 40 18             	mov    0x18(%eax),%eax
80105d70:	8b 40 44             	mov    0x44(%eax),%eax
80105d73:	8b 55 08             	mov    0x8(%ebp),%edx
80105d76:	c1 e2 02             	shl    $0x2,%edx
80105d79:	01 d0                	add    %edx,%eax
80105d7b:	83 c0 04             	add    $0x4,%eax
80105d7e:	ff 75 0c             	pushl  0xc(%ebp)
80105d81:	50                   	push   %eax
80105d82:	e8 41 ff ff ff       	call   80105cc8 <fetchint>
80105d87:	83 c4 08             	add    $0x8,%esp
}
80105d8a:	c9                   	leave  
80105d8b:	c3                   	ret    

80105d8c <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105d8c:	55                   	push   %ebp
80105d8d:	89 e5                	mov    %esp,%ebp
80105d8f:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
80105d92:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105d95:	50                   	push   %eax
80105d96:	ff 75 08             	pushl  0x8(%ebp)
80105d99:	e8 c6 ff ff ff       	call   80105d64 <argint>
80105d9e:	83 c4 08             	add    $0x8,%esp
80105da1:	85 c0                	test   %eax,%eax
80105da3:	79 07                	jns    80105dac <argptr+0x20>
    return -1;
80105da5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105daa:	eb 3b                	jmp    80105de7 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105dac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105db2:	8b 00                	mov    (%eax),%eax
80105db4:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105db7:	39 d0                	cmp    %edx,%eax
80105db9:	76 16                	jbe    80105dd1 <argptr+0x45>
80105dbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dbe:	89 c2                	mov    %eax,%edx
80105dc0:	8b 45 10             	mov    0x10(%ebp),%eax
80105dc3:	01 c2                	add    %eax,%edx
80105dc5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dcb:	8b 00                	mov    (%eax),%eax
80105dcd:	39 c2                	cmp    %eax,%edx
80105dcf:	76 07                	jbe    80105dd8 <argptr+0x4c>
    return -1;
80105dd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd6:	eb 0f                	jmp    80105de7 <argptr+0x5b>
  *pp = (char*)i;
80105dd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ddb:	89 c2                	mov    %eax,%edx
80105ddd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105de0:	89 10                	mov    %edx,(%eax)
  return 0;
80105de2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105de7:	c9                   	leave  
80105de8:	c3                   	ret    

80105de9 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105de9:	55                   	push   %ebp
80105dea:	89 e5                	mov    %esp,%ebp
80105dec:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105def:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105df2:	50                   	push   %eax
80105df3:	ff 75 08             	pushl  0x8(%ebp)
80105df6:	e8 69 ff ff ff       	call   80105d64 <argint>
80105dfb:	83 c4 08             	add    $0x8,%esp
80105dfe:	85 c0                	test   %eax,%eax
80105e00:	79 07                	jns    80105e09 <argstr+0x20>
    return -1;
80105e02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e07:	eb 0f                	jmp    80105e18 <argstr+0x2f>
  return fetchstr(addr, pp);
80105e09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e0c:	ff 75 0c             	pushl  0xc(%ebp)
80105e0f:	50                   	push   %eax
80105e10:	e8 ed fe ff ff       	call   80105d02 <fetchstr>
80105e15:	83 c4 08             	add    $0x8,%esp
}
80105e18:	c9                   	leave  
80105e19:	c3                   	ret    

80105e1a <syscall>:
[SYS_semup] sys_semup,
};

void
syscall(void)
{
80105e1a:	55                   	push   %ebp
80105e1b:	89 e5                	mov    %esp,%ebp
80105e1d:	53                   	push   %ebx
80105e1e:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105e21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e27:	8b 40 18             	mov    0x18(%eax),%eax
80105e2a:	8b 40 1c             	mov    0x1c(%eax),%eax
80105e2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105e30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e34:	7e 30                	jle    80105e66 <syscall+0x4c>
80105e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e39:	83 f8 1b             	cmp    $0x1b,%eax
80105e3c:	77 28                	ja     80105e66 <syscall+0x4c>
80105e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e41:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105e48:	85 c0                	test   %eax,%eax
80105e4a:	74 1a                	je     80105e66 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105e4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e52:	8b 58 18             	mov    0x18(%eax),%ebx
80105e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e58:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105e5f:	ff d0                	call   *%eax
80105e61:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105e64:	eb 34                	jmp    80105e9a <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105e66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e6c:	8d 50 6c             	lea    0x6c(%eax),%edx
80105e6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105e75:	8b 40 10             	mov    0x10(%eax),%eax
80105e78:	ff 75 f4             	pushl  -0xc(%ebp)
80105e7b:	52                   	push   %edx
80105e7c:	50                   	push   %eax
80105e7d:	68 78 94 10 80       	push   $0x80109478
80105e82:	e8 3f a5 ff ff       	call   801003c6 <cprintf>
80105e87:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105e8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e90:	8b 40 18             	mov    0x18(%eax),%eax
80105e93:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105e9a:	90                   	nop
80105e9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105e9e:	c9                   	leave  
80105e9f:	c3                   	ret    

80105ea0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105ea0:	55                   	push   %ebp
80105ea1:	89 e5                	mov    %esp,%ebp
80105ea3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105ea6:	83 ec 08             	sub    $0x8,%esp
80105ea9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105eac:	50                   	push   %eax
80105ead:	ff 75 08             	pushl  0x8(%ebp)
80105eb0:	e8 af fe ff ff       	call   80105d64 <argint>
80105eb5:	83 c4 10             	add    $0x10,%esp
80105eb8:	85 c0                	test   %eax,%eax
80105eba:	79 07                	jns    80105ec3 <argfd+0x23>
    return -1;
80105ebc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec1:	eb 50                	jmp    80105f13 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec6:	85 c0                	test   %eax,%eax
80105ec8:	78 21                	js     80105eeb <argfd+0x4b>
80105eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ecd:	83 f8 0f             	cmp    $0xf,%eax
80105ed0:	7f 19                	jg     80105eeb <argfd+0x4b>
80105ed2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ed8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105edb:	83 c2 08             	add    $0x8,%edx
80105ede:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ee2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ee5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ee9:	75 07                	jne    80105ef2 <argfd+0x52>
    return -1;
80105eeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef0:	eb 21                	jmp    80105f13 <argfd+0x73>
  if(pfd)
80105ef2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105ef6:	74 08                	je     80105f00 <argfd+0x60>
    *pfd = fd;
80105ef8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105efb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105efe:	89 10                	mov    %edx,(%eax)
  if(pf)
80105f00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f04:	74 08                	je     80105f0e <argfd+0x6e>
    *pf = f;
80105f06:	8b 45 10             	mov    0x10(%ebp),%eax
80105f09:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f0c:	89 10                	mov    %edx,(%eax)
  return 0;
80105f0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f13:	c9                   	leave  
80105f14:	c3                   	ret    

80105f15 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105f15:	55                   	push   %ebp
80105f16:	89 e5                	mov    %esp,%ebp
80105f18:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105f1b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105f22:	eb 30                	jmp    80105f54 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105f24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f2a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f2d:	83 c2 08             	add    $0x8,%edx
80105f30:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105f34:	85 c0                	test   %eax,%eax
80105f36:	75 18                	jne    80105f50 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105f38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f3e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f41:	8d 4a 08             	lea    0x8(%edx),%ecx
80105f44:	8b 55 08             	mov    0x8(%ebp),%edx
80105f47:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105f4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f4e:	eb 0f                	jmp    80105f5f <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105f50:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f54:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105f58:	7e ca                	jle    80105f24 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105f5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f5f:	c9                   	leave  
80105f60:	c3                   	ret    

80105f61 <sys_dup>:

int
sys_dup(void)
{
80105f61:	55                   	push   %ebp
80105f62:	89 e5                	mov    %esp,%ebp
80105f64:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105f67:	83 ec 04             	sub    $0x4,%esp
80105f6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f6d:	50                   	push   %eax
80105f6e:	6a 00                	push   $0x0
80105f70:	6a 00                	push   $0x0
80105f72:	e8 29 ff ff ff       	call   80105ea0 <argfd>
80105f77:	83 c4 10             	add    $0x10,%esp
80105f7a:	85 c0                	test   %eax,%eax
80105f7c:	79 07                	jns    80105f85 <sys_dup+0x24>
    return -1;
80105f7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f83:	eb 31                	jmp    80105fb6 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f88:	83 ec 0c             	sub    $0xc,%esp
80105f8b:	50                   	push   %eax
80105f8c:	e8 84 ff ff ff       	call   80105f15 <fdalloc>
80105f91:	83 c4 10             	add    $0x10,%esp
80105f94:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f9b:	79 07                	jns    80105fa4 <sys_dup+0x43>
    return -1;
80105f9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa2:	eb 12                	jmp    80105fb6 <sys_dup+0x55>
  filedup(f);
80105fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa7:	83 ec 0c             	sub    $0xc,%esp
80105faa:	50                   	push   %eax
80105fab:	e8 43 b0 ff ff       	call   80100ff3 <filedup>
80105fb0:	83 c4 10             	add    $0x10,%esp
  return fd;
80105fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105fb6:	c9                   	leave  
80105fb7:	c3                   	ret    

80105fb8 <sys_read>:

int
sys_read(void)
{
80105fb8:	55                   	push   %ebp
80105fb9:	89 e5                	mov    %esp,%ebp
80105fbb:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105fbe:	83 ec 04             	sub    $0x4,%esp
80105fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fc4:	50                   	push   %eax
80105fc5:	6a 00                	push   $0x0
80105fc7:	6a 00                	push   $0x0
80105fc9:	e8 d2 fe ff ff       	call   80105ea0 <argfd>
80105fce:	83 c4 10             	add    $0x10,%esp
80105fd1:	85 c0                	test   %eax,%eax
80105fd3:	78 2e                	js     80106003 <sys_read+0x4b>
80105fd5:	83 ec 08             	sub    $0x8,%esp
80105fd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fdb:	50                   	push   %eax
80105fdc:	6a 02                	push   $0x2
80105fde:	e8 81 fd ff ff       	call   80105d64 <argint>
80105fe3:	83 c4 10             	add    $0x10,%esp
80105fe6:	85 c0                	test   %eax,%eax
80105fe8:	78 19                	js     80106003 <sys_read+0x4b>
80105fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fed:	83 ec 04             	sub    $0x4,%esp
80105ff0:	50                   	push   %eax
80105ff1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ff4:	50                   	push   %eax
80105ff5:	6a 01                	push   $0x1
80105ff7:	e8 90 fd ff ff       	call   80105d8c <argptr>
80105ffc:	83 c4 10             	add    $0x10,%esp
80105fff:	85 c0                	test   %eax,%eax
80106001:	79 07                	jns    8010600a <sys_read+0x52>
    return -1;
80106003:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106008:	eb 17                	jmp    80106021 <sys_read+0x69>
  return fileread(f, p, n);
8010600a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010600d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106013:	83 ec 04             	sub    $0x4,%esp
80106016:	51                   	push   %ecx
80106017:	52                   	push   %edx
80106018:	50                   	push   %eax
80106019:	e8 65 b1 ff ff       	call   80101183 <fileread>
8010601e:	83 c4 10             	add    $0x10,%esp
}
80106021:	c9                   	leave  
80106022:	c3                   	ret    

80106023 <sys_write>:

int
sys_write(void)
{
80106023:	55                   	push   %ebp
80106024:	89 e5                	mov    %esp,%ebp
80106026:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106029:	83 ec 04             	sub    $0x4,%esp
8010602c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010602f:	50                   	push   %eax
80106030:	6a 00                	push   $0x0
80106032:	6a 00                	push   $0x0
80106034:	e8 67 fe ff ff       	call   80105ea0 <argfd>
80106039:	83 c4 10             	add    $0x10,%esp
8010603c:	85 c0                	test   %eax,%eax
8010603e:	78 2e                	js     8010606e <sys_write+0x4b>
80106040:	83 ec 08             	sub    $0x8,%esp
80106043:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106046:	50                   	push   %eax
80106047:	6a 02                	push   $0x2
80106049:	e8 16 fd ff ff       	call   80105d64 <argint>
8010604e:	83 c4 10             	add    $0x10,%esp
80106051:	85 c0                	test   %eax,%eax
80106053:	78 19                	js     8010606e <sys_write+0x4b>
80106055:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106058:	83 ec 04             	sub    $0x4,%esp
8010605b:	50                   	push   %eax
8010605c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010605f:	50                   	push   %eax
80106060:	6a 01                	push   $0x1
80106062:	e8 25 fd ff ff       	call   80105d8c <argptr>
80106067:	83 c4 10             	add    $0x10,%esp
8010606a:	85 c0                	test   %eax,%eax
8010606c:	79 07                	jns    80106075 <sys_write+0x52>
    return -1;
8010606e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106073:	eb 17                	jmp    8010608c <sys_write+0x69>
  return filewrite(f, p, n);
80106075:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106078:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010607b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010607e:	83 ec 04             	sub    $0x4,%esp
80106081:	51                   	push   %ecx
80106082:	52                   	push   %edx
80106083:	50                   	push   %eax
80106084:	e8 b2 b1 ff ff       	call   8010123b <filewrite>
80106089:	83 c4 10             	add    $0x10,%esp
}
8010608c:	c9                   	leave  
8010608d:	c3                   	ret    

8010608e <sys_close>:

int
sys_close(void)
{
8010608e:	55                   	push   %ebp
8010608f:	89 e5                	mov    %esp,%ebp
80106091:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80106094:	83 ec 04             	sub    $0x4,%esp
80106097:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010609a:	50                   	push   %eax
8010609b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010609e:	50                   	push   %eax
8010609f:	6a 00                	push   $0x0
801060a1:	e8 fa fd ff ff       	call   80105ea0 <argfd>
801060a6:	83 c4 10             	add    $0x10,%esp
801060a9:	85 c0                	test   %eax,%eax
801060ab:	79 07                	jns    801060b4 <sys_close+0x26>
    return -1;
801060ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b2:	eb 28                	jmp    801060dc <sys_close+0x4e>
  proc->ofile[fd] = 0;
801060b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060bd:	83 c2 08             	add    $0x8,%edx
801060c0:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801060c7:	00 
  fileclose(f);
801060c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cb:	83 ec 0c             	sub    $0xc,%esp
801060ce:	50                   	push   %eax
801060cf:	e8 70 af ff ff       	call   80101044 <fileclose>
801060d4:	83 c4 10             	add    $0x10,%esp
  return 0;
801060d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060dc:	c9                   	leave  
801060dd:	c3                   	ret    

801060de <sys_fstat>:

int
sys_fstat(void)
{
801060de:	55                   	push   %ebp
801060df:	89 e5                	mov    %esp,%ebp
801060e1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801060e4:	83 ec 04             	sub    $0x4,%esp
801060e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060ea:	50                   	push   %eax
801060eb:	6a 00                	push   $0x0
801060ed:	6a 00                	push   $0x0
801060ef:	e8 ac fd ff ff       	call   80105ea0 <argfd>
801060f4:	83 c4 10             	add    $0x10,%esp
801060f7:	85 c0                	test   %eax,%eax
801060f9:	78 17                	js     80106112 <sys_fstat+0x34>
801060fb:	83 ec 04             	sub    $0x4,%esp
801060fe:	6a 14                	push   $0x14
80106100:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106103:	50                   	push   %eax
80106104:	6a 01                	push   $0x1
80106106:	e8 81 fc ff ff       	call   80105d8c <argptr>
8010610b:	83 c4 10             	add    $0x10,%esp
8010610e:	85 c0                	test   %eax,%eax
80106110:	79 07                	jns    80106119 <sys_fstat+0x3b>
    return -1;
80106112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106117:	eb 13                	jmp    8010612c <sys_fstat+0x4e>
  return filestat(f, st);
80106119:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010611c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010611f:	83 ec 08             	sub    $0x8,%esp
80106122:	52                   	push   %edx
80106123:	50                   	push   %eax
80106124:	e8 03 b0 ff ff       	call   8010112c <filestat>
80106129:	83 c4 10             	add    $0x10,%esp
}
8010612c:	c9                   	leave  
8010612d:	c3                   	ret    

8010612e <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010612e:	55                   	push   %ebp
8010612f:	89 e5                	mov    %esp,%ebp
80106131:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106134:	83 ec 08             	sub    $0x8,%esp
80106137:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010613a:	50                   	push   %eax
8010613b:	6a 00                	push   $0x0
8010613d:	e8 a7 fc ff ff       	call   80105de9 <argstr>
80106142:	83 c4 10             	add    $0x10,%esp
80106145:	85 c0                	test   %eax,%eax
80106147:	78 15                	js     8010615e <sys_link+0x30>
80106149:	83 ec 08             	sub    $0x8,%esp
8010614c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010614f:	50                   	push   %eax
80106150:	6a 01                	push   $0x1
80106152:	e8 92 fc ff ff       	call   80105de9 <argstr>
80106157:	83 c4 10             	add    $0x10,%esp
8010615a:	85 c0                	test   %eax,%eax
8010615c:	79 0a                	jns    80106168 <sys_link+0x3a>
    return -1;
8010615e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106163:	e9 68 01 00 00       	jmp    801062d0 <sys_link+0x1a2>

  begin_op();
80106168:	e8 55 d3 ff ff       	call   801034c2 <begin_op>
  if((ip = namei(old)) == 0){
8010616d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106170:	83 ec 0c             	sub    $0xc,%esp
80106173:	50                   	push   %eax
80106174:	e8 58 c3 ff ff       	call   801024d1 <namei>
80106179:	83 c4 10             	add    $0x10,%esp
8010617c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010617f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106183:	75 0f                	jne    80106194 <sys_link+0x66>
    end_op();
80106185:	e8 c4 d3 ff ff       	call   8010354e <end_op>
    return -1;
8010618a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010618f:	e9 3c 01 00 00       	jmp    801062d0 <sys_link+0x1a2>
  }

  ilock(ip);
80106194:	83 ec 0c             	sub    $0xc,%esp
80106197:	ff 75 f4             	pushl  -0xc(%ebp)
8010619a:	e8 7a b7 ff ff       	call   80101919 <ilock>
8010619f:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801061a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061a9:	66 83 f8 01          	cmp    $0x1,%ax
801061ad:	75 1d                	jne    801061cc <sys_link+0x9e>
    iunlockput(ip);
801061af:	83 ec 0c             	sub    $0xc,%esp
801061b2:	ff 75 f4             	pushl  -0xc(%ebp)
801061b5:	e8 19 ba ff ff       	call   80101bd3 <iunlockput>
801061ba:	83 c4 10             	add    $0x10,%esp
    end_op();
801061bd:	e8 8c d3 ff ff       	call   8010354e <end_op>
    return -1;
801061c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c7:	e9 04 01 00 00       	jmp    801062d0 <sys_link+0x1a2>
  }

  ip->nlink++;
801061cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061cf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801061d3:	83 c0 01             	add    $0x1,%eax
801061d6:	89 c2                	mov    %eax,%edx
801061d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061db:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801061df:	83 ec 0c             	sub    $0xc,%esp
801061e2:	ff 75 f4             	pushl  -0xc(%ebp)
801061e5:	e8 5b b5 ff ff       	call   80101745 <iupdate>
801061ea:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801061ed:	83 ec 0c             	sub    $0xc,%esp
801061f0:	ff 75 f4             	pushl  -0xc(%ebp)
801061f3:	e8 79 b8 ff ff       	call   80101a71 <iunlock>
801061f8:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801061fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801061fe:	83 ec 08             	sub    $0x8,%esp
80106201:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106204:	52                   	push   %edx
80106205:	50                   	push   %eax
80106206:	e8 e2 c2 ff ff       	call   801024ed <nameiparent>
8010620b:	83 c4 10             	add    $0x10,%esp
8010620e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106211:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106215:	74 71                	je     80106288 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80106217:	83 ec 0c             	sub    $0xc,%esp
8010621a:	ff 75 f0             	pushl  -0x10(%ebp)
8010621d:	e8 f7 b6 ff ff       	call   80101919 <ilock>
80106222:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106225:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106228:	8b 10                	mov    (%eax),%edx
8010622a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622d:	8b 00                	mov    (%eax),%eax
8010622f:	39 c2                	cmp    %eax,%edx
80106231:	75 1d                	jne    80106250 <sys_link+0x122>
80106233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106236:	8b 40 04             	mov    0x4(%eax),%eax
80106239:	83 ec 04             	sub    $0x4,%esp
8010623c:	50                   	push   %eax
8010623d:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106240:	50                   	push   %eax
80106241:	ff 75 f0             	pushl  -0x10(%ebp)
80106244:	e8 ec bf ff ff       	call   80102235 <dirlink>
80106249:	83 c4 10             	add    $0x10,%esp
8010624c:	85 c0                	test   %eax,%eax
8010624e:	79 10                	jns    80106260 <sys_link+0x132>
    iunlockput(dp);
80106250:	83 ec 0c             	sub    $0xc,%esp
80106253:	ff 75 f0             	pushl  -0x10(%ebp)
80106256:	e8 78 b9 ff ff       	call   80101bd3 <iunlockput>
8010625b:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010625e:	eb 29                	jmp    80106289 <sys_link+0x15b>
  }
  iunlockput(dp);
80106260:	83 ec 0c             	sub    $0xc,%esp
80106263:	ff 75 f0             	pushl  -0x10(%ebp)
80106266:	e8 68 b9 ff ff       	call   80101bd3 <iunlockput>
8010626b:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010626e:	83 ec 0c             	sub    $0xc,%esp
80106271:	ff 75 f4             	pushl  -0xc(%ebp)
80106274:	e8 6a b8 ff ff       	call   80101ae3 <iput>
80106279:	83 c4 10             	add    $0x10,%esp

  end_op();
8010627c:	e8 cd d2 ff ff       	call   8010354e <end_op>

  return 0;
80106281:	b8 00 00 00 00       	mov    $0x0,%eax
80106286:	eb 48                	jmp    801062d0 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80106288:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80106289:	83 ec 0c             	sub    $0xc,%esp
8010628c:	ff 75 f4             	pushl  -0xc(%ebp)
8010628f:	e8 85 b6 ff ff       	call   80101919 <ilock>
80106294:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80106297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010629e:	83 e8 01             	sub    $0x1,%eax
801062a1:	89 c2                	mov    %eax,%edx
801062a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a6:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801062aa:	83 ec 0c             	sub    $0xc,%esp
801062ad:	ff 75 f4             	pushl  -0xc(%ebp)
801062b0:	e8 90 b4 ff ff       	call   80101745 <iupdate>
801062b5:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801062b8:	83 ec 0c             	sub    $0xc,%esp
801062bb:	ff 75 f4             	pushl  -0xc(%ebp)
801062be:	e8 10 b9 ff ff       	call   80101bd3 <iunlockput>
801062c3:	83 c4 10             	add    $0x10,%esp
  end_op();
801062c6:	e8 83 d2 ff ff       	call   8010354e <end_op>
  return -1;
801062cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062d0:	c9                   	leave  
801062d1:	c3                   	ret    

801062d2 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801062d2:	55                   	push   %ebp
801062d3:	89 e5                	mov    %esp,%ebp
801062d5:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801062d8:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801062df:	eb 40                	jmp    80106321 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801062e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e4:	6a 10                	push   $0x10
801062e6:	50                   	push   %eax
801062e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062ea:	50                   	push   %eax
801062eb:	ff 75 08             	pushl  0x8(%ebp)
801062ee:	e8 8e bb ff ff       	call   80101e81 <readi>
801062f3:	83 c4 10             	add    $0x10,%esp
801062f6:	83 f8 10             	cmp    $0x10,%eax
801062f9:	74 0d                	je     80106308 <isdirempty+0x36>
      panic("isdirempty: readi");
801062fb:	83 ec 0c             	sub    $0xc,%esp
801062fe:	68 94 94 10 80       	push   $0x80109494
80106303:	e8 5e a2 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80106308:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010630c:	66 85 c0             	test   %ax,%ax
8010630f:	74 07                	je     80106318 <isdirempty+0x46>
      return 0;
80106311:	b8 00 00 00 00       	mov    $0x0,%eax
80106316:	eb 1b                	jmp    80106333 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631b:	83 c0 10             	add    $0x10,%eax
8010631e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106321:	8b 45 08             	mov    0x8(%ebp),%eax
80106324:	8b 50 18             	mov    0x18(%eax),%edx
80106327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632a:	39 c2                	cmp    %eax,%edx
8010632c:	77 b3                	ja     801062e1 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010632e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106333:	c9                   	leave  
80106334:	c3                   	ret    

80106335 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106335:	55                   	push   %ebp
80106336:	89 e5                	mov    %esp,%ebp
80106338:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010633b:	83 ec 08             	sub    $0x8,%esp
8010633e:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106341:	50                   	push   %eax
80106342:	6a 00                	push   $0x0
80106344:	e8 a0 fa ff ff       	call   80105de9 <argstr>
80106349:	83 c4 10             	add    $0x10,%esp
8010634c:	85 c0                	test   %eax,%eax
8010634e:	79 0a                	jns    8010635a <sys_unlink+0x25>
    return -1;
80106350:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106355:	e9 bc 01 00 00       	jmp    80106516 <sys_unlink+0x1e1>

  begin_op();
8010635a:	e8 63 d1 ff ff       	call   801034c2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010635f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106362:	83 ec 08             	sub    $0x8,%esp
80106365:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106368:	52                   	push   %edx
80106369:	50                   	push   %eax
8010636a:	e8 7e c1 ff ff       	call   801024ed <nameiparent>
8010636f:	83 c4 10             	add    $0x10,%esp
80106372:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106375:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106379:	75 0f                	jne    8010638a <sys_unlink+0x55>
    end_op();
8010637b:	e8 ce d1 ff ff       	call   8010354e <end_op>
    return -1;
80106380:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106385:	e9 8c 01 00 00       	jmp    80106516 <sys_unlink+0x1e1>
  }

  ilock(dp);
8010638a:	83 ec 0c             	sub    $0xc,%esp
8010638d:	ff 75 f4             	pushl  -0xc(%ebp)
80106390:	e8 84 b5 ff ff       	call   80101919 <ilock>
80106395:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106398:	83 ec 08             	sub    $0x8,%esp
8010639b:	68 a6 94 10 80       	push   $0x801094a6
801063a0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801063a3:	50                   	push   %eax
801063a4:	e8 b7 bd ff ff       	call   80102160 <namecmp>
801063a9:	83 c4 10             	add    $0x10,%esp
801063ac:	85 c0                	test   %eax,%eax
801063ae:	0f 84 4a 01 00 00    	je     801064fe <sys_unlink+0x1c9>
801063b4:	83 ec 08             	sub    $0x8,%esp
801063b7:	68 a8 94 10 80       	push   $0x801094a8
801063bc:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801063bf:	50                   	push   %eax
801063c0:	e8 9b bd ff ff       	call   80102160 <namecmp>
801063c5:	83 c4 10             	add    $0x10,%esp
801063c8:	85 c0                	test   %eax,%eax
801063ca:	0f 84 2e 01 00 00    	je     801064fe <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801063d0:	83 ec 04             	sub    $0x4,%esp
801063d3:	8d 45 c8             	lea    -0x38(%ebp),%eax
801063d6:	50                   	push   %eax
801063d7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801063da:	50                   	push   %eax
801063db:	ff 75 f4             	pushl  -0xc(%ebp)
801063de:	e8 98 bd ff ff       	call   8010217b <dirlookup>
801063e3:	83 c4 10             	add    $0x10,%esp
801063e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063ed:	0f 84 0a 01 00 00    	je     801064fd <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
801063f3:	83 ec 0c             	sub    $0xc,%esp
801063f6:	ff 75 f0             	pushl  -0x10(%ebp)
801063f9:	e8 1b b5 ff ff       	call   80101919 <ilock>
801063fe:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106401:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106404:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106408:	66 85 c0             	test   %ax,%ax
8010640b:	7f 0d                	jg     8010641a <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010640d:	83 ec 0c             	sub    $0xc,%esp
80106410:	68 ab 94 10 80       	push   $0x801094ab
80106415:	e8 4c a1 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010641a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106421:	66 83 f8 01          	cmp    $0x1,%ax
80106425:	75 25                	jne    8010644c <sys_unlink+0x117>
80106427:	83 ec 0c             	sub    $0xc,%esp
8010642a:	ff 75 f0             	pushl  -0x10(%ebp)
8010642d:	e8 a0 fe ff ff       	call   801062d2 <isdirempty>
80106432:	83 c4 10             	add    $0x10,%esp
80106435:	85 c0                	test   %eax,%eax
80106437:	75 13                	jne    8010644c <sys_unlink+0x117>
    iunlockput(ip);
80106439:	83 ec 0c             	sub    $0xc,%esp
8010643c:	ff 75 f0             	pushl  -0x10(%ebp)
8010643f:	e8 8f b7 ff ff       	call   80101bd3 <iunlockput>
80106444:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106447:	e9 b2 00 00 00       	jmp    801064fe <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
8010644c:	83 ec 04             	sub    $0x4,%esp
8010644f:	6a 10                	push   $0x10
80106451:	6a 00                	push   $0x0
80106453:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106456:	50                   	push   %eax
80106457:	e8 e3 f5 ff ff       	call   80105a3f <memset>
8010645c:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010645f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106462:	6a 10                	push   $0x10
80106464:	50                   	push   %eax
80106465:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106468:	50                   	push   %eax
80106469:	ff 75 f4             	pushl  -0xc(%ebp)
8010646c:	e8 67 bb ff ff       	call   80101fd8 <writei>
80106471:	83 c4 10             	add    $0x10,%esp
80106474:	83 f8 10             	cmp    $0x10,%eax
80106477:	74 0d                	je     80106486 <sys_unlink+0x151>
    panic("unlink: writei");
80106479:	83 ec 0c             	sub    $0xc,%esp
8010647c:	68 bd 94 10 80       	push   $0x801094bd
80106481:	e8 e0 a0 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106486:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106489:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010648d:	66 83 f8 01          	cmp    $0x1,%ax
80106491:	75 21                	jne    801064b4 <sys_unlink+0x17f>
    dp->nlink--;
80106493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106496:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010649a:	83 e8 01             	sub    $0x1,%eax
8010649d:	89 c2                	mov    %eax,%edx
8010649f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a2:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801064a6:	83 ec 0c             	sub    $0xc,%esp
801064a9:	ff 75 f4             	pushl  -0xc(%ebp)
801064ac:	e8 94 b2 ff ff       	call   80101745 <iupdate>
801064b1:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801064b4:	83 ec 0c             	sub    $0xc,%esp
801064b7:	ff 75 f4             	pushl  -0xc(%ebp)
801064ba:	e8 14 b7 ff ff       	call   80101bd3 <iunlockput>
801064bf:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801064c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801064c9:	83 e8 01             	sub    $0x1,%eax
801064cc:	89 c2                	mov    %eax,%edx
801064ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d1:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801064d5:	83 ec 0c             	sub    $0xc,%esp
801064d8:	ff 75 f0             	pushl  -0x10(%ebp)
801064db:	e8 65 b2 ff ff       	call   80101745 <iupdate>
801064e0:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801064e3:	83 ec 0c             	sub    $0xc,%esp
801064e6:	ff 75 f0             	pushl  -0x10(%ebp)
801064e9:	e8 e5 b6 ff ff       	call   80101bd3 <iunlockput>
801064ee:	83 c4 10             	add    $0x10,%esp

  end_op();
801064f1:	e8 58 d0 ff ff       	call   8010354e <end_op>

  return 0;
801064f6:	b8 00 00 00 00       	mov    $0x0,%eax
801064fb:	eb 19                	jmp    80106516 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801064fd:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801064fe:	83 ec 0c             	sub    $0xc,%esp
80106501:	ff 75 f4             	pushl  -0xc(%ebp)
80106504:	e8 ca b6 ff ff       	call   80101bd3 <iunlockput>
80106509:	83 c4 10             	add    $0x10,%esp
  end_op();
8010650c:	e8 3d d0 ff ff       	call   8010354e <end_op>
  return -1;
80106511:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106516:	c9                   	leave  
80106517:	c3                   	ret    

80106518 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106518:	55                   	push   %ebp
80106519:	89 e5                	mov    %esp,%ebp
8010651b:	83 ec 38             	sub    $0x38,%esp
8010651e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106521:	8b 55 10             	mov    0x10(%ebp),%edx
80106524:	8b 45 14             	mov    0x14(%ebp),%eax
80106527:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010652b:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010652f:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106533:	83 ec 08             	sub    $0x8,%esp
80106536:	8d 45 de             	lea    -0x22(%ebp),%eax
80106539:	50                   	push   %eax
8010653a:	ff 75 08             	pushl  0x8(%ebp)
8010653d:	e8 ab bf ff ff       	call   801024ed <nameiparent>
80106542:	83 c4 10             	add    $0x10,%esp
80106545:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106548:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010654c:	75 0a                	jne    80106558 <create+0x40>
    return 0;
8010654e:	b8 00 00 00 00       	mov    $0x0,%eax
80106553:	e9 90 01 00 00       	jmp    801066e8 <create+0x1d0>
  ilock(dp);
80106558:	83 ec 0c             	sub    $0xc,%esp
8010655b:	ff 75 f4             	pushl  -0xc(%ebp)
8010655e:	e8 b6 b3 ff ff       	call   80101919 <ilock>
80106563:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106566:	83 ec 04             	sub    $0x4,%esp
80106569:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010656c:	50                   	push   %eax
8010656d:	8d 45 de             	lea    -0x22(%ebp),%eax
80106570:	50                   	push   %eax
80106571:	ff 75 f4             	pushl  -0xc(%ebp)
80106574:	e8 02 bc ff ff       	call   8010217b <dirlookup>
80106579:	83 c4 10             	add    $0x10,%esp
8010657c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010657f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106583:	74 50                	je     801065d5 <create+0xbd>
    iunlockput(dp);
80106585:	83 ec 0c             	sub    $0xc,%esp
80106588:	ff 75 f4             	pushl  -0xc(%ebp)
8010658b:	e8 43 b6 ff ff       	call   80101bd3 <iunlockput>
80106590:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106593:	83 ec 0c             	sub    $0xc,%esp
80106596:	ff 75 f0             	pushl  -0x10(%ebp)
80106599:	e8 7b b3 ff ff       	call   80101919 <ilock>
8010659e:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801065a1:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801065a6:	75 15                	jne    801065bd <create+0xa5>
801065a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065ab:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065af:	66 83 f8 02          	cmp    $0x2,%ax
801065b3:	75 08                	jne    801065bd <create+0xa5>
      return ip;
801065b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b8:	e9 2b 01 00 00       	jmp    801066e8 <create+0x1d0>
    iunlockput(ip);
801065bd:	83 ec 0c             	sub    $0xc,%esp
801065c0:	ff 75 f0             	pushl  -0x10(%ebp)
801065c3:	e8 0b b6 ff ff       	call   80101bd3 <iunlockput>
801065c8:	83 c4 10             	add    $0x10,%esp
    return 0;
801065cb:	b8 00 00 00 00       	mov    $0x0,%eax
801065d0:	e9 13 01 00 00       	jmp    801066e8 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801065d5:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801065d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065dc:	8b 00                	mov    (%eax),%eax
801065de:	83 ec 08             	sub    $0x8,%esp
801065e1:	52                   	push   %edx
801065e2:	50                   	push   %eax
801065e3:	e8 7c b0 ff ff       	call   80101664 <ialloc>
801065e8:	83 c4 10             	add    $0x10,%esp
801065eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065ee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065f2:	75 0d                	jne    80106601 <create+0xe9>
    panic("create: ialloc");
801065f4:	83 ec 0c             	sub    $0xc,%esp
801065f7:	68 cc 94 10 80       	push   $0x801094cc
801065fc:	e8 65 9f ff ff       	call   80100566 <panic>

  ilock(ip);
80106601:	83 ec 0c             	sub    $0xc,%esp
80106604:	ff 75 f0             	pushl  -0x10(%ebp)
80106607:	e8 0d b3 ff ff       	call   80101919 <ilock>
8010660c:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010660f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106612:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106616:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
8010661a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010661d:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106621:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106625:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106628:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010662e:	83 ec 0c             	sub    $0xc,%esp
80106631:	ff 75 f0             	pushl  -0x10(%ebp)
80106634:	e8 0c b1 ff ff       	call   80101745 <iupdate>
80106639:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010663c:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106641:	75 6a                	jne    801066ad <create+0x195>
    dp->nlink++;  // for ".."
80106643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106646:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010664a:	83 c0 01             	add    $0x1,%eax
8010664d:	89 c2                	mov    %eax,%edx
8010664f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106652:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106656:	83 ec 0c             	sub    $0xc,%esp
80106659:	ff 75 f4             	pushl  -0xc(%ebp)
8010665c:	e8 e4 b0 ff ff       	call   80101745 <iupdate>
80106661:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106667:	8b 40 04             	mov    0x4(%eax),%eax
8010666a:	83 ec 04             	sub    $0x4,%esp
8010666d:	50                   	push   %eax
8010666e:	68 a6 94 10 80       	push   $0x801094a6
80106673:	ff 75 f0             	pushl  -0x10(%ebp)
80106676:	e8 ba bb ff ff       	call   80102235 <dirlink>
8010667b:	83 c4 10             	add    $0x10,%esp
8010667e:	85 c0                	test   %eax,%eax
80106680:	78 1e                	js     801066a0 <create+0x188>
80106682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106685:	8b 40 04             	mov    0x4(%eax),%eax
80106688:	83 ec 04             	sub    $0x4,%esp
8010668b:	50                   	push   %eax
8010668c:	68 a8 94 10 80       	push   $0x801094a8
80106691:	ff 75 f0             	pushl  -0x10(%ebp)
80106694:	e8 9c bb ff ff       	call   80102235 <dirlink>
80106699:	83 c4 10             	add    $0x10,%esp
8010669c:	85 c0                	test   %eax,%eax
8010669e:	79 0d                	jns    801066ad <create+0x195>
      panic("create dots");
801066a0:	83 ec 0c             	sub    $0xc,%esp
801066a3:	68 db 94 10 80       	push   $0x801094db
801066a8:	e8 b9 9e ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801066ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066b0:	8b 40 04             	mov    0x4(%eax),%eax
801066b3:	83 ec 04             	sub    $0x4,%esp
801066b6:	50                   	push   %eax
801066b7:	8d 45 de             	lea    -0x22(%ebp),%eax
801066ba:	50                   	push   %eax
801066bb:	ff 75 f4             	pushl  -0xc(%ebp)
801066be:	e8 72 bb ff ff       	call   80102235 <dirlink>
801066c3:	83 c4 10             	add    $0x10,%esp
801066c6:	85 c0                	test   %eax,%eax
801066c8:	79 0d                	jns    801066d7 <create+0x1bf>
    panic("create: dirlink");
801066ca:	83 ec 0c             	sub    $0xc,%esp
801066cd:	68 e7 94 10 80       	push   $0x801094e7
801066d2:	e8 8f 9e ff ff       	call   80100566 <panic>

  iunlockput(dp);
801066d7:	83 ec 0c             	sub    $0xc,%esp
801066da:	ff 75 f4             	pushl  -0xc(%ebp)
801066dd:	e8 f1 b4 ff ff       	call   80101bd3 <iunlockput>
801066e2:	83 c4 10             	add    $0x10,%esp

  return ip;
801066e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801066e8:	c9                   	leave  
801066e9:	c3                   	ret    

801066ea <sys_open>:

int
sys_open(void)
{
801066ea:	55                   	push   %ebp
801066eb:	89 e5                	mov    %esp,%ebp
801066ed:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801066f0:	83 ec 08             	sub    $0x8,%esp
801066f3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066f6:	50                   	push   %eax
801066f7:	6a 00                	push   $0x0
801066f9:	e8 eb f6 ff ff       	call   80105de9 <argstr>
801066fe:	83 c4 10             	add    $0x10,%esp
80106701:	85 c0                	test   %eax,%eax
80106703:	78 15                	js     8010671a <sys_open+0x30>
80106705:	83 ec 08             	sub    $0x8,%esp
80106708:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010670b:	50                   	push   %eax
8010670c:	6a 01                	push   $0x1
8010670e:	e8 51 f6 ff ff       	call   80105d64 <argint>
80106713:	83 c4 10             	add    $0x10,%esp
80106716:	85 c0                	test   %eax,%eax
80106718:	79 0a                	jns    80106724 <sys_open+0x3a>
    return -1;
8010671a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010671f:	e9 61 01 00 00       	jmp    80106885 <sys_open+0x19b>

  begin_op();
80106724:	e8 99 cd ff ff       	call   801034c2 <begin_op>

  if(omode & O_CREATE){
80106729:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010672c:	25 00 02 00 00       	and    $0x200,%eax
80106731:	85 c0                	test   %eax,%eax
80106733:	74 2a                	je     8010675f <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106735:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106738:	6a 00                	push   $0x0
8010673a:	6a 00                	push   $0x0
8010673c:	6a 02                	push   $0x2
8010673e:	50                   	push   %eax
8010673f:	e8 d4 fd ff ff       	call   80106518 <create>
80106744:	83 c4 10             	add    $0x10,%esp
80106747:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010674a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010674e:	75 75                	jne    801067c5 <sys_open+0xdb>
      end_op();
80106750:	e8 f9 cd ff ff       	call   8010354e <end_op>
      return -1;
80106755:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010675a:	e9 26 01 00 00       	jmp    80106885 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010675f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106762:	83 ec 0c             	sub    $0xc,%esp
80106765:	50                   	push   %eax
80106766:	e8 66 bd ff ff       	call   801024d1 <namei>
8010676b:	83 c4 10             	add    $0x10,%esp
8010676e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106771:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106775:	75 0f                	jne    80106786 <sys_open+0x9c>
      end_op();
80106777:	e8 d2 cd ff ff       	call   8010354e <end_op>
      return -1;
8010677c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106781:	e9 ff 00 00 00       	jmp    80106885 <sys_open+0x19b>
    }
    ilock(ip);
80106786:	83 ec 0c             	sub    $0xc,%esp
80106789:	ff 75 f4             	pushl  -0xc(%ebp)
8010678c:	e8 88 b1 ff ff       	call   80101919 <ilock>
80106791:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106797:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010679b:	66 83 f8 01          	cmp    $0x1,%ax
8010679f:	75 24                	jne    801067c5 <sys_open+0xdb>
801067a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067a4:	85 c0                	test   %eax,%eax
801067a6:	74 1d                	je     801067c5 <sys_open+0xdb>
      iunlockput(ip);
801067a8:	83 ec 0c             	sub    $0xc,%esp
801067ab:	ff 75 f4             	pushl  -0xc(%ebp)
801067ae:	e8 20 b4 ff ff       	call   80101bd3 <iunlockput>
801067b3:	83 c4 10             	add    $0x10,%esp
      end_op();
801067b6:	e8 93 cd ff ff       	call   8010354e <end_op>
      return -1;
801067bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c0:	e9 c0 00 00 00       	jmp    80106885 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801067c5:	e8 bc a7 ff ff       	call   80100f86 <filealloc>
801067ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067d1:	74 17                	je     801067ea <sys_open+0x100>
801067d3:	83 ec 0c             	sub    $0xc,%esp
801067d6:	ff 75 f0             	pushl  -0x10(%ebp)
801067d9:	e8 37 f7 ff ff       	call   80105f15 <fdalloc>
801067de:	83 c4 10             	add    $0x10,%esp
801067e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801067e4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801067e8:	79 2e                	jns    80106818 <sys_open+0x12e>
    if(f)
801067ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067ee:	74 0e                	je     801067fe <sys_open+0x114>
      fileclose(f);
801067f0:	83 ec 0c             	sub    $0xc,%esp
801067f3:	ff 75 f0             	pushl  -0x10(%ebp)
801067f6:	e8 49 a8 ff ff       	call   80101044 <fileclose>
801067fb:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801067fe:	83 ec 0c             	sub    $0xc,%esp
80106801:	ff 75 f4             	pushl  -0xc(%ebp)
80106804:	e8 ca b3 ff ff       	call   80101bd3 <iunlockput>
80106809:	83 c4 10             	add    $0x10,%esp
    end_op();
8010680c:	e8 3d cd ff ff       	call   8010354e <end_op>
    return -1;
80106811:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106816:	eb 6d                	jmp    80106885 <sys_open+0x19b>
  }
  iunlock(ip);
80106818:	83 ec 0c             	sub    $0xc,%esp
8010681b:	ff 75 f4             	pushl  -0xc(%ebp)
8010681e:	e8 4e b2 ff ff       	call   80101a71 <iunlock>
80106823:	83 c4 10             	add    $0x10,%esp
  end_op();
80106826:	e8 23 cd ff ff       	call   8010354e <end_op>

  f->type = FD_INODE;
8010682b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010682e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106834:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106837:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010683a:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010683d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106840:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106847:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010684a:	83 e0 01             	and    $0x1,%eax
8010684d:	85 c0                	test   %eax,%eax
8010684f:	0f 94 c0             	sete   %al
80106852:	89 c2                	mov    %eax,%edx
80106854:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106857:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010685a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010685d:	83 e0 01             	and    $0x1,%eax
80106860:	85 c0                	test   %eax,%eax
80106862:	75 0a                	jne    8010686e <sys_open+0x184>
80106864:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106867:	83 e0 02             	and    $0x2,%eax
8010686a:	85 c0                	test   %eax,%eax
8010686c:	74 07                	je     80106875 <sys_open+0x18b>
8010686e:	b8 01 00 00 00       	mov    $0x1,%eax
80106873:	eb 05                	jmp    8010687a <sys_open+0x190>
80106875:	b8 00 00 00 00       	mov    $0x0,%eax
8010687a:	89 c2                	mov    %eax,%edx
8010687c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010687f:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106882:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106885:	c9                   	leave  
80106886:	c3                   	ret    

80106887 <sys_mkdir>:

int
sys_mkdir(void)
{
80106887:	55                   	push   %ebp
80106888:	89 e5                	mov    %esp,%ebp
8010688a:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010688d:	e8 30 cc ff ff       	call   801034c2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106892:	83 ec 08             	sub    $0x8,%esp
80106895:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106898:	50                   	push   %eax
80106899:	6a 00                	push   $0x0
8010689b:	e8 49 f5 ff ff       	call   80105de9 <argstr>
801068a0:	83 c4 10             	add    $0x10,%esp
801068a3:	85 c0                	test   %eax,%eax
801068a5:	78 1b                	js     801068c2 <sys_mkdir+0x3b>
801068a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068aa:	6a 00                	push   $0x0
801068ac:	6a 00                	push   $0x0
801068ae:	6a 01                	push   $0x1
801068b0:	50                   	push   %eax
801068b1:	e8 62 fc ff ff       	call   80106518 <create>
801068b6:	83 c4 10             	add    $0x10,%esp
801068b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068c0:	75 0c                	jne    801068ce <sys_mkdir+0x47>
    end_op();
801068c2:	e8 87 cc ff ff       	call   8010354e <end_op>
    return -1;
801068c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068cc:	eb 18                	jmp    801068e6 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801068ce:	83 ec 0c             	sub    $0xc,%esp
801068d1:	ff 75 f4             	pushl  -0xc(%ebp)
801068d4:	e8 fa b2 ff ff       	call   80101bd3 <iunlockput>
801068d9:	83 c4 10             	add    $0x10,%esp
  end_op();
801068dc:	e8 6d cc ff ff       	call   8010354e <end_op>
  return 0;
801068e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068e6:	c9                   	leave  
801068e7:	c3                   	ret    

801068e8 <sys_mknod>:

int
sys_mknod(void)
{
801068e8:	55                   	push   %ebp
801068e9:	89 e5                	mov    %esp,%ebp
801068eb:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801068ee:	e8 cf cb ff ff       	call   801034c2 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801068f3:	83 ec 08             	sub    $0x8,%esp
801068f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068f9:	50                   	push   %eax
801068fa:	6a 00                	push   $0x0
801068fc:	e8 e8 f4 ff ff       	call   80105de9 <argstr>
80106901:	83 c4 10             	add    $0x10,%esp
80106904:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106907:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010690b:	78 4f                	js     8010695c <sys_mknod+0x74>
     argint(1, &major) < 0 ||
8010690d:	83 ec 08             	sub    $0x8,%esp
80106910:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106913:	50                   	push   %eax
80106914:	6a 01                	push   $0x1
80106916:	e8 49 f4 ff ff       	call   80105d64 <argint>
8010691b:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
8010691e:	85 c0                	test   %eax,%eax
80106920:	78 3a                	js     8010695c <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106922:	83 ec 08             	sub    $0x8,%esp
80106925:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106928:	50                   	push   %eax
80106929:	6a 02                	push   $0x2
8010692b:	e8 34 f4 ff ff       	call   80105d64 <argint>
80106930:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106933:	85 c0                	test   %eax,%eax
80106935:	78 25                	js     8010695c <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106937:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010693a:	0f bf c8             	movswl %ax,%ecx
8010693d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106940:	0f bf d0             	movswl %ax,%edx
80106943:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106946:	51                   	push   %ecx
80106947:	52                   	push   %edx
80106948:	6a 03                	push   $0x3
8010694a:	50                   	push   %eax
8010694b:	e8 c8 fb ff ff       	call   80106518 <create>
80106950:	83 c4 10             	add    $0x10,%esp
80106953:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106956:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010695a:	75 0c                	jne    80106968 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010695c:	e8 ed cb ff ff       	call   8010354e <end_op>
    return -1;
80106961:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106966:	eb 18                	jmp    80106980 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106968:	83 ec 0c             	sub    $0xc,%esp
8010696b:	ff 75 f0             	pushl  -0x10(%ebp)
8010696e:	e8 60 b2 ff ff       	call   80101bd3 <iunlockput>
80106973:	83 c4 10             	add    $0x10,%esp
  end_op();
80106976:	e8 d3 cb ff ff       	call   8010354e <end_op>
  return 0;
8010697b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106980:	c9                   	leave  
80106981:	c3                   	ret    

80106982 <sys_chdir>:

int
sys_chdir(void)
{
80106982:	55                   	push   %ebp
80106983:	89 e5                	mov    %esp,%ebp
80106985:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106988:	e8 35 cb ff ff       	call   801034c2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010698d:	83 ec 08             	sub    $0x8,%esp
80106990:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106993:	50                   	push   %eax
80106994:	6a 00                	push   $0x0
80106996:	e8 4e f4 ff ff       	call   80105de9 <argstr>
8010699b:	83 c4 10             	add    $0x10,%esp
8010699e:	85 c0                	test   %eax,%eax
801069a0:	78 18                	js     801069ba <sys_chdir+0x38>
801069a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a5:	83 ec 0c             	sub    $0xc,%esp
801069a8:	50                   	push   %eax
801069a9:	e8 23 bb ff ff       	call   801024d1 <namei>
801069ae:	83 c4 10             	add    $0x10,%esp
801069b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069b8:	75 0c                	jne    801069c6 <sys_chdir+0x44>
    end_op();
801069ba:	e8 8f cb ff ff       	call   8010354e <end_op>
    return -1;
801069bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069c4:	eb 6e                	jmp    80106a34 <sys_chdir+0xb2>
  }
  ilock(ip);
801069c6:	83 ec 0c             	sub    $0xc,%esp
801069c9:	ff 75 f4             	pushl  -0xc(%ebp)
801069cc:	e8 48 af ff ff       	call   80101919 <ilock>
801069d1:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801069d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801069db:	66 83 f8 01          	cmp    $0x1,%ax
801069df:	74 1a                	je     801069fb <sys_chdir+0x79>
    iunlockput(ip);
801069e1:	83 ec 0c             	sub    $0xc,%esp
801069e4:	ff 75 f4             	pushl  -0xc(%ebp)
801069e7:	e8 e7 b1 ff ff       	call   80101bd3 <iunlockput>
801069ec:	83 c4 10             	add    $0x10,%esp
    end_op();
801069ef:	e8 5a cb ff ff       	call   8010354e <end_op>
    return -1;
801069f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069f9:	eb 39                	jmp    80106a34 <sys_chdir+0xb2>
  }
  iunlock(ip);
801069fb:	83 ec 0c             	sub    $0xc,%esp
801069fe:	ff 75 f4             	pushl  -0xc(%ebp)
80106a01:	e8 6b b0 ff ff       	call   80101a71 <iunlock>
80106a06:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106a09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a0f:	8b 40 68             	mov    0x68(%eax),%eax
80106a12:	83 ec 0c             	sub    $0xc,%esp
80106a15:	50                   	push   %eax
80106a16:	e8 c8 b0 ff ff       	call   80101ae3 <iput>
80106a1b:	83 c4 10             	add    $0x10,%esp
  end_op();
80106a1e:	e8 2b cb ff ff       	call   8010354e <end_op>
  proc->cwd = ip;
80106a23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a2c:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a34:	c9                   	leave  
80106a35:	c3                   	ret    

80106a36 <sys_exec>:

int
sys_exec(void)
{
80106a36:	55                   	push   %ebp
80106a37:	89 e5                	mov    %esp,%ebp
80106a39:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106a3f:	83 ec 08             	sub    $0x8,%esp
80106a42:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a45:	50                   	push   %eax
80106a46:	6a 00                	push   $0x0
80106a48:	e8 9c f3 ff ff       	call   80105de9 <argstr>
80106a4d:	83 c4 10             	add    $0x10,%esp
80106a50:	85 c0                	test   %eax,%eax
80106a52:	78 18                	js     80106a6c <sys_exec+0x36>
80106a54:	83 ec 08             	sub    $0x8,%esp
80106a57:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106a5d:	50                   	push   %eax
80106a5e:	6a 01                	push   $0x1
80106a60:	e8 ff f2 ff ff       	call   80105d64 <argint>
80106a65:	83 c4 10             	add    $0x10,%esp
80106a68:	85 c0                	test   %eax,%eax
80106a6a:	79 0a                	jns    80106a76 <sys_exec+0x40>
    return -1;
80106a6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a71:	e9 c6 00 00 00       	jmp    80106b3c <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106a76:	83 ec 04             	sub    $0x4,%esp
80106a79:	68 80 00 00 00       	push   $0x80
80106a7e:	6a 00                	push   $0x0
80106a80:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106a86:	50                   	push   %eax
80106a87:	e8 b3 ef ff ff       	call   80105a3f <memset>
80106a8c:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106a8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a99:	83 f8 1f             	cmp    $0x1f,%eax
80106a9c:	76 0a                	jbe    80106aa8 <sys_exec+0x72>
      return -1;
80106a9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aa3:	e9 94 00 00 00       	jmp    80106b3c <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aab:	c1 e0 02             	shl    $0x2,%eax
80106aae:	89 c2                	mov    %eax,%edx
80106ab0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106ab6:	01 c2                	add    %eax,%edx
80106ab8:	83 ec 08             	sub    $0x8,%esp
80106abb:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106ac1:	50                   	push   %eax
80106ac2:	52                   	push   %edx
80106ac3:	e8 00 f2 ff ff       	call   80105cc8 <fetchint>
80106ac8:	83 c4 10             	add    $0x10,%esp
80106acb:	85 c0                	test   %eax,%eax
80106acd:	79 07                	jns    80106ad6 <sys_exec+0xa0>
      return -1;
80106acf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ad4:	eb 66                	jmp    80106b3c <sys_exec+0x106>
    if(uarg == 0){
80106ad6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106adc:	85 c0                	test   %eax,%eax
80106ade:	75 27                	jne    80106b07 <sys_exec+0xd1>
      argv[i] = 0;
80106ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae3:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106aea:	00 00 00 00 
      break;
80106aee:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106af2:	83 ec 08             	sub    $0x8,%esp
80106af5:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106afb:	52                   	push   %edx
80106afc:	50                   	push   %eax
80106afd:	e8 54 a0 ff ff       	call   80100b56 <exec>
80106b02:	83 c4 10             	add    $0x10,%esp
80106b05:	eb 35                	jmp    80106b3c <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106b07:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106b0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b10:	c1 e2 02             	shl    $0x2,%edx
80106b13:	01 c2                	add    %eax,%edx
80106b15:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106b1b:	83 ec 08             	sub    $0x8,%esp
80106b1e:	52                   	push   %edx
80106b1f:	50                   	push   %eax
80106b20:	e8 dd f1 ff ff       	call   80105d02 <fetchstr>
80106b25:	83 c4 10             	add    $0x10,%esp
80106b28:	85 c0                	test   %eax,%eax
80106b2a:	79 07                	jns    80106b33 <sys_exec+0xfd>
      return -1;
80106b2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b31:	eb 09                	jmp    80106b3c <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106b33:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106b37:	e9 5a ff ff ff       	jmp    80106a96 <sys_exec+0x60>
  return exec(path, argv);
}
80106b3c:	c9                   	leave  
80106b3d:	c3                   	ret    

80106b3e <sys_pipe>:

int
sys_pipe(void)
{
80106b3e:	55                   	push   %ebp
80106b3f:	89 e5                	mov    %esp,%ebp
80106b41:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106b44:	83 ec 04             	sub    $0x4,%esp
80106b47:	6a 08                	push   $0x8
80106b49:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106b4c:	50                   	push   %eax
80106b4d:	6a 00                	push   $0x0
80106b4f:	e8 38 f2 ff ff       	call   80105d8c <argptr>
80106b54:	83 c4 10             	add    $0x10,%esp
80106b57:	85 c0                	test   %eax,%eax
80106b59:	79 0a                	jns    80106b65 <sys_pipe+0x27>
    return -1;
80106b5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b60:	e9 af 00 00 00       	jmp    80106c14 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106b65:	83 ec 08             	sub    $0x8,%esp
80106b68:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106b6b:	50                   	push   %eax
80106b6c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106b6f:	50                   	push   %eax
80106b70:	e8 4b d4 ff ff       	call   80103fc0 <pipealloc>
80106b75:	83 c4 10             	add    $0x10,%esp
80106b78:	85 c0                	test   %eax,%eax
80106b7a:	79 0a                	jns    80106b86 <sys_pipe+0x48>
    return -1;
80106b7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b81:	e9 8e 00 00 00       	jmp    80106c14 <sys_pipe+0xd6>
  fd0 = -1;
80106b86:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106b8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b90:	83 ec 0c             	sub    $0xc,%esp
80106b93:	50                   	push   %eax
80106b94:	e8 7c f3 ff ff       	call   80105f15 <fdalloc>
80106b99:	83 c4 10             	add    $0x10,%esp
80106b9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ba3:	78 18                	js     80106bbd <sys_pipe+0x7f>
80106ba5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ba8:	83 ec 0c             	sub    $0xc,%esp
80106bab:	50                   	push   %eax
80106bac:	e8 64 f3 ff ff       	call   80105f15 <fdalloc>
80106bb1:	83 c4 10             	add    $0x10,%esp
80106bb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106bb7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106bbb:	79 3f                	jns    80106bfc <sys_pipe+0xbe>
    if(fd0 >= 0)
80106bbd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bc1:	78 14                	js     80106bd7 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106bc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106bcc:	83 c2 08             	add    $0x8,%edx
80106bcf:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106bd6:	00 
    fileclose(rf);
80106bd7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106bda:	83 ec 0c             	sub    $0xc,%esp
80106bdd:	50                   	push   %eax
80106bde:	e8 61 a4 ff ff       	call   80101044 <fileclose>
80106be3:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106be6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106be9:	83 ec 0c             	sub    $0xc,%esp
80106bec:	50                   	push   %eax
80106bed:	e8 52 a4 ff ff       	call   80101044 <fileclose>
80106bf2:	83 c4 10             	add    $0x10,%esp
    return -1;
80106bf5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bfa:	eb 18                	jmp    80106c14 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106bfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106bff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c02:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106c04:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c07:	8d 50 04             	lea    0x4(%eax),%edx
80106c0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c0d:	89 02                	mov    %eax,(%edx)
  return 0;
80106c0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c14:	c9                   	leave  
80106c15:	c3                   	ret    

80106c16 <sys_fork>:
#include "proc.h"


int
sys_fork(void)
{
80106c16:	55                   	push   %ebp
80106c17:	89 e5                	mov    %esp,%ebp
80106c19:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106c1c:	e8 a6 db ff ff       	call   801047c7 <fork>
}
80106c21:	c9                   	leave  
80106c22:	c3                   	ret    

80106c23 <sys_exit>:

int
sys_exit(void)
{
80106c23:	55                   	push   %ebp
80106c24:	89 e5                	mov    %esp,%ebp
80106c26:	83 ec 08             	sub    $0x8,%esp
  exit();
80106c29:	e8 95 dd ff ff       	call   801049c3 <exit>
  return 0;  // not reached
80106c2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c33:	c9                   	leave  
80106c34:	c3                   	ret    

80106c35 <sys_wait>:

int
sys_wait(void)
{
80106c35:	55                   	push   %ebp
80106c36:	89 e5                	mov    %esp,%ebp
80106c38:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106c3b:	e8 be de ff ff       	call   80104afe <wait>
}
80106c40:	c9                   	leave  
80106c41:	c3                   	ret    

80106c42 <sys_kill>:

int
sys_kill(void)
{
80106c42:	55                   	push   %ebp
80106c43:	89 e5                	mov    %esp,%ebp
80106c45:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106c48:	83 ec 08             	sub    $0x8,%esp
80106c4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c4e:	50                   	push   %eax
80106c4f:	6a 00                	push   $0x0
80106c51:	e8 0e f1 ff ff       	call   80105d64 <argint>
80106c56:	83 c4 10             	add    $0x10,%esp
80106c59:	85 c0                	test   %eax,%eax
80106c5b:	79 07                	jns    80106c64 <sys_kill+0x22>
    return -1;
80106c5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c62:	eb 0f                	jmp    80106c73 <sys_kill+0x31>
  return kill(pid);
80106c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c67:	83 ec 0c             	sub    $0xc,%esp
80106c6a:	50                   	push   %eax
80106c6b:	e8 61 e3 ff ff       	call   80104fd1 <kill>
80106c70:	83 c4 10             	add    $0x10,%esp
}
80106c73:	c9                   	leave  
80106c74:	c3                   	ret    

80106c75 <sys_getpid>:

int
sys_getpid(void)
{
80106c75:	55                   	push   %ebp
80106c76:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106c78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c7e:	8b 40 10             	mov    0x10(%eax),%eax
}
80106c81:	5d                   	pop    %ebp
80106c82:	c3                   	ret    

80106c83 <sys_sbrk>:

int
sys_sbrk(void)
{
80106c83:	55                   	push   %ebp
80106c84:	89 e5                	mov    %esp,%ebp
80106c86:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106c89:	83 ec 08             	sub    $0x8,%esp
80106c8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c8f:	50                   	push   %eax
80106c90:	6a 00                	push   $0x0
80106c92:	e8 cd f0 ff ff       	call   80105d64 <argint>
80106c97:	83 c4 10             	add    $0x10,%esp
80106c9a:	85 c0                	test   %eax,%eax
80106c9c:	79 07                	jns    80106ca5 <sys_sbrk+0x22>
    return -1;
80106c9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ca3:	eb 28                	jmp    80106ccd <sys_sbrk+0x4a>
  addr = proc->sz;
80106ca5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cab:	8b 00                	mov    (%eax),%eax
80106cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cb3:	83 ec 0c             	sub    $0xc,%esp
80106cb6:	50                   	push   %eax
80106cb7:	e8 68 da ff ff       	call   80104724 <growproc>
80106cbc:	83 c4 10             	add    $0x10,%esp
80106cbf:	85 c0                	test   %eax,%eax
80106cc1:	79 07                	jns    80106cca <sys_sbrk+0x47>
    return -1;
80106cc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cc8:	eb 03                	jmp    80106ccd <sys_sbrk+0x4a>
  return addr;
80106cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106ccd:	c9                   	leave  
80106cce:	c3                   	ret    

80106ccf <sys_sleep>:

int
sys_sleep(void)
{
80106ccf:	55                   	push   %ebp
80106cd0:	89 e5                	mov    %esp,%ebp
80106cd2:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106cd5:	83 ec 08             	sub    $0x8,%esp
80106cd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cdb:	50                   	push   %eax
80106cdc:	6a 00                	push   $0x0
80106cde:	e8 81 f0 ff ff       	call   80105d64 <argint>
80106ce3:	83 c4 10             	add    $0x10,%esp
80106ce6:	85 c0                	test   %eax,%eax
80106ce8:	79 07                	jns    80106cf1 <sys_sleep+0x22>
    return -1;
80106cea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cef:	eb 77                	jmp    80106d68 <sys_sleep+0x99>
  acquire(&tickslock);
80106cf1:	83 ec 0c             	sub    $0xc,%esp
80106cf4:	68 80 64 11 80       	push   $0x80116480
80106cf9:	e8 de ea ff ff       	call   801057dc <acquire>
80106cfe:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106d01:	a1 c0 6c 11 80       	mov    0x80116cc0,%eax
80106d06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106d09:	eb 39                	jmp    80106d44 <sys_sleep+0x75>
    if(proc->killed){
80106d0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d11:	8b 40 24             	mov    0x24(%eax),%eax
80106d14:	85 c0                	test   %eax,%eax
80106d16:	74 17                	je     80106d2f <sys_sleep+0x60>
      release(&tickslock);
80106d18:	83 ec 0c             	sub    $0xc,%esp
80106d1b:	68 80 64 11 80       	push   $0x80116480
80106d20:	e8 1e eb ff ff       	call   80105843 <release>
80106d25:	83 c4 10             	add    $0x10,%esp
      return -1;
80106d28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d2d:	eb 39                	jmp    80106d68 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106d2f:	83 ec 08             	sub    $0x8,%esp
80106d32:	68 80 64 11 80       	push   $0x80116480
80106d37:	68 c0 6c 11 80       	push   $0x80116cc0
80106d3c:	e8 44 e1 ff ff       	call   80104e85 <sleep>
80106d41:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106d44:	a1 c0 6c 11 80       	mov    0x80116cc0,%eax
80106d49:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106d4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d4f:	39 d0                	cmp    %edx,%eax
80106d51:	72 b8                	jb     80106d0b <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106d53:	83 ec 0c             	sub    $0xc,%esp
80106d56:	68 80 64 11 80       	push   $0x80116480
80106d5b:	e8 e3 ea ff ff       	call   80105843 <release>
80106d60:	83 c4 10             	add    $0x10,%esp
  return 0;
80106d63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d68:	c9                   	leave  
80106d69:	c3                   	ret    

80106d6a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106d6a:	55                   	push   %ebp
80106d6b:	89 e5                	mov    %esp,%ebp
80106d6d:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106d70:	83 ec 0c             	sub    $0xc,%esp
80106d73:	68 80 64 11 80       	push   $0x80116480
80106d78:	e8 5f ea ff ff       	call   801057dc <acquire>
80106d7d:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106d80:	a1 c0 6c 11 80       	mov    0x80116cc0,%eax
80106d85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106d88:	83 ec 0c             	sub    $0xc,%esp
80106d8b:	68 80 64 11 80       	push   $0x80116480
80106d90:	e8 ae ea ff ff       	call   80105843 <release>
80106d95:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106d9b:	c9                   	leave  
80106d9c:	c3                   	ret    

80106d9d <sys_procstat>:

//
int
sys_procstat(void)
{
80106d9d:	55                   	push   %ebp
80106d9e:	89 e5                	mov    %esp,%ebp
80106da0:	83 ec 08             	sub    $0x8,%esp
  //cprintf("SE EJECUTA EL SYS_PROCSTAT\n");
  procdump();// ejecutamos la funcion procdump definida en proc.c
80106da3:	e8 b4 e2 ff ff       	call   8010505c <procdump>
  return 0;
80106da8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106dad:	c9                   	leave  
80106dae:	c3                   	ret    

80106daf <sys_setpriority>:

// change the priority of the process to the specified value
//
int
sys_setpriority(void)
{
80106daf:	55                   	push   %ebp
80106db0:	89 e5                	mov    %esp,%ebp
80106db2:	83 ec 18             	sub    $0x18,%esp
    int priority;
    if(argint(0, &priority) < 0){
80106db5:	83 ec 08             	sub    $0x8,%esp
80106db8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106dbb:	50                   	push   %eax
80106dbc:	6a 00                	push   $0x0
80106dbe:	e8 a1 ef ff ff       	call   80105d64 <argint>
80106dc3:	83 c4 10             	add    $0x10,%esp
80106dc6:	85 c0                	test   %eax,%eax
80106dc8:	79 07                	jns    80106dd1 <sys_setpriority+0x22>
      return -1;
80106dca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dcf:	eb 2b                	jmp    80106dfc <sys_setpriority+0x4d>
    }
    if(priority>=0 &&priority<MLFLEVELS){
80106dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dd4:	85 c0                	test   %eax,%eax
80106dd6:	78 1f                	js     80106df7 <sys_setpriority+0x48>
80106dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ddb:	83 f8 03             	cmp    $0x3,%eax
80106dde:	7f 17                	jg     80106df7 <sys_setpriority+0x48>
      proc->priority=priority;
80106de0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106de6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106de9:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
      return 0;
80106df0:	b8 00 00 00 00       	mov    $0x0,%eax
80106df5:	eb 05                	jmp    80106dfc <sys_setpriority+0x4d>
    }
    else{
      return -1;
80106df7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

}
80106dfc:	c9                   	leave  
80106dfd:	c3                   	ret    

80106dfe <sys_semget>:



int
sys_semget(void)
{
80106dfe:	55                   	push   %ebp
80106dff:	89 e5                	mov    %esp,%ebp
80106e01:	83 ec 18             	sub    $0x18,%esp
  int initvalue;
  int semid;
  argint(0, &semid);
80106e04:	83 ec 08             	sub    $0x8,%esp
80106e07:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e0a:	50                   	push   %eax
80106e0b:	6a 00                	push   $0x0
80106e0d:	e8 52 ef ff ff       	call   80105d64 <argint>
80106e12:	83 c4 10             	add    $0x10,%esp
  argint(1, &initvalue);
80106e15:	83 ec 08             	sub    $0x8,%esp
80106e18:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e1b:	50                   	push   %eax
80106e1c:	6a 01                	push   $0x1
80106e1e:	e8 41 ef ff ff       	call   80105d64 <argint>
80106e23:	83 c4 10             	add    $0x10,%esp
  return semget(semid,initvalue);
80106e26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e2c:	83 ec 08             	sub    $0x8,%esp
80106e2f:	52                   	push   %edx
80106e30:	50                   	push   %eax
80106e31:	e8 bb e4 ff ff       	call   801052f1 <semget>
80106e36:	83 c4 10             	add    $0x10,%esp
}
80106e39:	c9                   	leave  
80106e3a:	c3                   	ret    

80106e3b <sys_semfree>:

int
sys_semfree(void)
{
80106e3b:	55                   	push   %ebp
80106e3c:	89 e5                	mov    %esp,%ebp
80106e3e:	83 ec 18             	sub    $0x18,%esp
  int semid;
  argint(0, &semid);
80106e41:	83 ec 08             	sub    $0x8,%esp
80106e44:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e47:	50                   	push   %eax
80106e48:	6a 00                	push   $0x0
80106e4a:	e8 15 ef ff ff       	call   80105d64 <argint>
80106e4f:	83 c4 10             	add    $0x10,%esp
  return semfree(semid);
80106e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e55:	83 ec 0c             	sub    $0xc,%esp
80106e58:	50                   	push   %eax
80106e59:	e8 b7 e5 ff ff       	call   80105415 <semfree>
80106e5e:	83 c4 10             	add    $0x10,%esp

}
80106e61:	c9                   	leave  
80106e62:	c3                   	ret    

80106e63 <sys_semdown>:

int
sys_semdown(void)
{
80106e63:	55                   	push   %ebp
80106e64:	89 e5                	mov    %esp,%ebp
80106e66:	83 ec 18             	sub    $0x18,%esp
  int semid;
  argint(0, &semid);
80106e69:	83 ec 08             	sub    $0x8,%esp
80106e6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e6f:	50                   	push   %eax
80106e70:	6a 00                	push   $0x0
80106e72:	e8 ed ee ff ff       	call   80105d64 <argint>
80106e77:	83 c4 10             	add    $0x10,%esp
  return semdown(semid);
80106e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e7d:	83 ec 0c             	sub    $0xc,%esp
80106e80:	50                   	push   %eax
80106e81:	e8 20 e6 ff ff       	call   801054a6 <semdown>
80106e86:	83 c4 10             	add    $0x10,%esp
}
80106e89:	c9                   	leave  
80106e8a:	c3                   	ret    

80106e8b <sys_semup>:

int
sys_semup(void)
{
80106e8b:	55                   	push   %ebp
80106e8c:	89 e5                	mov    %esp,%ebp
80106e8e:	83 ec 18             	sub    $0x18,%esp
  int semid;
  argint(0, &semid);
80106e91:	83 ec 08             	sub    $0x8,%esp
80106e94:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e97:	50                   	push   %eax
80106e98:	6a 00                	push   $0x0
80106e9a:	e8 c5 ee ff ff       	call   80105d64 <argint>
80106e9f:	83 c4 10             	add    $0x10,%esp
  return semup(semid);
80106ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ea5:	83 ec 0c             	sub    $0xc,%esp
80106ea8:	50                   	push   %eax
80106ea9:	e8 ce e6 ff ff       	call   8010557c <semup>
80106eae:	83 c4 10             	add    $0x10,%esp
}
80106eb1:	c9                   	leave  
80106eb2:	c3                   	ret    

80106eb3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106eb3:	55                   	push   %ebp
80106eb4:	89 e5                	mov    %esp,%ebp
80106eb6:	83 ec 08             	sub    $0x8,%esp
80106eb9:	8b 55 08             	mov    0x8(%ebp),%edx
80106ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ebf:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106ec3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ec6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106eca:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ece:	ee                   	out    %al,(%dx)
}
80106ecf:	90                   	nop
80106ed0:	c9                   	leave  
80106ed1:	c3                   	ret    

80106ed2 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106ed2:	55                   	push   %ebp
80106ed3:	89 e5                	mov    %esp,%ebp
80106ed5:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106ed8:	6a 34                	push   $0x34
80106eda:	6a 43                	push   $0x43
80106edc:	e8 d2 ff ff ff       	call   80106eb3 <outb>
80106ee1:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106ee4:	68 9c 00 00 00       	push   $0x9c
80106ee9:	6a 40                	push   $0x40
80106eeb:	e8 c3 ff ff ff       	call   80106eb3 <outb>
80106ef0:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106ef3:	6a 2e                	push   $0x2e
80106ef5:	6a 40                	push   $0x40
80106ef7:	e8 b7 ff ff ff       	call   80106eb3 <outb>
80106efc:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106eff:	83 ec 0c             	sub    $0xc,%esp
80106f02:	6a 00                	push   $0x0
80106f04:	e8 a1 cf ff ff       	call   80103eaa <picenable>
80106f09:	83 c4 10             	add    $0x10,%esp
}
80106f0c:	90                   	nop
80106f0d:	c9                   	leave  
80106f0e:	c3                   	ret    

80106f0f <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106f0f:	1e                   	push   %ds
  pushl %es
80106f10:	06                   	push   %es
  pushl %fs
80106f11:	0f a0                	push   %fs
  pushl %gs
80106f13:	0f a8                	push   %gs
  pushal
80106f15:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106f16:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106f1a:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106f1c:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106f1e:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106f22:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106f24:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106f26:	54                   	push   %esp
  call trap
80106f27:	e8 d7 01 00 00       	call   80107103 <trap>
  addl $4, %esp
80106f2c:	83 c4 04             	add    $0x4,%esp

80106f2f <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106f2f:	61                   	popa   
  popl %gs
80106f30:	0f a9                	pop    %gs
  popl %fs
80106f32:	0f a1                	pop    %fs
  popl %es
80106f34:	07                   	pop    %es
  popl %ds
80106f35:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106f36:	83 c4 08             	add    $0x8,%esp
  iret
80106f39:	cf                   	iret   

80106f3a <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106f3a:	55                   	push   %ebp
80106f3b:	89 e5                	mov    %esp,%ebp
80106f3d:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106f40:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f43:	83 e8 01             	sub    $0x1,%eax
80106f46:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f4d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f51:	8b 45 08             	mov    0x8(%ebp),%eax
80106f54:	c1 e8 10             	shr    $0x10,%eax
80106f57:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106f5b:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106f5e:	0f 01 18             	lidtl  (%eax)
}
80106f61:	90                   	nop
80106f62:	c9                   	leave  
80106f63:	c3                   	ret    

80106f64 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106f64:	55                   	push   %ebp
80106f65:	89 e5                	mov    %esp,%ebp
80106f67:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106f6a:	0f 20 d0             	mov    %cr2,%eax
80106f6d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106f70:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106f73:	c9                   	leave  
80106f74:	c3                   	ret    

80106f75 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106f75:	55                   	push   %ebp
80106f76:	89 e5                	mov    %esp,%ebp
80106f78:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106f7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f82:	e9 c3 00 00 00       	jmp    8010704a <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f8a:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106f91:	89 c2                	mov    %eax,%edx
80106f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f96:	66 89 14 c5 c0 64 11 	mov    %dx,-0x7fee9b40(,%eax,8)
80106f9d:	80 
80106f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa1:	66 c7 04 c5 c2 64 11 	movw   $0x8,-0x7fee9b3e(,%eax,8)
80106fa8:	80 08 00 
80106fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fae:	0f b6 14 c5 c4 64 11 	movzbl -0x7fee9b3c(,%eax,8),%edx
80106fb5:	80 
80106fb6:	83 e2 e0             	and    $0xffffffe0,%edx
80106fb9:	88 14 c5 c4 64 11 80 	mov    %dl,-0x7fee9b3c(,%eax,8)
80106fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc3:	0f b6 14 c5 c4 64 11 	movzbl -0x7fee9b3c(,%eax,8),%edx
80106fca:	80 
80106fcb:	83 e2 1f             	and    $0x1f,%edx
80106fce:	88 14 c5 c4 64 11 80 	mov    %dl,-0x7fee9b3c(,%eax,8)
80106fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd8:	0f b6 14 c5 c5 64 11 	movzbl -0x7fee9b3b(,%eax,8),%edx
80106fdf:	80 
80106fe0:	83 e2 f0             	and    $0xfffffff0,%edx
80106fe3:	83 ca 0e             	or     $0xe,%edx
80106fe6:	88 14 c5 c5 64 11 80 	mov    %dl,-0x7fee9b3b(,%eax,8)
80106fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff0:	0f b6 14 c5 c5 64 11 	movzbl -0x7fee9b3b(,%eax,8),%edx
80106ff7:	80 
80106ff8:	83 e2 ef             	and    $0xffffffef,%edx
80106ffb:	88 14 c5 c5 64 11 80 	mov    %dl,-0x7fee9b3b(,%eax,8)
80107002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107005:	0f b6 14 c5 c5 64 11 	movzbl -0x7fee9b3b(,%eax,8),%edx
8010700c:	80 
8010700d:	83 e2 9f             	and    $0xffffff9f,%edx
80107010:	88 14 c5 c5 64 11 80 	mov    %dl,-0x7fee9b3b(,%eax,8)
80107017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010701a:	0f b6 14 c5 c5 64 11 	movzbl -0x7fee9b3b(,%eax,8),%edx
80107021:	80 
80107022:	83 ca 80             	or     $0xffffff80,%edx
80107025:	88 14 c5 c5 64 11 80 	mov    %dl,-0x7fee9b3b(,%eax,8)
8010702c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702f:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80107036:	c1 e8 10             	shr    $0x10,%eax
80107039:	89 c2                	mov    %eax,%edx
8010703b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703e:	66 89 14 c5 c6 64 11 	mov    %dx,-0x7fee9b3a(,%eax,8)
80107045:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107046:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010704a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107051:	0f 8e 30 ff ff ff    	jle    80106f87 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107057:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
8010705c:	66 a3 c0 66 11 80    	mov    %ax,0x801166c0
80107062:	66 c7 05 c2 66 11 80 	movw   $0x8,0x801166c2
80107069:	08 00 
8010706b:	0f b6 05 c4 66 11 80 	movzbl 0x801166c4,%eax
80107072:	83 e0 e0             	and    $0xffffffe0,%eax
80107075:	a2 c4 66 11 80       	mov    %al,0x801166c4
8010707a:	0f b6 05 c4 66 11 80 	movzbl 0x801166c4,%eax
80107081:	83 e0 1f             	and    $0x1f,%eax
80107084:	a2 c4 66 11 80       	mov    %al,0x801166c4
80107089:	0f b6 05 c5 66 11 80 	movzbl 0x801166c5,%eax
80107090:	83 c8 0f             	or     $0xf,%eax
80107093:	a2 c5 66 11 80       	mov    %al,0x801166c5
80107098:	0f b6 05 c5 66 11 80 	movzbl 0x801166c5,%eax
8010709f:	83 e0 ef             	and    $0xffffffef,%eax
801070a2:	a2 c5 66 11 80       	mov    %al,0x801166c5
801070a7:	0f b6 05 c5 66 11 80 	movzbl 0x801166c5,%eax
801070ae:	83 c8 60             	or     $0x60,%eax
801070b1:	a2 c5 66 11 80       	mov    %al,0x801166c5
801070b6:	0f b6 05 c5 66 11 80 	movzbl 0x801166c5,%eax
801070bd:	83 c8 80             	or     $0xffffff80,%eax
801070c0:	a2 c5 66 11 80       	mov    %al,0x801166c5
801070c5:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
801070ca:	c1 e8 10             	shr    $0x10,%eax
801070cd:	66 a3 c6 66 11 80    	mov    %ax,0x801166c6

  initlock(&tickslock, "time");
801070d3:	83 ec 08             	sub    $0x8,%esp
801070d6:	68 f8 94 10 80       	push   $0x801094f8
801070db:	68 80 64 11 80       	push   $0x80116480
801070e0:	e8 d5 e6 ff ff       	call   801057ba <initlock>
801070e5:	83 c4 10             	add    $0x10,%esp
}
801070e8:	90                   	nop
801070e9:	c9                   	leave  
801070ea:	c3                   	ret    

801070eb <idtinit>:

void
idtinit(void)
{
801070eb:	55                   	push   %ebp
801070ec:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801070ee:	68 00 08 00 00       	push   $0x800
801070f3:	68 c0 64 11 80       	push   $0x801164c0
801070f8:	e8 3d fe ff ff       	call   80106f3a <lidt>
801070fd:	83 c4 08             	add    $0x8,%esp
}
80107100:	90                   	nop
80107101:	c9                   	leave  
80107102:	c3                   	ret    

80107103 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107103:	55                   	push   %ebp
80107104:	89 e5                	mov    %esp,%ebp
80107106:	57                   	push   %edi
80107107:	56                   	push   %esi
80107108:	53                   	push   %ebx
80107109:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
8010710c:	8b 45 08             	mov    0x8(%ebp),%eax
8010710f:	8b 40 30             	mov    0x30(%eax),%eax
80107112:	83 f8 40             	cmp    $0x40,%eax
80107115:	75 3e                	jne    80107155 <trap+0x52>
    if(proc->killed)
80107117:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010711d:	8b 40 24             	mov    0x24(%eax),%eax
80107120:	85 c0                	test   %eax,%eax
80107122:	74 05                	je     80107129 <trap+0x26>
      exit();
80107124:	e8 9a d8 ff ff       	call   801049c3 <exit>
    proc->tf = tf;
80107129:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010712f:	8b 55 08             	mov    0x8(%ebp),%edx
80107132:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107135:	e8 e0 ec ff ff       	call   80105e1a <syscall>
    if(proc->killed)
8010713a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107140:	8b 40 24             	mov    0x24(%eax),%eax
80107143:	85 c0                	test   %eax,%eax
80107145:	0f 84 76 03 00 00    	je     801074c1 <trap+0x3be>
      exit();
8010714b:	e8 73 d8 ff ff       	call   801049c3 <exit>
    return;
80107150:	e9 6c 03 00 00       	jmp    801074c1 <trap+0x3be>
  }

  switch(tf->trapno){
80107155:	8b 45 08             	mov    0x8(%ebp),%eax
80107158:	8b 40 30             	mov    0x30(%eax),%eax
8010715b:	83 e8 20             	sub    $0x20,%eax
8010715e:	83 f8 1f             	cmp    $0x1f,%eax
80107161:	0f 87 c0 00 00 00    	ja     80107227 <trap+0x124>
80107167:	8b 04 85 38 96 10 80 	mov    -0x7fef69c8(,%eax,4),%eax
8010716e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80107170:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107176:	0f b6 00             	movzbl (%eax),%eax
80107179:	84 c0                	test   %al,%al
8010717b:	75 3d                	jne    801071ba <trap+0xb7>
      acquire(&tickslock);
8010717d:	83 ec 0c             	sub    $0xc,%esp
80107180:	68 80 64 11 80       	push   $0x80116480
80107185:	e8 52 e6 ff ff       	call   801057dc <acquire>
8010718a:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010718d:	a1 c0 6c 11 80       	mov    0x80116cc0,%eax
80107192:	83 c0 01             	add    $0x1,%eax
80107195:	a3 c0 6c 11 80       	mov    %eax,0x80116cc0
      wakeup(&ticks);
8010719a:	83 ec 0c             	sub    $0xc,%esp
8010719d:	68 c0 6c 11 80       	push   $0x80116cc0
801071a2:	e8 f3 dd ff ff       	call   80104f9a <wakeup>
801071a7:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801071aa:	83 ec 0c             	sub    $0xc,%esp
801071ad:	68 80 64 11 80       	push   $0x80116480
801071b2:	e8 8c e6 ff ff       	call   80105843 <release>
801071b7:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801071ba:	e8 d3 bd ff ff       	call   80102f92 <lapiceoi>
    break;
801071bf:	e9 ff 01 00 00       	jmp    801073c3 <trap+0x2c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801071c4:	e8 dc b5 ff ff       	call   801027a5 <ideintr>
    lapiceoi();
801071c9:	e8 c4 bd ff ff       	call   80102f92 <lapiceoi>
    break;
801071ce:	e9 f0 01 00 00       	jmp    801073c3 <trap+0x2c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801071d3:	e8 bc bb ff ff       	call   80102d94 <kbdintr>
    lapiceoi();
801071d8:	e8 b5 bd ff ff       	call   80102f92 <lapiceoi>
    break;
801071dd:	e9 e1 01 00 00       	jmp    801073c3 <trap+0x2c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801071e2:	e8 bb 04 00 00       	call   801076a2 <uartintr>
    lapiceoi();
801071e7:	e8 a6 bd ff ff       	call   80102f92 <lapiceoi>
    break;
801071ec:	e9 d2 01 00 00       	jmp    801073c3 <trap+0x2c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801071f1:	8b 45 08             	mov    0x8(%ebp),%eax
801071f4:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801071f7:	8b 45 08             	mov    0x8(%ebp),%eax
801071fa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801071fe:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107201:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107207:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010720a:	0f b6 c0             	movzbl %al,%eax
8010720d:	51                   	push   %ecx
8010720e:	52                   	push   %edx
8010720f:	50                   	push   %eax
80107210:	68 00 95 10 80       	push   $0x80109500
80107215:	e8 ac 91 ff ff       	call   801003c6 <cprintf>
8010721a:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010721d:	e8 70 bd ff ff       	call   80102f92 <lapiceoi>
    break;
80107222:	e9 9c 01 00 00       	jmp    801073c3 <trap+0x2c0>

  //PAGEBREAK: 13
  //if it is about accessing an unassigned page, it is assigned on demand! WIP

  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107227:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010722d:	85 c0                	test   %eax,%eax
8010722f:	74 11                	je     80107242 <trap+0x13f>
80107231:	8b 45 08             	mov    0x8(%ebp),%eax
80107234:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107238:	0f b7 c0             	movzwl %ax,%eax
8010723b:	83 e0 03             	and    $0x3,%eax
8010723e:	85 c0                	test   %eax,%eax
80107240:	75 40                	jne    80107282 <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107242:	e8 1d fd ff ff       	call   80106f64 <rcr2>
80107247:	89 c3                	mov    %eax,%ebx
80107249:	8b 45 08             	mov    0x8(%ebp),%eax
8010724c:	8b 48 38             	mov    0x38(%eax),%ecx
      tf->trapno, cpu->id, tf->eip, rcr2());
8010724f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107255:	0f b6 00             	movzbl (%eax),%eax
  //if it is about accessing an unassigned page, it is assigned on demand! WIP

  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107258:	0f b6 d0             	movzbl %al,%edx
8010725b:	8b 45 08             	mov    0x8(%ebp),%eax
8010725e:	8b 40 30             	mov    0x30(%eax),%eax
80107261:	83 ec 0c             	sub    $0xc,%esp
80107264:	53                   	push   %ebx
80107265:	51                   	push   %ecx
80107266:	52                   	push   %edx
80107267:	50                   	push   %eax
80107268:	68 24 95 10 80       	push   $0x80109524
8010726d:	e8 54 91 ff ff       	call   801003c6 <cprintf>
80107272:	83 c4 20             	add    $0x20,%esp
      tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107275:	83 ec 0c             	sub    $0xc,%esp
80107278:	68 56 95 10 80       	push   $0x80109556
8010727d:	e8 e4 92 ff ff       	call   80100566 <panic>
    }

    if(proc != 0 && tf->trapno == T_PGFLT){
80107282:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107288:	85 c0                	test   %eax,%eax
8010728a:	0f 84 d5 00 00 00    	je     80107365 <trap+0x262>
80107290:	8b 45 08             	mov    0x8(%ebp),%eax
80107293:	8b 40 30             	mov    0x30(%eax),%eax
80107296:	83 f8 0e             	cmp    $0xe,%eax
80107299:	0f 85 c6 00 00 00    	jne    80107365 <trap+0x262>
      uint cr2 = rcr2();
8010729f:	e8 c0 fc ff ff       	call   80106f64 <rcr2>
801072a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint basepgaddr;
      if(cr2 >= proc->topstack && cr2 < proc->topstack+ MAXSTACKPAGES*PGSIZE ){
801072a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072ad:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801072b3:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801072b6:	0f 87 a9 00 00 00    	ja     80107365 <trap+0x262>
801072bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072c2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801072c8:	05 00 50 00 00       	add    $0x5000,%eax
801072cd:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801072d0:	0f 86 8f 00 00 00    	jbe    80107365 <trap+0x262>
          cprintf("rcr2 : %d\n proc->topstack: %d",cr2,proc->topstack);
801072d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072dc:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801072e2:	83 ec 04             	sub    $0x4,%esp
801072e5:	50                   	push   %eax
801072e6:	ff 75 e4             	pushl  -0x1c(%ebp)
801072e9:	68 5b 95 10 80       	push   $0x8010955b
801072ee:	e8 d3 90 ff ff       	call   801003c6 <cprintf>
801072f3:	83 c4 10             	add    $0x10,%esp
          cprintf("trato de acceder fuera del limite del stack\n");
801072f6:	83 ec 0c             	sub    $0xc,%esp
801072f9:	68 7c 95 10 80       	push   $0x8010957c
801072fe:	e8 c3 90 ff ff       	call   801003c6 <cprintf>
80107303:	83 c4 10             	add    $0x10,%esp

        cprintf("rcr2 : %d\n proc->topstack: %d",cr2,proc->topstack);
80107306:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010730c:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80107312:	83 ec 04             	sub    $0x4,%esp
80107315:	50                   	push   %eax
80107316:	ff 75 e4             	pushl  -0x1c(%ebp)
80107319:	68 5b 95 10 80       	push   $0x8010955b
8010731e:	e8 a3 90 ff ff       	call   801003c6 <cprintf>
80107323:	83 c4 10             	add    $0x10,%esp
        cprintf("trato de acceder fuera del las paginas allocadas, alloca bajo demanda\n");
80107326:	83 ec 0c             	sub    $0xc,%esp
80107329:	68 ac 95 10 80       	push   $0x801095ac
8010732e:	e8 93 90 ff ff       	call   801003c6 <cprintf>
80107333:	83 c4 10             	add    $0x10,%esp
        basepgaddr=PGROUNDDOWN(cr2);
80107336:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107339:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010733e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE);
80107341:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107344:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
8010734a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107350:	8b 40 04             	mov    0x4(%eax),%eax
80107353:	83 ec 04             	sub    $0x4,%esp
80107356:	52                   	push   %edx
80107357:	ff 75 e0             	pushl  -0x20(%ebp)
8010735a:	50                   	push   %eax
8010735b:	e8 96 17 00 00       	call   80108af6 <allocuvm>
80107360:	83 c4 10             	add    $0x10,%esp
        break;
80107363:	eb 5e                	jmp    801073c3 <trap+0x2c0>
      }

    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107365:	e8 fa fb ff ff       	call   80106f64 <rcr2>
8010736a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010736d:	8b 45 08             	mov    0x8(%ebp),%eax
80107370:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107373:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107379:	0f b6 00             	movzbl (%eax),%eax
        break;
      }

    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010737c:	0f b6 d8             	movzbl %al,%ebx
8010737f:	8b 45 08             	mov    0x8(%ebp),%eax
80107382:	8b 48 34             	mov    0x34(%eax),%ecx
80107385:	8b 45 08             	mov    0x8(%ebp),%eax
80107388:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
8010738b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107391:	8d 78 6c             	lea    0x6c(%eax),%edi
80107394:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
        break;
      }

    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010739a:	8b 40 10             	mov    0x10(%eax),%eax
8010739d:	ff 75 d4             	pushl  -0x2c(%ebp)
801073a0:	56                   	push   %esi
801073a1:	53                   	push   %ebx
801073a2:	51                   	push   %ecx
801073a3:	52                   	push   %edx
801073a4:	57                   	push   %edi
801073a5:	50                   	push   %eax
801073a6:	68 f4 95 10 80       	push   $0x801095f4
801073ab:	e8 16 90 ff ff       	call   801003c6 <cprintf>
801073b0:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
801073b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073b9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801073c0:	eb 01                	jmp    801073c3 <trap+0x2c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801073c2:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801073c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073c9:	85 c0                	test   %eax,%eax
801073cb:	74 24                	je     801073f1 <trap+0x2ee>
801073cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073d3:	8b 40 24             	mov    0x24(%eax),%eax
801073d6:	85 c0                	test   %eax,%eax
801073d8:	74 17                	je     801073f1 <trap+0x2ee>
801073da:	8b 45 08             	mov    0x8(%ebp),%eax
801073dd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801073e1:	0f b7 c0             	movzwl %ax,%eax
801073e4:	83 e0 03             	and    $0x3,%eax
801073e7:	83 f8 03             	cmp    $0x3,%eax
801073ea:	75 05                	jne    801073f1 <trap+0x2ee>
    exit();
801073ec:	e8 d2 d5 ff ff       	call   801049c3 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
801073f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073f7:	85 c0                	test   %eax,%eax
801073f9:	0f 84 92 00 00 00    	je     80107491 <trap+0x38e>
801073ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107405:	8b 40 0c             	mov    0xc(%eax),%eax
80107408:	83 f8 04             	cmp    $0x4,%eax
8010740b:	0f 85 80 00 00 00    	jne    80107491 <trap+0x38e>
80107411:	8b 45 08             	mov    0x8(%ebp),%eax
80107414:	8b 40 30             	mov    0x30(%eax),%eax
80107417:	83 f8 20             	cmp    $0x20,%eax
8010741a:	75 75                	jne    80107491 <trap+0x38e>
    proc->ticks++;
8010741c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107422:	0f b7 50 7c          	movzwl 0x7c(%eax),%edx
80107426:	83 c2 01             	add    $0x1,%edx
80107429:	66 89 50 7c          	mov    %dx,0x7c(%eax)
    if(proc->ticks % TIMESLICE==0){
8010742d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107433:	0f b7 48 7c          	movzwl 0x7c(%eax),%ecx
80107437:	0f b7 c1             	movzwl %cx,%eax
8010743a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
80107440:	c1 e8 10             	shr    $0x10,%eax
80107443:	89 c2                	mov    %eax,%edx
80107445:	66 c1 ea 05          	shr    $0x5,%dx
80107449:	89 d0                	mov    %edx,%eax
8010744b:	c1 e0 02             	shl    $0x2,%eax
8010744e:	01 d0                	add    %edx,%eax
80107450:	c1 e0 03             	shl    $0x3,%eax
80107453:	29 c1                	sub    %eax,%ecx
80107455:	89 ca                	mov    %ecx,%edx
80107457:	66 85 d2             	test   %dx,%dx
8010745a:	75 11                	jne    8010746d <trap+0x36a>
      //cprintf("proceso pid=%d ejecuta el yield en el tick %d \n",proc->pid,proc->ticks);
      proc->ticks=0;
8010745c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107462:	66 c7 40 7c 00 00    	movw   $0x0,0x7c(%eax)
      yield();
80107468:	e8 76 d9 ff ff       	call   80104de3 <yield>
    }
    if(ticks % TICKSFORAGING ==0){
8010746d:	8b 0d c0 6c 11 80    	mov    0x80116cc0,%ecx
80107473:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
80107478:	89 c8                	mov    %ecx,%eax
8010747a:	f7 e2                	mul    %edx
8010747c:	89 d0                	mov    %edx,%eax
8010747e:	c1 e8 05             	shr    $0x5,%eax
80107481:	6b c0 64             	imul   $0x64,%eax,%eax
80107484:	29 c1                	sub    %eax,%ecx
80107486:	89 c8                	mov    %ecx,%eax
80107488:	85 c0                	test   %eax,%eax
8010748a:	75 05                	jne    80107491 <trap+0x38e>
      //cprintf("ticks = %d pid %d\n",ticks,proc->pid);
      aging();
8010748c:	e8 59 dd ff ff       	call   801051ea <aging>
    }

  }
  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107491:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107497:	85 c0                	test   %eax,%eax
80107499:	74 27                	je     801074c2 <trap+0x3bf>
8010749b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074a1:	8b 40 24             	mov    0x24(%eax),%eax
801074a4:	85 c0                	test   %eax,%eax
801074a6:	74 1a                	je     801074c2 <trap+0x3bf>
801074a8:	8b 45 08             	mov    0x8(%ebp),%eax
801074ab:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801074af:	0f b7 c0             	movzwl %ax,%eax
801074b2:	83 e0 03             	and    $0x3,%eax
801074b5:	83 f8 03             	cmp    $0x3,%eax
801074b8:	75 08                	jne    801074c2 <trap+0x3bf>
    exit();
801074ba:	e8 04 d5 ff ff       	call   801049c3 <exit>
801074bf:	eb 01                	jmp    801074c2 <trap+0x3bf>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801074c1:	90                   	nop

  }
  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801074c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801074c5:	5b                   	pop    %ebx
801074c6:	5e                   	pop    %esi
801074c7:	5f                   	pop    %edi
801074c8:	5d                   	pop    %ebp
801074c9:	c3                   	ret    

801074ca <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801074ca:	55                   	push   %ebp
801074cb:	89 e5                	mov    %esp,%ebp
801074cd:	83 ec 14             	sub    $0x14,%esp
801074d0:	8b 45 08             	mov    0x8(%ebp),%eax
801074d3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801074d7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801074db:	89 c2                	mov    %eax,%edx
801074dd:	ec                   	in     (%dx),%al
801074de:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801074e1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801074e5:	c9                   	leave  
801074e6:	c3                   	ret    

801074e7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801074e7:	55                   	push   %ebp
801074e8:	89 e5                	mov    %esp,%ebp
801074ea:	83 ec 08             	sub    $0x8,%esp
801074ed:	8b 55 08             	mov    0x8(%ebp),%edx
801074f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801074f3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801074f7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801074fa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801074fe:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107502:	ee                   	out    %al,(%dx)
}
80107503:	90                   	nop
80107504:	c9                   	leave  
80107505:	c3                   	ret    

80107506 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107506:	55                   	push   %ebp
80107507:	89 e5                	mov    %esp,%ebp
80107509:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010750c:	6a 00                	push   $0x0
8010750e:	68 fa 03 00 00       	push   $0x3fa
80107513:	e8 cf ff ff ff       	call   801074e7 <outb>
80107518:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010751b:	68 80 00 00 00       	push   $0x80
80107520:	68 fb 03 00 00       	push   $0x3fb
80107525:	e8 bd ff ff ff       	call   801074e7 <outb>
8010752a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010752d:	6a 0c                	push   $0xc
8010752f:	68 f8 03 00 00       	push   $0x3f8
80107534:	e8 ae ff ff ff       	call   801074e7 <outb>
80107539:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010753c:	6a 00                	push   $0x0
8010753e:	68 f9 03 00 00       	push   $0x3f9
80107543:	e8 9f ff ff ff       	call   801074e7 <outb>
80107548:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010754b:	6a 03                	push   $0x3
8010754d:	68 fb 03 00 00       	push   $0x3fb
80107552:	e8 90 ff ff ff       	call   801074e7 <outb>
80107557:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010755a:	6a 00                	push   $0x0
8010755c:	68 fc 03 00 00       	push   $0x3fc
80107561:	e8 81 ff ff ff       	call   801074e7 <outb>
80107566:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107569:	6a 01                	push   $0x1
8010756b:	68 f9 03 00 00       	push   $0x3f9
80107570:	e8 72 ff ff ff       	call   801074e7 <outb>
80107575:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107578:	68 fd 03 00 00       	push   $0x3fd
8010757d:	e8 48 ff ff ff       	call   801074ca <inb>
80107582:	83 c4 04             	add    $0x4,%esp
80107585:	3c ff                	cmp    $0xff,%al
80107587:	74 6e                	je     801075f7 <uartinit+0xf1>
    return;
  uart = 1;
80107589:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107590:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107593:	68 fa 03 00 00       	push   $0x3fa
80107598:	e8 2d ff ff ff       	call   801074ca <inb>
8010759d:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801075a0:	68 f8 03 00 00       	push   $0x3f8
801075a5:	e8 20 ff ff ff       	call   801074ca <inb>
801075aa:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
801075ad:	83 ec 0c             	sub    $0xc,%esp
801075b0:	6a 04                	push   $0x4
801075b2:	e8 f3 c8 ff ff       	call   80103eaa <picenable>
801075b7:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801075ba:	83 ec 08             	sub    $0x8,%esp
801075bd:	6a 00                	push   $0x0
801075bf:	6a 04                	push   $0x4
801075c1:	e8 81 b4 ff ff       	call   80102a47 <ioapicenable>
801075c6:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801075c9:	c7 45 f4 b8 96 10 80 	movl   $0x801096b8,-0xc(%ebp)
801075d0:	eb 19                	jmp    801075eb <uartinit+0xe5>
    uartputc(*p);
801075d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d5:	0f b6 00             	movzbl (%eax),%eax
801075d8:	0f be c0             	movsbl %al,%eax
801075db:	83 ec 0c             	sub    $0xc,%esp
801075de:	50                   	push   %eax
801075df:	e8 16 00 00 00       	call   801075fa <uartputc>
801075e4:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801075e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801075eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ee:	0f b6 00             	movzbl (%eax),%eax
801075f1:	84 c0                	test   %al,%al
801075f3:	75 dd                	jne    801075d2 <uartinit+0xcc>
801075f5:	eb 01                	jmp    801075f8 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801075f7:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801075f8:	c9                   	leave  
801075f9:	c3                   	ret    

801075fa <uartputc>:

void
uartputc(int c)
{
801075fa:	55                   	push   %ebp
801075fb:	89 e5                	mov    %esp,%ebp
801075fd:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107600:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107605:	85 c0                	test   %eax,%eax
80107607:	74 53                	je     8010765c <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107609:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107610:	eb 11                	jmp    80107623 <uartputc+0x29>
    microdelay(10);
80107612:	83 ec 0c             	sub    $0xc,%esp
80107615:	6a 0a                	push   $0xa
80107617:	e8 91 b9 ff ff       	call   80102fad <microdelay>
8010761c:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010761f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107623:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107627:	7f 1a                	jg     80107643 <uartputc+0x49>
80107629:	83 ec 0c             	sub    $0xc,%esp
8010762c:	68 fd 03 00 00       	push   $0x3fd
80107631:	e8 94 fe ff ff       	call   801074ca <inb>
80107636:	83 c4 10             	add    $0x10,%esp
80107639:	0f b6 c0             	movzbl %al,%eax
8010763c:	83 e0 20             	and    $0x20,%eax
8010763f:	85 c0                	test   %eax,%eax
80107641:	74 cf                	je     80107612 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107643:	8b 45 08             	mov    0x8(%ebp),%eax
80107646:	0f b6 c0             	movzbl %al,%eax
80107649:	83 ec 08             	sub    $0x8,%esp
8010764c:	50                   	push   %eax
8010764d:	68 f8 03 00 00       	push   $0x3f8
80107652:	e8 90 fe ff ff       	call   801074e7 <outb>
80107657:	83 c4 10             	add    $0x10,%esp
8010765a:	eb 01                	jmp    8010765d <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
8010765c:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
8010765d:	c9                   	leave  
8010765e:	c3                   	ret    

8010765f <uartgetc>:

static int
uartgetc(void)
{
8010765f:	55                   	push   %ebp
80107660:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107662:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107667:	85 c0                	test   %eax,%eax
80107669:	75 07                	jne    80107672 <uartgetc+0x13>
    return -1;
8010766b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107670:	eb 2e                	jmp    801076a0 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107672:	68 fd 03 00 00       	push   $0x3fd
80107677:	e8 4e fe ff ff       	call   801074ca <inb>
8010767c:	83 c4 04             	add    $0x4,%esp
8010767f:	0f b6 c0             	movzbl %al,%eax
80107682:	83 e0 01             	and    $0x1,%eax
80107685:	85 c0                	test   %eax,%eax
80107687:	75 07                	jne    80107690 <uartgetc+0x31>
    return -1;
80107689:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010768e:	eb 10                	jmp    801076a0 <uartgetc+0x41>
  return inb(COM1+0);
80107690:	68 f8 03 00 00       	push   $0x3f8
80107695:	e8 30 fe ff ff       	call   801074ca <inb>
8010769a:	83 c4 04             	add    $0x4,%esp
8010769d:	0f b6 c0             	movzbl %al,%eax
}
801076a0:	c9                   	leave  
801076a1:	c3                   	ret    

801076a2 <uartintr>:

void
uartintr(void)
{
801076a2:	55                   	push   %ebp
801076a3:	89 e5                	mov    %esp,%ebp
801076a5:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801076a8:	83 ec 0c             	sub    $0xc,%esp
801076ab:	68 5f 76 10 80       	push   $0x8010765f
801076b0:	e8 28 91 ff ff       	call   801007dd <consoleintr>
801076b5:	83 c4 10             	add    $0x10,%esp
}
801076b8:	90                   	nop
801076b9:	c9                   	leave  
801076ba:	c3                   	ret    

801076bb <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801076bb:	6a 00                	push   $0x0
  pushl $0
801076bd:	6a 00                	push   $0x0
  jmp alltraps
801076bf:	e9 4b f8 ff ff       	jmp    80106f0f <alltraps>

801076c4 <vector1>:
.globl vector1
vector1:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $1
801076c6:	6a 01                	push   $0x1
  jmp alltraps
801076c8:	e9 42 f8 ff ff       	jmp    80106f0f <alltraps>

801076cd <vector2>:
.globl vector2
vector2:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $2
801076cf:	6a 02                	push   $0x2
  jmp alltraps
801076d1:	e9 39 f8 ff ff       	jmp    80106f0f <alltraps>

801076d6 <vector3>:
.globl vector3
vector3:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $3
801076d8:	6a 03                	push   $0x3
  jmp alltraps
801076da:	e9 30 f8 ff ff       	jmp    80106f0f <alltraps>

801076df <vector4>:
.globl vector4
vector4:
  pushl $0
801076df:	6a 00                	push   $0x0
  pushl $4
801076e1:	6a 04                	push   $0x4
  jmp alltraps
801076e3:	e9 27 f8 ff ff       	jmp    80106f0f <alltraps>

801076e8 <vector5>:
.globl vector5
vector5:
  pushl $0
801076e8:	6a 00                	push   $0x0
  pushl $5
801076ea:	6a 05                	push   $0x5
  jmp alltraps
801076ec:	e9 1e f8 ff ff       	jmp    80106f0f <alltraps>

801076f1 <vector6>:
.globl vector6
vector6:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $6
801076f3:	6a 06                	push   $0x6
  jmp alltraps
801076f5:	e9 15 f8 ff ff       	jmp    80106f0f <alltraps>

801076fa <vector7>:
.globl vector7
vector7:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $7
801076fc:	6a 07                	push   $0x7
  jmp alltraps
801076fe:	e9 0c f8 ff ff       	jmp    80106f0f <alltraps>

80107703 <vector8>:
.globl vector8
vector8:
  pushl $8
80107703:	6a 08                	push   $0x8
  jmp alltraps
80107705:	e9 05 f8 ff ff       	jmp    80106f0f <alltraps>

8010770a <vector9>:
.globl vector9
vector9:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $9
8010770c:	6a 09                	push   $0x9
  jmp alltraps
8010770e:	e9 fc f7 ff ff       	jmp    80106f0f <alltraps>

80107713 <vector10>:
.globl vector10
vector10:
  pushl $10
80107713:	6a 0a                	push   $0xa
  jmp alltraps
80107715:	e9 f5 f7 ff ff       	jmp    80106f0f <alltraps>

8010771a <vector11>:
.globl vector11
vector11:
  pushl $11
8010771a:	6a 0b                	push   $0xb
  jmp alltraps
8010771c:	e9 ee f7 ff ff       	jmp    80106f0f <alltraps>

80107721 <vector12>:
.globl vector12
vector12:
  pushl $12
80107721:	6a 0c                	push   $0xc
  jmp alltraps
80107723:	e9 e7 f7 ff ff       	jmp    80106f0f <alltraps>

80107728 <vector13>:
.globl vector13
vector13:
  pushl $13
80107728:	6a 0d                	push   $0xd
  jmp alltraps
8010772a:	e9 e0 f7 ff ff       	jmp    80106f0f <alltraps>

8010772f <vector14>:
.globl vector14
vector14:
  pushl $14
8010772f:	6a 0e                	push   $0xe
  jmp alltraps
80107731:	e9 d9 f7 ff ff       	jmp    80106f0f <alltraps>

80107736 <vector15>:
.globl vector15
vector15:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $15
80107738:	6a 0f                	push   $0xf
  jmp alltraps
8010773a:	e9 d0 f7 ff ff       	jmp    80106f0f <alltraps>

8010773f <vector16>:
.globl vector16
vector16:
  pushl $0
8010773f:	6a 00                	push   $0x0
  pushl $16
80107741:	6a 10                	push   $0x10
  jmp alltraps
80107743:	e9 c7 f7 ff ff       	jmp    80106f0f <alltraps>

80107748 <vector17>:
.globl vector17
vector17:
  pushl $17
80107748:	6a 11                	push   $0x11
  jmp alltraps
8010774a:	e9 c0 f7 ff ff       	jmp    80106f0f <alltraps>

8010774f <vector18>:
.globl vector18
vector18:
  pushl $0
8010774f:	6a 00                	push   $0x0
  pushl $18
80107751:	6a 12                	push   $0x12
  jmp alltraps
80107753:	e9 b7 f7 ff ff       	jmp    80106f0f <alltraps>

80107758 <vector19>:
.globl vector19
vector19:
  pushl $0
80107758:	6a 00                	push   $0x0
  pushl $19
8010775a:	6a 13                	push   $0x13
  jmp alltraps
8010775c:	e9 ae f7 ff ff       	jmp    80106f0f <alltraps>

80107761 <vector20>:
.globl vector20
vector20:
  pushl $0
80107761:	6a 00                	push   $0x0
  pushl $20
80107763:	6a 14                	push   $0x14
  jmp alltraps
80107765:	e9 a5 f7 ff ff       	jmp    80106f0f <alltraps>

8010776a <vector21>:
.globl vector21
vector21:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $21
8010776c:	6a 15                	push   $0x15
  jmp alltraps
8010776e:	e9 9c f7 ff ff       	jmp    80106f0f <alltraps>

80107773 <vector22>:
.globl vector22
vector22:
  pushl $0
80107773:	6a 00                	push   $0x0
  pushl $22
80107775:	6a 16                	push   $0x16
  jmp alltraps
80107777:	e9 93 f7 ff ff       	jmp    80106f0f <alltraps>

8010777c <vector23>:
.globl vector23
vector23:
  pushl $0
8010777c:	6a 00                	push   $0x0
  pushl $23
8010777e:	6a 17                	push   $0x17
  jmp alltraps
80107780:	e9 8a f7 ff ff       	jmp    80106f0f <alltraps>

80107785 <vector24>:
.globl vector24
vector24:
  pushl $0
80107785:	6a 00                	push   $0x0
  pushl $24
80107787:	6a 18                	push   $0x18
  jmp alltraps
80107789:	e9 81 f7 ff ff       	jmp    80106f0f <alltraps>

8010778e <vector25>:
.globl vector25
vector25:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $25
80107790:	6a 19                	push   $0x19
  jmp alltraps
80107792:	e9 78 f7 ff ff       	jmp    80106f0f <alltraps>

80107797 <vector26>:
.globl vector26
vector26:
  pushl $0
80107797:	6a 00                	push   $0x0
  pushl $26
80107799:	6a 1a                	push   $0x1a
  jmp alltraps
8010779b:	e9 6f f7 ff ff       	jmp    80106f0f <alltraps>

801077a0 <vector27>:
.globl vector27
vector27:
  pushl $0
801077a0:	6a 00                	push   $0x0
  pushl $27
801077a2:	6a 1b                	push   $0x1b
  jmp alltraps
801077a4:	e9 66 f7 ff ff       	jmp    80106f0f <alltraps>

801077a9 <vector28>:
.globl vector28
vector28:
  pushl $0
801077a9:	6a 00                	push   $0x0
  pushl $28
801077ab:	6a 1c                	push   $0x1c
  jmp alltraps
801077ad:	e9 5d f7 ff ff       	jmp    80106f0f <alltraps>

801077b2 <vector29>:
.globl vector29
vector29:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $29
801077b4:	6a 1d                	push   $0x1d
  jmp alltraps
801077b6:	e9 54 f7 ff ff       	jmp    80106f0f <alltraps>

801077bb <vector30>:
.globl vector30
vector30:
  pushl $0
801077bb:	6a 00                	push   $0x0
  pushl $30
801077bd:	6a 1e                	push   $0x1e
  jmp alltraps
801077bf:	e9 4b f7 ff ff       	jmp    80106f0f <alltraps>

801077c4 <vector31>:
.globl vector31
vector31:
  pushl $0
801077c4:	6a 00                	push   $0x0
  pushl $31
801077c6:	6a 1f                	push   $0x1f
  jmp alltraps
801077c8:	e9 42 f7 ff ff       	jmp    80106f0f <alltraps>

801077cd <vector32>:
.globl vector32
vector32:
  pushl $0
801077cd:	6a 00                	push   $0x0
  pushl $32
801077cf:	6a 20                	push   $0x20
  jmp alltraps
801077d1:	e9 39 f7 ff ff       	jmp    80106f0f <alltraps>

801077d6 <vector33>:
.globl vector33
vector33:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $33
801077d8:	6a 21                	push   $0x21
  jmp alltraps
801077da:	e9 30 f7 ff ff       	jmp    80106f0f <alltraps>

801077df <vector34>:
.globl vector34
vector34:
  pushl $0
801077df:	6a 00                	push   $0x0
  pushl $34
801077e1:	6a 22                	push   $0x22
  jmp alltraps
801077e3:	e9 27 f7 ff ff       	jmp    80106f0f <alltraps>

801077e8 <vector35>:
.globl vector35
vector35:
  pushl $0
801077e8:	6a 00                	push   $0x0
  pushl $35
801077ea:	6a 23                	push   $0x23
  jmp alltraps
801077ec:	e9 1e f7 ff ff       	jmp    80106f0f <alltraps>

801077f1 <vector36>:
.globl vector36
vector36:
  pushl $0
801077f1:	6a 00                	push   $0x0
  pushl $36
801077f3:	6a 24                	push   $0x24
  jmp alltraps
801077f5:	e9 15 f7 ff ff       	jmp    80106f0f <alltraps>

801077fa <vector37>:
.globl vector37
vector37:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $37
801077fc:	6a 25                	push   $0x25
  jmp alltraps
801077fe:	e9 0c f7 ff ff       	jmp    80106f0f <alltraps>

80107803 <vector38>:
.globl vector38
vector38:
  pushl $0
80107803:	6a 00                	push   $0x0
  pushl $38
80107805:	6a 26                	push   $0x26
  jmp alltraps
80107807:	e9 03 f7 ff ff       	jmp    80106f0f <alltraps>

8010780c <vector39>:
.globl vector39
vector39:
  pushl $0
8010780c:	6a 00                	push   $0x0
  pushl $39
8010780e:	6a 27                	push   $0x27
  jmp alltraps
80107810:	e9 fa f6 ff ff       	jmp    80106f0f <alltraps>

80107815 <vector40>:
.globl vector40
vector40:
  pushl $0
80107815:	6a 00                	push   $0x0
  pushl $40
80107817:	6a 28                	push   $0x28
  jmp alltraps
80107819:	e9 f1 f6 ff ff       	jmp    80106f0f <alltraps>

8010781e <vector41>:
.globl vector41
vector41:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $41
80107820:	6a 29                	push   $0x29
  jmp alltraps
80107822:	e9 e8 f6 ff ff       	jmp    80106f0f <alltraps>

80107827 <vector42>:
.globl vector42
vector42:
  pushl $0
80107827:	6a 00                	push   $0x0
  pushl $42
80107829:	6a 2a                	push   $0x2a
  jmp alltraps
8010782b:	e9 df f6 ff ff       	jmp    80106f0f <alltraps>

80107830 <vector43>:
.globl vector43
vector43:
  pushl $0
80107830:	6a 00                	push   $0x0
  pushl $43
80107832:	6a 2b                	push   $0x2b
  jmp alltraps
80107834:	e9 d6 f6 ff ff       	jmp    80106f0f <alltraps>

80107839 <vector44>:
.globl vector44
vector44:
  pushl $0
80107839:	6a 00                	push   $0x0
  pushl $44
8010783b:	6a 2c                	push   $0x2c
  jmp alltraps
8010783d:	e9 cd f6 ff ff       	jmp    80106f0f <alltraps>

80107842 <vector45>:
.globl vector45
vector45:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $45
80107844:	6a 2d                	push   $0x2d
  jmp alltraps
80107846:	e9 c4 f6 ff ff       	jmp    80106f0f <alltraps>

8010784b <vector46>:
.globl vector46
vector46:
  pushl $0
8010784b:	6a 00                	push   $0x0
  pushl $46
8010784d:	6a 2e                	push   $0x2e
  jmp alltraps
8010784f:	e9 bb f6 ff ff       	jmp    80106f0f <alltraps>

80107854 <vector47>:
.globl vector47
vector47:
  pushl $0
80107854:	6a 00                	push   $0x0
  pushl $47
80107856:	6a 2f                	push   $0x2f
  jmp alltraps
80107858:	e9 b2 f6 ff ff       	jmp    80106f0f <alltraps>

8010785d <vector48>:
.globl vector48
vector48:
  pushl $0
8010785d:	6a 00                	push   $0x0
  pushl $48
8010785f:	6a 30                	push   $0x30
  jmp alltraps
80107861:	e9 a9 f6 ff ff       	jmp    80106f0f <alltraps>

80107866 <vector49>:
.globl vector49
vector49:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $49
80107868:	6a 31                	push   $0x31
  jmp alltraps
8010786a:	e9 a0 f6 ff ff       	jmp    80106f0f <alltraps>

8010786f <vector50>:
.globl vector50
vector50:
  pushl $0
8010786f:	6a 00                	push   $0x0
  pushl $50
80107871:	6a 32                	push   $0x32
  jmp alltraps
80107873:	e9 97 f6 ff ff       	jmp    80106f0f <alltraps>

80107878 <vector51>:
.globl vector51
vector51:
  pushl $0
80107878:	6a 00                	push   $0x0
  pushl $51
8010787a:	6a 33                	push   $0x33
  jmp alltraps
8010787c:	e9 8e f6 ff ff       	jmp    80106f0f <alltraps>

80107881 <vector52>:
.globl vector52
vector52:
  pushl $0
80107881:	6a 00                	push   $0x0
  pushl $52
80107883:	6a 34                	push   $0x34
  jmp alltraps
80107885:	e9 85 f6 ff ff       	jmp    80106f0f <alltraps>

8010788a <vector53>:
.globl vector53
vector53:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $53
8010788c:	6a 35                	push   $0x35
  jmp alltraps
8010788e:	e9 7c f6 ff ff       	jmp    80106f0f <alltraps>

80107893 <vector54>:
.globl vector54
vector54:
  pushl $0
80107893:	6a 00                	push   $0x0
  pushl $54
80107895:	6a 36                	push   $0x36
  jmp alltraps
80107897:	e9 73 f6 ff ff       	jmp    80106f0f <alltraps>

8010789c <vector55>:
.globl vector55
vector55:
  pushl $0
8010789c:	6a 00                	push   $0x0
  pushl $55
8010789e:	6a 37                	push   $0x37
  jmp alltraps
801078a0:	e9 6a f6 ff ff       	jmp    80106f0f <alltraps>

801078a5 <vector56>:
.globl vector56
vector56:
  pushl $0
801078a5:	6a 00                	push   $0x0
  pushl $56
801078a7:	6a 38                	push   $0x38
  jmp alltraps
801078a9:	e9 61 f6 ff ff       	jmp    80106f0f <alltraps>

801078ae <vector57>:
.globl vector57
vector57:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $57
801078b0:	6a 39                	push   $0x39
  jmp alltraps
801078b2:	e9 58 f6 ff ff       	jmp    80106f0f <alltraps>

801078b7 <vector58>:
.globl vector58
vector58:
  pushl $0
801078b7:	6a 00                	push   $0x0
  pushl $58
801078b9:	6a 3a                	push   $0x3a
  jmp alltraps
801078bb:	e9 4f f6 ff ff       	jmp    80106f0f <alltraps>

801078c0 <vector59>:
.globl vector59
vector59:
  pushl $0
801078c0:	6a 00                	push   $0x0
  pushl $59
801078c2:	6a 3b                	push   $0x3b
  jmp alltraps
801078c4:	e9 46 f6 ff ff       	jmp    80106f0f <alltraps>

801078c9 <vector60>:
.globl vector60
vector60:
  pushl $0
801078c9:	6a 00                	push   $0x0
  pushl $60
801078cb:	6a 3c                	push   $0x3c
  jmp alltraps
801078cd:	e9 3d f6 ff ff       	jmp    80106f0f <alltraps>

801078d2 <vector61>:
.globl vector61
vector61:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $61
801078d4:	6a 3d                	push   $0x3d
  jmp alltraps
801078d6:	e9 34 f6 ff ff       	jmp    80106f0f <alltraps>

801078db <vector62>:
.globl vector62
vector62:
  pushl $0
801078db:	6a 00                	push   $0x0
  pushl $62
801078dd:	6a 3e                	push   $0x3e
  jmp alltraps
801078df:	e9 2b f6 ff ff       	jmp    80106f0f <alltraps>

801078e4 <vector63>:
.globl vector63
vector63:
  pushl $0
801078e4:	6a 00                	push   $0x0
  pushl $63
801078e6:	6a 3f                	push   $0x3f
  jmp alltraps
801078e8:	e9 22 f6 ff ff       	jmp    80106f0f <alltraps>

801078ed <vector64>:
.globl vector64
vector64:
  pushl $0
801078ed:	6a 00                	push   $0x0
  pushl $64
801078ef:	6a 40                	push   $0x40
  jmp alltraps
801078f1:	e9 19 f6 ff ff       	jmp    80106f0f <alltraps>

801078f6 <vector65>:
.globl vector65
vector65:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $65
801078f8:	6a 41                	push   $0x41
  jmp alltraps
801078fa:	e9 10 f6 ff ff       	jmp    80106f0f <alltraps>

801078ff <vector66>:
.globl vector66
vector66:
  pushl $0
801078ff:	6a 00                	push   $0x0
  pushl $66
80107901:	6a 42                	push   $0x42
  jmp alltraps
80107903:	e9 07 f6 ff ff       	jmp    80106f0f <alltraps>

80107908 <vector67>:
.globl vector67
vector67:
  pushl $0
80107908:	6a 00                	push   $0x0
  pushl $67
8010790a:	6a 43                	push   $0x43
  jmp alltraps
8010790c:	e9 fe f5 ff ff       	jmp    80106f0f <alltraps>

80107911 <vector68>:
.globl vector68
vector68:
  pushl $0
80107911:	6a 00                	push   $0x0
  pushl $68
80107913:	6a 44                	push   $0x44
  jmp alltraps
80107915:	e9 f5 f5 ff ff       	jmp    80106f0f <alltraps>

8010791a <vector69>:
.globl vector69
vector69:
  pushl $0
8010791a:	6a 00                	push   $0x0
  pushl $69
8010791c:	6a 45                	push   $0x45
  jmp alltraps
8010791e:	e9 ec f5 ff ff       	jmp    80106f0f <alltraps>

80107923 <vector70>:
.globl vector70
vector70:
  pushl $0
80107923:	6a 00                	push   $0x0
  pushl $70
80107925:	6a 46                	push   $0x46
  jmp alltraps
80107927:	e9 e3 f5 ff ff       	jmp    80106f0f <alltraps>

8010792c <vector71>:
.globl vector71
vector71:
  pushl $0
8010792c:	6a 00                	push   $0x0
  pushl $71
8010792e:	6a 47                	push   $0x47
  jmp alltraps
80107930:	e9 da f5 ff ff       	jmp    80106f0f <alltraps>

80107935 <vector72>:
.globl vector72
vector72:
  pushl $0
80107935:	6a 00                	push   $0x0
  pushl $72
80107937:	6a 48                	push   $0x48
  jmp alltraps
80107939:	e9 d1 f5 ff ff       	jmp    80106f0f <alltraps>

8010793e <vector73>:
.globl vector73
vector73:
  pushl $0
8010793e:	6a 00                	push   $0x0
  pushl $73
80107940:	6a 49                	push   $0x49
  jmp alltraps
80107942:	e9 c8 f5 ff ff       	jmp    80106f0f <alltraps>

80107947 <vector74>:
.globl vector74
vector74:
  pushl $0
80107947:	6a 00                	push   $0x0
  pushl $74
80107949:	6a 4a                	push   $0x4a
  jmp alltraps
8010794b:	e9 bf f5 ff ff       	jmp    80106f0f <alltraps>

80107950 <vector75>:
.globl vector75
vector75:
  pushl $0
80107950:	6a 00                	push   $0x0
  pushl $75
80107952:	6a 4b                	push   $0x4b
  jmp alltraps
80107954:	e9 b6 f5 ff ff       	jmp    80106f0f <alltraps>

80107959 <vector76>:
.globl vector76
vector76:
  pushl $0
80107959:	6a 00                	push   $0x0
  pushl $76
8010795b:	6a 4c                	push   $0x4c
  jmp alltraps
8010795d:	e9 ad f5 ff ff       	jmp    80106f0f <alltraps>

80107962 <vector77>:
.globl vector77
vector77:
  pushl $0
80107962:	6a 00                	push   $0x0
  pushl $77
80107964:	6a 4d                	push   $0x4d
  jmp alltraps
80107966:	e9 a4 f5 ff ff       	jmp    80106f0f <alltraps>

8010796b <vector78>:
.globl vector78
vector78:
  pushl $0
8010796b:	6a 00                	push   $0x0
  pushl $78
8010796d:	6a 4e                	push   $0x4e
  jmp alltraps
8010796f:	e9 9b f5 ff ff       	jmp    80106f0f <alltraps>

80107974 <vector79>:
.globl vector79
vector79:
  pushl $0
80107974:	6a 00                	push   $0x0
  pushl $79
80107976:	6a 4f                	push   $0x4f
  jmp alltraps
80107978:	e9 92 f5 ff ff       	jmp    80106f0f <alltraps>

8010797d <vector80>:
.globl vector80
vector80:
  pushl $0
8010797d:	6a 00                	push   $0x0
  pushl $80
8010797f:	6a 50                	push   $0x50
  jmp alltraps
80107981:	e9 89 f5 ff ff       	jmp    80106f0f <alltraps>

80107986 <vector81>:
.globl vector81
vector81:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $81
80107988:	6a 51                	push   $0x51
  jmp alltraps
8010798a:	e9 80 f5 ff ff       	jmp    80106f0f <alltraps>

8010798f <vector82>:
.globl vector82
vector82:
  pushl $0
8010798f:	6a 00                	push   $0x0
  pushl $82
80107991:	6a 52                	push   $0x52
  jmp alltraps
80107993:	e9 77 f5 ff ff       	jmp    80106f0f <alltraps>

80107998 <vector83>:
.globl vector83
vector83:
  pushl $0
80107998:	6a 00                	push   $0x0
  pushl $83
8010799a:	6a 53                	push   $0x53
  jmp alltraps
8010799c:	e9 6e f5 ff ff       	jmp    80106f0f <alltraps>

801079a1 <vector84>:
.globl vector84
vector84:
  pushl $0
801079a1:	6a 00                	push   $0x0
  pushl $84
801079a3:	6a 54                	push   $0x54
  jmp alltraps
801079a5:	e9 65 f5 ff ff       	jmp    80106f0f <alltraps>

801079aa <vector85>:
.globl vector85
vector85:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $85
801079ac:	6a 55                	push   $0x55
  jmp alltraps
801079ae:	e9 5c f5 ff ff       	jmp    80106f0f <alltraps>

801079b3 <vector86>:
.globl vector86
vector86:
  pushl $0
801079b3:	6a 00                	push   $0x0
  pushl $86
801079b5:	6a 56                	push   $0x56
  jmp alltraps
801079b7:	e9 53 f5 ff ff       	jmp    80106f0f <alltraps>

801079bc <vector87>:
.globl vector87
vector87:
  pushl $0
801079bc:	6a 00                	push   $0x0
  pushl $87
801079be:	6a 57                	push   $0x57
  jmp alltraps
801079c0:	e9 4a f5 ff ff       	jmp    80106f0f <alltraps>

801079c5 <vector88>:
.globl vector88
vector88:
  pushl $0
801079c5:	6a 00                	push   $0x0
  pushl $88
801079c7:	6a 58                	push   $0x58
  jmp alltraps
801079c9:	e9 41 f5 ff ff       	jmp    80106f0f <alltraps>

801079ce <vector89>:
.globl vector89
vector89:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $89
801079d0:	6a 59                	push   $0x59
  jmp alltraps
801079d2:	e9 38 f5 ff ff       	jmp    80106f0f <alltraps>

801079d7 <vector90>:
.globl vector90
vector90:
  pushl $0
801079d7:	6a 00                	push   $0x0
  pushl $90
801079d9:	6a 5a                	push   $0x5a
  jmp alltraps
801079db:	e9 2f f5 ff ff       	jmp    80106f0f <alltraps>

801079e0 <vector91>:
.globl vector91
vector91:
  pushl $0
801079e0:	6a 00                	push   $0x0
  pushl $91
801079e2:	6a 5b                	push   $0x5b
  jmp alltraps
801079e4:	e9 26 f5 ff ff       	jmp    80106f0f <alltraps>

801079e9 <vector92>:
.globl vector92
vector92:
  pushl $0
801079e9:	6a 00                	push   $0x0
  pushl $92
801079eb:	6a 5c                	push   $0x5c
  jmp alltraps
801079ed:	e9 1d f5 ff ff       	jmp    80106f0f <alltraps>

801079f2 <vector93>:
.globl vector93
vector93:
  pushl $0
801079f2:	6a 00                	push   $0x0
  pushl $93
801079f4:	6a 5d                	push   $0x5d
  jmp alltraps
801079f6:	e9 14 f5 ff ff       	jmp    80106f0f <alltraps>

801079fb <vector94>:
.globl vector94
vector94:
  pushl $0
801079fb:	6a 00                	push   $0x0
  pushl $94
801079fd:	6a 5e                	push   $0x5e
  jmp alltraps
801079ff:	e9 0b f5 ff ff       	jmp    80106f0f <alltraps>

80107a04 <vector95>:
.globl vector95
vector95:
  pushl $0
80107a04:	6a 00                	push   $0x0
  pushl $95
80107a06:	6a 5f                	push   $0x5f
  jmp alltraps
80107a08:	e9 02 f5 ff ff       	jmp    80106f0f <alltraps>

80107a0d <vector96>:
.globl vector96
vector96:
  pushl $0
80107a0d:	6a 00                	push   $0x0
  pushl $96
80107a0f:	6a 60                	push   $0x60
  jmp alltraps
80107a11:	e9 f9 f4 ff ff       	jmp    80106f0f <alltraps>

80107a16 <vector97>:
.globl vector97
vector97:
  pushl $0
80107a16:	6a 00                	push   $0x0
  pushl $97
80107a18:	6a 61                	push   $0x61
  jmp alltraps
80107a1a:	e9 f0 f4 ff ff       	jmp    80106f0f <alltraps>

80107a1f <vector98>:
.globl vector98
vector98:
  pushl $0
80107a1f:	6a 00                	push   $0x0
  pushl $98
80107a21:	6a 62                	push   $0x62
  jmp alltraps
80107a23:	e9 e7 f4 ff ff       	jmp    80106f0f <alltraps>

80107a28 <vector99>:
.globl vector99
vector99:
  pushl $0
80107a28:	6a 00                	push   $0x0
  pushl $99
80107a2a:	6a 63                	push   $0x63
  jmp alltraps
80107a2c:	e9 de f4 ff ff       	jmp    80106f0f <alltraps>

80107a31 <vector100>:
.globl vector100
vector100:
  pushl $0
80107a31:	6a 00                	push   $0x0
  pushl $100
80107a33:	6a 64                	push   $0x64
  jmp alltraps
80107a35:	e9 d5 f4 ff ff       	jmp    80106f0f <alltraps>

80107a3a <vector101>:
.globl vector101
vector101:
  pushl $0
80107a3a:	6a 00                	push   $0x0
  pushl $101
80107a3c:	6a 65                	push   $0x65
  jmp alltraps
80107a3e:	e9 cc f4 ff ff       	jmp    80106f0f <alltraps>

80107a43 <vector102>:
.globl vector102
vector102:
  pushl $0
80107a43:	6a 00                	push   $0x0
  pushl $102
80107a45:	6a 66                	push   $0x66
  jmp alltraps
80107a47:	e9 c3 f4 ff ff       	jmp    80106f0f <alltraps>

80107a4c <vector103>:
.globl vector103
vector103:
  pushl $0
80107a4c:	6a 00                	push   $0x0
  pushl $103
80107a4e:	6a 67                	push   $0x67
  jmp alltraps
80107a50:	e9 ba f4 ff ff       	jmp    80106f0f <alltraps>

80107a55 <vector104>:
.globl vector104
vector104:
  pushl $0
80107a55:	6a 00                	push   $0x0
  pushl $104
80107a57:	6a 68                	push   $0x68
  jmp alltraps
80107a59:	e9 b1 f4 ff ff       	jmp    80106f0f <alltraps>

80107a5e <vector105>:
.globl vector105
vector105:
  pushl $0
80107a5e:	6a 00                	push   $0x0
  pushl $105
80107a60:	6a 69                	push   $0x69
  jmp alltraps
80107a62:	e9 a8 f4 ff ff       	jmp    80106f0f <alltraps>

80107a67 <vector106>:
.globl vector106
vector106:
  pushl $0
80107a67:	6a 00                	push   $0x0
  pushl $106
80107a69:	6a 6a                	push   $0x6a
  jmp alltraps
80107a6b:	e9 9f f4 ff ff       	jmp    80106f0f <alltraps>

80107a70 <vector107>:
.globl vector107
vector107:
  pushl $0
80107a70:	6a 00                	push   $0x0
  pushl $107
80107a72:	6a 6b                	push   $0x6b
  jmp alltraps
80107a74:	e9 96 f4 ff ff       	jmp    80106f0f <alltraps>

80107a79 <vector108>:
.globl vector108
vector108:
  pushl $0
80107a79:	6a 00                	push   $0x0
  pushl $108
80107a7b:	6a 6c                	push   $0x6c
  jmp alltraps
80107a7d:	e9 8d f4 ff ff       	jmp    80106f0f <alltraps>

80107a82 <vector109>:
.globl vector109
vector109:
  pushl $0
80107a82:	6a 00                	push   $0x0
  pushl $109
80107a84:	6a 6d                	push   $0x6d
  jmp alltraps
80107a86:	e9 84 f4 ff ff       	jmp    80106f0f <alltraps>

80107a8b <vector110>:
.globl vector110
vector110:
  pushl $0
80107a8b:	6a 00                	push   $0x0
  pushl $110
80107a8d:	6a 6e                	push   $0x6e
  jmp alltraps
80107a8f:	e9 7b f4 ff ff       	jmp    80106f0f <alltraps>

80107a94 <vector111>:
.globl vector111
vector111:
  pushl $0
80107a94:	6a 00                	push   $0x0
  pushl $111
80107a96:	6a 6f                	push   $0x6f
  jmp alltraps
80107a98:	e9 72 f4 ff ff       	jmp    80106f0f <alltraps>

80107a9d <vector112>:
.globl vector112
vector112:
  pushl $0
80107a9d:	6a 00                	push   $0x0
  pushl $112
80107a9f:	6a 70                	push   $0x70
  jmp alltraps
80107aa1:	e9 69 f4 ff ff       	jmp    80106f0f <alltraps>

80107aa6 <vector113>:
.globl vector113
vector113:
  pushl $0
80107aa6:	6a 00                	push   $0x0
  pushl $113
80107aa8:	6a 71                	push   $0x71
  jmp alltraps
80107aaa:	e9 60 f4 ff ff       	jmp    80106f0f <alltraps>

80107aaf <vector114>:
.globl vector114
vector114:
  pushl $0
80107aaf:	6a 00                	push   $0x0
  pushl $114
80107ab1:	6a 72                	push   $0x72
  jmp alltraps
80107ab3:	e9 57 f4 ff ff       	jmp    80106f0f <alltraps>

80107ab8 <vector115>:
.globl vector115
vector115:
  pushl $0
80107ab8:	6a 00                	push   $0x0
  pushl $115
80107aba:	6a 73                	push   $0x73
  jmp alltraps
80107abc:	e9 4e f4 ff ff       	jmp    80106f0f <alltraps>

80107ac1 <vector116>:
.globl vector116
vector116:
  pushl $0
80107ac1:	6a 00                	push   $0x0
  pushl $116
80107ac3:	6a 74                	push   $0x74
  jmp alltraps
80107ac5:	e9 45 f4 ff ff       	jmp    80106f0f <alltraps>

80107aca <vector117>:
.globl vector117
vector117:
  pushl $0
80107aca:	6a 00                	push   $0x0
  pushl $117
80107acc:	6a 75                	push   $0x75
  jmp alltraps
80107ace:	e9 3c f4 ff ff       	jmp    80106f0f <alltraps>

80107ad3 <vector118>:
.globl vector118
vector118:
  pushl $0
80107ad3:	6a 00                	push   $0x0
  pushl $118
80107ad5:	6a 76                	push   $0x76
  jmp alltraps
80107ad7:	e9 33 f4 ff ff       	jmp    80106f0f <alltraps>

80107adc <vector119>:
.globl vector119
vector119:
  pushl $0
80107adc:	6a 00                	push   $0x0
  pushl $119
80107ade:	6a 77                	push   $0x77
  jmp alltraps
80107ae0:	e9 2a f4 ff ff       	jmp    80106f0f <alltraps>

80107ae5 <vector120>:
.globl vector120
vector120:
  pushl $0
80107ae5:	6a 00                	push   $0x0
  pushl $120
80107ae7:	6a 78                	push   $0x78
  jmp alltraps
80107ae9:	e9 21 f4 ff ff       	jmp    80106f0f <alltraps>

80107aee <vector121>:
.globl vector121
vector121:
  pushl $0
80107aee:	6a 00                	push   $0x0
  pushl $121
80107af0:	6a 79                	push   $0x79
  jmp alltraps
80107af2:	e9 18 f4 ff ff       	jmp    80106f0f <alltraps>

80107af7 <vector122>:
.globl vector122
vector122:
  pushl $0
80107af7:	6a 00                	push   $0x0
  pushl $122
80107af9:	6a 7a                	push   $0x7a
  jmp alltraps
80107afb:	e9 0f f4 ff ff       	jmp    80106f0f <alltraps>

80107b00 <vector123>:
.globl vector123
vector123:
  pushl $0
80107b00:	6a 00                	push   $0x0
  pushl $123
80107b02:	6a 7b                	push   $0x7b
  jmp alltraps
80107b04:	e9 06 f4 ff ff       	jmp    80106f0f <alltraps>

80107b09 <vector124>:
.globl vector124
vector124:
  pushl $0
80107b09:	6a 00                	push   $0x0
  pushl $124
80107b0b:	6a 7c                	push   $0x7c
  jmp alltraps
80107b0d:	e9 fd f3 ff ff       	jmp    80106f0f <alltraps>

80107b12 <vector125>:
.globl vector125
vector125:
  pushl $0
80107b12:	6a 00                	push   $0x0
  pushl $125
80107b14:	6a 7d                	push   $0x7d
  jmp alltraps
80107b16:	e9 f4 f3 ff ff       	jmp    80106f0f <alltraps>

80107b1b <vector126>:
.globl vector126
vector126:
  pushl $0
80107b1b:	6a 00                	push   $0x0
  pushl $126
80107b1d:	6a 7e                	push   $0x7e
  jmp alltraps
80107b1f:	e9 eb f3 ff ff       	jmp    80106f0f <alltraps>

80107b24 <vector127>:
.globl vector127
vector127:
  pushl $0
80107b24:	6a 00                	push   $0x0
  pushl $127
80107b26:	6a 7f                	push   $0x7f
  jmp alltraps
80107b28:	e9 e2 f3 ff ff       	jmp    80106f0f <alltraps>

80107b2d <vector128>:
.globl vector128
vector128:
  pushl $0
80107b2d:	6a 00                	push   $0x0
  pushl $128
80107b2f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107b34:	e9 d6 f3 ff ff       	jmp    80106f0f <alltraps>

80107b39 <vector129>:
.globl vector129
vector129:
  pushl $0
80107b39:	6a 00                	push   $0x0
  pushl $129
80107b3b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107b40:	e9 ca f3 ff ff       	jmp    80106f0f <alltraps>

80107b45 <vector130>:
.globl vector130
vector130:
  pushl $0
80107b45:	6a 00                	push   $0x0
  pushl $130
80107b47:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107b4c:	e9 be f3 ff ff       	jmp    80106f0f <alltraps>

80107b51 <vector131>:
.globl vector131
vector131:
  pushl $0
80107b51:	6a 00                	push   $0x0
  pushl $131
80107b53:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107b58:	e9 b2 f3 ff ff       	jmp    80106f0f <alltraps>

80107b5d <vector132>:
.globl vector132
vector132:
  pushl $0
80107b5d:	6a 00                	push   $0x0
  pushl $132
80107b5f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107b64:	e9 a6 f3 ff ff       	jmp    80106f0f <alltraps>

80107b69 <vector133>:
.globl vector133
vector133:
  pushl $0
80107b69:	6a 00                	push   $0x0
  pushl $133
80107b6b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107b70:	e9 9a f3 ff ff       	jmp    80106f0f <alltraps>

80107b75 <vector134>:
.globl vector134
vector134:
  pushl $0
80107b75:	6a 00                	push   $0x0
  pushl $134
80107b77:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107b7c:	e9 8e f3 ff ff       	jmp    80106f0f <alltraps>

80107b81 <vector135>:
.globl vector135
vector135:
  pushl $0
80107b81:	6a 00                	push   $0x0
  pushl $135
80107b83:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107b88:	e9 82 f3 ff ff       	jmp    80106f0f <alltraps>

80107b8d <vector136>:
.globl vector136
vector136:
  pushl $0
80107b8d:	6a 00                	push   $0x0
  pushl $136
80107b8f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107b94:	e9 76 f3 ff ff       	jmp    80106f0f <alltraps>

80107b99 <vector137>:
.globl vector137
vector137:
  pushl $0
80107b99:	6a 00                	push   $0x0
  pushl $137
80107b9b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107ba0:	e9 6a f3 ff ff       	jmp    80106f0f <alltraps>

80107ba5 <vector138>:
.globl vector138
vector138:
  pushl $0
80107ba5:	6a 00                	push   $0x0
  pushl $138
80107ba7:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107bac:	e9 5e f3 ff ff       	jmp    80106f0f <alltraps>

80107bb1 <vector139>:
.globl vector139
vector139:
  pushl $0
80107bb1:	6a 00                	push   $0x0
  pushl $139
80107bb3:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107bb8:	e9 52 f3 ff ff       	jmp    80106f0f <alltraps>

80107bbd <vector140>:
.globl vector140
vector140:
  pushl $0
80107bbd:	6a 00                	push   $0x0
  pushl $140
80107bbf:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107bc4:	e9 46 f3 ff ff       	jmp    80106f0f <alltraps>

80107bc9 <vector141>:
.globl vector141
vector141:
  pushl $0
80107bc9:	6a 00                	push   $0x0
  pushl $141
80107bcb:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107bd0:	e9 3a f3 ff ff       	jmp    80106f0f <alltraps>

80107bd5 <vector142>:
.globl vector142
vector142:
  pushl $0
80107bd5:	6a 00                	push   $0x0
  pushl $142
80107bd7:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107bdc:	e9 2e f3 ff ff       	jmp    80106f0f <alltraps>

80107be1 <vector143>:
.globl vector143
vector143:
  pushl $0
80107be1:	6a 00                	push   $0x0
  pushl $143
80107be3:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107be8:	e9 22 f3 ff ff       	jmp    80106f0f <alltraps>

80107bed <vector144>:
.globl vector144
vector144:
  pushl $0
80107bed:	6a 00                	push   $0x0
  pushl $144
80107bef:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107bf4:	e9 16 f3 ff ff       	jmp    80106f0f <alltraps>

80107bf9 <vector145>:
.globl vector145
vector145:
  pushl $0
80107bf9:	6a 00                	push   $0x0
  pushl $145
80107bfb:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107c00:	e9 0a f3 ff ff       	jmp    80106f0f <alltraps>

80107c05 <vector146>:
.globl vector146
vector146:
  pushl $0
80107c05:	6a 00                	push   $0x0
  pushl $146
80107c07:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107c0c:	e9 fe f2 ff ff       	jmp    80106f0f <alltraps>

80107c11 <vector147>:
.globl vector147
vector147:
  pushl $0
80107c11:	6a 00                	push   $0x0
  pushl $147
80107c13:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107c18:	e9 f2 f2 ff ff       	jmp    80106f0f <alltraps>

80107c1d <vector148>:
.globl vector148
vector148:
  pushl $0
80107c1d:	6a 00                	push   $0x0
  pushl $148
80107c1f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107c24:	e9 e6 f2 ff ff       	jmp    80106f0f <alltraps>

80107c29 <vector149>:
.globl vector149
vector149:
  pushl $0
80107c29:	6a 00                	push   $0x0
  pushl $149
80107c2b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107c30:	e9 da f2 ff ff       	jmp    80106f0f <alltraps>

80107c35 <vector150>:
.globl vector150
vector150:
  pushl $0
80107c35:	6a 00                	push   $0x0
  pushl $150
80107c37:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107c3c:	e9 ce f2 ff ff       	jmp    80106f0f <alltraps>

80107c41 <vector151>:
.globl vector151
vector151:
  pushl $0
80107c41:	6a 00                	push   $0x0
  pushl $151
80107c43:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107c48:	e9 c2 f2 ff ff       	jmp    80106f0f <alltraps>

80107c4d <vector152>:
.globl vector152
vector152:
  pushl $0
80107c4d:	6a 00                	push   $0x0
  pushl $152
80107c4f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107c54:	e9 b6 f2 ff ff       	jmp    80106f0f <alltraps>

80107c59 <vector153>:
.globl vector153
vector153:
  pushl $0
80107c59:	6a 00                	push   $0x0
  pushl $153
80107c5b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107c60:	e9 aa f2 ff ff       	jmp    80106f0f <alltraps>

80107c65 <vector154>:
.globl vector154
vector154:
  pushl $0
80107c65:	6a 00                	push   $0x0
  pushl $154
80107c67:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107c6c:	e9 9e f2 ff ff       	jmp    80106f0f <alltraps>

80107c71 <vector155>:
.globl vector155
vector155:
  pushl $0
80107c71:	6a 00                	push   $0x0
  pushl $155
80107c73:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107c78:	e9 92 f2 ff ff       	jmp    80106f0f <alltraps>

80107c7d <vector156>:
.globl vector156
vector156:
  pushl $0
80107c7d:	6a 00                	push   $0x0
  pushl $156
80107c7f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107c84:	e9 86 f2 ff ff       	jmp    80106f0f <alltraps>

80107c89 <vector157>:
.globl vector157
vector157:
  pushl $0
80107c89:	6a 00                	push   $0x0
  pushl $157
80107c8b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107c90:	e9 7a f2 ff ff       	jmp    80106f0f <alltraps>

80107c95 <vector158>:
.globl vector158
vector158:
  pushl $0
80107c95:	6a 00                	push   $0x0
  pushl $158
80107c97:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107c9c:	e9 6e f2 ff ff       	jmp    80106f0f <alltraps>

80107ca1 <vector159>:
.globl vector159
vector159:
  pushl $0
80107ca1:	6a 00                	push   $0x0
  pushl $159
80107ca3:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107ca8:	e9 62 f2 ff ff       	jmp    80106f0f <alltraps>

80107cad <vector160>:
.globl vector160
vector160:
  pushl $0
80107cad:	6a 00                	push   $0x0
  pushl $160
80107caf:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107cb4:	e9 56 f2 ff ff       	jmp    80106f0f <alltraps>

80107cb9 <vector161>:
.globl vector161
vector161:
  pushl $0
80107cb9:	6a 00                	push   $0x0
  pushl $161
80107cbb:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107cc0:	e9 4a f2 ff ff       	jmp    80106f0f <alltraps>

80107cc5 <vector162>:
.globl vector162
vector162:
  pushl $0
80107cc5:	6a 00                	push   $0x0
  pushl $162
80107cc7:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107ccc:	e9 3e f2 ff ff       	jmp    80106f0f <alltraps>

80107cd1 <vector163>:
.globl vector163
vector163:
  pushl $0
80107cd1:	6a 00                	push   $0x0
  pushl $163
80107cd3:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107cd8:	e9 32 f2 ff ff       	jmp    80106f0f <alltraps>

80107cdd <vector164>:
.globl vector164
vector164:
  pushl $0
80107cdd:	6a 00                	push   $0x0
  pushl $164
80107cdf:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107ce4:	e9 26 f2 ff ff       	jmp    80106f0f <alltraps>

80107ce9 <vector165>:
.globl vector165
vector165:
  pushl $0
80107ce9:	6a 00                	push   $0x0
  pushl $165
80107ceb:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107cf0:	e9 1a f2 ff ff       	jmp    80106f0f <alltraps>

80107cf5 <vector166>:
.globl vector166
vector166:
  pushl $0
80107cf5:	6a 00                	push   $0x0
  pushl $166
80107cf7:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107cfc:	e9 0e f2 ff ff       	jmp    80106f0f <alltraps>

80107d01 <vector167>:
.globl vector167
vector167:
  pushl $0
80107d01:	6a 00                	push   $0x0
  pushl $167
80107d03:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107d08:	e9 02 f2 ff ff       	jmp    80106f0f <alltraps>

80107d0d <vector168>:
.globl vector168
vector168:
  pushl $0
80107d0d:	6a 00                	push   $0x0
  pushl $168
80107d0f:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107d14:	e9 f6 f1 ff ff       	jmp    80106f0f <alltraps>

80107d19 <vector169>:
.globl vector169
vector169:
  pushl $0
80107d19:	6a 00                	push   $0x0
  pushl $169
80107d1b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107d20:	e9 ea f1 ff ff       	jmp    80106f0f <alltraps>

80107d25 <vector170>:
.globl vector170
vector170:
  pushl $0
80107d25:	6a 00                	push   $0x0
  pushl $170
80107d27:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107d2c:	e9 de f1 ff ff       	jmp    80106f0f <alltraps>

80107d31 <vector171>:
.globl vector171
vector171:
  pushl $0
80107d31:	6a 00                	push   $0x0
  pushl $171
80107d33:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107d38:	e9 d2 f1 ff ff       	jmp    80106f0f <alltraps>

80107d3d <vector172>:
.globl vector172
vector172:
  pushl $0
80107d3d:	6a 00                	push   $0x0
  pushl $172
80107d3f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107d44:	e9 c6 f1 ff ff       	jmp    80106f0f <alltraps>

80107d49 <vector173>:
.globl vector173
vector173:
  pushl $0
80107d49:	6a 00                	push   $0x0
  pushl $173
80107d4b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107d50:	e9 ba f1 ff ff       	jmp    80106f0f <alltraps>

80107d55 <vector174>:
.globl vector174
vector174:
  pushl $0
80107d55:	6a 00                	push   $0x0
  pushl $174
80107d57:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107d5c:	e9 ae f1 ff ff       	jmp    80106f0f <alltraps>

80107d61 <vector175>:
.globl vector175
vector175:
  pushl $0
80107d61:	6a 00                	push   $0x0
  pushl $175
80107d63:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107d68:	e9 a2 f1 ff ff       	jmp    80106f0f <alltraps>

80107d6d <vector176>:
.globl vector176
vector176:
  pushl $0
80107d6d:	6a 00                	push   $0x0
  pushl $176
80107d6f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107d74:	e9 96 f1 ff ff       	jmp    80106f0f <alltraps>

80107d79 <vector177>:
.globl vector177
vector177:
  pushl $0
80107d79:	6a 00                	push   $0x0
  pushl $177
80107d7b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107d80:	e9 8a f1 ff ff       	jmp    80106f0f <alltraps>

80107d85 <vector178>:
.globl vector178
vector178:
  pushl $0
80107d85:	6a 00                	push   $0x0
  pushl $178
80107d87:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107d8c:	e9 7e f1 ff ff       	jmp    80106f0f <alltraps>

80107d91 <vector179>:
.globl vector179
vector179:
  pushl $0
80107d91:	6a 00                	push   $0x0
  pushl $179
80107d93:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107d98:	e9 72 f1 ff ff       	jmp    80106f0f <alltraps>

80107d9d <vector180>:
.globl vector180
vector180:
  pushl $0
80107d9d:	6a 00                	push   $0x0
  pushl $180
80107d9f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107da4:	e9 66 f1 ff ff       	jmp    80106f0f <alltraps>

80107da9 <vector181>:
.globl vector181
vector181:
  pushl $0
80107da9:	6a 00                	push   $0x0
  pushl $181
80107dab:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107db0:	e9 5a f1 ff ff       	jmp    80106f0f <alltraps>

80107db5 <vector182>:
.globl vector182
vector182:
  pushl $0
80107db5:	6a 00                	push   $0x0
  pushl $182
80107db7:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107dbc:	e9 4e f1 ff ff       	jmp    80106f0f <alltraps>

80107dc1 <vector183>:
.globl vector183
vector183:
  pushl $0
80107dc1:	6a 00                	push   $0x0
  pushl $183
80107dc3:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107dc8:	e9 42 f1 ff ff       	jmp    80106f0f <alltraps>

80107dcd <vector184>:
.globl vector184
vector184:
  pushl $0
80107dcd:	6a 00                	push   $0x0
  pushl $184
80107dcf:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107dd4:	e9 36 f1 ff ff       	jmp    80106f0f <alltraps>

80107dd9 <vector185>:
.globl vector185
vector185:
  pushl $0
80107dd9:	6a 00                	push   $0x0
  pushl $185
80107ddb:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107de0:	e9 2a f1 ff ff       	jmp    80106f0f <alltraps>

80107de5 <vector186>:
.globl vector186
vector186:
  pushl $0
80107de5:	6a 00                	push   $0x0
  pushl $186
80107de7:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107dec:	e9 1e f1 ff ff       	jmp    80106f0f <alltraps>

80107df1 <vector187>:
.globl vector187
vector187:
  pushl $0
80107df1:	6a 00                	push   $0x0
  pushl $187
80107df3:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107df8:	e9 12 f1 ff ff       	jmp    80106f0f <alltraps>

80107dfd <vector188>:
.globl vector188
vector188:
  pushl $0
80107dfd:	6a 00                	push   $0x0
  pushl $188
80107dff:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107e04:	e9 06 f1 ff ff       	jmp    80106f0f <alltraps>

80107e09 <vector189>:
.globl vector189
vector189:
  pushl $0
80107e09:	6a 00                	push   $0x0
  pushl $189
80107e0b:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107e10:	e9 fa f0 ff ff       	jmp    80106f0f <alltraps>

80107e15 <vector190>:
.globl vector190
vector190:
  pushl $0
80107e15:	6a 00                	push   $0x0
  pushl $190
80107e17:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107e1c:	e9 ee f0 ff ff       	jmp    80106f0f <alltraps>

80107e21 <vector191>:
.globl vector191
vector191:
  pushl $0
80107e21:	6a 00                	push   $0x0
  pushl $191
80107e23:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107e28:	e9 e2 f0 ff ff       	jmp    80106f0f <alltraps>

80107e2d <vector192>:
.globl vector192
vector192:
  pushl $0
80107e2d:	6a 00                	push   $0x0
  pushl $192
80107e2f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107e34:	e9 d6 f0 ff ff       	jmp    80106f0f <alltraps>

80107e39 <vector193>:
.globl vector193
vector193:
  pushl $0
80107e39:	6a 00                	push   $0x0
  pushl $193
80107e3b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107e40:	e9 ca f0 ff ff       	jmp    80106f0f <alltraps>

80107e45 <vector194>:
.globl vector194
vector194:
  pushl $0
80107e45:	6a 00                	push   $0x0
  pushl $194
80107e47:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107e4c:	e9 be f0 ff ff       	jmp    80106f0f <alltraps>

80107e51 <vector195>:
.globl vector195
vector195:
  pushl $0
80107e51:	6a 00                	push   $0x0
  pushl $195
80107e53:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107e58:	e9 b2 f0 ff ff       	jmp    80106f0f <alltraps>

80107e5d <vector196>:
.globl vector196
vector196:
  pushl $0
80107e5d:	6a 00                	push   $0x0
  pushl $196
80107e5f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107e64:	e9 a6 f0 ff ff       	jmp    80106f0f <alltraps>

80107e69 <vector197>:
.globl vector197
vector197:
  pushl $0
80107e69:	6a 00                	push   $0x0
  pushl $197
80107e6b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107e70:	e9 9a f0 ff ff       	jmp    80106f0f <alltraps>

80107e75 <vector198>:
.globl vector198
vector198:
  pushl $0
80107e75:	6a 00                	push   $0x0
  pushl $198
80107e77:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107e7c:	e9 8e f0 ff ff       	jmp    80106f0f <alltraps>

80107e81 <vector199>:
.globl vector199
vector199:
  pushl $0
80107e81:	6a 00                	push   $0x0
  pushl $199
80107e83:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107e88:	e9 82 f0 ff ff       	jmp    80106f0f <alltraps>

80107e8d <vector200>:
.globl vector200
vector200:
  pushl $0
80107e8d:	6a 00                	push   $0x0
  pushl $200
80107e8f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107e94:	e9 76 f0 ff ff       	jmp    80106f0f <alltraps>

80107e99 <vector201>:
.globl vector201
vector201:
  pushl $0
80107e99:	6a 00                	push   $0x0
  pushl $201
80107e9b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107ea0:	e9 6a f0 ff ff       	jmp    80106f0f <alltraps>

80107ea5 <vector202>:
.globl vector202
vector202:
  pushl $0
80107ea5:	6a 00                	push   $0x0
  pushl $202
80107ea7:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107eac:	e9 5e f0 ff ff       	jmp    80106f0f <alltraps>

80107eb1 <vector203>:
.globl vector203
vector203:
  pushl $0
80107eb1:	6a 00                	push   $0x0
  pushl $203
80107eb3:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107eb8:	e9 52 f0 ff ff       	jmp    80106f0f <alltraps>

80107ebd <vector204>:
.globl vector204
vector204:
  pushl $0
80107ebd:	6a 00                	push   $0x0
  pushl $204
80107ebf:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107ec4:	e9 46 f0 ff ff       	jmp    80106f0f <alltraps>

80107ec9 <vector205>:
.globl vector205
vector205:
  pushl $0
80107ec9:	6a 00                	push   $0x0
  pushl $205
80107ecb:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107ed0:	e9 3a f0 ff ff       	jmp    80106f0f <alltraps>

80107ed5 <vector206>:
.globl vector206
vector206:
  pushl $0
80107ed5:	6a 00                	push   $0x0
  pushl $206
80107ed7:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107edc:	e9 2e f0 ff ff       	jmp    80106f0f <alltraps>

80107ee1 <vector207>:
.globl vector207
vector207:
  pushl $0
80107ee1:	6a 00                	push   $0x0
  pushl $207
80107ee3:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107ee8:	e9 22 f0 ff ff       	jmp    80106f0f <alltraps>

80107eed <vector208>:
.globl vector208
vector208:
  pushl $0
80107eed:	6a 00                	push   $0x0
  pushl $208
80107eef:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107ef4:	e9 16 f0 ff ff       	jmp    80106f0f <alltraps>

80107ef9 <vector209>:
.globl vector209
vector209:
  pushl $0
80107ef9:	6a 00                	push   $0x0
  pushl $209
80107efb:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107f00:	e9 0a f0 ff ff       	jmp    80106f0f <alltraps>

80107f05 <vector210>:
.globl vector210
vector210:
  pushl $0
80107f05:	6a 00                	push   $0x0
  pushl $210
80107f07:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107f0c:	e9 fe ef ff ff       	jmp    80106f0f <alltraps>

80107f11 <vector211>:
.globl vector211
vector211:
  pushl $0
80107f11:	6a 00                	push   $0x0
  pushl $211
80107f13:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107f18:	e9 f2 ef ff ff       	jmp    80106f0f <alltraps>

80107f1d <vector212>:
.globl vector212
vector212:
  pushl $0
80107f1d:	6a 00                	push   $0x0
  pushl $212
80107f1f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107f24:	e9 e6 ef ff ff       	jmp    80106f0f <alltraps>

80107f29 <vector213>:
.globl vector213
vector213:
  pushl $0
80107f29:	6a 00                	push   $0x0
  pushl $213
80107f2b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107f30:	e9 da ef ff ff       	jmp    80106f0f <alltraps>

80107f35 <vector214>:
.globl vector214
vector214:
  pushl $0
80107f35:	6a 00                	push   $0x0
  pushl $214
80107f37:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107f3c:	e9 ce ef ff ff       	jmp    80106f0f <alltraps>

80107f41 <vector215>:
.globl vector215
vector215:
  pushl $0
80107f41:	6a 00                	push   $0x0
  pushl $215
80107f43:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107f48:	e9 c2 ef ff ff       	jmp    80106f0f <alltraps>

80107f4d <vector216>:
.globl vector216
vector216:
  pushl $0
80107f4d:	6a 00                	push   $0x0
  pushl $216
80107f4f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107f54:	e9 b6 ef ff ff       	jmp    80106f0f <alltraps>

80107f59 <vector217>:
.globl vector217
vector217:
  pushl $0
80107f59:	6a 00                	push   $0x0
  pushl $217
80107f5b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107f60:	e9 aa ef ff ff       	jmp    80106f0f <alltraps>

80107f65 <vector218>:
.globl vector218
vector218:
  pushl $0
80107f65:	6a 00                	push   $0x0
  pushl $218
80107f67:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107f6c:	e9 9e ef ff ff       	jmp    80106f0f <alltraps>

80107f71 <vector219>:
.globl vector219
vector219:
  pushl $0
80107f71:	6a 00                	push   $0x0
  pushl $219
80107f73:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107f78:	e9 92 ef ff ff       	jmp    80106f0f <alltraps>

80107f7d <vector220>:
.globl vector220
vector220:
  pushl $0
80107f7d:	6a 00                	push   $0x0
  pushl $220
80107f7f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107f84:	e9 86 ef ff ff       	jmp    80106f0f <alltraps>

80107f89 <vector221>:
.globl vector221
vector221:
  pushl $0
80107f89:	6a 00                	push   $0x0
  pushl $221
80107f8b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107f90:	e9 7a ef ff ff       	jmp    80106f0f <alltraps>

80107f95 <vector222>:
.globl vector222
vector222:
  pushl $0
80107f95:	6a 00                	push   $0x0
  pushl $222
80107f97:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107f9c:	e9 6e ef ff ff       	jmp    80106f0f <alltraps>

80107fa1 <vector223>:
.globl vector223
vector223:
  pushl $0
80107fa1:	6a 00                	push   $0x0
  pushl $223
80107fa3:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107fa8:	e9 62 ef ff ff       	jmp    80106f0f <alltraps>

80107fad <vector224>:
.globl vector224
vector224:
  pushl $0
80107fad:	6a 00                	push   $0x0
  pushl $224
80107faf:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107fb4:	e9 56 ef ff ff       	jmp    80106f0f <alltraps>

80107fb9 <vector225>:
.globl vector225
vector225:
  pushl $0
80107fb9:	6a 00                	push   $0x0
  pushl $225
80107fbb:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107fc0:	e9 4a ef ff ff       	jmp    80106f0f <alltraps>

80107fc5 <vector226>:
.globl vector226
vector226:
  pushl $0
80107fc5:	6a 00                	push   $0x0
  pushl $226
80107fc7:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107fcc:	e9 3e ef ff ff       	jmp    80106f0f <alltraps>

80107fd1 <vector227>:
.globl vector227
vector227:
  pushl $0
80107fd1:	6a 00                	push   $0x0
  pushl $227
80107fd3:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107fd8:	e9 32 ef ff ff       	jmp    80106f0f <alltraps>

80107fdd <vector228>:
.globl vector228
vector228:
  pushl $0
80107fdd:	6a 00                	push   $0x0
  pushl $228
80107fdf:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107fe4:	e9 26 ef ff ff       	jmp    80106f0f <alltraps>

80107fe9 <vector229>:
.globl vector229
vector229:
  pushl $0
80107fe9:	6a 00                	push   $0x0
  pushl $229
80107feb:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107ff0:	e9 1a ef ff ff       	jmp    80106f0f <alltraps>

80107ff5 <vector230>:
.globl vector230
vector230:
  pushl $0
80107ff5:	6a 00                	push   $0x0
  pushl $230
80107ff7:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107ffc:	e9 0e ef ff ff       	jmp    80106f0f <alltraps>

80108001 <vector231>:
.globl vector231
vector231:
  pushl $0
80108001:	6a 00                	push   $0x0
  pushl $231
80108003:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108008:	e9 02 ef ff ff       	jmp    80106f0f <alltraps>

8010800d <vector232>:
.globl vector232
vector232:
  pushl $0
8010800d:	6a 00                	push   $0x0
  pushl $232
8010800f:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108014:	e9 f6 ee ff ff       	jmp    80106f0f <alltraps>

80108019 <vector233>:
.globl vector233
vector233:
  pushl $0
80108019:	6a 00                	push   $0x0
  pushl $233
8010801b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108020:	e9 ea ee ff ff       	jmp    80106f0f <alltraps>

80108025 <vector234>:
.globl vector234
vector234:
  pushl $0
80108025:	6a 00                	push   $0x0
  pushl $234
80108027:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010802c:	e9 de ee ff ff       	jmp    80106f0f <alltraps>

80108031 <vector235>:
.globl vector235
vector235:
  pushl $0
80108031:	6a 00                	push   $0x0
  pushl $235
80108033:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108038:	e9 d2 ee ff ff       	jmp    80106f0f <alltraps>

8010803d <vector236>:
.globl vector236
vector236:
  pushl $0
8010803d:	6a 00                	push   $0x0
  pushl $236
8010803f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108044:	e9 c6 ee ff ff       	jmp    80106f0f <alltraps>

80108049 <vector237>:
.globl vector237
vector237:
  pushl $0
80108049:	6a 00                	push   $0x0
  pushl $237
8010804b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108050:	e9 ba ee ff ff       	jmp    80106f0f <alltraps>

80108055 <vector238>:
.globl vector238
vector238:
  pushl $0
80108055:	6a 00                	push   $0x0
  pushl $238
80108057:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010805c:	e9 ae ee ff ff       	jmp    80106f0f <alltraps>

80108061 <vector239>:
.globl vector239
vector239:
  pushl $0
80108061:	6a 00                	push   $0x0
  pushl $239
80108063:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108068:	e9 a2 ee ff ff       	jmp    80106f0f <alltraps>

8010806d <vector240>:
.globl vector240
vector240:
  pushl $0
8010806d:	6a 00                	push   $0x0
  pushl $240
8010806f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108074:	e9 96 ee ff ff       	jmp    80106f0f <alltraps>

80108079 <vector241>:
.globl vector241
vector241:
  pushl $0
80108079:	6a 00                	push   $0x0
  pushl $241
8010807b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108080:	e9 8a ee ff ff       	jmp    80106f0f <alltraps>

80108085 <vector242>:
.globl vector242
vector242:
  pushl $0
80108085:	6a 00                	push   $0x0
  pushl $242
80108087:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010808c:	e9 7e ee ff ff       	jmp    80106f0f <alltraps>

80108091 <vector243>:
.globl vector243
vector243:
  pushl $0
80108091:	6a 00                	push   $0x0
  pushl $243
80108093:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108098:	e9 72 ee ff ff       	jmp    80106f0f <alltraps>

8010809d <vector244>:
.globl vector244
vector244:
  pushl $0
8010809d:	6a 00                	push   $0x0
  pushl $244
8010809f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801080a4:	e9 66 ee ff ff       	jmp    80106f0f <alltraps>

801080a9 <vector245>:
.globl vector245
vector245:
  pushl $0
801080a9:	6a 00                	push   $0x0
  pushl $245
801080ab:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801080b0:	e9 5a ee ff ff       	jmp    80106f0f <alltraps>

801080b5 <vector246>:
.globl vector246
vector246:
  pushl $0
801080b5:	6a 00                	push   $0x0
  pushl $246
801080b7:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801080bc:	e9 4e ee ff ff       	jmp    80106f0f <alltraps>

801080c1 <vector247>:
.globl vector247
vector247:
  pushl $0
801080c1:	6a 00                	push   $0x0
  pushl $247
801080c3:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801080c8:	e9 42 ee ff ff       	jmp    80106f0f <alltraps>

801080cd <vector248>:
.globl vector248
vector248:
  pushl $0
801080cd:	6a 00                	push   $0x0
  pushl $248
801080cf:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801080d4:	e9 36 ee ff ff       	jmp    80106f0f <alltraps>

801080d9 <vector249>:
.globl vector249
vector249:
  pushl $0
801080d9:	6a 00                	push   $0x0
  pushl $249
801080db:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801080e0:	e9 2a ee ff ff       	jmp    80106f0f <alltraps>

801080e5 <vector250>:
.globl vector250
vector250:
  pushl $0
801080e5:	6a 00                	push   $0x0
  pushl $250
801080e7:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801080ec:	e9 1e ee ff ff       	jmp    80106f0f <alltraps>

801080f1 <vector251>:
.globl vector251
vector251:
  pushl $0
801080f1:	6a 00                	push   $0x0
  pushl $251
801080f3:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801080f8:	e9 12 ee ff ff       	jmp    80106f0f <alltraps>

801080fd <vector252>:
.globl vector252
vector252:
  pushl $0
801080fd:	6a 00                	push   $0x0
  pushl $252
801080ff:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108104:	e9 06 ee ff ff       	jmp    80106f0f <alltraps>

80108109 <vector253>:
.globl vector253
vector253:
  pushl $0
80108109:	6a 00                	push   $0x0
  pushl $253
8010810b:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108110:	e9 fa ed ff ff       	jmp    80106f0f <alltraps>

80108115 <vector254>:
.globl vector254
vector254:
  pushl $0
80108115:	6a 00                	push   $0x0
  pushl $254
80108117:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010811c:	e9 ee ed ff ff       	jmp    80106f0f <alltraps>

80108121 <vector255>:
.globl vector255
vector255:
  pushl $0
80108121:	6a 00                	push   $0x0
  pushl $255
80108123:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108128:	e9 e2 ed ff ff       	jmp    80106f0f <alltraps>

8010812d <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010812d:	55                   	push   %ebp
8010812e:	89 e5                	mov    %esp,%ebp
80108130:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108133:	8b 45 0c             	mov    0xc(%ebp),%eax
80108136:	83 e8 01             	sub    $0x1,%eax
80108139:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010813d:	8b 45 08             	mov    0x8(%ebp),%eax
80108140:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108144:	8b 45 08             	mov    0x8(%ebp),%eax
80108147:	c1 e8 10             	shr    $0x10,%eax
8010814a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010814e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108151:	0f 01 10             	lgdtl  (%eax)
}
80108154:	90                   	nop
80108155:	c9                   	leave  
80108156:	c3                   	ret    

80108157 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108157:	55                   	push   %ebp
80108158:	89 e5                	mov    %esp,%ebp
8010815a:	83 ec 04             	sub    $0x4,%esp
8010815d:	8b 45 08             	mov    0x8(%ebp),%eax
80108160:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108164:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108168:	0f 00 d8             	ltr    %ax
}
8010816b:	90                   	nop
8010816c:	c9                   	leave  
8010816d:	c3                   	ret    

8010816e <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010816e:	55                   	push   %ebp
8010816f:	89 e5                	mov    %esp,%ebp
80108171:	83 ec 04             	sub    $0x4,%esp
80108174:	8b 45 08             	mov    0x8(%ebp),%eax
80108177:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010817b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010817f:	8e e8                	mov    %eax,%gs
}
80108181:	90                   	nop
80108182:	c9                   	leave  
80108183:	c3                   	ret    

80108184 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80108184:	55                   	push   %ebp
80108185:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108187:	8b 45 08             	mov    0x8(%ebp),%eax
8010818a:	0f 22 d8             	mov    %eax,%cr3
}
8010818d:	90                   	nop
8010818e:	5d                   	pop    %ebp
8010818f:	c3                   	ret    

80108190 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108190:	55                   	push   %ebp
80108191:	89 e5                	mov    %esp,%ebp
80108193:	8b 45 08             	mov    0x8(%ebp),%eax
80108196:	05 00 00 00 80       	add    $0x80000000,%eax
8010819b:	5d                   	pop    %ebp
8010819c:	c3                   	ret    

8010819d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010819d:	55                   	push   %ebp
8010819e:	89 e5                	mov    %esp,%ebp
801081a0:	8b 45 08             	mov    0x8(%ebp),%eax
801081a3:	05 00 00 00 80       	add    $0x80000000,%eax
801081a8:	5d                   	pop    %ebp
801081a9:	c3                   	ret    

801081aa <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801081aa:	55                   	push   %ebp
801081ab:	89 e5                	mov    %esp,%ebp
801081ad:	53                   	push   %ebx
801081ae:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801081b1:	e8 83 ad ff ff       	call   80102f39 <cpunum>
801081b6:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801081bc:	05 80 33 11 80       	add    $0x80113380,%eax
801081c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801081c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c7:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801081cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d0:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801081d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d9:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801081dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801081e4:	83 e2 f0             	and    $0xfffffff0,%edx
801081e7:	83 ca 0a             	or     $0xa,%edx
801081ea:	88 50 7d             	mov    %dl,0x7d(%eax)
801081ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801081f4:	83 ca 10             	or     $0x10,%edx
801081f7:	88 50 7d             	mov    %dl,0x7d(%eax)
801081fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108201:	83 e2 9f             	and    $0xffffff9f,%edx
80108204:	88 50 7d             	mov    %dl,0x7d(%eax)
80108207:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010820e:	83 ca 80             	or     $0xffffff80,%edx
80108211:	88 50 7d             	mov    %dl,0x7d(%eax)
80108214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108217:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010821b:	83 ca 0f             	or     $0xf,%edx
8010821e:	88 50 7e             	mov    %dl,0x7e(%eax)
80108221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108224:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108228:	83 e2 ef             	and    $0xffffffef,%edx
8010822b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010822e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108231:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108235:	83 e2 df             	and    $0xffffffdf,%edx
80108238:	88 50 7e             	mov    %dl,0x7e(%eax)
8010823b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108242:	83 ca 40             	or     $0x40,%edx
80108245:	88 50 7e             	mov    %dl,0x7e(%eax)
80108248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010824f:	83 ca 80             	or     $0xffffff80,%edx
80108252:	88 50 7e             	mov    %dl,0x7e(%eax)
80108255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108258:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010825c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825f:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108266:	ff ff 
80108268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826b:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108272:	00 00 
80108274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108277:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010827e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108281:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108288:	83 e2 f0             	and    $0xfffffff0,%edx
8010828b:	83 ca 02             	or     $0x2,%edx
8010828e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108294:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108297:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010829e:	83 ca 10             	or     $0x10,%edx
801082a1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801082a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082aa:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801082b1:	83 e2 9f             	and    $0xffffff9f,%edx
801082b4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801082ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082bd:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801082c4:	83 ca 80             	or     $0xffffff80,%edx
801082c7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801082cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801082d7:	83 ca 0f             	or     $0xf,%edx
801082da:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801082e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801082ea:	83 e2 ef             	and    $0xffffffef,%edx
801082ed:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801082f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801082fd:	83 e2 df             	and    $0xffffffdf,%edx
80108300:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108309:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108310:	83 ca 40             	or     $0x40,%edx
80108313:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108323:	83 ca 80             	or     $0xffffff80,%edx
80108326:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010832c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832f:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108339:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108340:	ff ff 
80108342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108345:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010834c:	00 00 
8010834e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108351:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010835b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108362:	83 e2 f0             	and    $0xfffffff0,%edx
80108365:	83 ca 0a             	or     $0xa,%edx
80108368:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010836e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108371:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108378:	83 ca 10             	or     $0x10,%edx
8010837b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108384:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010838b:	83 ca 60             	or     $0x60,%edx
8010838e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108397:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010839e:	83 ca 80             	or     $0xffffff80,%edx
801083a1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801083a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083aa:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801083b1:	83 ca 0f             	or     $0xf,%edx
801083b4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801083ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bd:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801083c4:	83 e2 ef             	and    $0xffffffef,%edx
801083c7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801083cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801083d7:	83 e2 df             	and    $0xffffffdf,%edx
801083da:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801083e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801083ea:	83 ca 40             	or     $0x40,%edx
801083ed:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801083f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801083fd:	83 ca 80             	or     $0xffffff80,%edx
80108400:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108409:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108413:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010841a:	ff ff 
8010841c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841f:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108426:	00 00 
80108428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842b:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108435:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010843c:	83 e2 f0             	and    $0xfffffff0,%edx
8010843f:	83 ca 02             	or     $0x2,%edx
80108442:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010844b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108452:	83 ca 10             	or     $0x10,%edx
80108455:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010845b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108465:	83 ca 60             	or     $0x60,%edx
80108468:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010846e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108471:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108478:	83 ca 80             	or     $0xffffff80,%edx
8010847b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108481:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108484:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010848b:	83 ca 0f             	or     $0xf,%edx
8010848e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108497:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010849e:	83 e2 ef             	and    $0xffffffef,%edx
801084a1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801084a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084aa:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801084b1:	83 e2 df             	and    $0xffffffdf,%edx
801084b4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801084ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bd:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801084c4:	83 ca 40             	or     $0x40,%edx
801084c7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801084cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801084d7:	83 ca 80             	or     $0xffffff80,%edx
801084da:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801084e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e3:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801084ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ed:	05 b4 00 00 00       	add    $0xb4,%eax
801084f2:	89 c3                	mov    %eax,%ebx
801084f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f7:	05 b4 00 00 00       	add    $0xb4,%eax
801084fc:	c1 e8 10             	shr    $0x10,%eax
801084ff:	89 c2                	mov    %eax,%edx
80108501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108504:	05 b4 00 00 00       	add    $0xb4,%eax
80108509:	c1 e8 18             	shr    $0x18,%eax
8010850c:	89 c1                	mov    %eax,%ecx
8010850e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108511:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108518:	00 00 
8010851a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851d:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108527:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
8010852d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108530:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108537:	83 e2 f0             	and    $0xfffffff0,%edx
8010853a:	83 ca 02             	or     $0x2,%edx
8010853d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108546:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010854d:	83 ca 10             	or     $0x10,%edx
80108550:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108559:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108560:	83 e2 9f             	and    $0xffffff9f,%edx
80108563:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010856c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108573:	83 ca 80             	or     $0xffffff80,%edx
80108576:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010857c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108586:	83 e2 f0             	and    $0xfffffff0,%edx
80108589:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010858f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108592:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108599:	83 e2 ef             	and    $0xffffffef,%edx
8010859c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801085a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801085ac:	83 e2 df             	and    $0xffffffdf,%edx
801085af:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801085b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801085bf:	83 ca 40             	or     $0x40,%edx
801085c2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801085c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085cb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801085d2:	83 ca 80             	or     $0xffffff80,%edx
801085d5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801085db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085de:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801085e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e7:	83 c0 70             	add    $0x70,%eax
801085ea:	83 ec 08             	sub    $0x8,%esp
801085ed:	6a 38                	push   $0x38
801085ef:	50                   	push   %eax
801085f0:	e8 38 fb ff ff       	call   8010812d <lgdt>
801085f5:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801085f8:	83 ec 0c             	sub    $0xc,%esp
801085fb:	6a 18                	push   $0x18
801085fd:	e8 6c fb ff ff       	call   8010816e <loadgs>
80108602:	83 c4 10             	add    $0x10,%esp

  // Initialize cpu-local storage.
  cpu = c;
80108605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108608:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
8010860e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108615:	00 00 00 00 
}
80108619:	90                   	nop
8010861a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010861d:	c9                   	leave  
8010861e:	c3                   	ret    

8010861f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010861f:	55                   	push   %ebp
80108620:	89 e5                	mov    %esp,%ebp
80108622:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108625:	8b 45 0c             	mov    0xc(%ebp),%eax
80108628:	c1 e8 16             	shr    $0x16,%eax
8010862b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108632:	8b 45 08             	mov    0x8(%ebp),%eax
80108635:	01 d0                	add    %edx,%eax
80108637:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010863a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010863d:	8b 00                	mov    (%eax),%eax
8010863f:	83 e0 01             	and    $0x1,%eax
80108642:	85 c0                	test   %eax,%eax
80108644:	74 18                	je     8010865e <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108646:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108649:	8b 00                	mov    (%eax),%eax
8010864b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108650:	50                   	push   %eax
80108651:	e8 47 fb ff ff       	call   8010819d <p2v>
80108656:	83 c4 04             	add    $0x4,%esp
80108659:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010865c:	eb 48                	jmp    801086a6 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010865e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108662:	74 0e                	je     80108672 <walkpgdir+0x53>
80108664:	e8 6a a5 ff ff       	call   80102bd3 <kalloc>
80108669:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010866c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108670:	75 07                	jne    80108679 <walkpgdir+0x5a>
      return 0;
80108672:	b8 00 00 00 00       	mov    $0x0,%eax
80108677:	eb 44                	jmp    801086bd <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108679:	83 ec 04             	sub    $0x4,%esp
8010867c:	68 00 10 00 00       	push   $0x1000
80108681:	6a 00                	push   $0x0
80108683:	ff 75 f4             	pushl  -0xc(%ebp)
80108686:	e8 b4 d3 ff ff       	call   80105a3f <memset>
8010868b:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010868e:	83 ec 0c             	sub    $0xc,%esp
80108691:	ff 75 f4             	pushl  -0xc(%ebp)
80108694:	e8 f7 fa ff ff       	call   80108190 <v2p>
80108699:	83 c4 10             	add    $0x10,%esp
8010869c:	83 c8 07             	or     $0x7,%eax
8010869f:	89 c2                	mov    %eax,%edx
801086a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086a4:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801086a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801086a9:	c1 e8 0c             	shr    $0xc,%eax
801086ac:	25 ff 03 00 00       	and    $0x3ff,%eax
801086b1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086bb:	01 d0                	add    %edx,%eax
}
801086bd:	c9                   	leave  
801086be:	c3                   	ret    

801086bf <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801086bf:	55                   	push   %ebp
801086c0:	89 e5                	mov    %esp,%ebp
801086c2:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801086c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801086c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801086d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801086d3:	8b 45 10             	mov    0x10(%ebp),%eax
801086d6:	01 d0                	add    %edx,%eax
801086d8:	83 e8 01             	sub    $0x1,%eax
801086db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801086e3:	83 ec 04             	sub    $0x4,%esp
801086e6:	6a 01                	push   $0x1
801086e8:	ff 75 f4             	pushl  -0xc(%ebp)
801086eb:	ff 75 08             	pushl  0x8(%ebp)
801086ee:	e8 2c ff ff ff       	call   8010861f <walkpgdir>
801086f3:	83 c4 10             	add    $0x10,%esp
801086f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086f9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086fd:	75 07                	jne    80108706 <mappages+0x47>
      return -1;
801086ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108704:	eb 47                	jmp    8010874d <mappages+0x8e>
    if(*pte & PTE_P)
80108706:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108709:	8b 00                	mov    (%eax),%eax
8010870b:	83 e0 01             	and    $0x1,%eax
8010870e:	85 c0                	test   %eax,%eax
80108710:	74 0d                	je     8010871f <mappages+0x60>
      panic("remap");
80108712:	83 ec 0c             	sub    $0xc,%esp
80108715:	68 c0 96 10 80       	push   $0x801096c0
8010871a:	e8 47 7e ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
8010871f:	8b 45 18             	mov    0x18(%ebp),%eax
80108722:	0b 45 14             	or     0x14(%ebp),%eax
80108725:	83 c8 01             	or     $0x1,%eax
80108728:	89 c2                	mov    %eax,%edx
8010872a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010872d:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010872f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108732:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108735:	74 10                	je     80108747 <mappages+0x88>
      break;
    a += PGSIZE;
80108737:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010873e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108745:	eb 9c                	jmp    801086e3 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108747:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108748:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010874d:	c9                   	leave  
8010874e:	c3                   	ret    

8010874f <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010874f:	55                   	push   %ebp
80108750:	89 e5                	mov    %esp,%ebp
80108752:	53                   	push   %ebx
80108753:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108756:	e8 78 a4 ff ff       	call   80102bd3 <kalloc>
8010875b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010875e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108762:	75 0a                	jne    8010876e <setupkvm+0x1f>
    return 0;
80108764:	b8 00 00 00 00       	mov    $0x0,%eax
80108769:	e9 8e 00 00 00       	jmp    801087fc <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
8010876e:	83 ec 04             	sub    $0x4,%esp
80108771:	68 00 10 00 00       	push   $0x1000
80108776:	6a 00                	push   $0x0
80108778:	ff 75 f0             	pushl  -0x10(%ebp)
8010877b:	e8 bf d2 ff ff       	call   80105a3f <memset>
80108780:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108783:	83 ec 0c             	sub    $0xc,%esp
80108786:	68 00 00 00 0e       	push   $0xe000000
8010878b:	e8 0d fa ff ff       	call   8010819d <p2v>
80108790:	83 c4 10             	add    $0x10,%esp
80108793:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108798:	76 0d                	jbe    801087a7 <setupkvm+0x58>
    panic("PHYSTOP too high");
8010879a:	83 ec 0c             	sub    $0xc,%esp
8010879d:	68 c6 96 10 80       	push   $0x801096c6
801087a2:	e8 bf 7d ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801087a7:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
801087ae:	eb 40                	jmp    801087f0 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801087b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b3:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
801087b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b9:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801087bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bf:	8b 58 08             	mov    0x8(%eax),%ebx
801087c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c5:	8b 40 04             	mov    0x4(%eax),%eax
801087c8:	29 c3                	sub    %eax,%ebx
801087ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cd:	8b 00                	mov    (%eax),%eax
801087cf:	83 ec 0c             	sub    $0xc,%esp
801087d2:	51                   	push   %ecx
801087d3:	52                   	push   %edx
801087d4:	53                   	push   %ebx
801087d5:	50                   	push   %eax
801087d6:	ff 75 f0             	pushl  -0x10(%ebp)
801087d9:	e8 e1 fe ff ff       	call   801086bf <mappages>
801087de:	83 c4 20             	add    $0x20,%esp
801087e1:	85 c0                	test   %eax,%eax
801087e3:	79 07                	jns    801087ec <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801087e5:	b8 00 00 00 00       	mov    $0x0,%eax
801087ea:	eb 10                	jmp    801087fc <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801087ec:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801087f0:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
801087f7:	72 b7                	jb     801087b0 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801087f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801087fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801087ff:	c9                   	leave  
80108800:	c3                   	ret    

80108801 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108801:	55                   	push   %ebp
80108802:	89 e5                	mov    %esp,%ebp
80108804:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108807:	e8 43 ff ff ff       	call   8010874f <setupkvm>
8010880c:	a3 18 6d 11 80       	mov    %eax,0x80116d18
  switchkvm();
80108811:	e8 03 00 00 00       	call   80108819 <switchkvm>
}
80108816:	90                   	nop
80108817:	c9                   	leave  
80108818:	c3                   	ret    

80108819 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108819:	55                   	push   %ebp
8010881a:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010881c:	a1 18 6d 11 80       	mov    0x80116d18,%eax
80108821:	50                   	push   %eax
80108822:	e8 69 f9 ff ff       	call   80108190 <v2p>
80108827:	83 c4 04             	add    $0x4,%esp
8010882a:	50                   	push   %eax
8010882b:	e8 54 f9 ff ff       	call   80108184 <lcr3>
80108830:	83 c4 04             	add    $0x4,%esp
}
80108833:	90                   	nop
80108834:	c9                   	leave  
80108835:	c3                   	ret    

80108836 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108836:	55                   	push   %ebp
80108837:	89 e5                	mov    %esp,%ebp
80108839:	56                   	push   %esi
8010883a:	53                   	push   %ebx
  pushcli();
8010883b:	e8 f9 d0 ff ff       	call   80105939 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108840:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108846:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010884d:	83 c2 08             	add    $0x8,%edx
80108850:	89 d6                	mov    %edx,%esi
80108852:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108859:	83 c2 08             	add    $0x8,%edx
8010885c:	c1 ea 10             	shr    $0x10,%edx
8010885f:	89 d3                	mov    %edx,%ebx
80108861:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108868:	83 c2 08             	add    $0x8,%edx
8010886b:	c1 ea 18             	shr    $0x18,%edx
8010886e:	89 d1                	mov    %edx,%ecx
80108870:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108877:	67 00 
80108879:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108880:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108886:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010888d:	83 e2 f0             	and    $0xfffffff0,%edx
80108890:	83 ca 09             	or     $0x9,%edx
80108893:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108899:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801088a0:	83 ca 10             	or     $0x10,%edx
801088a3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801088a9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801088b0:	83 e2 9f             	and    $0xffffff9f,%edx
801088b3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801088b9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801088c0:	83 ca 80             	or     $0xffffff80,%edx
801088c3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801088c9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801088d0:	83 e2 f0             	and    $0xfffffff0,%edx
801088d3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801088d9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801088e0:	83 e2 ef             	and    $0xffffffef,%edx
801088e3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801088e9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801088f0:	83 e2 df             	and    $0xffffffdf,%edx
801088f3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801088f9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108900:	83 ca 40             	or     $0x40,%edx
80108903:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108909:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108910:	83 e2 7f             	and    $0x7f,%edx
80108913:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108919:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010891f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108925:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010892c:	83 e2 ef             	and    $0xffffffef,%edx
8010892f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108935:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010893b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108941:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108947:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010894e:	8b 52 08             	mov    0x8(%edx),%edx
80108951:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108957:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010895a:	83 ec 0c             	sub    $0xc,%esp
8010895d:	6a 30                	push   $0x30
8010895f:	e8 f3 f7 ff ff       	call   80108157 <ltr>
80108964:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108967:	8b 45 08             	mov    0x8(%ebp),%eax
8010896a:	8b 40 04             	mov    0x4(%eax),%eax
8010896d:	85 c0                	test   %eax,%eax
8010896f:	75 0d                	jne    8010897e <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108971:	83 ec 0c             	sub    $0xc,%esp
80108974:	68 d7 96 10 80       	push   $0x801096d7
80108979:	e8 e8 7b ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010897e:	8b 45 08             	mov    0x8(%ebp),%eax
80108981:	8b 40 04             	mov    0x4(%eax),%eax
80108984:	83 ec 0c             	sub    $0xc,%esp
80108987:	50                   	push   %eax
80108988:	e8 03 f8 ff ff       	call   80108190 <v2p>
8010898d:	83 c4 10             	add    $0x10,%esp
80108990:	83 ec 0c             	sub    $0xc,%esp
80108993:	50                   	push   %eax
80108994:	e8 eb f7 ff ff       	call   80108184 <lcr3>
80108999:	83 c4 10             	add    $0x10,%esp
  popcli();
8010899c:	e8 dd cf ff ff       	call   8010597e <popcli>
}
801089a1:	90                   	nop
801089a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801089a5:	5b                   	pop    %ebx
801089a6:	5e                   	pop    %esi
801089a7:	5d                   	pop    %ebp
801089a8:	c3                   	ret    

801089a9 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801089a9:	55                   	push   %ebp
801089aa:	89 e5                	mov    %esp,%ebp
801089ac:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801089af:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801089b6:	76 0d                	jbe    801089c5 <inituvm+0x1c>
    panic("inituvm: more than a page");
801089b8:	83 ec 0c             	sub    $0xc,%esp
801089bb:	68 eb 96 10 80       	push   $0x801096eb
801089c0:	e8 a1 7b ff ff       	call   80100566 <panic>
  mem = kalloc();
801089c5:	e8 09 a2 ff ff       	call   80102bd3 <kalloc>
801089ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801089cd:	83 ec 04             	sub    $0x4,%esp
801089d0:	68 00 10 00 00       	push   $0x1000
801089d5:	6a 00                	push   $0x0
801089d7:	ff 75 f4             	pushl  -0xc(%ebp)
801089da:	e8 60 d0 ff ff       	call   80105a3f <memset>
801089df:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801089e2:	83 ec 0c             	sub    $0xc,%esp
801089e5:	ff 75 f4             	pushl  -0xc(%ebp)
801089e8:	e8 a3 f7 ff ff       	call   80108190 <v2p>
801089ed:	83 c4 10             	add    $0x10,%esp
801089f0:	83 ec 0c             	sub    $0xc,%esp
801089f3:	6a 06                	push   $0x6
801089f5:	50                   	push   %eax
801089f6:	68 00 10 00 00       	push   $0x1000
801089fb:	6a 00                	push   $0x0
801089fd:	ff 75 08             	pushl  0x8(%ebp)
80108a00:	e8 ba fc ff ff       	call   801086bf <mappages>
80108a05:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108a08:	83 ec 04             	sub    $0x4,%esp
80108a0b:	ff 75 10             	pushl  0x10(%ebp)
80108a0e:	ff 75 0c             	pushl  0xc(%ebp)
80108a11:	ff 75 f4             	pushl  -0xc(%ebp)
80108a14:	e8 e5 d0 ff ff       	call   80105afe <memmove>
80108a19:	83 c4 10             	add    $0x10,%esp
}
80108a1c:	90                   	nop
80108a1d:	c9                   	leave  
80108a1e:	c3                   	ret    

80108a1f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108a1f:	55                   	push   %ebp
80108a20:	89 e5                	mov    %esp,%ebp
80108a22:	53                   	push   %ebx
80108a23:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108a26:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a29:	25 ff 0f 00 00       	and    $0xfff,%eax
80108a2e:	85 c0                	test   %eax,%eax
80108a30:	74 0d                	je     80108a3f <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108a32:	83 ec 0c             	sub    $0xc,%esp
80108a35:	68 08 97 10 80       	push   $0x80109708
80108a3a:	e8 27 7b ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108a3f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a46:	e9 95 00 00 00       	jmp    80108ae0 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a51:	01 d0                	add    %edx,%eax
80108a53:	83 ec 04             	sub    $0x4,%esp
80108a56:	6a 00                	push   $0x0
80108a58:	50                   	push   %eax
80108a59:	ff 75 08             	pushl  0x8(%ebp)
80108a5c:	e8 be fb ff ff       	call   8010861f <walkpgdir>
80108a61:	83 c4 10             	add    $0x10,%esp
80108a64:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a6b:	75 0d                	jne    80108a7a <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108a6d:	83 ec 0c             	sub    $0xc,%esp
80108a70:	68 2b 97 10 80       	push   $0x8010972b
80108a75:	e8 ec 7a ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108a7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a7d:	8b 00                	mov    (%eax),%eax
80108a7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a84:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108a87:	8b 45 18             	mov    0x18(%ebp),%eax
80108a8a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108a8d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108a92:	77 0b                	ja     80108a9f <loaduvm+0x80>
      n = sz - i;
80108a94:	8b 45 18             	mov    0x18(%ebp),%eax
80108a97:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108a9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a9d:	eb 07                	jmp    80108aa6 <loaduvm+0x87>
    else
      n = PGSIZE;
80108a9f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108aa6:	8b 55 14             	mov    0x14(%ebp),%edx
80108aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aac:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108aaf:	83 ec 0c             	sub    $0xc,%esp
80108ab2:	ff 75 e8             	pushl  -0x18(%ebp)
80108ab5:	e8 e3 f6 ff ff       	call   8010819d <p2v>
80108aba:	83 c4 10             	add    $0x10,%esp
80108abd:	ff 75 f0             	pushl  -0x10(%ebp)
80108ac0:	53                   	push   %ebx
80108ac1:	50                   	push   %eax
80108ac2:	ff 75 10             	pushl  0x10(%ebp)
80108ac5:	e8 b7 93 ff ff       	call   80101e81 <readi>
80108aca:	83 c4 10             	add    $0x10,%esp
80108acd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108ad0:	74 07                	je     80108ad9 <loaduvm+0xba>
      return -1;
80108ad2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ad7:	eb 18                	jmp    80108af1 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108ad9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae3:	3b 45 18             	cmp    0x18(%ebp),%eax
80108ae6:	0f 82 5f ff ff ff    	jb     80108a4b <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108af1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108af4:	c9                   	leave  
80108af5:	c3                   	ret    

80108af6 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108af6:	55                   	push   %ebp
80108af7:	89 e5                	mov    %esp,%ebp
80108af9:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108afc:	8b 45 10             	mov    0x10(%ebp),%eax
80108aff:	85 c0                	test   %eax,%eax
80108b01:	79 0a                	jns    80108b0d <allocuvm+0x17>
    return 0;
80108b03:	b8 00 00 00 00       	mov    $0x0,%eax
80108b08:	e9 b0 00 00 00       	jmp    80108bbd <allocuvm+0xc7>
  if(newsz < oldsz)
80108b0d:	8b 45 10             	mov    0x10(%ebp),%eax
80108b10:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b13:	73 08                	jae    80108b1d <allocuvm+0x27>
    return oldsz;
80108b15:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b18:	e9 a0 00 00 00       	jmp    80108bbd <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b20:	05 ff 0f 00 00       	add    $0xfff,%eax
80108b25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108b2d:	eb 7f                	jmp    80108bae <allocuvm+0xb8>
    mem = kalloc();
80108b2f:	e8 9f a0 ff ff       	call   80102bd3 <kalloc>
80108b34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108b37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b3b:	75 2b                	jne    80108b68 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108b3d:	83 ec 0c             	sub    $0xc,%esp
80108b40:	68 49 97 10 80       	push   $0x80109749
80108b45:	e8 7c 78 ff ff       	call   801003c6 <cprintf>
80108b4a:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108b4d:	83 ec 04             	sub    $0x4,%esp
80108b50:	ff 75 0c             	pushl  0xc(%ebp)
80108b53:	ff 75 10             	pushl  0x10(%ebp)
80108b56:	ff 75 08             	pushl  0x8(%ebp)
80108b59:	e8 61 00 00 00       	call   80108bbf <deallocuvm>
80108b5e:	83 c4 10             	add    $0x10,%esp
      return 0;
80108b61:	b8 00 00 00 00       	mov    $0x0,%eax
80108b66:	eb 55                	jmp    80108bbd <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108b68:	83 ec 04             	sub    $0x4,%esp
80108b6b:	68 00 10 00 00       	push   $0x1000
80108b70:	6a 00                	push   $0x0
80108b72:	ff 75 f0             	pushl  -0x10(%ebp)
80108b75:	e8 c5 ce ff ff       	call   80105a3f <memset>
80108b7a:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108b7d:	83 ec 0c             	sub    $0xc,%esp
80108b80:	ff 75 f0             	pushl  -0x10(%ebp)
80108b83:	e8 08 f6 ff ff       	call   80108190 <v2p>
80108b88:	83 c4 10             	add    $0x10,%esp
80108b8b:	89 c2                	mov    %eax,%edx
80108b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b90:	83 ec 0c             	sub    $0xc,%esp
80108b93:	6a 06                	push   $0x6
80108b95:	52                   	push   %edx
80108b96:	68 00 10 00 00       	push   $0x1000
80108b9b:	50                   	push   %eax
80108b9c:	ff 75 08             	pushl  0x8(%ebp)
80108b9f:	e8 1b fb ff ff       	call   801086bf <mappages>
80108ba4:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108ba7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb1:	3b 45 10             	cmp    0x10(%ebp),%eax
80108bb4:	0f 82 75 ff ff ff    	jb     80108b2f <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108bba:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108bbd:	c9                   	leave  
80108bbe:	c3                   	ret    

80108bbf <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108bbf:	55                   	push   %ebp
80108bc0:	89 e5                	mov    %esp,%ebp
80108bc2:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108bc5:	8b 45 10             	mov    0x10(%ebp),%eax
80108bc8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108bcb:	72 08                	jb     80108bd5 <deallocuvm+0x16>
    return oldsz;
80108bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bd0:	e9 a5 00 00 00       	jmp    80108c7a <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108bd5:	8b 45 10             	mov    0x10(%ebp),%eax
80108bd8:	05 ff 0f 00 00       	add    $0xfff,%eax
80108bdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108be2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108be5:	e9 81 00 00 00       	jmp    80108c6b <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bed:	83 ec 04             	sub    $0x4,%esp
80108bf0:	6a 00                	push   $0x0
80108bf2:	50                   	push   %eax
80108bf3:	ff 75 08             	pushl  0x8(%ebp)
80108bf6:	e8 24 fa ff ff       	call   8010861f <walkpgdir>
80108bfb:	83 c4 10             	add    $0x10,%esp
80108bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108c01:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c05:	75 09                	jne    80108c10 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108c07:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108c0e:	eb 54                	jmp    80108c64 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c13:	8b 00                	mov    (%eax),%eax
80108c15:	83 e0 01             	and    $0x1,%eax
80108c18:	85 c0                	test   %eax,%eax
80108c1a:	74 48                	je     80108c64 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108c1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c1f:	8b 00                	mov    (%eax),%eax
80108c21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c26:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108c29:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108c2d:	75 0d                	jne    80108c3c <deallocuvm+0x7d>
        panic("kfree");
80108c2f:	83 ec 0c             	sub    $0xc,%esp
80108c32:	68 61 97 10 80       	push   $0x80109761
80108c37:	e8 2a 79 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80108c3c:	83 ec 0c             	sub    $0xc,%esp
80108c3f:	ff 75 ec             	pushl  -0x14(%ebp)
80108c42:	e8 56 f5 ff ff       	call   8010819d <p2v>
80108c47:	83 c4 10             	add    $0x10,%esp
80108c4a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108c4d:	83 ec 0c             	sub    $0xc,%esp
80108c50:	ff 75 e8             	pushl  -0x18(%ebp)
80108c53:	e8 de 9e ff ff       	call   80102b36 <kfree>
80108c58:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c5e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108c64:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c6e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c71:	0f 82 73 ff ff ff    	jb     80108bea <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108c77:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108c7a:	c9                   	leave  
80108c7b:	c3                   	ret    

80108c7c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108c7c:	55                   	push   %ebp
80108c7d:	89 e5                	mov    %esp,%ebp
80108c7f:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108c82:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108c86:	75 0d                	jne    80108c95 <freevm+0x19>
    panic("freevm: no pgdir");
80108c88:	83 ec 0c             	sub    $0xc,%esp
80108c8b:	68 67 97 10 80       	push   $0x80109767
80108c90:	e8 d1 78 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108c95:	83 ec 04             	sub    $0x4,%esp
80108c98:	6a 00                	push   $0x0
80108c9a:	68 00 00 00 80       	push   $0x80000000
80108c9f:	ff 75 08             	pushl  0x8(%ebp)
80108ca2:	e8 18 ff ff ff       	call   80108bbf <deallocuvm>
80108ca7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108caa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108cb1:	eb 4f                	jmp    80108d02 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80108cc0:	01 d0                	add    %edx,%eax
80108cc2:	8b 00                	mov    (%eax),%eax
80108cc4:	83 e0 01             	and    $0x1,%eax
80108cc7:	85 c0                	test   %eax,%eax
80108cc9:	74 33                	je     80108cfe <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd8:	01 d0                	add    %edx,%eax
80108cda:	8b 00                	mov    (%eax),%eax
80108cdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ce1:	83 ec 0c             	sub    $0xc,%esp
80108ce4:	50                   	push   %eax
80108ce5:	e8 b3 f4 ff ff       	call   8010819d <p2v>
80108cea:	83 c4 10             	add    $0x10,%esp
80108ced:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108cf0:	83 ec 0c             	sub    $0xc,%esp
80108cf3:	ff 75 f0             	pushl  -0x10(%ebp)
80108cf6:	e8 3b 9e ff ff       	call   80102b36 <kfree>
80108cfb:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108cfe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108d02:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108d09:	76 a8                	jbe    80108cb3 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108d0b:	83 ec 0c             	sub    $0xc,%esp
80108d0e:	ff 75 08             	pushl  0x8(%ebp)
80108d11:	e8 20 9e ff ff       	call   80102b36 <kfree>
80108d16:	83 c4 10             	add    $0x10,%esp
}
80108d19:	90                   	nop
80108d1a:	c9                   	leave  
80108d1b:	c3                   	ret    

80108d1c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108d1c:	55                   	push   %ebp
80108d1d:	89 e5                	mov    %esp,%ebp
80108d1f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108d22:	83 ec 04             	sub    $0x4,%esp
80108d25:	6a 00                	push   $0x0
80108d27:	ff 75 0c             	pushl  0xc(%ebp)
80108d2a:	ff 75 08             	pushl  0x8(%ebp)
80108d2d:	e8 ed f8 ff ff       	call   8010861f <walkpgdir>
80108d32:	83 c4 10             	add    $0x10,%esp
80108d35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108d38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108d3c:	75 0d                	jne    80108d4b <clearpteu+0x2f>
    panic("clearpteu");
80108d3e:	83 ec 0c             	sub    $0xc,%esp
80108d41:	68 78 97 10 80       	push   $0x80109778
80108d46:	e8 1b 78 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80108d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4e:	8b 00                	mov    (%eax),%eax
80108d50:	83 e0 fb             	and    $0xfffffffb,%eax
80108d53:	89 c2                	mov    %eax,%edx
80108d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d58:	89 10                	mov    %edx,(%eax)
}
80108d5a:	90                   	nop
80108d5b:	c9                   	leave  
80108d5c:	c3                   	ret    

80108d5d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108d5d:	55                   	push   %ebp
80108d5e:	89 e5                	mov    %esp,%ebp
80108d60:	53                   	push   %ebx
80108d61:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108d64:	e8 e6 f9 ff ff       	call   8010874f <setupkvm>
80108d69:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108d6c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108d70:	75 0a                	jne    80108d7c <copyuvm+0x1f>
    return 0;
80108d72:	b8 00 00 00 00       	mov    $0x0,%eax
80108d77:	e9 ee 00 00 00       	jmp    80108e6a <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80108d7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d83:	e9 ba 00 00 00       	jmp    80108e42 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0){
80108d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d8b:	83 ec 04             	sub    $0x4,%esp
80108d8e:	6a 00                	push   $0x0
80108d90:	50                   	push   %eax
80108d91:	ff 75 08             	pushl  0x8(%ebp)
80108d94:	e8 86 f8 ff ff       	call   8010861f <walkpgdir>
80108d99:	83 c4 10             	add    $0x10,%esp
80108d9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d9f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108da3:	75 0d                	jne    80108db2 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108da5:	83 ec 0c             	sub    $0xc,%esp
80108da8:	68 82 97 10 80       	push   $0x80109782
80108dad:	e8 b4 77 ff ff       	call   80100566 <panic>
     }
     if(!(*pte & PTE_P)){
80108db2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108db5:	8b 00                	mov    (%eax),%eax
80108db7:	83 e0 01             	and    $0x1,%eax
80108dba:	85 c0                	test   %eax,%eax
80108dbc:	74 7c                	je     80108e3a <copyuvm+0xdd>
       continue;
    //   panic("copyuvm: page not present");
     }
    pa = PTE_ADDR(*pte);
80108dbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dc1:	8b 00                	mov    (%eax),%eax
80108dc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dc8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108dcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dce:	8b 00                	mov    (%eax),%eax
80108dd0:	25 ff 0f 00 00       	and    $0xfff,%eax
80108dd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108dd8:	e8 f6 9d ff ff       	call   80102bd3 <kalloc>
80108ddd:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108de0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108de4:	74 6d                	je     80108e53 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108de6:	83 ec 0c             	sub    $0xc,%esp
80108de9:	ff 75 e8             	pushl  -0x18(%ebp)
80108dec:	e8 ac f3 ff ff       	call   8010819d <p2v>
80108df1:	83 c4 10             	add    $0x10,%esp
80108df4:	83 ec 04             	sub    $0x4,%esp
80108df7:	68 00 10 00 00       	push   $0x1000
80108dfc:	50                   	push   %eax
80108dfd:	ff 75 e0             	pushl  -0x20(%ebp)
80108e00:	e8 f9 cc ff ff       	call   80105afe <memmove>
80108e05:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108e08:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108e0b:	83 ec 0c             	sub    $0xc,%esp
80108e0e:	ff 75 e0             	pushl  -0x20(%ebp)
80108e11:	e8 7a f3 ff ff       	call   80108190 <v2p>
80108e16:	83 c4 10             	add    $0x10,%esp
80108e19:	89 c2                	mov    %eax,%edx
80108e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1e:	83 ec 0c             	sub    $0xc,%esp
80108e21:	53                   	push   %ebx
80108e22:	52                   	push   %edx
80108e23:	68 00 10 00 00       	push   $0x1000
80108e28:	50                   	push   %eax
80108e29:	ff 75 f0             	pushl  -0x10(%ebp)
80108e2c:	e8 8e f8 ff ff       	call   801086bf <mappages>
80108e31:	83 c4 20             	add    $0x20,%esp
80108e34:	85 c0                	test   %eax,%eax
80108e36:	78 1e                	js     80108e56 <copyuvm+0xf9>
80108e38:	eb 01                	jmp    80108e3b <copyuvm+0xde>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0){
      panic("copyuvm: pte should exist");
     }
     if(!(*pte & PTE_P)){
       continue;
80108e3a:	90                   	nop
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108e3b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e45:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e48:	0f 82 3a ff ff ff    	jb     80108d88 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e51:	eb 17                	jmp    80108e6a <copyuvm+0x10d>
    //   panic("copyuvm: page not present");
     }
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108e53:	90                   	nop
80108e54:	eb 01                	jmp    80108e57 <copyuvm+0xfa>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108e56:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108e57:	83 ec 0c             	sub    $0xc,%esp
80108e5a:	ff 75 f0             	pushl  -0x10(%ebp)
80108e5d:	e8 1a fe ff ff       	call   80108c7c <freevm>
80108e62:	83 c4 10             	add    $0x10,%esp
  return 0;
80108e65:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e6d:	c9                   	leave  
80108e6e:	c3                   	ret    

80108e6f <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108e6f:	55                   	push   %ebp
80108e70:	89 e5                	mov    %esp,%ebp
80108e72:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108e75:	83 ec 04             	sub    $0x4,%esp
80108e78:	6a 00                	push   $0x0
80108e7a:	ff 75 0c             	pushl  0xc(%ebp)
80108e7d:	ff 75 08             	pushl  0x8(%ebp)
80108e80:	e8 9a f7 ff ff       	call   8010861f <walkpgdir>
80108e85:	83 c4 10             	add    $0x10,%esp
80108e88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e8e:	8b 00                	mov    (%eax),%eax
80108e90:	83 e0 01             	and    $0x1,%eax
80108e93:	85 c0                	test   %eax,%eax
80108e95:	75 07                	jne    80108e9e <uva2ka+0x2f>
    return 0;
80108e97:	b8 00 00 00 00       	mov    $0x0,%eax
80108e9c:	eb 29                	jmp    80108ec7 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ea1:	8b 00                	mov    (%eax),%eax
80108ea3:	83 e0 04             	and    $0x4,%eax
80108ea6:	85 c0                	test   %eax,%eax
80108ea8:	75 07                	jne    80108eb1 <uva2ka+0x42>
    return 0;
80108eaa:	b8 00 00 00 00       	mov    $0x0,%eax
80108eaf:	eb 16                	jmp    80108ec7 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80108eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eb4:	8b 00                	mov    (%eax),%eax
80108eb6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ebb:	83 ec 0c             	sub    $0xc,%esp
80108ebe:	50                   	push   %eax
80108ebf:	e8 d9 f2 ff ff       	call   8010819d <p2v>
80108ec4:	83 c4 10             	add    $0x10,%esp
}
80108ec7:	c9                   	leave  
80108ec8:	c3                   	ret    

80108ec9 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108ec9:	55                   	push   %ebp
80108eca:	89 e5                	mov    %esp,%ebp
80108ecc:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108ecf:	8b 45 10             	mov    0x10(%ebp),%eax
80108ed2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108ed5:	eb 7f                	jmp    80108f56 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108eda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108edf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108ee2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ee5:	83 ec 08             	sub    $0x8,%esp
80108ee8:	50                   	push   %eax
80108ee9:	ff 75 08             	pushl  0x8(%ebp)
80108eec:	e8 7e ff ff ff       	call   80108e6f <uva2ka>
80108ef1:	83 c4 10             	add    $0x10,%esp
80108ef4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108ef7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108efb:	75 07                	jne    80108f04 <copyout+0x3b>
      return -1;
80108efd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f02:	eb 61                	jmp    80108f65 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108f04:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f07:	2b 45 0c             	sub    0xc(%ebp),%eax
80108f0a:	05 00 10 00 00       	add    $0x1000,%eax
80108f0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f15:	3b 45 14             	cmp    0x14(%ebp),%eax
80108f18:	76 06                	jbe    80108f20 <copyout+0x57>
      n = len;
80108f1a:	8b 45 14             	mov    0x14(%ebp),%eax
80108f1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108f20:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f23:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108f26:	89 c2                	mov    %eax,%edx
80108f28:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f2b:	01 d0                	add    %edx,%eax
80108f2d:	83 ec 04             	sub    $0x4,%esp
80108f30:	ff 75 f0             	pushl  -0x10(%ebp)
80108f33:	ff 75 f4             	pushl  -0xc(%ebp)
80108f36:	50                   	push   %eax
80108f37:	e8 c2 cb ff ff       	call   80105afe <memmove>
80108f3c:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f42:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f48:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108f4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f4e:	05 00 10 00 00       	add    $0x1000,%eax
80108f53:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108f56:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108f5a:	0f 85 77 ff ff ff    	jne    80108ed7 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108f60:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f65:	c9                   	leave  
80108f66:	c3                   	ret    
