//
//  ISO3166.swift
//  Moody
//
//  Created by Daniel Eggert on 12/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation

struct ISO3166 {
    enum Country: Int16 {
        case guy = 328
        case pol = 616
        case ltu = 440
        case nic = 558
        case isl = 352
        case lao = 418
        case btn = 64
        case plw = 585
        case hkg = 344
        case cze = 203
        case dza = 12
        case civ = 384
        case grl = 304
        case msr = 500
        case cub = 192
        case bwa = 72
        case nor = 578
        case swz = 748
        case fin = 246
        case uga = 800
        case alb = 8
        case cym = 136
        case eri = 232
        case blz = 84
        case mnp = 580
        case tur = 792
        case hun = 348
        case sjm = 744
        case ven = 862
        case egy = 818
        case nru = 520
        case twn = 158
        case mex = 484
        case abw = 533
        case vgb = 92
        case gab = 266
        case can = 124
        case imn = 833
        case gum = 316
        case sen = 686
        case gib = 292
        case cok = 184
        case tuv = 798
        case brb = 52
        case bdi = 108
        case blm = 652
        case ssd = 728
        case syc = 690
        case gha = 288
        case lva = 428
        case nam = 516
        case brn = 96
        case nld = 528
        case jor = 400
        case glp = 312
        case che = 756
        case aia = 660
        case svk = 703
        case com = 174
        case irl = 372
        case shn = 654
        case bvt = 74
        case mlt = 470
        case sgp = 702
        case ton = 776
        case tgo = 768
        case nzl = 554
        case bel = 56
        case sle = 694
        case jpn = 392
        case vut = 548
        case bmu = 60
        case mac = 446
        case npl = 524
        case mdv = 462
        case kgz = 417
        case tun = 788
        case prt = 620
        case tto = 780
        case ind = 356
        case pry = 600
        case ner = 562
        case lie = 438
        case bhs = 44
        case kaz = 398
        case dnk = 208
        case cri = 188
        case phl = 608
        case nfk = 574
        case bes = 535
        case lbn = 422
        case fro = 234
        case dom = 214
        case blr = 112
        case chn = 156
        case vat = 336
        case grd = 308
        case bra = 76
        case gmb = 270
        case mng = 496
        case tcd = 148
        case mwi = 454
        case lbr = 430
        case moz = 508
        case ago = 24
        case kna = 659
        case atg = 28
        case ury = 858
        case grc = 300
        case arm = 51
        case hmd = 334
        case esp = 724
        case cuw = 531
        case cpv = 132
        case cod = 180
        case mli = 466
        case dma = 212
        case khm = 116
        case aus = 36
        case cog = 178
        case ben = 204
        case fsm = 583
        case pse = 275
        case are = 784
        case gin = 324
        case bfa = 854
        case irq = 368
        case bhr = 48
        case aut = 40
        case iot = 86
        case som = 706
        case afg = 4
        case zaf = 710
        case dji = 262
        case hnd = 340
        case mhl = 584
        case rus = 643
        case vct = 670
        case est = 233
        case gbr = 826
        case qat = 634
        case mtq = 474
        case per = 604
        case ecu = 218
        case srb = 688
        case jam = 388
        case mkd = 807
        case col = 170
        case kor = 410
        case tls = 626
        case lca = 662
        case tza = 834
        case smr = 674
        case hti = 332
        case gtm = 320
        case lso = 426
        case deu = 276
        case mmr = 104
        case idn = 360
        case ncl = 540
        case pak = 586
        case hrv = 191
        case esh = 732
        case flk = 238
        case pan = 591
        case irn = 364
        case and = 20
        case umi = 581
        case svn = 705
        case bih = 70
        case fra = 250
        case tca = 796
        case kwt = 414
        case stp = 678
        case ant = 530
        case tkm = 795
        case tkl = 772
        case cyp = 196
        case eth = 231
        case prk = 408
        case sgs = 239
        case ggy = 831
        case yem = 887
        case mus = 480
        case aze = 31
        case guf = 254
        case cxr = 162
        case ken = 404
        case lka = 144
        case asm = 16
        case pyf = 258
        case rwa = 646
        case atf = 260
        case mdg = 450
        case mrt = 478
        case sxm = 534
        case fji = 242
        case png = 598
        case lux = 442
        case mda = 498
        case isr = 376
        case bol = 68
        case sau = 682
        case swe = 752
        case spm = 666
        case usa = 840
        case caf = 140
        case sdn = 736
        case slb = 90
        case zmb = 894
        case cck = 166
        case ala = 248
        case kir = 296
        case mys = 458
        case myt = 175
        case mco = 492
        case pri = 630
        case rou = 642
        case vnm = 704
        case tha = 764
        case vir = 850
        case ata = 10
        case arg = 32
        case bgr = 100
        case chl = 152
        case tjk = 762
        case wsm = 882
        case niu = 570
        case ita = 380
        case geo = 268
        case wlf = 876
        case jey = 832
        case gnq = 226
        case cmr = 120
        case gnb = 624
        case reu = 638
        case zwe = 716
        case ukr = 804
        case pcn = 612
        case mar = 504
        case uzb = 860
        case bgd = 50
        case maf = 663
        case sur = 740
        case syr = 760
        case slv = 222
        case lby = 434
        case omn = 512
        case mne = 499
        case nga = 566
        case unknown = 0
    }

