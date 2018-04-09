Chaindev_Latoken Core integration/staging tree
=====================================

[![Build Status](https://travis-ci.org/LAToken/chaindev_latoken.svg?branch=master)](https://travis-ci.org/LAToken/chaindev_latoken)


Инстуркция по запуску:

1. git clone https://github.com/LAToken/chaindev_latoken.git
2. cd chaindev_latoken
3. ./autogen.sh
4. ./configure
5. make
6. ./src/chaindev_latokend -testnet
7. Подождите и получите secs и nNonce.
8. Поменяйте их значения на полученные в файле /src/chainparams.cpp в классе CTestNetParams. Закомментируйте: 
        for (; nNonce < (int)1e9; ++nNonce) {       
            genesis = CreateGenesisBlock(secs, nNonce, 0x1e0ffff0, 1, 50 * COIN);
            consensus.hashGenesisBlock = genesis.GetHash();
            arith_uint256 bnTarget;
            bool fNegative, fOveflow;
            bnTarget.SetCompact(0x1e0ffff0, &fNegative, &fOveflow);
            if (UintToArith256(consensus.hashGenesisBlock) <= bnTarget) {
                break;
            }
        }
        fprintf(stderr, "nNonce: %d ||| secs: %d\n", nNonce, secs);
9. Снова make и ./src/chaindev_latokend -testnet
10. Сеть локально запущена, к ней можно обращаться через ./src/chaindev_latoken-cli -testnet <commmand> (вместо <command> например getnewaddress - выведи произвольный валидный адрес в сети или generate n m - намайни до n блоков за m итераций).

Update: выбор так называемого параметра блока nBits, который определяет таргет для майнеров. Его нужно выбирать в зависимости от выставленного consensus.powLimit. Для uint256S("0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff") - на старте подходят все хеши с одним нулем вначале, что является начальным таргетом для развертывания тестовой сети, ибо мы хотим генерировать блоки быстро с обычным процессором. Для него подходят исходные nBits. выставленные в сети у genesisBlock у litecoin и bitcoin. Для значений с большим числом нулей - его также надо перебрать с помощью тупого перебора всех uint32 и условий в файле src/pow.cpp:

unsigned int nBits = 0x00001000;
for (; nBits < 0xffffffff; ++nBits) {
    arith_uint256 bnTarget;
    bool fNegative, fOverflow;
    bnTarget.SetCompact(nBits, &fNegative, &fOverflow);
    if (!fNegative && bnTarget != 0 && !fOverflow && bnTarget <= UintToArith256(consensus.powLimit)) {
        break;
    }
}
        
   
