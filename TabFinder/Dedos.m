//
//  Dedos.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 08/08/12.
//
//

#import "Dedos.h"

@implementation Dedos


+(NSInteger)findSmaller:(NSArray *)notes {
    NSInteger smaller = 24;
    for (int i=0; i<notes.count; i++) {
        NSNumber *notaAtual = (NSNumber *)[notes objectAtIndex:i];
        if (notaAtual.integerValue < smaller && notaAtual.integerValue > 0) {
            smaller = notaAtual.integerValue;
        }
    }
    return smaller;
}

+(NSInteger)cordaQueEstaAProximaNota:(NSArray *)notas {
    NSInteger menor = [self findSmaller:notas];
    for (int i=0; i<6; i++) {
        NSNumber *notaAtual = [notas objectAtIndex:i];
        if (notaAtual.integerValue == menor) return i;
    }
    return -1;
}


+(NSArray *)getDedos:(NSArray *)notas {
    @try {
    NSMutableArray *dedos = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1], nil];
    NSMutableArray *notasAux = [notas mutableCopy];
    NSMutableArray *dedosDisponiveis = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], nil];
    bool pestana = YES;
    NSInteger menor = [self findSmaller:notas];
    //seta dedo 1
    NSInteger cordaRaiz = [self cordaQueEstaAProximaNota:notasAux];
    [dedos replaceObjectAtIndex:cordaRaiz withObject:[NSNumber numberWithInt:1]];
    [notasAux replaceObjectAtIndex:cordaRaiz withObject:[NSNumber numberWithInt:-1]];
    
    //vai usar pestana?
    for (NSInteger i = cordaRaiz; i<6; i++) {
        NSInteger notaAnalise = ((NSNumber *)[notas objectAtIndex:i]).integerValue;
        if (notaAnalise == -1 && i==5) continue;
        if (notaAnalise <= 0) pestana = NO;
    }
    
    for (NSInteger i=0; i<5; i++) {
        NSInteger proximaCorda = [self cordaQueEstaAProximaNota:notasAux];
        if (proximaCorda == -1) break;
        [notasAux replaceObjectAtIndex:proximaCorda withObject:[NSNumber numberWithInt:-1]];
        
        NSNumber *aux = [notas objectAtIndex:proximaCorda];
        if (aux.integerValue == menor && pestana) {
            [dedos replaceObjectAtIndex:proximaCorda withObject:[NSNumber numberWithInt:1]];
            continue;
        }
        NSInteger distancia = ((NSNumber *)[notas objectAtIndex:proximaCorda]).integerValue - menor;
        NSInteger proximoDedoDisponivel = ((NSNumber *)[dedosDisponiveis objectAtIndex:0]).integerValue;
        NSInteger quantasNotasAFrente = [self quantasNotasAFrente:proximaCorda paraNotas:notas comOffset:((NSNumber *)[notas objectAtIndex:proximaCorda]).integerValue];
        if (distancia >= 2 && proximoDedoDisponivel == 2 && quantasNotasAFrente <= 1) {
            [dedosDisponiveis removeObjectAtIndex:0];
        }
        
        if (distancia >= 3 && proximoDedoDisponivel == 3 && quantasNotasAFrente == 0) {
            [dedosDisponiveis removeObjectAtIndex:0];
        }
        
        [dedos replaceObjectAtIndex:proximaCorda withObject:[[dedosDisponiveis objectAtIndex:0] copy]];
        [dedosDisponiveis removeObjectAtIndex:0];
    }
    return dedos;
    }
    @catch (NSException *exception) {
        return [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1], nil];
    }
}

+(NSInteger)quantasNotasAFrente:(NSInteger)corda paraNotas:(NSArray *)notas comOffset:(NSInteger)offset {
    int qtd = 0;
    for (int i = 0; i<6; i++) {
        NSNumber *aux = [notas objectAtIndex:i];
        if (aux.integerValue >= offset && i != corda) {
            qtd++;
        }
    }
    return qtd;
}
@end