    enum Continent: Int16 {
        case na = 10001
        case an = 10002
        case eu = 10003
        case af = 10004
        case `as` = 10005
        case sa = 10006
        case oc = 10007
    }
}

private let countriesAndContinents: [(ISO3166.Continent, ISO3166.Country)] = [
    (.as, .afg),
    (.eu, .alb),
    (.an, .ata),
    (.af, .dza),
    (.oc, .asm),
    (.eu, .and),
    (.af, .ago),
    (.na, .atg),
    (.eu, .aze),
    (.as, .aze),
    (.sa, .arg),
    (.oc, .aus),
    (.eu, .aut),
    (.na, .bhs),
    (.as, .bhr),
    (.as, .bgd),
    (.eu, .arm),
    (.as, .arm),
    (.na, .brb),
    (.eu, .bel),
    (.na, .bmu),
    (.as, .btn),
    (.sa, .bol),
    (.eu, .bih),
    (.af, .bwa),
    (.an, .bvt),
    (.sa, .bra),
    (.na, .blz),
    (.as, .iot),
    (.oc, .slb),
    (.na, .vgb),
    (.as, .brn),
    (.eu, .bgr),
    (.as, .mmr),
    (.af, .bdi),
    (.eu, .blr),
    (.as, .khm),
    (.af, .cmr),
    (.na, .can),
    (.af, .cpv),
    (.na, .cym),
    (.af, .caf),
    (.as, .lka),
    (.af, .tcd),
    (.sa, .chl),
    (.as, .chn),
    (.as, .twn),
    (.as, .cxr),
    (.as, .cck),
    (.sa, .col),
    (.af, .com),
    (.af, .myt),
    (.af, .cog),
    (.af, .cod),
    (.oc, .cok),
    (.na, .cri),
    (.eu, .hrv),
    (.na, .cub),
    (.eu, .cyp),
    (.as, .cyp),
    (.eu, .cze),
    (.af, .ben),
    (.eu, .dnk),
    (.na, .dma),
    (.na, .dom),
    (.sa, .ecu),
    (.na, .slv),
    (.af, .gnq),
    (.af, .eth),
    (.af, .eri),
    (.eu, .est),
    (.eu, .fro),
    (.sa, .flk),
    (.an, .sgs),
    (.oc, .fji),
    (.eu, .fin),
    (.eu, .ala),
    (.eu, .fra),
    (.sa, .guf),
    (.oc, .pyf),
    (.an, .atf),
    (.af, .dji),
    (.af, .gab),
    (.eu, .geo),
    (.as, .geo),
    (.af, .gmb),
    (.as, .pse),
    (.eu, .deu),
    (.af, .gha),
    (.eu, .gib),
    (.oc, .kir),
    (.eu, .grc),
    (.na, .grl),
    (.na, .grd),
    (.na, .glp),
    (.oc, .gum),
    (.na, .gtm),
    (.af, .gin),
    (.sa, .guy),
    (.na, .hti),
    (.an, .hmd),
    (.eu, .vat),
    (.na, .hnd),
    (.as, .hkg),
    (.eu, .hun),
    (.eu, .isl),
    (.as, .ind),
    (.as, .idn),
    (.as, .irn),
    (.as, .irq),
    (.eu, .irl),
    (.as, .isr),
    (.eu, .ita),
    (.af, .civ),
    (.na, .jam),
    (.as, .jpn),
    (.eu, .kaz),
    (.as, .kaz),
    (.as, .jor),
    (.af, .ken),
    (.as, .prk),
    (.as, .kor),
    (.as, .kwt),
    (.as, .kgz),
    (.as, .lao),
    (.as, .lbn),
    (.af, .lso),
    (.eu, .lva),
    (.af, .lbr),
    (.af, .lby),
    (.eu, .lie),
    (.eu, .ltu),
    (.eu, .lux),
    (.as, .mac),
    (.af, .mdg),
    (.af, .mwi),
    (.as, .mys),
    (.as, .mdv),
    (.af, .mli),
    (.eu, .mlt),
    (.na, .mtq),
    (.af, .mrt),
    (.af, .mus),
    (.na, .mex),
    (.eu, .mco),
    (.as, .mng),
    (.eu, .mda),
    (.eu, .mne),
    (.na, .msr),
    (.af, .mar),
    (.af, .moz),
    (.as, .omn),
    (.af, .nam),
    (.oc, .nru),
    (.as, .npl),
    (.eu, .nld),
    (.na, .ant),
    (.na, .cuw),
    (.na, .abw),
    (.na, .sxm),
    (.na, .bes),
    (.oc, .ncl),
    (.oc, .vut),
    (.oc, .nzl),
    (.na, .nic),
    (.af, .ner),
    (.af, .nga),
    (.oc, .niu),
    (.oc, .nfk),
    (.eu, .nor),
    (.oc, .mnp),
    (.oc, .umi),
    (.na, .umi),
    (.oc, .fsm),
    (.oc, .mhl),
    (.oc, .plw),
    (.as, .pak),
    (.na, .pan),
    (.oc, .png),
    (.sa, .pry),
    (.sa, .per),
    (.as, .phl),
    (.oc, .pcn),
    (.eu, .pol),
    (.eu, .prt),
    (.af, .gnb),
    (.as, .tls),
    (.na, .pri),
    (.as, .qat),
    (.af, .reu),
    (.eu, .rou),
    (.eu, .rus),
    (.as, .rus),
    (.af, .rwa),
    (.na, .blm),
    (.af, .shn),
    (.na, .kna),
    (.na, .aia),
    (.na, .lca),
    (.na, .maf),
    (.na, .spm),
    (.na, .vct),
    (.eu, .smr),
    (.af, .stp),
    (.as, .sau),
    (.af, .sen),
    (.eu, .srb),
    (.af, .syc),
    (.af, .sle),
    (.as, .sgp),
    (.eu, .svk),
    (.as, .vnm),
    (.eu, .svn),
    (.af, .som),
    (.af, .zaf),
    (.af, .zwe),
    (.eu, .esp),
    (.af, .ssd),
    (.af, .esh),
    (.af, .sdn),
    (.sa, .sur),
    (.eu, .sjm),
    (.af, .swz),
    (.eu, .swe),
    (.eu, .che),
    (.as, .syr),
    (.as, .tjk),
    (.as, .tha),
    (.af, .tgo),
    (.oc, .tkl),
    (.oc, .ton),
    (.na, .tto),
    (.as, .are),
    (.af, .tun),
    (.eu, .tur),
    (.as, .tur),
    (.as, .tkm),
    (.na, .tca),
    (.oc, .tuv),
    (.af, .uga),
    (.eu, .ukr),
    (.eu, .mkd),
    (.af, .egy),
    (.eu, .gbr),
    (.eu, .ggy),
    (.eu, .jey),
    (.eu, .imn),
    (.af, .tza),
    (.na, .usa),
    (.na, .vir),
    (.af, .bfa),
    (.sa, .ury),
    (.as, .uzb),
    (.sa, .ven),
    (.oc, .wlf),
    (.oc, .wsm),
    (.as, .yem),
    (.af, .zmb),
]

