//
//  ChordRequest.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 07/08/12.
//
//

#import "ChordRequest.h"
#import "Chord.h"
#import "Dedos.h"
#import "ChordTO.h"

@implementation ChordRequest

#define CIFRACLUB @"http://www.cifraclub.com.br/ajax/dicionario_suggest.php?q="

+(NSMutableArray *)chordSuggestionForString:(NSString *)searchText {
    NSString *urlString = [[NSString stringWithFormat: @"%@%@",CIFRACLUB,searchText] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    if (html.length == 3) {
        return [[NSMutableArray alloc] initWithObjects:@"No chords were found.", nil];
    }
    html = [html substringFromIndex:2];
    html = [html substringToIndex:html.length-2];
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"\\u00ba" withString:@"º"];
    html = [html stringByReplacingOccurrencesOfString:@"\\u00b0" withString:@"º"];
    html = [html stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    html = [html stringByReplacingOccurrencesOfString:@"+" withString:@"M"];
    NSMutableArray *ret = (NSMutableArray *)[html componentsSeparatedByString:@","];
    return ret;
}

+(NSMutableArray *)chordRequest:(NSString *)chordName {
    NSURL *aUrl = [NSURL URLWithString:@"http://www.cifraclub.com.br/ajax/dicionario.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    chordName = [chordName stringByReplacingOccurrencesOfString:@"dim" withString:@"º"];
    chordName = [chordName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *postString = [NSString stringWithFormat:@"bpc=false&target=#d_resultado_acordes&acorde=%@&capo=0&afinacao=E-A-D-G-B-E&casas=X+X+X+X+X+X",chordName];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    return [self parseChordsFromJSON:responseData];
}

//retorna um array com as strings a serem passadas para o jtab 
+(NSMutableArray *)parseChordsFromJSON:(NSData *)data {
    NSMutableArray *chords = [[NSMutableArray alloc] init];
    NSError *error;
    NSDictionary *jsonDictionary = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error] valueForKeyPath:@"violao"];
    int i=0;
    for (id chordString in jsonDictionary) {
        NSMutableArray *notes = [self getNotesFromChord:chordString];
        NSArray *dedos = [Dedos getDedos:notes];
        NSInteger base = [self baseAcorde:notes];
        ChordTO *to = [[ChordTO alloc] init];
        to.notes = notes;
        to.fingers = dedos;
        to.base = base;
        [chords addObject:to];
//        [chords addObject:[self resultingChordFromNotes:notes andFingers:dedos withBase:base forDiv:i]];
        i++;
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"base" ascending:YES];
    [chords sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (ChordTO *chordTO in chords) {
        [ret addObject:[self resultingChordFromNotes:chordTO.notes andFingers:chordTO.fingers withBase:chordTO.base forDiv:([chords indexOfObject:chordTO]+1)]];
    }
    return ret;
}

+(NSString *)resultingChordFromNotes:(NSArray *)notes andFingers:(NSArray *)fingers withBase:(NSInteger)base forDiv:(NSInteger)div {
    int c0 = ((NSNumber *)[notes objectAtIndex:0]).integerValue;
    int c1 = ((NSNumber *)[notes objectAtIndex:1]).integerValue;
    int c2 = ((NSNumber *)[notes objectAtIndex:2]).integerValue;
    int c3 = ((NSNumber *)[notes objectAtIndex:3]).integerValue;
    int c4 = ((NSNumber *)[notes objectAtIndex:4]).integerValue;
    int c5 = ((NSNumber *)[notes objectAtIndex:5]).integerValue;
    int f0 = ((NSNumber *)[fingers objectAtIndex:0]).integerValue;
    int f1 = ((NSNumber *)[fingers objectAtIndex:1]).integerValue;
    int f2 = ((NSNumber *)[fingers objectAtIndex:2]).integerValue;
    int f3 = ((NSNumber *)[fingers objectAtIndex:3]).integerValue;
    int f4 = ((NSNumber *)[fingers objectAtIndex:4]).integerValue;
    int f5 = ((NSNumber *)[fingers objectAtIndex:5]).integerValue;
    return [[NSString stringWithFormat:@"jtab.render('tab%d','%@',[ %d, [%d,%d ],  [%d,%d],  [%d,%d],  [%d,%d],  [%d,%d],  [%d,%d] ])",div, @" ", base, c0, f0, c1, f1, c2, f2, c3, f3, c4, f4, c5, f5] stringByReplacingOccurrencesOfString:@",-1" withString:@""];
}


+(NSMutableArray *)getNotesFromChord:(NSString *)chordString {
    NSArray *splitNotes = [chordString componentsSeparatedByString:@" "];
    NSMutableArray *chord = [[NSMutableArray alloc] initWithCapacity:6];
    for (NSString *note in splitNotes) {
        NSString *noteAux = note;
        if ([note hasPrefix:@"P"]) {
            noteAux = [noteAux substringFromIndex:1];
        }
        if ([noteAux isEqualToString:@"X"]) {
            [chord addObject:[NSNumber numberWithInt:-1]];
        }
        else {
            [chord addObject:[NSNumber numberWithInt:noteAux.intValue]];
        }
    }
    return chord;
}


+(NSInteger)baseAcorde:(NSArray *)notas {
    NSInteger menor = 24;
    NSInteger maior = 0;
    for (int i=0; i<6; i++) {
        NSNumber *aux = [notas objectAtIndex:i];
        if (aux.integerValue < menor && aux.integerValue > -1 && aux.integerValue > 0) {
            menor = aux.integerValue;
        }
        if (aux.integerValue > maior) {
            maior = aux.integerValue;
        }
    }
    if (maior <= 5) {
        return 0;
    }
    return (menor -2);
}


@end
