import random
import time

start_time=time.time()
def blakley_multiplication (a, b, n):
        # a * b mod n
    R = 0
    b_bin="{0:0256b}".format(b)
    k = len(b_bin)

    for i in range(0,k):
            #print(f"bl {i}")
            R= 2 * R + (int((b >> (k - 1 - i)) & 1)) * a
            #print((b >> (k - 1 - i)) & 1)
            if R>= n:
                R = R - n
            if R>=n:
                R = R - n
    return R


def mod_exp_binary(M, exp, mod):
    # Convert the exponent to its binary form
    bin_exp = bin(exp)[2:]  # Exp in binary form
    length = len(bin_exp)
    if bin_exp[length-1]=='1' :
        C=M
    else :
        C=1
    
    for i in range (length-2,-1,-1):
        C=blakley_multiplication(C,C,mod)
        if bin_exp[i]==1:
            C=blakley_multiplication(C,M,mod)
    return C


def test_prepocessing (base, exp, mod) :
    result = mod_exp_binary(base, exp, mod)
    result=blakley_multiplication(base,exp,mod)
    #print(f"Result of {base}^{exp} mod {mod} = {result}")
    return result

def gen_rand():
  base = random.randint(1000000,10000000000)
  exp  = random.randint(1000000,10000000000)
  modulo = random.randrange(base, base+10000, 2)
  return base, exp, modulo

# moyenne=0
# for i in range(100) :
#     start_time=time.time()
#     base, exp, modulo = gen_rand()
#     r1=test_prepocessing(base,exp,modulo)
#     #r2=test_prepocessing(base, exp, modulo)
#     '''if r1 != r2 :
#         print(f"correct : {(base**exp)%modulo} R1 : {r1} and R2 {r2}\n")
#     else :
#         print("correct")'''
#     moyenne += time.time() - start_time

# print(f"programme : {moyenne/100}")


def test_encrypt():
      print("en")
      message = "0x0000000011111111222222223333333344444444555555556666666677777777"
      m = int(message, 0)

      power = "0x0000000000000000000000000000000000000000000000000000000000010001"
      e = int(power, 0)

      n = "0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d"
      n = int(n, 0)

      expected = int("0x23026c469918f5ea097f843dc5d5259192f9d3510415841ce834324f4c237ac7",0)
      actual = mod_exp_binary(m, e, n)
      if expected==actual :
        print("Encryption successful\n")
      else :
          print("Test encryption mauvais")

def test_decrypt():
       print("de")
       message = "0x23026c469918f5ea097f843dc5d5259192f9d3510415841ce834324f4c237ac7"
       c = int(message, 0)

       power = "0x0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9"
       d = int(power, 0)

       n = "0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d"
       n = int(n, 0)

       expected = int("0x0000000011111111222222223333333344444444555555556666666677777777", 0)
       actual = mod_exp_binary(c, d, n)
       if expected==actual :
            print("Decryption successful\n")
       else :
            print("Test Decryption mauvais")


moyenne=0

# start_time=time.time()
# test_encrypt()
# test_decrypt()
#test_prepocessing(2,5,3)
# moyenne += time.time() - start_time

# print(f"programme encrypt : {moyenne/100}")
#test_encrypt()
#test_decrypt()
value1 = int("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA", 16)
print(value1)
value2 = int("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9", 16)
mod = int("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB", 16)
blakley_multiplication(value1, value2, mod)