extension ISO3166.Continent {
    init?(country: ISO3166.Country) {
        let cc = countriesAndContinents.first { $0.1 == country }
        guard let (continent, _) = cc else { return nil }
        self = continent
    }
}

extension ISO3166.Country {
    static func fromISO3166(_ s: String) -> ISO3166.Country {
        switch (s.lowercased()) {
        case "guy": return .guy
        case "pol": return .pol
        case "ltu": return .ltu
        case "nic": return .nic
        case "isl": return .isl
        case "lao": return .lao
        case "btn": return .btn
        case "plw": return .plw
        case "hkg": return .hkg
        case "cze": return .cze
        case "dza": return .dza
        case "civ": return .civ
        case "grl": return .grl
        case "msr": return .msr
        case "cub": return .cub
        case "bwa": return .bwa
        case "nor": return .nor
        case "swz": return .swz
        case "fin": return .fin
        case "uga": return .uga
        case "alb": return .alb
        case "cym": return .cym
        case "eri": return .eri
        case "blz": return .blz
        case "mnp": return .mnp
        case "tur": return .tur
        case "hun": return .hun
        case "sjm": return .sjm
        case "ven": return .ven
        case "egy": return .egy
        case "nru": return .nru
        case "twn": return .twn
        case "mex": return .mex
        case "abw": return .abw
        case "vgb": return .vgb
        case "gab": return .gab
        case "can": return .can
        case "imn": return .imn
        case "gum": return .gum
        case "sen": return .sen
        case "gib": return .gib
        case "cok": return .cok
        case "tuv": return .tuv
        case "brb": return .brb
        case "bdi": return .bdi
        case "blm": return .blm
        case "ssd": return .ssd
        case "syc": return .syc
        case "gha": return .gha
        case "lva": return .lva
        case "nam": return .nam
        case "brn": return .brn
        case "nld": return .nld
        case "jor": return .jor
        case "glp": return .glp
        case "che": return .che
        case "aia": return .aia
        case "svk": return .svk
        case "com": return .com
        case "irl": return .irl
        case "shn": return .shn
        case "bvt": return .bvt
        case "mlt": return .mlt
        case "sgp": return .sgp
        case "ton": return .ton
        case "tgo": return .tgo
        case "nzl": return .nzl
        case "bel": return .bel
        case "sle": return .sle
        case "jpn": return .jpn
        case "vut": return .vut
        case "bmu": return .bmu
        case "mac": return .mac
        case "npl": return .npl
        case "mdv": return .mdv
        case "kgz": return .kgz
        case "tun": return .tun
        case "prt": return .prt
        case "tto": return .tto
        case "ind": return .ind
        case "pry": return .pry
        case "ner": return .ner
        case "lie": return .lie
        case "bhs": return .bhs
        case "kaz": return .kaz
        case "dnk": return .dnk
        case "cri": return .cri
        case "phl": return .phl
        case "nfk": return .nfk
        case "bes": return .bes
        case "lbn": return .lbn
        case "fro": return .fro
        case "dom": return .dom
        case "blr": return .blr
        case "chn": return .chn
        case "vat": return .vat
        case "grd": return .grd
        case "bra": return .bra
        case "gmb": return .gmb
        case "mng": return .mng
        case "tcd": return .tcd
        case "mwi": return .mwi
        case "lbr": return .lbr
        case "moz": return .moz
        case "ago": return .ago
        case "kna": return .kna
        case "atg": return .atg
        case "ury": return .ury
        case "grc": return .grc
        case "arm": return .arm
        case "hmd": return .hmd
        case "esp": return .esp
        case "cuw": return .cuw
        case "cpv": return .cpv
        case "cod": return .cod
        case "mli": return .mli
        case "dma": return .dma
        case "khm": return .khm
        case "aus": return .aus
        case "cog": return .cog
        case "ben": return .ben
        case "fsm": return .fsm
        case "pse": return .pse
        case "are": return .are
        case "gin": return .gin
        case "bfa": return .bfa
        case "irq": return .irq
        case "bhr": return .bhr
        case "aut": return .aut
        case "iot": return .iot
        case "som": return .som
        case "afg": return .afg
        case "zaf": return .zaf
        case "dji": return .dji
        case "hnd": return .hnd
        case "mhl": return .mhl
        case "rus": return .rus
        case "vct": return .vct
        case "est": return .est
        case "gbr": return .gbr
        case "qat": return .qat
        case "mtq": return .mtq
        case "per": return .per
        case "ecu": return .ecu
        case "srb": return .srb
        case "jam": return .jam
        case "mkd": return .mkd
        case "col": return .col
        case "kor": return .kor
        case "tls": return .tls
        case "lca": return .lca
        case "tza": return .tza
        case "smr": return .smr
        case "hti": return .hti
        case "gtm": return .gtm
        case "lso": return .lso
        case "deu": return .deu
        case "mmr": return .mmr
        case "idn": return .idn
        case "ncl": return .ncl
        case "pak": return .pak
        case "hrv": return .hrv
        case "esh": return .esh
        case "flk": return .flk
        case "pan": return .pan
        case "irn": return .irn
        case "and": return .and
        case "umi": return .umi
        case "svn": return .svn
        case "bih": return .bih
        case "fra": return .fra
        case "tca": return .tca
        case "kwt": return .kwt
        case "stp": return .stp
        case "ant": return .ant
        case "tkm": return .tkm
        case "tkl": return .tkl
        case "cyp": return .cyp
        case "eth": return .eth
        case "prk": return .prk
        case "sgs": return .sgs
        case "ggy": return .ggy
        case "yem": return .yem
        case "mus": return .mus
        case "aze": return .aze
        case "guf": return .guf
        case "cxr": return .cxr
        case "ken": return .ken
        case "lka": return .lka
        case "asm": return .asm
        case "pyf": return .pyf
        case "rwa": return .rwa
        case "atf": return .atf
        case "mdg": return .mdg
        case "mrt": return .mrt
        case "sxm": return .sxm
        case "fji": return .fji
        case "png": return .png
        case "lux": return .lux
        case "mda": return .mda
        case "isr": return .isr
        case "bol": return .bol
        case "sau": return .sau
        case "swe": return .swe
        case "spm": return .spm
        case "usa": return .usa
        case "caf": return .caf
        case "sdn": return .sdn
        case "slb": return .slb
        case "zmb": return .zmb
        case "cck": return .cck
        case "ala": return .ala
        case "kir": return .kir
        case "mys": return .mys
        case "myt": return .myt
        case "mco": return .mco
        case "pri": return .pri
        case "rou": return .rou
        case "vnm": return .vnm
        case "tha": return .tha
        case "vir": return .vir
        case "ata": return .ata
        case "arg": return .arg
        case "bgr": return .bgr
        case "chl": return .chl
        case "tjk": return .tjk
        case "wsm": return .wsm
        case "niu": return .niu
        case "ita": return .ita
        case "geo": return .geo
        case "wlf": return .wlf
        case "jey": return .jey
        case "gnq": return .gnq
        case "cmr": return .cmr
        case "gnb": return .gnb
        case "reu": return .reu
        case "zwe": return .zwe
        case "ukr": return .ukr
        case "pcn": return .pcn
        case "mar": return .mar
        case "uzb": return .uzb
        case "bgd": return .bgd
        case "maf": return .maf
        case "sur": return .sur
        case "syr": return .syr
        case "slv": return .slv
        case "lby": return .lby
        case "omn": return .omn
        case "mne": return .mne
        case "nga": return .nga
        case "gy": return .guy
        case "pl": return .pol
        case "lt": return .ltu
        case "ni": return .nic
        case "is": return .isl
        case "la": return .lao
        case "bt": return .btn
        case "pw": return .plw
        case "hk": return .hkg
        case "cz": return .cze
        case "dz": return .dza
        case "ci": return .civ
        case "gl": return .grl
        case "ms": return .msr
        case "cu": return .cub
        case "bw": return .bwa
        case "no": return .nor
        case "sz": return .swz
        case "fi": return .fin
        case "ug": return .uga
        case "al": return .alb
        case "ky": return .cym
        case "er": return .eri
        case "bz": return .blz
        case "mp": return .mnp
        case "tr": return .tur
        case "hu": return .hun
        case "sj": return .sjm
        case "ve": return .ven
        case "eg": return .egy
        case "nr": return .nru
        case "tw": return .twn
        case "mx": return .mex
        case "aw": return .abw
        case "vg": return .vgb
        case "ga": return .gab
        case "ca": return .can
        case "im": return .imn
        case "gu": return .gum
        case "sn": return .sen
        case "gi": return .gib
        case "ck": return .cok
        case "tv": return .tuv
        case "bb": return .brb
        case "bi": return .bdi
        case "bl": return .blm
        case "ss": return .ssd
        case "sc": return .syc
        case "gh": return .gha
        case "lv": return .lva
        case "na": return .nam
        case "bn": return .brn
        case "nl": return .nld
        case "jo": return .jor
        case "gp": return .glp
        case "ch": return .che
        case "ai": return .aia
        case "sk": return .svk
        case "km": return .com
        case "ie": return .irl
        case "sh": return .shn
        case "bv": return .bvt
        case "mt": return .mlt
        case "sg": return .sgp
        case "to": return .ton
        case "tg": return .tgo
        case "nz": return .nzl
        case "be": return .bel
        case "sl": return .sle
        case "jp": return .jpn
        case "vu": return .vut
        case "bm": return .bmu
        case "mo": return .mac
        case "np": return .npl
        case "mv": return .mdv
        case "kg": return .kgz
        case "tn": return .tun
        case "pt": return .prt
        case "tt": return .tto
        case "in": return .ind
        case "py": return .pry
        case "ne": return .ner
        case "li": return .lie
        case "bs": return .bhs
        case "kz": return .kaz
        case "dk": return .dnk
        case "cr": return .cri
        case "ph": return .phl
        case "nf": return .nfk
        case "bq": return .bes
        case "lb": return .lbn
        case "fo": return .fro
        case "do": return .dom
        case "by": return .blr
        case "cn": return .chn
        case "va": return .vat
        case "gd": return .grd
        case "br": return .bra
        case "gm": return .gmb
        case "mn": return .mng
        case "td": return .tcd
        case "mw": return .mwi
        case "lr": return .lbr
        case "mz": return .moz
        case "ao": return .ago
        case "kn": return .kna
        case "ag": return .atg
        case "uy": return .ury
        case "gr": return .grc
        case "am": return .arm
        case "hm": return .hmd
        case "es": return .esp
        case "cw": return .cuw
        case "cv": return .cpv
        case "cd": return .cod
        case "ml": return .mli
        case "dm": return .dma
        case "kh": return .khm
        case "au": return .aus
        case "cg": return .cog
        case "bj": return .ben
        case "fm": return .fsm
        case "ps": return .pse
        case "ae": return .are
        case "gn": return .gin
        case "bf": return .bfa
        case "iq": return .irq
        case "bh": return .bhr
        case "at": return .aut
        case "io": return .iot
        case "so": return .som
        case "af": return .afg
        case "za": return .zaf
        case "dj": return .dji
        case "hn": return .hnd
        case "mh": return .mhl
        case "ru": return .rus
        case "vc": return .vct
        case "ee": return .est
        case "gb": return .gbr
        case "qa": return .qat
        case "mq": return .mtq
        case "pe": return .per
        case "ec": return .ecu
        case "rs": return .srb
        case "jm": return .jam
        case "mk": return .mkd
        case "co": return .col
        case "kr": return .kor
        case "tl": return .tls
        case "lc": return .lca
        case "tz": return .tza
        case "sm": return .smr
        case "ht": return .hti
        case "gt": return .gtm
        case "ls": return .lso
        case "de": return .deu
        case "mm": return .mmr
        case "id": return .idn
        case "nc": return .ncl
        case "pk": return .pak
        case "hr": return .hrv
        case "eh": return .esh
        case "fk": return .flk
        case "pa": return .pan
        case "ir": return .irn
        case "ad": return .and
        case "um": return .umi
        case "si": return .svn
        case "ba": return .bih
        case "fr": return .fra
        case "tc": return .tca
        case "kw": return .kwt
        case "st": return .stp
        case "an": return .ant
        case "tm": return .tkm
        case "tk": return .tkl
        case "cy": return .cyp
        case "et": return .eth
        case "kp": return .prk
        case "gs": return .sgs
        case "gg": return .ggy
        case "ye": return .yem
        case "mu": return .mus
        case "az": return .aze
        case "gf": return .guf
        case "cx": return .cxr
        case "ke": return .ken
        case "lk": return .lka
        case "as": return .asm
        case "pf": return .pyf
        case "rw": return .rwa
        case "tf": return .atf
        case "mg": return .mdg
        case "mr": return .mrt
        case "sx": return .sxm
        case "fj": return .fji
        case "pg": return .png
        case "lu": return .lux
        case "md": return .mda
        case "il": return .isr
        case "bo": return .bol
        case "sa": return .sau
        case "se": return .swe
        case "pm": return .spm
        case "us": return .usa
        case "cf": return .caf
        case "sd": return .sdn
        case "sb": return .slb
        case "zm": return .zmb
        case "cc": return .cck
        case "ax": return .ala
        case "ki": return .kir
        case "my": return .mys
        case "yt": return .myt
        case "mc": return .mco
        case "pr": return .pri
        case "ro": return .rou
        case "vn": return .vnm
        case "th": return .tha
        case "vi": return .vir
        case "aq": return .ata
        case "ar": return .arg
        case "bg": return .bgr
        case "cl": return .chl
        case "tj": return .tjk
        case "ws": return .wsm
        case "nu": return .niu
        case "it": return .ita
        case "ge": return .geo
        case "wf": return .wlf
        case "je": return .jey
        case "gq": return .gnq
        case "cm": return .cmr
        case "gw": return .gnb
        case "re": return .reu
        case "zw": return .zwe
        case "ua": return .ukr
        case "pn": return .pcn
        case "ma": return .mar
        case "uz": return .uzb
        case "bd": return .bgd
        case "mf": return .maf
        case "sr": return .sur
        case "sy": return .syr
        case "sv": return .slv
        case "ly": return .lby
        case "om": return .omn
        case "me": return .mne
        case "ng": return .nga
        default: return .unknown
        }
    }
}

