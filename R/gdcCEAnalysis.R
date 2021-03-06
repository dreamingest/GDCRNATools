##' @title Competing endogenous RNAs (ceRNAs) analysis
##' @description Identify ceRNAs by (1) number of shared miRNAs between lncRNA and mRNA; 
##'   (2) expression correlation of lncRNA and mRNA;
##'   (3) regulation similarity of shared miRNAs on lncRNA and mRNA;
##'   (4) sensitivity correlation
##' @param lnc a vector of Ensembl long non-coding gene ids 
##' @param pc a vector of Ensembl protein coding gene ids 
##' @param deMIR a vector of differentially expressed miRNAs. Default is \code{NULL}
##' @param lnc.targets a character string specifying the database of miRNA-lncRNA interactions.
##'   Should be one of \code{'spongeScan'}, \code{'starBase'}, and \code{'miRcode'}. Default is \code{'starBase'}. \cr\cr
##'   Or a \code{list} of miRNA-lncRNA interactions generated by users
##' @param pc.targets a character string specifying the database of miRNA-lncRNA interactions.
##'   Should be one of \code{'spongeScan'}, \code{'starBase'}, and \code{'miRcode'}. Default is \code{'starBase'}. \cr\cr
##'   Or a \code{list} of miRNA-lncRNA interactions generated by users
##' @param rna.expr \code{\link[limma]{voom}} transformed gene expression data
##' @param mir.expr \code{\link[limma]{voom}} transformed mature miRNA expression data
##' @return A dataframe containing ceRNA pairs, expression correlation between lncRNA and mRNA,
##'   the number and hypergeometric significance of shared miRNAs, regulation similarity score, 
##'   and the mean sensitity correlation (the difference between Pearson correlation and partial correlation)
##'   of multiple lncRNA-miRNA-mRNA triplets, etc.
##' @references
##'   Paci P, Colombo T, Farina L. Computational analysis identifies a sponge interaction network 
##'   between long non-coding RNAs and messenger RNAs in human breast cancer. 
##'   BMC systems biology. 2014 Jul 17;8(1):83.
##' @export
##' @author Ruidong Li and Han Qu
##' @examples 
##' ####### ceRNA network analysis #######
##' deLNC <- c('ENSG00000260920','ENSG00000242125','ENSG00000261211')
##' dePC <- c('ENSG00000043355','ENSG00000109586','ENSG00000144355')
##' genes <- c(deLNC, dePC)
##' samples <- c('TCGA-2F-A9KO-01',	'TCGA-2F-A9KP-01',
##'              'TCGA-2F-A9KQ-01',	'TCGA-2F-A9KR-01',	
##'              'TCGA-2F-A9KT-01',	'TCGA-2F-A9KW-01')
##' rnaExpr <- data.frame(matrix(c(2.7,7.0,4.9,6.9,4.6,2.5,
##'                     0.5,2.5,5.7,6.5,4.9,3.8,
##'                     2.1,2.9,5.9,5.7,4.5,3.5,
##'                     2.7,5.9,4.5,5.8,5.2,3.0,
##'                     2.5,2.2,5.3,4.4,4.4,2.9,
##'                     2.4,3.8,6.2,3.8,3.8,4.2),6,6), stringsAsFactors=FALSE)
##' rownames(rnaExpr) <- genes
##' colnames(rnaExpr) <- samples
##' 
##' mirExpr <- data.frame(matrix(c(7.7,7.4,7.9,8.9,8.6,9.5,
##'                     5.1,4.4,5.5,8.5,4.4,3.5,
##'                     4.9,5.5,6.9,6.1,5.5,4.1,
##'                     12.4,13.5,15.1,15.4,13.0,12.8,
##'                     2.5,2.2,5.3,4.4,4.4,2.9,
##'                     2.4,2.7,6.2,1.5,4.4,4.2),6,6),stringsAsFactors=FALSE)
##' colnames(mirExpr) <- samples
##' rownames(mirExpr) <- c('hsa-miR-340-5p','hsa-miR-181b-5p','hsa-miR-181a-5p',
##'                        'hsa-miR-181c-5p','hsa-miR-199b-5p','hsa-miR-182-5p')
##' 
##' ceOutput <- gdcCEAnalysis(lnc         = deLNC, 
##'                           pc          = dePC, 
##'                           lnc.targets = 'starBase', 
##'                           pc.targets  = 'starBase', 
##'                           rna.expr    = rnaExpr, 
##'                          mir.expr    = mirExpr)
gdcCEAnalysis <- function(lnc, pc, deMIR=NULL, lnc.targets='starBase', 
                          pc.targets='starBase', rna.expr, mir.expr) {
    
    hyperOutput <- hyperTestFun(lnc, pc, deMIR, 
                                lnc.targets=lnc.targets, pc.targets=pc.targets)
    cat ('Step 1/3: Hypergenometric test done !\n')
    
    regOutput <- multiRegTestFun(hyperOutput, rna.expr=rna.expr, mir.expr=mir.expr)
    cat ('Step 2/3: Correlation analysis done !\n')
    cat ('Step 3/3: Regulation pattern analysis done !\n')
    
    ceOutput <- data.frame(hyperOutput, regOutput, row.names=NULL)
    
    return(ceOutput)
}



