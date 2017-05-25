

import math

MAX=100
def mandelbrot(c):
    z = 0
    i = 0
    while abs(z) < 2 and i < MAX:
        z = z**2 + c
        i += 1
    return i



def color(mag):
    cmin=0
    cmax=MAX
    """ Return a tuple of floats between 0 and 1 for R, G, and B. """
    # Normalize to 0-1
    try: x = float(mag-cmin)/(cmax-cmin)
    except ZeroDivisionError: x = 0.5 # cmax == cmin
    blue  = int(min((max((4*(0.75-x), 0.)), 1.))*255)
    red   = int(min((max((4*(x-0.25), 0.)), 1.))*255)
    green = int(min((max((4*math.fabs(x-0.5)-1., 0.)), 1.))*255)
    return (red, green, blue)

def bw(mag):
    v = int(mag/MAX*255)
    return (v, v, v)

def main_gui():

    c_start, c_end = -1.5 +1j, 1 - 1j
    #WIDTH, HEIGHT = 1280, 1024
    WIDTH, HEIGHT = 320, 240
    WIDTH, HEIGHT = 640, 480
    SF = 2

    mouse_state = [0, 0]

    rect = [[0,0], [0,0]]

    def pix2c(x, y):
        cx = x * (c_end.real - c_start.real) / WIDTH
        cy = y * (c_end.imag - c_start.imag) / HEIGHT
        return cx + cy*1j + c_start

    import pygame

    pygame.init()
    screen = pygame.display.set_mode((WIDTH*SF, HEIGHT*SF))

    while (True):

        for x in range(WIDTH):
            #print('{:2.0f}%'.format(x / WIDTH * 100))
            for y in range(HEIGHT):
                pix = color(mandelbrot(pix2c(x, y)))
                pygame.draw.rect(screen, pix, (x*SF, y*SF, SF, SF), 0)

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    pygame.quit()
                    sys.exit()

            pygame.display.update()

            mouse_state[0] = pygame.mouse.get_pressed()[0]
            if mouse_state[0] != mouse_state[1] and mouse_state[0]:
                print('presset at ', pygame.mouse.get_pos())
                rect[0] = pygame.mouse.get_pos()

            if mouse_state[0]:
                rect[1] = pygame.mouse.get_pos()
                pygame.draw.rect(screen, (255, 0, 0), (rect[0][0], rect[0][1], rect[1][0]-rect[0][0], rect[1][1]-rect[0][1]), 1)

            if mouse_state[0] != mouse_state[1] and not mouse_state[0]:
                print('release at ', pygame.mouse.get_pos())
                c_start = pix2c(rect[0][0]/SF, rect[0][1]/SF)
                c_end = pix2c(rect[1][0]/SF, rect[1][1]/SF)
                mouse_state[1] = mouse_state[0]
                break

            mouse_state[1] = mouse_state[0]

        # check for quit events



def fix_point(val, n_bit, decimals):
    mask = int(2**n_bit)-1
    val_int = int( val * 2**(n_bit-decimals-1)) & mask
    format ='0x{:0' + '{:d}'.format(math.ceil(n_bit/4)) +'x}'
    return format.format(val_int)


def main_test_fix_point():
    test_vector = (1, 2, .5, .25, .75, 2.25, 1.125, -1, -.25)

    for f in test_vector:
        print('{},  -> {}'.format(f, fix_point(f, 16, 3)))


NBIT=18
DEC = 4

def mandelbrot_test_vector():

    test_vector = (
        0.5 + .25j,
        .5 + .3j,
        .7 + .4j,
        -.4 + .7j,
        -0.6 - .8j,
        .8 - .7j,
        0,
    )

    for c in test_vector:
        print('complex "{}" = [re={}, img={}] -> mandelbrot = "{}"'.format(c, fix_point(c.real, NBIT, DEC), fix_point(c.imag, NBIT, DEC), mandelbrot(c)))



def one_loop_test_vector():

    test_vector = (
        ((.5 +.5j), (.5 +.5j)),
        ((.5 + .5j), (.0 +0j)),
        ((2 + 1.5j), (.0 + 0j)),
        (0.5 + .25j, .5 + .3j),
        (.7 + .4j, -.4 + .7j),
        (-0.6 - .8j, .8 - .7j),
    )

    def mandel(z, c):
        return z**2 + c

    def str_clx_fix(var, value):
        return '{}={}[re={}, img={}]'.format(var, value, fix_point(value.real, NBIT, DEC), fix_point(value.imag, NBIT, DEC))

    i = 0
    for zi, ci in test_vector:
        i += 1
        print()
        print('case {}:'.format(i))
        print(str_clx_fix('Zi', zi) + ', ' + str_clx_fix('Ci', ci) )
        print(' -> ' + str_clx_fix('Zi+1', mandel(zi, ci)) + ', Diverge={}'.format(abs(zi)>2))




def main():
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--show', action='store_true', default=False, help='show the calculate mandelbrot')
    parser.add_argument('-f', '--full-vector', action='store_true', default=False, help='Show the test vector for the full mandelbrot calculation')
    parser.add_argument('-p', '--partial-vector', action='store_true', default=False, help='Show the test vector for one mandelbrot calcaution step')


    args = parser.parse_args()

    if args.show:
        main_gui()

    if args.full_vector:
        mandelbrot_test_vector()

    if args.partial_vector:
        one_loop_test_vector()

if __name__ == '__main__':
    import sys
    sys.exit(main())