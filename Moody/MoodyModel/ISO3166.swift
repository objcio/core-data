//
//  ISO3166.swift
//  Moody
//
//  Created by Daniel Eggert on 12/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation

public struct ISO3166 {
    public enum Country: Int16 {
        case GUY = 328
        case POL = 616
        case LTU = 440
        case NIC = 558
        case ISL = 352
        case LAO = 418
        case BTN = 64
        case PLW = 585
        case HKG = 344
        case CZE = 203
        case DZA = 12
        case CIV = 384
        case GRL = 304
        case MSR = 500
        case CUB = 192
        case BWA = 72
        case NOR = 578
        case SWZ = 748
        case FIN = 246
        case UGA = 800
        case ALB = 8
        case CYM = 136
        case ERI = 232
        case BLZ = 84
        case MNP = 580
        case TUR = 792
        case HUN = 348
        case SJM = 744
        case VEN = 862
        case EGY = 818
        case NRU = 520
        case TWN = 158
        case MEX = 484
        case ABW = 533
        case VGB = 92
        case GAB = 266
        case CAN = 124
        case IMN = 833
        case GUM = 316
        case SEN = 686
        case GIB = 292
        case COK = 184
        case TUV = 798
        case BRB = 52
        case BDI = 108
        case BLM = 652
        case SSD = 728
        case SYC = 690
        case GHA = 288
        case LVA = 428
        case NAM = 516
        case BRN = 96
        case NLD = 528
        case JOR = 400
        case GLP = 312
        case CHE = 756
        case AIA = 660
        case SVK = 703
        case COM = 174
        case IRL = 372
        case SHN = 654
        case BVT = 74
        case MLT = 470
        case SGP = 702
        case TON = 776
        case TGO = 768
        case NZL = 554
        case BEL = 56
        case SLE = 694
        case JPN = 392
        case VUT = 548
        case BMU = 60
        case MAC = 446
        case NPL = 524
        case MDV = 462
        case KGZ = 417
        case TUN = 788
        case PRT = 620
        case TTO = 780
        case IND = 356
        case PRY = 600
        case NER = 562
        case LIE = 438
        case BHS = 44
        case KAZ = 398
        case DNK = 208
        case CRI = 188
        case PHL = 608
        case NFK = 574
        case BES = 535
        case LBN = 422
        case FRO = 234
        case DOM = 214
        case BLR = 112
        case CHN = 156
        case VAT = 336
        case GRD = 308
        case BRA = 76
        case GMB = 270
        case MNG = 496
        case TCD = 148
        case MWI = 454
        case LBR = 430
        case MOZ = 508
        case AGO = 24
        case KNA = 659
        case ATG = 28
        case URY = 858
        case GRC = 300
        case ARM = 51
        case HMD = 334
        case ESP = 724
        case CUW = 531
        case CPV = 132
        case COD = 180
        case MLI = 466
        case DMA = 212
        case KHM = 116
        case AUS = 36
        case COG = 178
        case BEN = 204
        case FSM = 583
        case PSE = 275
        case ARE = 784
        case GIN = 324
        case BFA = 854
        case IRQ = 368
        case BHR = 48
        case AUT = 40
        case IOT = 86
        case SOM = 706
        case AFG = 4
        case ZAF = 710
        case DJI = 262
        case HND = 340
        case MHL = 584
        case RUS = 643
        case VCT = 670
        case EST = 233
        case GBR = 826
        case QAT = 634
        case MTQ = 474
        case PER = 604
        case ECU = 218
        case SRB = 688
        case JAM = 388
        case MKD = 807
        case COL = 170
        case KOR = 410
        case TLS = 626
        case LCA = 662
        case TZA = 834
        case SMR = 674
        case HTI = 332
        case GTM = 320
        case LSO = 426
        case DEU = 276
        case MMR = 104
        case IDN = 360
        case NCL = 540
        case PAK = 586
        case HRV = 191
        case ESH = 732
        case FLK = 238
        case PAN = 591
        case IRN = 364
        case AND = 20
        case UMI = 581
        case SVN = 705
        case BIH = 70
        case FRA = 250
        case TCA = 796
        case KWT = 414
        case STP = 678
        case ANT = 530
        case TKM = 795
        case TKL = 772
        case CYP = 196
        case ETH = 231
        case PRK = 408
        case SGS = 239
        case GGY = 831
        case YEM = 887
        case MUS = 480
        case AZE = 31
        case GUF = 254
        case CXR = 162
        case KEN = 404
        case LKA = 144
        case ASM = 16
        case PYF = 258
        case RWA = 646
        case ATF = 260
        case MDG = 450
        case MRT = 478
        case SXM = 534
        case FJI = 242
        case PNG = 598
        case LUX = 442
        case MDA = 498
        case ISR = 376
        case BOL = 68
        case SAU = 682
        case SWE = 752
        case SPM = 666
        case USA = 840
        case CAF = 140
        case SDN = 736
        case SLB = 90
        case ZMB = 894
        case CCK = 166
        case ALA = 248
        case KIR = 296
        case MYS = 458
        case MYT = 175
        case MCO = 492
        case PRI = 630
        case ROU = 642
        case VNM = 704
        case THA = 764
        case VIR = 850
        case ATA = 10
        case ARG = 32
        case BGR = 100
        case CHL = 152
        case TJK = 762
        case WSM = 882
        case NIU = 570
        case ITA = 380
        case GEO = 268
        case WLF = 876
        case JEY = 832
        case GNQ = 226
        case CMR = 120
        case GNB = 624
        case REU = 638
        case ZWE = 716
        case UKR = 804
        case PCN = 612
        case MAR = 504
        case UZB = 860
        case BGD = 50
        case MAF = 663
        case SUR = 740
        case SYR = 760
        case SLV = 222
        case LBY = 434
        case OMN = 512
        case MNE = 499
        case NGA = 566
        case Unknown = 0
    }
    public enum Continent: Int16 {
        case NA = 10001
        case AN = 10002
        case EU = 10003
        case AF = 10004
        case AS = 10005
        case SA = 10006
        case OC = 10007
    }
}