#### hypergeometric test
hyperTestFun <- function(lnc, pc, deMIR, lnc.targets='starBase', pc.targets='starBase') {
    if (! lnc.targets %in% c('spongeScan','starBase','miRcode')) {
        lnc.targets <- lnc.targets
    } else {
        lnc.targets <- lncTargets[[lnc.targets]]
    }
    
    if (! pc.targets %in% c('mirTarBase','starBase','miRcode')) {
        pc.targets <- pc.targets
    } else {
        pc.targets <- pcTargets[[pc.targets]]
    }
    
    mir1 <- unique(unlist(lnc.targets))
    mir2 <- unique(unlist(pc.targets))
    
    mirs <- union(mir1,mir2)
    popTotal <- length(mirs)
    
    ceLNC <- lnc[lnc %in% names(lnc.targets)]
    cePC <- pc[pc %in% names(pc.targets)]
    #ceMIR <- mir[mir %in% mirs]
    
    hyperOutput <- list()
    i <- 0
    for (lncID in ceLNC) {
        listTotal <- length(lnc.targets[[lncID]])
        for (gene in cePC) {
            i = i + 1
            ovlp <- intersect(lnc.targets[[lncID]], pc.targets[[gene]])
            
            popHits <- length(pc.targets[[gene]])
            Counts <- length(ovlp)
            
            ovlpMIRs <- paste(ovlp, collapse = ',')
            foldEnrichment <- Counts/listTotal*popTotal/popHits
            pValue <- phyper(Counts-1, popHits, popTotal-popHits, 
                             listTotal, lower.tail=FALSE, log.p=FALSE)
            
            ceMIR <- Reduce(intersect, list(ovlp, deMIR))
            deMIRs <- paste(ceMIR, collapse = ',')
            deMIRCounts <- length(ceMIR)
            
            hyperOutput[[i]] <- c(lncID, gene, Counts, listTotal,
                                  popHits,popTotal,foldEnrichment,pValue,ovlpMIRs,
                                  deMIRCounts, deMIRs)
            
        }
    }
    
    #hyperOutput <- Reduce(rbind, hyperOutput)  ## slower
    hyperOutput <- do.call(rbind, hyperOutput)
    #hyperOutput <- rbind_list(hyperOutput) ## not test
    
    colnames(hyperOutput) <- c('lncRNAs','Genes','Counts','listTotal','popHits','popTotal',
                               'foldEnrichment','hyperPValue','miRNAs','deMIRCounts','deMIRs')
    hyperOutput <- as.data.frame(as.matrix(hyperOutput), stringsAsFactors=FALSE)
    hyperOutput <- hyperOutput[as.numeric(hyperOutput$Counts)>0,]
    
    #hyperOutput$FDR <- p.adjust(as.numeric(as.character(hyperOutput$pValue)), method = 'fdr')
    #hyperOutput <- hyperOutput[hyperOutput$Counts>0,]
    #hyperOutput$lncRNAs <- ensembl2symbolFun(hyperOutput$lncRNAs)
    #hyperOutput$gene <- ensembl2symbolFun(hyperOutput$gene)
    
    if (is.null(deMIR)) {
        hyperOutput <- hyperOutput[,! colnames(hyperOutput) %in% c('deMIRCounts','deMIRs')]
    }
    
    return (hyperOutput)
  
}



########################################################
######## other scores
multiRegFun <- function(lnc, pc, mirs, rna.expr, mir.expr) {
  
    lncDa <- unlist(rna.expr[lnc,])
    pcDa <- unlist(rna.expr[pc,])
    
    corpl <- cor.test(pcDa, lncDa, alternative='greater')
    ppl <- corpl$p.value
    regpl <- corpl$estimate
    
    mirs <- as.character(mirs)
    
    if (mirs == '') {
        reg <- NA
        lncACT <- NA
        partialSen <- NA
        cosCol <- NA
        
    } else {
        mirs <- unlist(strsplit(mirs, ',', fixed=TRUE))
        mirCor <- sapply(mirs, function(mir) mirCorTestFun(lncDa, pcDa, mir, mir.expr))
        
        reglm <- mirCor[1,]
        regpm <- mirCor[2,]
        
        regSim <- 1-mean((abs(reglm - regpm)/(abs(reglm) + abs(regpm)))^length(mirs))
        #lncACT <- mean((abs(regpl)+abs(reglm)+abs(regpm))/3)
        sppc <- mean(regpl-(regpl-reglm*regpm)/(sqrt(1-reglm^2)*sqrt(1-regpm^2)))
        #cos <- sum(reglm*regpm)/(sqrt(sum(reglm^2))*sqrt(sum(regpm^2)))
        #col <- sum(abs(reglm)*abs(regpm))/(sqrt(sum(abs(reglm)))*sqrt(sum(abs(regpm))))
        #cosCol <- (cos+col)/2
        
    }
    
    #scores <- c(regpl, ppl, reg, lncACT, partialSen, cosCol)
    scores <- c(cor=regpl, corPValue=ppl, regSim, sppc)
    return (scores)
}



multiRegTestFun <- function(hyperOutput, rna.expr, mir.expr) {
  
    samples <- intersect(colnames(rna.expr), colnames(mir.expr))
    
    rna.expr <- rna.expr[,samples]
    mir.expr <- mir.expr[,samples]
    
    lncID <- hyperOutput$lncRNAs
    pcID <- hyperOutput$Genes
    mirID <- hyperOutput$miRNAs
    
    
    reg <- sapply(1:nrow(hyperOutput), function(i) 
        multiRegFun(lncID[i], pcID[i], mirID[i], rna.expr, mir.expr))
    
    reg <- t(reg)
    colnames(reg) <- c('cor','corPValue','regSim', 'sppc')
    return (data.frame(reg))
  
}



mirCorTestFun <- function(lncDa, pcDa, mir, mir.expr) {
    mirDa <- unlist(mir.expr[mir,])
    
    corlm <- cor.test(lncDa, mirDa, alternative='less')
    corpm <- cor.test(pcDa, mirDa, alternative='less')
    
    reglm <- corlm$estimate
    regpm <- corpm$estimate
    
    return (c(reglm, regpm)) ## lnc then pc
  
}