extension ISO3166.Country {
    var threeLetterName: String {
        switch self {
        case .guy: return "guy"
        case .pol: return "pol"
        case .ltu: return "ltu"
        case .nic: return "nic"
        case .isl: return "isl"
        case .lao: return "lao"
        case .btn: return "btn"
        case .plw: return "plw"
        case .hkg: return "hkg"
        case .cze: return "cze"
        case .dza: return "dza"
        case .civ: return "civ"
        case .grl: return "grl"
        case .msr: return "msr"
        case .cub: return "cub"
        case .bwa: return "bwa"
        case .nor: return "nor"
        case .swz: return "swz"
        case .fin: return "fin"
        case .uga: return "uga"
        case .alb: return "alb"
        case .cym: return "cym"
        case .eri: return "eri"
        case .blz: return "blz"
        case .mnp: return "mnp"
        case .tur: return "tur"
        case .hun: return "hun"
        case .sjm: return "sjm"
        case .ven: return "ven"
        case .egy: return "egy"
        case .nru: return "nru"
        case .twn: return "twn"
        case .mex: return "mex"
        case .abw: return "abw"
        case .vgb: return "vgb"
        case .gab: return "gab"
        case .can: return "can"
        case .imn: return "imn"
        case .gum: return "gum"
        case .sen: return "sen"
        case .gib: return "gib"
        case .cok: return "cok"
        case .tuv: return "tuv"
        case .brb: return "brb"
        case .bdi: return "bdi"
        case .blm: return "blm"
        case .ssd: return "ssd"
        case .syc: return "syc"
        case .gha: return "gha"
        case .lva: return "lva"
        case .nam: return "nam"
        case .brn: return "brn"
        case .nld: return "nld"
        case .jor: return "jor"
        case .glp: return "glp"
        case .che: return "che"
        case .aia: return "aia"
        case .svk: return "svk"
        case .com: return "com"
        case .irl: return "irl"
        case .shn: return "shn"
        case .bvt: return "bvt"
        case .mlt: return "mlt"
        case .sgp: return "sgp"
        case .ton: return "ton"
        case .tgo: return "tgo"
        case .nzl: return "nzl"
        case .bel: return "bel"
        case .sle: return "sle"
        case .jpn: return "jpn"
        case .vut: return "vut"
        case .bmu: return "bmu"
        case .mac: return "mac"
        case .npl: return "npl"
        case .mdv: return "mdv"
        case .kgz: return "kgz"
        case .tun: return "tun"
        case .prt: return "prt"
        case .tto: return "tto"
        case .ind: return "ind"
        case .pry: return "pry"
        case .ner: return "ner"
        case .lie: return "lie"
        case .bhs: return "bhs"
        case .kaz: return "kaz"
        case .dnk: return "dnk"
        case .cri: return "cri"
        case .phl: return "phl"
        case .nfk: return "nfk"
        case .bes: return "bes"
        case .lbn: return "lbn"
        case .fro: return "fro"
        case .dom: return "dom"
        case .blr: return "blr"
        case .chn: return "chn"
        case .vat: return "vat"
        case .grd: return "grd"
        case .bra: return "bra"
        case .gmb: return "gmb"
        case .mng: return "mng"
        case .tcd: return "tcd"
        case .mwi: return "mwi"
        case .lbr: return "lbr"
        case .moz: return "moz"
        case .ago: return "ago"
        case .kna: return "kna"
        case .atg: return "atg"
        case .ury: return "ury"
        case .grc: return "grc"
        case .arm: return "arm"
        case .hmd: return "hmd"
        case .esp: return "esp"
        case .cuw: return "cuw"
        case .cpv: return "cpv"
        case .cod: return "cod"
        case .mli: return "mli"
        case .dma: return "dma"
        case .khm: return "khm"
        case .aus: return "aus"
        case .cog: return "cog"
        case .ben: return "ben"
        case .fsm: return "fsm"
        case .pse: return "pse"
        case .are: return "are"
        case .gin: return "gin"
        case .bfa: return "bfa"
        case .irq: return "irq"
        case .bhr: return "bhr"
        case .aut: return "aut"
        case .iot: return "iot"
        case .som: return "som"
        case .afg: return "afg"
        case .zaf: return "zaf"
        case .dji: return "dji"
        case .hnd: return "hnd"
        case .mhl: return "mhl"
        case .rus: return "rus"
        case .vct: return "vct"
        case .est: return "est"
        case .gbr: return "gbr"
        case .qat: return "qat"
        case .mtq: return "mtq"
        case .per: return "per"
        case .ecu: return "ecu"
        case .srb: return "srb"
        case .jam: return "jam"
        case .mkd: return "mkd"
        case .col: return "col"
        case .kor: return "kor"
        case .tls: return "tls"
        case .lca: return "lca"
        case .tza: return "tza"
        case .smr: return "smr"
        case .hti: return "hti"
        case .gtm: return "gtm"
        case .lso: return "lso"
        case .deu: return "deu"
        case .mmr: return "mmr"
        case .idn: return "idn"
        case .ncl: return "ncl"
        case .pak: return "pak"
        case .hrv: return "hrv"
        case .esh: return "esh"
        case .flk: return "flk"
        case .pan: return "pan"
        case .irn: return "irn"
        case .and: return "and"
        case .umi: return "umi"
        case .svn: return "svn"
        case .bih: return "bih"
        case .fra: return "fra"
        case .tca: return "tca"
        case .kwt: return "kwt"
        case .stp: return "stp"
        case .ant: return "ant"
        case .tkm: return "tkm"
        case .tkl: return "tkl"
        case .cyp: return "cyp"
        case .eth: return "eth"
        case .prk: return "prk"
        case .sgs: return "sgs"
        case .ggy: return "ggy"
        case .yem: return "yem"
        case .mus: return "mus"
        case .aze: return "aze"
        case .guf: return "guf"
        case .cxr: return "cxr"
        case .ken: return "ken"
        case .lka: return "lka"
        case .asm: return "asm"
        case .pyf: return "pyf"
        case .rwa: return "rwa"
        case .atf: return "atf"
        case .mdg: return "mdg"
        case .mrt: return "mrt"
        case .sxm: return "sxm"
        case .fji: return "fji"
        case .png: return "png"
        case .lux: return "lux"
        case .mda: return "mda"
        case .isr: return "isr"
        case .bol: return "bol"
        case .sau: return "sau"
        case .swe: return "swe"
        case .spm: return "spm"
        case .usa: return "usa"
        case .caf: return "caf"
        case .sdn: return "sdn"
        case .slb: return "slb"
        case .zmb: return "zmb"
        case .cck: return "cck"
        case .ala: return "ala"
        case .kir: return "kir"
        case .mys: return "mys"
        case .myt: return "myt"
        case .mco: return "mco"
        case .pri: return "pri"
        case .rou: return "rou"
        case .vnm: return "vnm"
        case .tha: return "tha"
        case .vir: return "vir"
        case .ata: return "ata"
        case .arg: return "arg"
        case .bgr: return "bgr"
        case .chl: return "chl"
        case .tjk: return "tjk"
        case .wsm: return "wsm"
        case .niu: return "niu"
        case .ita: return "ita"
        case .geo: return "geo"
        case .wlf: return "wlf"
        case .jey: return "jey"
        case .gnq: return "gnq"
        case .cmr: return "cmr"
        case .gnb: return "gnb"
        case .reu: return "reu"
        case .zwe: return "zwe"
        case .ukr: return "ukr"
        case .pcn: return "pcn"
        case .mar: return "mar"
        case .uzb: return "uzb"
        case .bgd: return "bgd"
        case .maf: return "maf"
        case .sur: return "sur"
        case .syr: return "syr"
        case .slv: return "slv"
        case .lby: return "lby"
        case .omn: return "omn"
        case .mne: return "mne"
        case .nga: return "nga"
        default: return "Unknown"
        }
    }
}

extension ISO3166.Country: CustomStringConvertible {
    var description: String { return threeLetterName }
}

extension ISO3166.Continent: CustomStringConvertible {
    var description: String {
        return NSLocalizedString(localizationKey, tableName: nil, bundle: Bundle(for: Continent.self), value: localizationKey, comment: "")
    }
    fileprivate var localizationKey: String {
        switch (self) {
        case .na: return "continent.NorthAmerica"
        case .an: return "continent.Antarctica"
        case .eu: return "continent.Europe"
        case .af: return "continent.Africa"
        case .as: return "continent.Asia"
        case .sa: return "continent.SouthAmerica"
        case .oc: return "continent.Oceania"
        }
    }
}

extension ISO3166.Country: LocalizedStringConvertible {
    var localizedDescription: String {
        let loc = NSLocale.current
        return (loc as NSLocale).displayName(forKey: NSLocale.Key.countryCode,
            value: threeLetterName) ?? NSLocalizedString("country.Unknown", tableName: nil, bundle: Bundle(for: Continent.self), value: "country.Unknown", comment: "")
    }
}

extension ISO3166.Continent: LocalizedStringConvertible {
    var localizedDescription: String { return String(describing: self) }
}