private let countriesAndContinents: [(ISO3166.Continent, ISO3166.Country)] = [
    (.AS, .AFG),
    (.EU, .ALB),
    (.AN, .ATA),
    (.AF, .DZA),
    (.OC, .ASM),
    (.EU, .AND),
    (.AF, .AGO),
    (.NA, .ATG),
    (.EU, .AZE),
    (.AS, .AZE),
    (.SA, .ARG),
    (.OC, .AUS),
    (.EU, .AUT),
    (.NA, .BHS),
    (.AS, .BHR),
    (.AS, .BGD),
    (.EU, .ARM),
    (.AS, .ARM),
    (.NA, .BRB),
    (.EU, .BEL),
    (.NA, .BMU),
    (.AS, .BTN),
    (.SA, .BOL),
    (.EU, .BIH),
    (.AF, .BWA),
    (.AN, .BVT),
    (.SA, .BRA),
    (.NA, .BLZ),
    (.AS, .IOT),
    (.OC, .SLB),
    (.NA, .VGB),
    (.AS, .BRN),
    (.EU, .BGR),
    (.AS, .MMR),
    (.AF, .BDI),
    (.EU, .BLR),
    (.AS, .KHM),
    (.AF, .CMR),
    (.NA, .CAN),
    (.AF, .CPV),
    (.NA, .CYM),
    (.AF, .CAF),
    (.AS, .LKA),
    (.AF, .TCD),
    (.SA, .CHL),
    (.AS, .CHN),
    (.AS, .TWN),
    (.AS, .CXR),
    (.AS, .CCK),
    (.SA, .COL),
    (.AF, .COM),
    (.AF, .MYT),
    (.AF, .COG),
    (.AF, .COD),
    (.OC, .COK),
    (.NA, .CRI),
    (.EU, .HRV),
    (.NA, .CUB),
    (.EU, .CYP),
    (.AS, .CYP),
    (.EU, .CZE),
    (.AF, .BEN),
    (.EU, .DNK),
    (.NA, .DMA),
    (.NA, .DOM),
    (.SA, .ECU),
    (.NA, .SLV),
    (.AF, .GNQ),
    (.AF, .ETH),
    (.AF, .ERI),
    (.EU, .EST),
    (.EU, .FRO),
    (.SA, .FLK),
    (.AN, .SGS),
    (.OC, .FJI),
    (.EU, .FIN),
    (.EU, .ALA),
    (.EU, .FRA),
    (.SA, .GUF),
    (.OC, .PYF),
    (.AN, .ATF),
    (.AF, .DJI),
    (.AF, .GAB),
    (.EU, .GEO),
    (.AS, .GEO),
    (.AF, .GMB),
    (.AS, .PSE),
    (.EU, .DEU),
    (.AF, .GHA),
    (.EU, .GIB),
    (.OC, .KIR),
    (.EU, .GRC),
    (.NA, .GRL),
    (.NA, .GRD),
    (.NA, .GLP),
    (.OC, .GUM),
    (.NA, .GTM),
    (.AF, .GIN),
    (.SA, .GUY),
    (.NA, .HTI),
    (.AN, .HMD),
    (.EU, .VAT),
    (.NA, .HND),
    (.AS, .HKG),
    (.EU, .HUN),
    (.EU, .ISL),
    (.AS, .IND),
    (.AS, .IDN),
    (.AS, .IRN),
    (.AS, .IRQ),
    (.EU, .IRL),
    (.AS, .ISR),
    (.EU, .ITA),
    (.AF, .CIV),
    (.NA, .JAM),
    (.AS, .JPN),
    (.EU, .KAZ),
    (.AS, .KAZ),
    (.AS, .JOR),
    (.AF, .KEN),
    (.AS, .PRK),
    (.AS, .KOR),
    (.AS, .KWT),
    (.AS, .KGZ),
    (.AS, .LAO),
    (.AS, .LBN),
    (.AF, .LSO),
    (.EU, .LVA),
    (.AF, .LBR),
    (.AF, .LBY),
    (.EU, .LIE),
    (.EU, .LTU),
    (.EU, .LUX),
    (.AS, .MAC),
    (.AF, .MDG),
    (.AF, .MWI),
    (.AS, .MYS),
    (.AS, .MDV),
    (.AF, .MLI),
    (.EU, .MLT),
    (.NA, .MTQ),
    (.AF, .MRT),
    (.AF, .MUS),
    (.NA, .MEX),
    (.EU, .MCO),
    (.AS, .MNG),
    (.EU, .MDA),
    (.EU, .MNE),
    (.NA, .MSR),
    (.AF, .MAR),
    (.AF, .MOZ),
    (.AS, .OMN),
    (.AF, .NAM),
    (.OC, .NRU),
    (.AS, .NPL),
    (.EU, .NLD),
    (.NA, .ANT),
    (.NA, .CUW),
    (.NA, .ABW),
    (.NA, .SXM),
    (.NA, .BES),
    (.OC, .NCL),
    (.OC, .VUT),
    (.OC, .NZL),
    (.NA, .NIC),
    (.AF, .NER),
    (.AF, .NGA),
    (.OC, .NIU),
    (.OC, .NFK),
    (.EU, .NOR),
    (.OC, .MNP),
    (.OC, .UMI),
    (.NA, .UMI),
    (.OC, .FSM),
    (.OC, .MHL),
    (.OC, .PLW),
    (.AS, .PAK),
    (.NA, .PAN),
    (.OC, .PNG),
    (.SA, .PRY),
    (.SA, .PER),
    (.AS, .PHL),
    (.OC, .PCN),
    (.EU, .POL),
    (.EU, .PRT),
    (.AF, .GNB),
    (.AS, .TLS),
    (.NA, .PRI),
    (.AS, .QAT),
    (.AF, .REU),
    (.EU, .ROU),
    (.EU, .RUS),
    (.AS, .RUS),
    (.AF, .RWA),
    (.NA, .BLM),
    (.AF, .SHN),
    (.NA, .KNA),
    (.NA, .AIA),
    (.NA, .LCA),
    (.NA, .MAF),
    (.NA, .SPM),
    (.NA, .VCT),
    (.EU, .SMR),
    (.AF, .STP),
    (.AS, .SAU),
    (.AF, .SEN),
    (.EU, .SRB),
    (.AF, .SYC),
    (.AF, .SLE),
    (.AS, .SGP),
    (.EU, .SVK),
    (.AS, .VNM),
    (.EU, .SVN),
    (.AF, .SOM),
    (.AF, .ZAF),
    (.AF, .ZWE),
    (.EU, .ESP),
    (.AF, .SSD),
    (.AF, .ESH),
    (.AF, .SDN),
    (.SA, .SUR),
    (.EU, .SJM),
    (.AF, .SWZ),
    (.EU, .SWE),
    (.EU, .CHE),
    (.AS, .SYR),
    (.AS, .TJK),
    (.AS, .THA),
    (.AF, .TGO),
    (.OC, .TKL),
    (.OC, .TON),
    (.NA, .TTO),
    (.AS, .ARE),
    (.AF, .TUN),
    (.EU, .TUR),
    (.AS, .TUR),
    (.AS, .TKM),
    (.NA, .TCA),
    (.OC, .TUV),
    (.AF, .UGA),
    (.EU, .UKR),
    (.EU, .MKD),
    (.AF, .EGY),
    (.EU, .GBR),
    (.EU, .GGY),
    (.EU, .JEY),
    (.EU, .IMN),
    (.AF, .TZA),
    (.NA, .USA),
    (.NA, .VIR),
    (.AF, .BFA),
    (.SA, .URY),
    (.AS, .UZB),
    (.SA, .VEN),
    (.OC, .WLF),
    (.OC, .WSM),
    (.AS, .YEM),
    (.AF, .ZMB),
]

