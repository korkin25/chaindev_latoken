Chaindev_Latoken Core integration/staging tree
=====================================

[![Build Status](https://travis-ci.org/LAToken/chaindev_latoken.svg?branch=master)](https://travis-ci.org/LAToken/chaindev_latoken)
Форкаем https://github.com/litecoin-project/litecoin. 
1. Придумываем название для нашего токена - например, chaindev_latoken.
2. Переименовываем склонированную папку в chaindev_latoken.
3. В ней в терминале делаем команду grep -rl 'litecoin' ./ | xargs sed -i 's/litecoin/chaindev_latoken/g' - команда заменит все вхождения litecoin в файлах на chaindev_latoken и после сборки сгенерирует файлы chaindev_latokend и chaindev_latoken-cli как у биткоина только с названием вашего альта.

Инструкция по выставлению параметров:
1. Основное действие происходит в файле src/chainparams.cpp. Меняем параметры класса CTestNetParams, но то же самое можно делать и с CChainMainNetParams. Выставляйте consensus.BIP34Height = 0; сonsensus.BIP34Hash = uint256S("0x00"); consensus.BIP65Height = 0; consensus.BIP66Height = 0; - значения с каких блоков в основной цепочке принимаются изменения протоколов BIP34, BIP65, BIP66 - у нас они сразу же. 
2. consensus.powLimit = uint256S("0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff") - выставляется в отличии от биткоина всего с 1 начальным нулем, ибо мы для начала хотим такую сложность сети, чтобы быстро генерить блоки - это верхний предел для сложности генерации блоков. О difficulty можно почитать тут - https://bitcoin.org/en/developer-reference#target-nbits и вообще https://bitcoin.org/en/developer-reference и https://bitcoin.org/en/developer-guide для понимания того, как работает блокчейн биткоина. 
3. consensus.nPowTargetTimespan = 4 * 60; - 4 минуты, сколько продолжается время для текущей сложности
4. consensus.nPowTargetSpacing = 60; - 1 минута, через сколько генерятся блоки в цепочке;      consensus.nMinerConfirmationWindow = consensus.nPowTargetTimespan / consensus.nPowTargetSpacing; - через сколько блоков меняется сложность consensus.nRuleChangeActivationThreshold = 0.75 * consensus.nMinerConfirmationWindow; - 75% от предыдущего параметра для тестовой сети и 95% для основной сети. consensus.fPowAllowMinDifficultyBlocks = true - нам нужна минимальная сложность; consensus.fPowNoRetargeting = false - мы хотим retargeting; 
consensus.nMinimumChainWork = uint256S("0x00") - вначале 0 для сети; consensus.defaultAssumeValid = uint256S("0x00"); - валидная цепочка для нулевого блока (параметр для оптимизации, не влияющий на запуск сети) pchMessageStart[0] = 0xf2; pchMessageStart[1] = 0xde; pchMessageStart[2] = 0xc3; pchMessageStart[3] = 0xf5; - ставьте какими угодно, примерно радномными, странный параметр, скорее всего используется для генерации сообщений между нодами в сети с определенным началом nDefaultPort = 55103; - выставляем внутренний порт для своей сети; nPruneAfterHeight = 1000; - через сколько блоков в цепочке удалять старые блоки. Дальше как в файле src/chainparams.cpp вставляете кусок, начиная с unsigned int nBits = 0x00001000; до genesis = CreateGenesisBlock(secs, nNonce, nBits, 1, 50 * COIN); - это генерирует вам нужные параметры timestamp, nNonce, nBits. Затем после генерации закомменьте часть с циклами и выставите найденные константые значение и собирете снова. Закомменьте следующие строчки от assert до base58 невключительно. Выставьте в первых четырех массивах base58Prefixes вторые элементы какие хотите до 255 - для того, чтобы ваши адреса сети имели специфичный вид. В последних двух третий и четвертый элементы. checkpointData = {
    {
        {0, consensus.hashGenesisBlock},
    }
}; chainTxData = ChainTxData{
    0,
    0,
    0
}; - выставьте как в src/chainparams.cpp - это данные для проверки уже имеющихся блоков.
4. Далее в chainparamsbase.cpp в классе CBaseTestNetParams выставьте нужный вам nRPCPort, по которому вы будете делать RPC запросы и укажите после в chaindev_latoken.conf (-rpcport).
5. В chainparamsseeds.h в pnSeed6_test выставьте в формате hex ipv4 адреса (они равны первые два байта 0xff и 0xff, далее преобразованные сами в hex формат). Порты выставьте равные nDefaultPort.
6. В файле amount.h можете поменять static const CAmount MAX_MONEY = 84000000 * COIN; например на 10^8.
7. В файле consensus/consensus.h можете поменять static const unsigned int MAX_BLOCK_SERIALIZED_SIZE = 2500000;
static const unsigned int MAX_BLOCK_WEIGHT = 2500000; с 4 миллионов байт на 2,5. COINBASE_MATURITY со 100 на 6 - это после скольки блоков майнеру можно будет вывести свою награду за создание блока.


Инстуркция по запуску:

1. git clone https://github.com/LAToken/chaindev_latoken.git
2. cd chaindev_latoken
3. ./autogen.sh
4. ./configure
5. make
6. ./src/chaindev_latokend -testnet
7. Подождите и получите secs и nNonce.
8. Поменяйте их значения на полученные в файле /src/chainparams.cpp в классе CTestNetParams. Закомментируйте: 
        for (; nNonce < (int)2e9; ++nNonce) {       
            genesis = CreateGenesisBlock(secs, nNonce, 0x1e0ffff0, 1, 50 * COIN);
            consensus.hashGenesisBlock = genesis.GetHash();
            arith_uint256 bnTarget;
            bool fNegative, fOveflow;
            bnTarget.SetCompact(0x1e0ffff0, &fNegative, &fOveflow);
            if (UintToArith256(genesis.GetPoWHash()) <= bnTarget) {
                consensus.hashGenesisBlock = genesis.GetHash();
                break;
            }
        }
        fprintf(stderr, "nNonce: %d ||| secs: %d\n", nNonce, secs);
9. Снова make и ./src/chaindev_latokend -testnet
10. Сеть локально запущена, к ней можно обращаться через ./src/chaindev_latoken-cli -testnet <commmand> (вместо <command> например getnewaddress - выведи произвольный валидный адрес в сети или generate n m - намайни до n блоков за m итераций).

Важный update: выбор так называемого параметра блока nBits в src/chainparams.cpp, который определяет таргет для майнеров. Его нужно выбирать в зависимости от выставленного consensus.powLimit. Для uint256S("0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff") - на старте подходят все хеши с одним нулем вначале, что является начальным таргетом для развертывания тестовой сети, ибо мы хотим генерировать блоки быстро с обычным процессором. Для него подходят исходные nBits. выставленные в сети у genesisBlock у litecoin и bitcoin. Для значений с большим числом нулей - его также надо перебрать с помощью тупого перебора всех uint32 и условий в файле src/pow.cpp. Обновленнйы код можно посмотреть в файле src/chainparams.cpp в классе CChainTestNetParams.   
   