extension ISO3166.Continent {
    static func fromCountry(country: ISO3166.Country) -> ISO3166.Continent? {
        let cc = countriesAndContinents.findFirstOccurence {
            return ($0.1 == country)
        }
        if let (continent, _) = cc {
            return continent
        }
        return nil
    }
}

extension ISO3166.Country {
    public static func fromISO3166(s: String) -> ISO3166.Country {
        switch (s.lowercaseString) {
        case "guy": return .GUY
        case "pol": return .POL
        case "ltu": return .LTU
        case "nic": return .NIC
        case "isl": return .ISL
        case "lao": return .LAO
        case "btn": return .BTN
        case "plw": return .PLW
        case "hkg": return .HKG
        case "cze": return .CZE
        case "dza": return .DZA
        case "civ": return .CIV
        case "grl": return .GRL
        case "msr": return .MSR
        case "cub": return .CUB
        case "bwa": return .BWA
        case "nor": return .NOR
        case "swz": return .SWZ
        case "fin": return .FIN
        case "uga": return .UGA
        case "alb": return .ALB
        case "cym": return .CYM
        case "eri": return .ERI
        case "blz": return .BLZ
        case "mnp": return .MNP
        case "tur": return .TUR
        case "hun": return .HUN
        case "sjm": return .SJM
        case "ven": return .VEN
        case "egy": return .EGY
        case "nru": return .NRU
        case "twn": return .TWN
        case "mex": return .MEX
        case "abw": return .ABW
        case "vgb": return .VGB
        case "gab": return .GAB
        case "can": return .CAN
        case "imn": return .IMN
        case "gum": return .GUM
        case "sen": return .SEN
        case "gib": return .GIB
        case "cok": return .COK
        case "tuv": return .TUV
        case "brb": return .BRB
        case "bdi": return .BDI
        case "blm": return .BLM
        case "ssd": return .SSD
        case "syc": return .SYC
        case "gha": return .GHA
        case "lva": return .LVA
        case "nam": return .NAM
        case "brn": return .BRN
        case "nld": return .NLD
        case "jor": return .JOR
        case "glp": return .GLP
        case "che": return .CHE
        case "aia": return .AIA
        case "svk": return .SVK
        case "com": return .COM
        case "irl": return .IRL
        case "shn": return .SHN
        case "bvt": return .BVT
        case "mlt": return .MLT
        case "sgp": return .SGP
        case "ton": return .TON
        case "tgo": return .TGO
        case "nzl": return .NZL
        case "bel": return .BEL
        case "sle": return .SLE
        case "jpn": return .JPN
        case "vut": return .VUT
        case "bmu": return .BMU
        case "mac": return .MAC
        case "npl": return .NPL
        case "mdv": return .MDV
        case "kgz": return .KGZ
        case "tun": return .TUN
        case "prt": return .PRT
        case "tto": return .TTO
        case "ind": return .IND
        case "pry": return .PRY
        case "ner": return .NER
        case "lie": return .LIE
        case "bhs": return .BHS
        case "kaz": return .KAZ
        case "dnk": return .DNK
        case "cri": return .CRI
        case "phl": return .PHL
        case "nfk": return .NFK
        case "bes": return .BES
        case "lbn": return .LBN
        case "fro": return .FRO
        case "dom": return .DOM
        case "blr": return .BLR
        case "chn": return .CHN
        case "vat": return .VAT
        case "grd": return .GRD
        case "bra": return .BRA
        case "gmb": return .GMB
        case "mng": return .MNG
        case "tcd": return .TCD
        case "mwi": return .MWI
        case "lbr": return .LBR
        case "moz": return .MOZ
        case "ago": return .AGO
        case "kna": return .KNA
        case "atg": return .ATG
        case "ury": return .URY
        case "grc": return .GRC
        case "arm": return .ARM
        case "hmd": return .HMD
        case "esp": return .ESP
        case "cuw": return .CUW
        case "cpv": return .CPV
        case "cod": return .COD
        case "mli": return .MLI
        case "dma": return .DMA
        case "khm": return .KHM
        case "aus": return .AUS
        case "cog": return .COG
        case "ben": return .BEN
        case "fsm": return .FSM
        case "pse": return .PSE
        case "are": return .ARE
        case "gin": return .GIN
        case "bfa": return .BFA
        case "irq": return .IRQ
        case "bhr": return .BHR
        case "aut": return .AUT
        case "iot": return .IOT
        case "som": return .SOM
        case "afg": return .AFG
        case "zaf": return .ZAF
        case "dji": return .DJI
        case "hnd": return .HND
        case "mhl": return .MHL
        case "rus": return .RUS
        case "vct": return .VCT
        case "est": return .EST
        case "gbr": return .GBR
        case "qat": return .QAT
        case "mtq": return .MTQ
        case "per": return .PER
        case "ecu": return .ECU
        case "srb": return .SRB
        case "jam": return .JAM
        case "mkd": return .MKD
        case "col": return .COL
        case "kor": return .KOR
        case "tls": return .TLS
        case "lca": return .LCA
        case "tza": return .TZA
        case "smr": return .SMR
        case "hti": return .HTI
        case "gtm": return .GTM
        case "lso": return .LSO
        case "deu": return .DEU
        case "mmr": return .MMR
        case "idn": return .IDN
        case "ncl": return .NCL
        case "pak": return .PAK
        case "hrv": return .HRV
        case "esh": return .ESH
        case "flk": return .FLK
        case "pan": return .PAN
        case "irn": return .IRN
        case "and": return .AND
        case "umi": return .UMI
        case "svn": return .SVN
        case "bih": return .BIH
        case "fra": return .FRA
        case "tca": return .TCA
        case "kwt": return .KWT
        case "stp": return .STP
        case "ant": return .ANT
        case "tkm": return .TKM
        case "tkl": return .TKL
        case "cyp": return .CYP
        case "eth": return .ETH
        case "prk": return .PRK
        case "sgs": return .SGS
        case "ggy": return .GGY
        case "yem": return .YEM
        case "mus": return .MUS
        case "aze": return .AZE
        case "guf": return .GUF
        case "cxr": return .CXR
        case "ken": return .KEN
        case "lka": return .LKA
        case "asm": return .ASM
        case "pyf": return .PYF
        case "rwa": return .RWA
        case "atf": return .ATF
        case "mdg": return .MDG
        case "mrt": return .MRT
        case "sxm": return .SXM
        case "fji": return .FJI
        case "png": return .PNG
        case "lux": return .LUX
        case "mda": return .MDA
        case "isr": return .ISR
        case "bol": return .BOL
        case "sau": return .SAU
        case "swe": return .SWE
        case "spm": return .SPM
        case "usa": return .USA
        case "caf": return .CAF
        case "sdn": return .SDN
        case "slb": return .SLB
        case "zmb": return .ZMB
        case "cck": return .CCK
        case "ala": return .ALA
        case "kir": return .KIR
        case "mys": return .MYS
        case "myt": return .MYT
        case "mco": return .MCO
        case "pri": return .PRI
        case "rou": return .ROU
        case "vnm": return .VNM
        case "tha": return .THA
        case "vir": return .VIR
        case "ata": return .ATA
        case "arg": return .ARG
        case "bgr": return .BGR
        case "chl": return .CHL
        case "tjk": return .TJK
        case "wsm": return .WSM
        case "niu": return .NIU
        case "ita": return .ITA
        case "geo": return .GEO
        case "wlf": return .WLF
        case "jey": return .JEY
        case "gnq": return .GNQ
        case "cmr": return .CMR
        case "gnb": return .GNB
        case "reu": return .REU
        case "zwe": return .ZWE
        case "ukr": return .UKR
        case "pcn": return .PCN
        case "mar": return .MAR
        case "uzb": return .UZB
        case "bgd": return .BGD
        case "maf": return .MAF
        case "sur": return .SUR
        case "syr": return .SYR
        case "slv": return .SLV
        case "lby": return .LBY
        case "omn": return .OMN
        case "mne": return .MNE
        case "nga": return .NGA
        case "gy": return .GUY
        case "pl": return .POL
        case "lt": return .LTU
        case "ni": return .NIC
        case "is": return .ISL
        case "la": return .LAO
        case "bt": return .BTN
        case "pw": return .PLW
        case "hk": return .HKG
        case "cz": return .CZE
        case "dz": return .DZA
        case "ci": return .CIV
        case "gl": return .GRL
        case "ms": return .MSR
        case "cu": return .CUB
        case "bw": return .BWA
        case "no": return .NOR
        case "sz": return .SWZ
        case "fi": return .FIN
        case "ug": return .UGA
        case "al": return .ALB
        case "ky": return .CYM
        case "er": return .ERI
        case "bz": return .BLZ
        case "mp": return .MNP
        case "tr": return .TUR
        case "hu": return .HUN
        case "sj": return .SJM
        case "ve": return .VEN
        case "eg": return .EGY
        case "nr": return .NRU
        case "tw": return .TWN
        case "mx": return .MEX
        case "aw": return .ABW
        case "vg": return .VGB
        case "ga": return .GAB
        case "ca": return .CAN
        case "im": return .IMN
        case "gu": return .GUM
        case "sn": return .SEN
        case "gi": return .GIB
        case "ck": return .COK
        case "tv": return .TUV
        case "bb": return .BRB
        case "bi": return .BDI
        case "bl": return .BLM
        case "ss": return .SSD
        case "sc": return .SYC
        case "gh": return .GHA
        case "lv": return .LVA
        case "na": return .NAM
        case "bn": return .BRN
        case "nl": return .NLD
        case "jo": return .JOR
        case "gp": return .GLP
        case "ch": return .CHE
        case "ai": return .AIA
        case "sk": return .SVK
        case "km": return .COM
        case "ie": return .IRL
        case "sh": return .SHN
        case "bv": return .BVT
        case "mt": return .MLT
        case "sg": return .SGP
        case "to": return .TON
        case "tg": return .TGO
        case "nz": return .NZL
        case "be": return .BEL
        case "sl": return .SLE
        case "jp": return .JPN
        case "vu": return .VUT
        case "bm": return .BMU
        case "mo": return .MAC
        case "np": return .NPL
        case "mv": return .MDV
        case "kg": return .KGZ
        case "tn": return .TUN
        case "pt": return .PRT
        case "tt": return .TTO
        case "in": return .IND
        case "py": return .PRY
        case "ne": return .NER
        case "li": return .LIE
        case "bs": return .BHS
        case "kz": return .KAZ
        case "dk": return .DNK
        case "cr": return .CRI
        case "ph": return .PHL
        case "nf": return .NFK
        case "bq": return .BES
        case "lb": return .LBN
        case "fo": return .FRO
        case "do": return .DOM
        case "by": return .BLR
        case "cn": return .CHN
        case "va": return .VAT
        case "gd": return .GRD
        case "br": return .BRA
        case "gm": return .GMB
        case "mn": return .MNG
        case "td": return .TCD
        case "mw": return .MWI
        case "lr": return .LBR
        case "mz": return .MOZ
        case "ao": return .AGO
        case "kn": return .KNA
        case "ag": return .ATG
        case "uy": return .URY
        case "gr": return .GRC
        case "am": return .ARM
        case "hm": return .HMD
        case "es": return .ESP
        case "cw": return .CUW
        case "cv": return .CPV
        case "cd": return .COD
        case "ml": return .MLI
        case "dm": return .DMA
        case "kh": return .KHM
        case "au": return .AUS
        case "cg": return .COG
        case "bj": return .BEN
        case "fm": return .FSM
        case "ps": return .PSE
        case "ae": return .ARE
        case "gn": return .GIN
        case "bf": return .BFA
        case "iq": return .IRQ
        case "bh": return .BHR
        case "at": return .AUT
        case "io": return .IOT
        case "so": return .SOM
        case "af": return .AFG
        case "za": return .ZAF
        case "dj": return .DJI
        case "hn": return .HND
        case "mh": return .MHL
        case "ru": return .RUS
        case "vc": return .VCT
        case "ee": return .EST
        case "gb": return .GBR
        case "qa": return .QAT
        case "mq": return .MTQ
        case "pe": return .PER
        case "ec": return .ECU
        case "rs": return .SRB
        case "jm": return .JAM
        case "mk": return .MKD
        case "co": return .COL
        case "kr": return .KOR
        case "tl": return .TLS
        case "lc": return .LCA
        case "tz": return .TZA
        case "sm": return .SMR
        case "ht": return .HTI
        case "gt": return .GTM
        case "ls": return .LSO
        case "de": return .DEU
        case "mm": return .MMR
        case "id": return .IDN
        case "nc": return .NCL
        case "pk": return .PAK
        case "hr": return .HRV
        case "eh": return .ESH
        case "fk": return .FLK
        case "pa": return .PAN
        case "ir": return .IRN
        case "ad": return .AND
        case "um": return .UMI
        case "si": return .SVN
        case "ba": return .BIH
        case "fr": return .FRA
        case "tc": return .TCA
        case "kw": return .KWT
        case "st": return .STP
        case "an": return .ANT
        case "tm": return .TKM
        case "tk": return .TKL
        case "cy": return .CYP
        case "et": return .ETH
        case "kp": return .PRK
        case "gs": return .SGS
        case "gg": return .GGY
        case "ye": return .YEM
        case "mu": return .MUS
        case "az": return .AZE
        case "gf": return .GUF
        case "cx": return .CXR
        case "ke": return .KEN
        case "lk": return .LKA
        case "as": return .ASM
        case "pf": return .PYF
        case "rw": return .RWA
        case "tf": return .ATF
        case "mg": return .MDG
        case "mr": return .MRT
        case "sx": return .SXM
        case "fj": return .FJI
        case "pg": return .PNG
        case "lu": return .LUX
        case "md": return .MDA
        case "il": return .ISR
        case "bo": return .BOL
        case "sa": return .SAU
        case "se": return .SWE
        case "pm": return .SPM
        case "us": return .USA
        case "cf": return .CAF
        case "sd": return .SDN
        case "sb": return .SLB
        case "zm": return .ZMB
        case "cc": return .CCK
        case "ax": return .ALA
        case "ki": return .KIR
        case "my": return .MYS
        case "yt": return .MYT
        case "mc": return .MCO
        case "pr": return .PRI
        case "ro": return .ROU
        case "vn": return .VNM
        case "th": return .THA
        case "vi": return .VIR
        case "aq": return .ATA
        case "ar": return .ARG
        case "bg": return .BGR
        case "cl": return .CHL
        case "tj": return .TJK
        case "ws": return .WSM
        case "nu": return .NIU
        case "it": return .ITA
        case "ge": return .GEO
        case "wf": return .WLF
        case "je": return .JEY
        case "gq": return .GNQ
        case "cm": return .CMR
        case "gw": return .GNB
        case "re": return .REU
        case "zw": return .ZWE
        case "ua": return .UKR
        case "pn": return .PCN
        case "ma": return .MAR
        case "uz": return .UZB
        case "bd": return .BGD
        case "mf": return .MAF
        case "sr": return .SUR
        case "sy": return .SYR
        case "sv": return .SLV
        case "ly": return .LBY
        case "om": return .OMN
        case "me": return .MNE
        case "ng": return .NGA
        default: return .Unknown
        }
    }
}

extension ISO3166.Country {
    public var threeLetterName: String {
        switch self {
        case .GUY: return "guy"
        case .POL: return "pol"
        case .LTU: return "ltu"
        case .NIC: return "nic"
        case .ISL: return "isl"
        case .LAO: return "lao"
        case .BTN: return "btn"
        case .PLW: return "plw"
        case .HKG: return "hkg"
        case .CZE: return "cze"
        case .DZA: return "dza"
        case .CIV: return "civ"
        case .GRL: return "grl"
        case .MSR: return "msr"
        case .CUB: return "cub"
        case .BWA: return "bwa"
        case .NOR: return "nor"
        case .SWZ: return "swz"
        case .FIN: return "fin"
        case .UGA: return "uga"
        case .ALB: return "alb"
        case .CYM: return "cym"
        case .ERI: return "eri"
        case .BLZ: return "blz"
        case .MNP: return "mnp"
        case .TUR: return "tur"
        case .HUN: return "hun"
        case .SJM: return "sjm"
        case .VEN: return "ven"
        case .EGY: return "egy"
        case .NRU: return "nru"
        case .TWN: return "twn"
        case .MEX: return "mex"
        case .ABW: return "abw"
        case .VGB: return "vgb"
        case .GAB: return "gab"
        case .CAN: return "can"
        case .IMN: return "imn"
        case .GUM: return "gum"
        case .SEN: return "sen"
        case .GIB: return "gib"
        case .COK: return "cok"
        case .TUV: return "tuv"
        case .BRB: return "brb"
        case .BDI: return "bdi"
        case .BLM: return "blm"
        case .SSD: return "ssd"
        case .SYC: return "syc"
        case .GHA: return "gha"
        case .LVA: return "lva"
        case .NAM: return "nam"
        case .BRN: return "brn"
        case .NLD: return "nld"
        case .JOR: return "jor"
        case .GLP: return "glp"
        case .CHE: return "che"
        case .AIA: return "aia"
        case .SVK: return "svk"
        case .COM: return "com"
        case .IRL: return "irl"
        case .SHN: return "shn"
        case .BVT: return "bvt"
        case .MLT: return "mlt"
        case .SGP: return "sgp"
        case .TON: return "ton"
        case .TGO: return "tgo"
        case .NZL: return "nzl"
        case .BEL: return "bel"
        case .SLE: return "sle"
        case .JPN: return "jpn"
        case .VUT: return "vut"
        case .BMU: return "bmu"
        case .MAC: return "mac"
        case .NPL: return "npl"
        case .MDV: return "mdv"
        case .KGZ: return "kgz"
        case .TUN: return "tun"
        case .PRT: return "prt"
        case .TTO: return "tto"
        case .IND: return "ind"
        case .PRY: return "pry"
        case .NER: return "ner"
        case .LIE: return "lie"
        case .BHS: return "bhs"
        case .KAZ: return "kaz"
        case .DNK: return "dnk"
        case .CRI: return "cri"
        case .PHL: return "phl"
        case .NFK: return "nfk"
        case .BES: return "bes"
        case .LBN: return "lbn"
        case .FRO: return "fro"
        case .DOM: return "dom"
        case .BLR: return "blr"
        case .CHN: return "chn"
        case .VAT: return "vat"
        case .GRD: return "grd"
        case .BRA: return "bra"
        case .GMB: return "gmb"
        case .MNG: return "mng"
        case .TCD: return "tcd"
        case .MWI: return "mwi"
        case .LBR: return "lbr"
        case .MOZ: return "moz"
        case .AGO: return "ago"
        case .KNA: return "kna"
        case .ATG: return "atg"
        case .URY: return "ury"
        case .GRC: return "grc"
        case .ARM: return "arm"
        case .HMD: return "hmd"
        case .ESP: return "esp"
        case .CUW: return "cuw"
        case .CPV: return "cpv"
        case .COD: return "cod"
        case .MLI: return "mli"
        case .DMA: return "dma"
        case .KHM: return "khm"
        case .AUS: return "aus"
        case .COG: return "cog"
        case .BEN: return "ben"
        case .FSM: return "fsm"
        case .PSE: return "pse"
        case .ARE: return "are"
        case .GIN: return "gin"
        case .BFA: return "bfa"
        case .IRQ: return "irq"
        case .BHR: return "bhr"
        case .AUT: return "aut"
        case .IOT: return "iot"
        case .SOM: return "som"
        case .AFG: return "afg"
        case .ZAF: return "zaf"
        case .DJI: return "dji"
        case .HND: return "hnd"
        case .MHL: return "mhl"
        case .RUS: return "rus"
        case .VCT: return "vct"
        case .EST: return "est"
        case .GBR: return "gbr"
        case .QAT: return "qat"
        case .MTQ: return "mtq"
        case .PER: return "per"
        case .ECU: return "ecu"
        case .SRB: return "srb"
        case .JAM: return "jam"
        case .MKD: return "mkd"
        case .COL: return "col"
        case .KOR: return "kor"
        case .TLS: return "tls"
        case .LCA: return "lca"
        case .TZA: return "tza"
        case .SMR: return "smr"
        case .HTI: return "hti"
        case .GTM: return "gtm"
        case .LSO: return "lso"
        case .DEU: return "deu"
        case .MMR: return "mmr"
        case .IDN: return "idn"
        case .NCL: return "ncl"
        case .PAK: return "pak"
        case .HRV: return "hrv"
        case .ESH: return "esh"
        case .FLK: return "flk"
        case .PAN: return "pan"
        case .IRN: return "irn"
        case .AND: return "and"
        case .UMI: return "umi"
        case .SVN: return "svn"
        case .BIH: return "bih"
        case .FRA: return "fra"
        case .TCA: return "tca"
        case .KWT: return "kwt"
        case .STP: return "stp"
        case .ANT: return "ant"
        case .TKM: return "tkm"
        case .TKL: return "tkl"
        case .CYP: return "cyp"
        case .ETH: return "eth"
        case .PRK: return "prk"
        case .SGS: return "sgs"
        case .GGY: return "ggy"
        case .YEM: return "yem"
        case .MUS: return "mus"
        case .AZE: return "aze"
        case .GUF: return "guf"
        case .CXR: return "cxr"
        case .KEN: return "ken"
        case .LKA: return "lka"
        case .ASM: return "asm"
        case .PYF: return "pyf"
        case .RWA: return "rwa"
        case .ATF: return "atf"
        case .MDG: return "mdg"
        case .MRT: return "mrt"
        case .SXM: return "sxm"
        case .FJI: return "fji"
        case .PNG: return "png"
        case .LUX: return "lux"
        case .MDA: return "mda"
        case .ISR: return "isr"
        case .BOL: return "bol"
        case .SAU: return "sau"
        case .SWE: return "swe"
        case .SPM: return "spm"
        case .USA: return "usa"
        case .CAF: return "caf"
        case .SDN: return "sdn"
        case .SLB: return "slb"
        case .ZMB: return "zmb"
        case .CCK: return "cck"
        case .ALA: return "ala"
        case .KIR: return "kir"
        case .MYS: return "mys"
        case .MYT: return "myt"
        case .MCO: return "mco"
        case .PRI: return "pri"
        case .ROU: return "rou"
        case .VNM: return "vnm"
        case .THA: return "tha"
        case .VIR: return "vir"
        case .ATA: return "ata"
        case .ARG: return "arg"
        case .BGR: return "bgr"
        case .CHL: return "chl"
        case .TJK: return "tjk"
        case .WSM: return "wsm"
        case .NIU: return "niu"
        case .ITA: return "ita"
        case .GEO: return "geo"
        case .WLF: return "wlf"
        case .JEY: return "jey"
        case .GNQ: return "gnq"
        case .CMR: return "cmr"
        case .GNB: return "gnb"
        case .REU: return "reu"
        case .ZWE: return "zwe"
        case .UKR: return "ukr"
        case .PCN: return "pcn"
        case .MAR: return "mar"
        case .UZB: return "uzb"
        case .BGD: return "bgd"
        case .MAF: return "maf"
        case .SUR: return "sur"
        case .SYR: return "syr"
        case .SLV: return "slv"
        case .LBY: return "lby"
        case .OMN: return "omn"
        case .MNE: return "mne"
        case .NGA: return "nga"
        default: return "Unknown"
        }
    }
}

extension ISO3166.Country: CustomStringConvertible {
    public var description: String { return threeLetterName }
}

extension ISO3166.Continent: CustomStringConvertible {
    public var description: String {
        return NSLocalizedString(localizationKey, tableName: nil, bundle: NSBundle(forClass: Continent.self), value: localizationKey, comment: "")
    }
    private var localizationKey: String {
        switch (self) {
        case .NA: return "continent.NorthAmerica"
        case .AN: return "continent.Antarctica"
        case .EU: return "continent.Europe"
        case .AF: return "continent.Africa"
        case .AS: return "continent.Asia"
        case .SA: return "continent.SouthAmerica"
        case .OC: return "continent.Oceania"
        }
    }
}

extension ISO3166.Country: LocalizedStringConvertible {
    public var localizedDescription: String {
        let loc = NSLocale.currentLocale()
        return loc.displayNameForKey(NSLocaleCountryCode,
            value: threeLetterName) ?? NSLocalizedString("country.Unknown", tableName: nil, bundle: NSBundle(forClass: Continent.self), value: "country.Unknown", comment: "")
    }
}

extension ISO3166.Continent: LocalizedStringConvertible {
    public var localizedDescription: String { return String(self) }
}
