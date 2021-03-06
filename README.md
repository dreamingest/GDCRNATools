# *GDCRNATools* - An R package for downloading, organizing, and integrative analyzing lncRNA, mRNA, and miRNA data in GDC


# Introduction

The [Genomic Data Commons (GDC)](https://portal.gdc.cancer.gov/) maintains standardized genomic, clinical, and biospecimen data from National Cancer Institute (NCI) programs including [The Cancer Genome Atlas (TCGA)](https://tcga-data.nci.nih.gov/) and [Therapeutically Applicable Research To Generate Effective Treatments (TARGET)](https://ocg.cancer.gov/programs/target), It also accepts high quality datasets from non-NCI supported cancer research programs, such as genomic data from the [Foundation Medicine](https://www.foundationmedicine.com/).

`GDCRNATools` is an R package which provides a standard, easy-to-use and comprehensive pipeline for downloading, organizing, and integrative analyzing RNA expression data in the GDC portal with an emphasis on deciphering the lncRNA-mRNA related ceRNA regulatory network in cancer.

Many analyses can be perfomed using `GDCRNATools`, including differential gene expression analysis ([limma](http://bioconductor.org/packages/release/bioc/html/limma.html)(Ritchie et al. 2015), [edgeR](http://bioconductor.org/packages/release/bioc/html/edgeR.html)(Robinson, McCarthy, and Smyth 2010), and [DESeq2](http://bioconductor.org/packages/release/bioc/html/DESeq2.html)(Love, Huber, and Anders 2014)), univariate survival analysis (CoxPH and KM), competing endogenous RNA network analysis (hypergeometric test, Pearson correlation analysis, regulation similarity analysis, sensitivity Pearson partial  correlation), and functional enrichment analysis(GO, KEGG, DO). Besides some routine visualization methods such as volcano plot, scatter plot, and bubble plot, etc., three simple shiny apps are developed in GDCRNATools allowing users visualize the results on a local webpage.


This user-friendly package allows researchers perform the analysis by simply running a few functions and integrate their own pipelines such as molecular subtype classification, [weighted correlation network analysis (WGCNA)](https://labs.genetics.ucla.edu/horvath/CoexpressionNetwork/Rpackages/WGCNA/)(Langfelder and Horvath 2008), and TF-miRNA co-regulatory network analysis, etc. into the workflow easily.


# Installation
`GDCRNATools` is now under review in Bioconductor. Users can install the package locally.

## On Windows system
* Download the package [GDCRNATools_0.99.0.tar.gz](https://github.com/Jialab-UCR/Jialab-UCR.github.io/blob/master/GDCRNATools_0.99.0.tar.gz)
* Make sure you have [Rtools](https://cran.r-project.org/bin/windows/Rtools/) installed
* ADD R and Rtools to the Path Variable on the Environment Variables panel, including

  c:\program files\Rtools\bin

  c:\program files\Rtools\gcc-4.6.3\bin

  c:\program files\R\R.3.x.x\bin\i386

  c:\program files\R\R.3.x.x\bin\x64 

* Open a command prompt. Type R CMD INSTALL GDCRNATools_0.99.0.tar.gz

## On Linux and Mac systems
Run the following command in R
```R
install.packages('GDCRNATools_0.99.0.tar.gz', repos = NULL, type='source')
```

If `GDCRNATools` cannot be installed due to the lack of dependencies, please run the following code ahead to install those pacakges simutaneously or separately:
```R
source("https://bioconductor.org/biocLite.R")

### install packages simutaneously ###
biocLite(c('limma', 'edgeR', 'DESeq2', 'clusterProfiler', 'DOSE', 'org.Hs.eg.db', 'biomaRt', 'BiocParallel'))
install.packages(c('shiny', 'jsonlite', 'rjson', 'survival', 'survminer', 'ggplot2', 'gplots', 'Hmisc'))

### install packages seperately ###
biocLite('limma')
biocLite('edgeR')
biocLite('DESeq2')
biocLite('clusterProfiler')
biocLite('DOSE')
biocLite('org.Hs.eg.db')
biocLite('biomaRt')
biocLite('BiocParallel')

install.packages('shiny')
install.packages('jsonlite')
install.packages('rjson')
install.packages('survival')
install.packages('survminer')
install.packages('ggplot2')
install.packages('gplots')
install.packages('Hmisc')
```



# Manual
A simply manual of `GDCRNATools` is available below. Users are also highly recommended to download the comprhensive manual in _.html_ format and view on local computer [GDCRNATools Manual](https://github.com/Jialab-UCR/Jialab-UCR.github.io/blob/master/GDCRNATools_manual.html)




## 1 Data download
> Two methods are provided for downloading Gene Expression Quantification (HTSeq-Counts), Isoform Expression Quantification (BCGSC miRNA Profiling), and Clinical (Clinical Supplement) data:

* Manual download  
Step1: Download [GDC Data Transfer Tool](https://gdc.cancer.gov/access-data/gdc-data-transfer-tool) on the GDC website  
Step2: Add data to the GDC cart, then download manifest file and metadata of the cart  
Step3: Download data using `gdcRNADownload()` function by providing the manifest file  

* Automatic download  
Download [GDC Data Transfer Tool](https://gdc.cancer.gov/access-data/gdc-data-transfer-tool), manifest file, and data automatically by specifying the `project.id` and `data.type` in `gdcRNADownload()` function for RNAseq and miRNAs data, and in `gdcClinicalDownload()` function for clinical data

Users can also download data from GDC using the API method developed in [TCGAbiolinks](https://bioconductor.org/packages/release/bioc/html/TCGAbiolinks.html)(Colaprico et al. 2016) or using [TCGA-Assembler](http://www.compgenome.org/TCGA-Assembler/)(Zhu, Qiu, and Ji 2014)

### 1.1 Manual download

**1.1.1 Installation of GDC Data Transfer Tool gdc-client**

Download [GDC Data Transfer Tool](https://gdc.cancer.gov/access-data/gdc-data-transfer-tool) from the GDC website and unzip the file

**1.1.2 Download manifest file and metadata from GDC Data Portal**

![](https://github.com/Jialab-UCR/Jialab-UCR.github.io/blob/master/figures/download_rna.PRAD.gif)

**1.1.3 Download data**
```{r rnaseq, eval=FALSE, message=FALSE, warning=FALSE}
####### Download RNAseq data #######
gdcRNADownload(manifest  = 'TCGA-PRAD/TCGA-PRAD.RNAseq.gdc_manifest.2017-11-23T14-40-52.txt',
               directory = 'TCGA-PRAD/RNAseq')

####### Download miRNAs data #######
gdcRNADownload(manifest  = 'TCGA-PRAD/TCGA-PRAD.miRNAs.gdc_manifest.2017-11-22T15-36-57.txt',
               directory = 'TCGA-PRAD/miRNAs')

####### Download Clinical data #######
gdcRNADownload(manifest  = 'TCGA-PRAD/TCGA-PRAD.Clinical.gdc_manifest.2017-11-23T14-42-01.txt',
               directory = 'TCGA-PRAD/Clinical')
```



### 1.2 Automatic download
* `gdcRNADownload()` will download HTSeq-Counts data if `data.type='RNAseq'` and download BCGSC miRNA Profiling data if `data.type='miRNAs'`. `project.id` argument is required to be provided.

* `gdcClinicalDownload()` download clinical data in .xml format automatically by simply specifying the `project.id` argument.

#### 1.2.1 Download RNAseq/miRNAs data

```{r manual, eval=FALSE, message=FALSE, warning=FALSE}
####### Download RNAseq data #######
gdcRNADownload(project.id     = 'TCGA-PRAD', 
               data.type      = 'RNAseq', 
               write.manifest = FALSE,
               directory      = 'TCGA-PRAD/RNAseq')

####### Download miRNAs data #######
gdcRNADownload(project.id     = 'TCGA-PRAD', 
               data.type      = 'miRNAs', 
               write.manifest = FALSE,
               directory      = 'TCGA-PRAD/miRNAs')
```


#### 1.2.2 Download clinical data
```{r manual clinical, eval=FALSE, message=FALSE, warning=FALSE}
####### Download clinical data #######
gdcClinicalDownload(project.id     = 'TCGA-PRAD',  
                    write.manifest = FALSE,
                    directory      = 'TCGA-PRAD/Clinical')
```


## 2 Data organization

### 2.1 Parse metadata

Metadata can be parsed by either providing the metadata file that is downloaded in the data download step, or specifying the `project.id` and `data.type` in `gdcParseMetadata()` function to obtain information of data in the manifest file to facilitate data organization and basic clinical information of patients such as age, stage and gender, etc. for data analysis.


#### 2.1.1 Parse metadata by providing the metadata file
```{r parse meta, message=FALSE, warning=FALSE, eval=FALSE}
####### Parse RNAseq metadata #######
metaMatrix.RNA <- gdcParseMetadata(metafile='TCGA-PRAD/TCGA-PRAD.RNAseq.metadata.2017-11-23T17-23-59.json')

####### Parse miRNAs metadata #######
metaMatrix.MIR <- gdcParseMetadata(metafile='TCGA-PRAD/TCGA-PRAD.miRNAs.metadata.2017-11-23T17-33-55.json')
```

#### 2.1.2 Parse metadata by specifying project.id and data.type
```{r parse meta2, message=FALSE, warning=FALSE, eval=TRUE}
####### Parse RNAseq metadata #######
metaMatrix.RNA <- gdcParseMetadata(project.id = 'TCGA-PRAD',
                                   data.type  = 'RNAseq', 
                                   write.meta = FALSE)
```

```{r parse meta3, message=FALSE, warning=FALSE, eval=TRUE}
####### Parse miRNAs metadata #######
metaMatrix.MIR <- gdcParseMetadata(project.id = 'TCGA-PRAD',
                                   data.type  = 'miRNAs', 
                                   write.meta = FALSE)
```




### 2.2 Filter samples

#### 2.2.1 Filter duplicated samples
Only one sample would be kept if the sample had been sequenced more than once by `gdcFilterDuplicate()`.

```{r filter meta, message=FALSE, warning=FALSE, eval=TRUE}
####### Filter duplicated samples in RNAseq metadata #######
metaMatrix.RNA <- gdcFilterDuplicate(metaMatrix.RNA)
```

```{r filter meta2, message=FALSE, warning=FALSE, eval=TRUE}
####### Filter duplicated samples in miRNAs metadata #######
metaMatrix.MIR <- gdcFilterDuplicate(metaMatrix.MIR)
```



#### 2.2.2 Filter non-Primary Tumor and non-Solid Tissue Normal samples
Samples that are neither Primary Tumor (code: 01) nor Solid Tissue Normal (code: 11) would be filtered out by `gdcFilterSampleType()`.

```{r filter meta3, message=FALSE, warning=FALSE, eval=TRUE}
####### Filter non-Primary Tumor and non-Solid Tissue Normal samples in RNAseq metadata #######
metaMatrix.RNA <- gdcFilterSampleType(metaMatrix.RNA)
```

```{r filter meta4, message=FALSE, warning=FALSE, eval=TRUE}
####### Filter non-Primary Tumor and non-Solid Tissue Normal samples in miRNAs metadata #######
metaMatrix.MIR <- gdcFilterSampleType(metaMatrix.MIR)
```



### 2.3 Merge data

* `gdcRNAMerge()` merges raw counts data of RNAseq to a single expression matrix with rows are *Ensembl id* and columns are *samples*. Total read counts for 5p and 3p strands of miRNAs can be processed from isoform quantification files and then merged to a single expression matrix with rows are *miRBase v21 identifiers* and columns are *samples*.

* `gdcClinicalMerge()` merges clinical data to a dataframe with rows are *patient id* and columns are *clinical traits*. If `key.info=TRUE`, only those most commonly used clinical traits will be reported, otherwise, all the clinical information will be reported.


#### 2.3.1 Merge RNAseq/miRNAs data
```{r merge RNAseq, message=FALSE, warning=FALSE, eval=FALSE}
####### Merge RNAseq data #######
rnaMatrix <- gdcRNAMerge(metadata  = metaMatrix.RNA, 
                         path      = 'TCGA-PRAD/RNAseq/', 
                         data.type = 'RNAseq')

####### Merge miRNAs data #######
mirMatrix <- gdcRNAMerge(metadata  = metaMatrix.MIR,
                         path      = 'TCGA-PRAD/miRNAs/',
                         data.type = 'miRNAs')
```

#### 2.3.2 Merge clinical data
```{r merge clinical, message=FALSE, warning=FALSE, eval=FALSE}
####### Merge clinical data #######
clinicalDa <- gdcClinicalMerge(path = 'TCGA-PRAD/Clinical/', key.info = TRUE)
```



### 2.4 TMM normalization and voom transformation
It has repeatedly shown that normalization is a critical way to ensure accurate estimation and detection of differential expression (DE) by removing systematic technical effects that occur in the data(Robinson and Oshlack 2010). TMM normalization is a simple and effective method for estimating relative RNA production levels from RNA-seq data. Voom is moreover faster and more convenient than existing RNA-seq methods, and converts RNA-seq data into a form that can be analyzed using similar tools as for microarrays(Law et al. 2014).

By running `gdcVoomNormalization()` function, raw counts data would be normalized by TMM method implemented in [edgeR](http://bioconductor.org/packages/release/bioc/html/edgeR.html)(Robinson, McCarthy, and Smyth 2010) and further transformed by the voom method provided in [limma](http://bioconductor.org/packages/release/bioc/html/limma.html)(Ritchie et al. 2015). Low expression genes (logcpm < 1 in more than half of the samples) will be filtered out by default. All the genes can be kept by setting `filter=TRUE` in the `gdcVoomNormalization()`.



```{r normalization, message=FALSE, warning=FALSE, eval=FALSE}
####### RNAseq data #######
rnaExpr <- gdcVoomNormalization(counts = rnaMatrix, filter = FALSE)

####### miRNAs data #######
mirExpr <- gdcVoomNormalization(counts = mirMatrix, filter = FALSE)
```




## 3. Differential gene expression analysis

***

`gdcDEAnalysis()`, a convenience wrapper, provides three widely used methods [limma](http://bioconductor.org/packages/release/bioc/html/limma.html)(Ritchie et al. 2015), [edgeR](http://bioconductor.org/packages/release/bioc/html/edgeR.html)(Robinson, McCarthy, and Smyth 2010), and [DESeq2](http://bioconductor.org/packages/release/bioc/html/DESeq2.html)(Love, Huber, and Anders 2014) to identify differentially expressed genes (DEGs) or miRNAs between any two groups defined by users. Note that [DESeq2](http://bioconductor.org/packages/release/bioc/html/DESeq2.html)(Love, Huber, and Anders 2014) maybe slow with a single core. Multiple cores can be specified with the `nCore` argument if [DESeq2](http://bioconductor.org/packages/release/bioc/html/DESeq2.html)(Love, Huber, and Anders 2014) is in use. Users are encouraged to consult the vignette of each method for more detailed information.

### 3.1 DE analysis
```{r deg, message=FALSE, warning=FALSE, eval=FALSE}
DEGAll <- gdcDEAnalysis(counts     = rnaMatrix, 
                        group      = metaMatrix.RNA$sample_type, 
                        comparison = 'PrimaryTumor-SolidTissueNormal', 
                        method     = 'limma')
```


### 3.2 Report DE genes/miRNAs

All DEGs, DE long non-coding genes, DE protein coding genes and DE miRNAs could be reported separately by setting `geneType` argument in `gdcDEReport()`. Gene symbols and biotypes based on the Ensembl 90 annotation are reported in the output.

```{r extract, message=FALSE, warning=FALSE, eval=TRUE}
### All DEGs
deALL <- gdcDEReport(deg = DEGAll, gene.type = 'all')
```

```{r extract2, message=FALSE, warning=FALSE, eval=TRUE}
#### DE long-noncoding
deLNC <- gdcDEReport(deg = DEGAll, gene.type = 'long_non_coding')
```

```{r extract3, message=FALSE, warning=FALSE, eval=TRUE}
#### DE protein coding genes
dePC <- gdcDEReport(deg = DEGAll, gene.type = 'protein_coding')
```


### 3.3 DEG visualization

Volcano plot and bar plot are used to visualize DE analysis results in different manners by `gdcVolcanoPlot()` and `gdcBarPlot()` functions, respectively . Hierarchical clustering on the expression matrix of DEGs can be analyzed and plotted by the `gdcHeatmap()` function.

#### 3.3.1 Volcano plot
```{r volcano, fig.align='center', fig.width=5, message=FALSE, warning=FALSE, eval=TRUE}
gdcVolcanoPlot(DEGAll)
```
![](https://github.com/Jialab-UCR/Jialab-UCR.github.io/blob/master/figures/gdcVolcanoPlot.png)

#### 3.3.2 Barplot
```{r barplot, fig.align='center', fig.height=6, message=FALSE, warning=FALSE, eval=TRUE}
gdcBarPlot(deg = deALL, angle = 45, data.type = 'RNAseq')
```
![](https://github.com/Jialab-UCR/Jialab-UCR.github.io/blob/master/figures/gdcBarPlot.png)


#### 3.3.3 Heatmap
Heatmap is generated based on the `heatmap.2()` function in [gplots](https://cran.r-project.org/web/packages/gplots/index.html) package.
```{r heatmap, message=FALSE, warning=FALSE, eval=TRUE}
degName = rownames(deALL)
```

```{r heatmap 2, message=FALSE, warning=FALSE, eval=FALSE}
gdcHeatmap(deg.id = degName, metadata = metaMatrix.RNA, rna.expr = rnaExpr)
```

![](vignettes/figures/gdcHeatmap.png)


## 4 Competing endogenous RNAs network analysis

> Three criteria are used to determine the competing endogenous interactions between lncRNA-mRNA pairs: 

* The lncRNA and mRNA must share significant number of miRNAs
* Expression of lncRNA and mRNA must be positively correlated
* Those common miRNAs should play similar roles in regulating the expression of lncRNA and mRNA



### 4.1 Hypergeometric test

Hypergenometric test is performed to test whether a lncRNA and mRNA share many miRNAs significantly.

A newly developed algorithm **[spongeScan](http://spongescan.rc.ufl.edu/)**(Furi’o-Tar’i et al. 2016) is used to predict MREs in lncRNAs acting as ceRNAs. Databases such as **[starBase v2.0](http://starbase.sysu.edu.cn/)**(J.-H. Li et al. 2014), **[miRcode](http://www.mircode.org/)**(Jeggari, Marks, and Larsson 2012) and **[mirTarBase release 7.0](http://mirtarbase.mbc.nctu.edu.tw/)**(Chou et al. 2017) are used to collect predicted and experimentally validated miRNA-mRNA and/or miRNA-lncRNA interactions. Gene IDs in these databases are updated to the latest Ensembl 90 annotation of human genome and miRNAs names are updated to the new release miRBase 21 identifiers. Users can also provide their own datasets of miRNA-lncRNA and miRNA-mRNA interactions.







> The figure and equation below illustrate how the hypergeometric test works 

![](vignettes/figures/hyper.png)

<a href="https://www.codecogs.com/eqnedit.php?latex=p=1-\sum_{k=0}^m&space;\frac{\binom{K}{k}\binom{N-K}{n-k}}{\binom{N}{n}}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?p=1-\sum_{k=0}^m&space;\frac{\binom{K}{k}\binom{N-K}{n-k}}{\binom{N}{n}}" title="p=1-\sum_{k=0}^m \frac{\binom{K}{k}\binom{N-K}{n-k}}{\binom{N}{n}}" /></a>


here <a href="https://www.codecogs.com/eqnedit.php?latex=m" target="_blank"><img src="https://latex.codecogs.com/gif.latex?m" title="m" /></a> is the number of shared miRNAs, <a href="https://www.codecogs.com/eqnedit.php?latex=N" target="_blank"><img src="https://latex.codecogs.com/gif.latex?N" title="N" /></a> is the total number of miRNAs in the database, <a href="https://www.codecogs.com/eqnedit.php?latex=n" target="_blank"><img src="https://latex.codecogs.com/gif.latex?n" title="n" /></a> is the number of miRNAs targeting the lncRNA, <a href="https://www.codecogs.com/eqnedit.php?latex=K" target="_blank"><img src="https://latex.codecogs.com/gif.latex?K" title="K" /></a> is the number of miRNAs targeting the protein coding gene.


### 4.2 Pearson correlation analysis

Pearson correlation coefficient is a measure of the strength of a linear association between two variables. As we all know, miRNAs are negative regulators of gene expression. If more common miRNAs are occupied by a lncRNA, less of them will bind to the target mRNA, thus increasing the expression level of mRNA. So expression of the lncRNA and mRNA in a ceRNA pair should be positively correlated.



### 4.3 Regulation pattern analysis

> Two methods are used to measure the regulatory role of miRNAs on the lncRNA and mRNA:

* Regulation similarity

We defined a measurement *regulation similarity score* to check the similarity between miRNAs-lncRNA expression correlation and miRNAs-mRNA expression correlation.

<a href="https://www.codecogs.com/eqnedit.php?latex=$$Regulation\&space;similarity\&space;score&space;=&space;1-\frac{1}{M}&space;\sum_{k=1}^M&space;[{\frac{|corr(m_k,l)-corr(m_k,g)|}{|corr(m_k,l)|&plus;|corr(m_k,g)|}}]^M$$" target="_blank"><img src="https://latex.codecogs.com/gif.latex?$$Regulation\&space;similarity\&space;score&space;=&space;1-\frac{1}{M}&space;\sum_{k=1}^M&space;[{\frac{|corr(m_k,l)-corr(m_k,g)|}{|corr(m_k,l)|&plus;|corr(m_k,g)|}}]^M$$" title="$$Regulation\ similarity\ score = 1-\frac{1}{M} \sum_{k=1}^M [{\frac{|corr(m_k,l)-corr(m_k,g)|}{|corr(m_k,l)|+|corr(m_k,g)|}}]^M$$" /></a>

where <a href="https://www.codecogs.com/eqnedit.php?latex=m" target="_blank"><img src="https://latex.codecogs.com/gif.latex?m" title="m" /></a> is the total number of shared miRNAs, <a href="https://www.codecogs.com/eqnedit.php?latex=k" target="_blank"><img src="https://latex.codecogs.com/gif.latex?k" title="k" /></a> is the <a href="https://www.codecogs.com/eqnedit.php?latex=k" target="_blank"><img src="https://latex.codecogs.com/gif.latex?k" title="k" /></a>th shared miRNAs, <a href="https://www.codecogs.com/eqnedit.php?latex=corr(m_k,&space;l)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?corr(m_k,&space;l)" title="corr(m_k, l)" /></a> and <a href="https://www.codecogs.com/eqnedit.php?latex=corr(m_k,&space;g)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?corr(m_k,&space;g)" title="corr(m_k, g)" /></a> represents the Pearson correlation between the <a href="https://www.codecogs.com/eqnedit.php?latex=k" target="_blank"><img src="https://latex.codecogs.com/gif.latex?k" title="k" /></a>th miRNA and lncRNA, the <a href="https://www.codecogs.com/eqnedit.php?latex=k" target="_blank"><img src="https://latex.codecogs.com/gif.latex?k" title="k" /></a>th miRNA and mRNA, respectively


* Sensitivity correlation

Sensitivity correlation is defined by Paci et al.(2014) to measure if the correlation between a lncRNA and mRNA is mediated by a miRNA in the lncRNA-miRNA-mRNA triplet. We take average of all triplets of a lncRNA-mRNA pair and their shared miRNAs as the sensitivity correlation between a selected lncRNA and mRNA.

<a href="https://www.codecogs.com/eqnedit.php?latex=Sensitivity\&space;correlation&space;=&space;corr(l,g)-\frac{1}{M}\sum_{k=1}^M&space;{\frac{corr(l,g)-corr(m_k,l)corr(m_k,g)}{\sqrt{1-corr(m_k,l)^2}\sqrt{1-corr(m_k,g)^2}}}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?Sensitivity\&space;correlation&space;=&space;corr(l,g)-\frac{1}{M}\sum_{k=1}^M&space;{\frac{corr(l,g)-corr(m_k,l)corr(m_k,g)}{\sqrt{1-corr(m_k,l)^2}\sqrt{1-corr(m_k,g)^2}}}" title="Sensitivity\ correlation = corr(l,g)-\frac{1}{M}\sum_{k=1}^M {\frac{corr(l,g)-corr(m_k,l)corr(m_k,g)}{\sqrt{1-corr(m_k,l)^2}\sqrt{1-corr(m_k,g)^2}}}" /></a>


where <a href="https://www.codecogs.com/eqnedit.php?latex=M" target="_blank"><img src="https://latex.codecogs.com/gif.latex?M" title="M" /></a> is the total number of shared miRNAs, <a href="https://www.codecogs.com/eqnedit.php?latex=k" target="_blank"><img src="https://latex.codecogs.com/gif.latex?k" title="k" /></a> is the <a href="https://www.codecogs.com/eqnedit.php?latex=k" target="_blank"><img src="https://latex.codecogs.com/gif.latex?k" title="k" /></a>th shared miRNAs, <a href="https://www.codecogs.com/eqnedit.php?latex=corr(l,&space;g)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?corr(l,&space;g)" title="corr(l, g)" /></a>, <a href="https://www.codecogs.com/eqnedit.php?latex=corr(m_k,&space;l)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?corr(m_k,&space;l)" title="corr(m_k, l)" /></a> and <a href="https://www.codecogs.com/eqnedit.php?latex=corr(m_k,&space;g)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?corr(m_k,&space;g)" title="corr(m_k, g)" /></a> represents the Pearson correlation between the long non-coding RNA and the protein coding gene, the kth miRNA and lncRNA, the kth miRNA and mRNA, respectively




***
The hypergeometric test of shared miRNAs, expression correlation analysis of lncRNA-mRNA pair, and regulation pattern analysis of shared miRNAs are all implemented in the `gdcCEAnalysis()` function.



```{r ce, message=FALSE, warning=FALSE, eval=FALSE}
ceOutput <- gdcCEAnalysis(lnc         = rownames(deLNC), 
                          pc          = rownames(dePC), 
                          lnc.targets = 'starBase', 
                          pc.targets  = 'starBase', 
                          rna.expr    = rnaExpr, 
                          mir.expr    = mirExpr)
```




### 4.4 ceRNAs visualization
#### 4.4.1 Correlation plot
```{r correlation, fig.align='center', message=FALSE, warning=FALSE, eval=FALSE}
gdcCorPlot(gene1    = 'ENSG00000234456', 
           gene2    = 'ENSG00000105971',
           rna.expr = rnaExpr,
           metadata = metaMatrix.RNA)
```

![](vignettes/figures/gdcCorPlot.png)


#### 4.4.2 Correlation plot on a local webpage by shinyCorplot

Typing and running `gdcCorPlot()` for each pair of lncRNA-mRNA is bothering when multiple pairs are being interested in. `shinyCorPlot()` , a interactive plot function based on `shiny` package, can be easily operated by just clicking the genes in each drop down box (in the GUI window). By running `shinyCorPlot()` function, a local webpage would pop up and correlation plot between a lncRNA and mRNA would be automatically shown.

```{r shiny cor plot, eval=FALSE, echo=TRUE, message=FALSE, warning=FALSE}
shinyCorPlot(gene1    = rownames(deLNC), 
             gene2    = rownames(dePC), 
             rna.expr = rnaExpr, 
             metadata = metaMatrix.RNA)
```

![](vignettes/figures/TCGA-PRAD.shinyCorPlot.gif)



#### 4.4.3 Network visulization in Cytoscape

lncRNA-miRNA-mRNA interactions can be reported by the `gdcExportNetwork()` and visualized in **[Cytoscape](http://www.cytoscape.org/)**.

```{r message=FALSE, warning=FALSE, eval=FALSE}
ceOutput2 <- ceOutput[ceOutput$hyperPValue<0.01 & ceOutput$corPValue<0.01 & ceOutput$regSim != 0,]

edges <- gdcExportNetwork(ceNetwork = ceOutput2, net = 'edges')
nodes <- gdcExportNetwork(ceNetwork = ceOutput2, net = 'nodes')
```



![](vignettes/figures/network.png)




## 5 Univariate survival analysis

Two methods are provided to perform univariate survival analysis: Cox Proportional-Hazards (CoxPH) model and Kaplan Meier (KM) analysis based on the [survival](https://cran.r-project.org/web/packages/survival/index.html) package. CoxPH model considers expression value as continous variable while KM analysis divides patients into high-expreesion and low-expression groups by a user-defined threshold such as median or mean. `gdcSurvivalAnalysis()` take a list of genes as input and report the hazard ratio, 95% confidence intervals, and test significance of each gene on overall survival.


### 5.1 CoxPH analysis

```{r survival, message=FALSE, warning=FALSE, eval=FALSE}
####### CoxPH analysis #######
survOutput <- gdcSurvivalAnalysis(gene     = rownames(deALL), 
                                  method   = 'coxph', 
                                  rna.expr = rnaExpr, 
                                  metadata = metaMatrix.RNA)
```


### 5.2 KM analysis
```{r survival2, message=FALSE, warning=FALSE, eval=FALSE}
####### KM analysis #######
survOutput <- gdcSurvivalAnalysis(gene     = rownames(deALL), 
                                  method   = 'KM', 
                                  rna.expr = rnaExpr, 
                                  metadata = metaMatrix.RNA, 
                                  sep      = 'median')
```

### 5.3 KM analysis visualization
#### 5.5.1 KM plot
KM survival curves are ploted using the `gdcKMPlot()` function which is based on the R package [survminer](https://cran.r-project.org/web/packages/survminer/index.html).
```{r km plot, fig.align='center', fig.width=7, message=FALSE, warning=FALSE, eval=FALSE}
gdcKMPlot(gene     = 'ENSG00000197275', 
          rna.expr = rnaExpr, 
          metadata = metaMatrix.RNA, 
          sep      = 'median')
```

![](vignettes/figures/gdcKMPlot.png)

#### 5.3.2 KM plot on a local webpage by shinyKMPlot
The `shinyKMPlot()` function is also a simply `shiny` app which allow users view KM plots of all genes of interests on a local webpackage conveniently.
```{r shiny km plot, eval=FALSE, echo=TRUE, message=FALSE, warning=FALSE, eval=FALSE}
shinyKMPlot(gene = rownames(deALL), rna.expr = rnaExpr, metadata = metaMatrix.RNA)
```

![](vignettes/figures/TCGA-PRAD.shinyKMPlot.gif)



## 6 Functional enrichment analysis

One of the main uses of the GO is to perform enrichment analysis on gene sets. For example, given a set of genes that are up-regulated under certain conditions, an enrichment analysis will find which GO terms are over-represented (or under-represented) using annotations for that gene set and pathway enrichment can also be applied afterwards.

***

### 6.1 GO, KEGG and DO analyses
`gdcEnrichAnalysis()` can perform Gene ontology (GO), Kyoto Encyclopedia of Genes and Genomes (KEGG) and Disease Ontology (DO) functional enrichment analyses of a list of genes simultaneously. GO and KEGG analyses are based on the R/Bioconductor packages [clusterProfilier](https://bioconductor.org/packages/release/bioc/html/clusterProfiler.html)(Yu et al. 2012) and [DOSE](https://bioconductor.org/packages/release/bioc/html/DOSE.html)(Yu et al. 2015). Redundant GO terms can be removed by specifying `simplify=TRUE` in the `gdcEnrichAnalysis()` function which uses the `simplify()` function in the  [clusterProfilier](https://bioconductor.org/packages/release/bioc/html/clusterProfiler.html)(Yu et al. 2012) package. 

```{r enrichment, message=FALSE, warning=FALSE, eval=FALSE}
enrichOutput <- gdcEnrichAnalysis(gene = rownames(deALL), simplify = TRUE)
```


### 6.2 Enrichment visualization

The output generated by `gdcEnrichAnalysis()` can be used for visualization in the `gdcEnrichPlot()` function by specifying `type`,`category` and `numTerms` arguments. 


#### 6.2.1 GO barplot
```{r go bar, fig.height=8, fig.width=15.5, message=FALSE, warning=FALSE}
gdcEnrichPlot(enrichOutput, type = 'bar', category = 'GO', num.terms = 10)
```
![](https://github.com/Jialab-UCR/Jialab-UCR.github.io/blob/master/figures/gdcEnrichPlot.GO.bar.png)

#### 6.2.2 GO bubble plot
```{r go bubble, echo=TRUE, fig.height=8, fig.width=12.5, message=FALSE, warning=FALSE}
gdcEnrichPlot(enrichOutput, type='bubble', category='GO', num.terms = 10)
```
![](https://github.com/Jialab-UCR/Jialab-UCR.github.io/blob/master/figures/gdcEnrichPlot.GO.bubble.png)

#### 6.2.3 KEGG/DO barplot
```{r kegg bar, fig.height=3.5, fig.width=12.5, message=FALSE, warning=FALSE}
gdcEnrichPlot(enrichment = enrichOutput, 
              type       = 'bar', 
              category   = 'KEGG', 
              bar.color  = 'chocolate1', 
              num.terms  = 20)
```
![](https://github.com/Jialab-UCR/Jialab-UCR.github.io/blob/master/figures/gdcEnrichPlot.KEGG.bar.png)


```{r do bar, fig.height=3, fig.width=10, message=FALSE, warning=FALSE}
gdcEnrichPlot(enrichment = enrichOutput, 
              type       = 'bar', 
              category   = 'DO', 
              bar.color  = 'dodgerblue', 
              num.terms  = 20)
```

![](https://github.com/Jialab-UCR/Jialab-UCR.github.io/blob/master/figures/gdcEnrichPlot.DO.bar.png)

#### 6.2.4 KEGG/DO bubble plot
```{r kegg bubble, fig.height=5, fig.width=10.5, message=FALSE, warning=FALSE}
gdcEnrichPlot(enrichOutput, category='KEGG',type = 'bubble', num.terms = 20)
```
![](https://github.com/Jialab-UCR/Jialab-UCR.github.io/blob/master/figures/gdcEnrichPlot.KEGG.bubble.png)


```{r do bubble, fig.height=5, fig.width=8.3, message=FALSE, warning=FALSE}
gdcEnrichPlot(enrichOutput, category='DO',type = 'bubble', num.terms = 20)
```
![](https://github.com/Jialab-UCR/Jialab-UCR.github.io/blob/master/figures/gdcEnrichPlot.DO.bubble.png)

#### 6.2.5 Pathview

Users can visualize a pathway map with `pathview()` function in the [pathview](https://bioconductor.org/packages/release/bioc/html/pathview.html)(Luo and Brouwer 2013) package. It displays related many-genes-to-many-terms on 2-D view, shows by genes on BioCarta & KEGG pathway maps. Gradient colors can be used to indicate if genes are up-regulated or down-regulated.

```{r pathview, message=FALSE, warning=FALSE, eval=TRUE}
deg <- deALL$logFC
names(deg) <- rownames(deALL)
```


```{r pathview2, message=FALSE, warning=FALSE, eval=FALSE}
library(pathview)
hsa04022 <- pathview(gene.data   = deg,
                     pathway.id  = "hsa04022",
                     species     = "hsa",
                     gene.idtype = 'ENSEMBL',
                     limit       = list(gene=max(abs(geneList)), cpd=1))
```


![](vignettes/figures/hsa04022.pathview.png)


#### 6.2.6 View pathway maps on a local webpage by shinyPathview
`shinyPathview()` allows users view and download pathways of interests by simply selecting the pathway terms on a local webpage.

```{r shiny pathview, message=FALSE, warning=FALSE, include=FALSE}
pathways <- as.character(enrichOutput$Terms[enrichOutput$Category=='KEGG'])
```


```{r shiny pathview2, eval=FALSE, echo=TRUE, message=FALSE, warning=FALSE}
shinyPathview(deg, pathways = pathways, directory = 'pathview')
```

![](vignettes/figures/TCGA-PRAD.shinyPathview.gif)


## sessionInfo
```{r sessionInfo}
sessionInfo()
```

## References
Chou, Chih-Hung, Sirjana Shrestha, Chi-Dung Yang, Nai-Wen Chang, Yu-Ling Lin, Kuang-Wen Liao, Wei-Chi Huang, et al. 2017. “MiRTarBase Update 2018: A Resource for Experimentally Validated MicroRNA-Target Interactions.” Nucleic Acids Research, November, gkx1067–gkx1067. doi:10.1093/nar/gkx1067.

Colaprico, Antonio, Tiago C. Silva, Catharina Olsen, Luciano Garofano, Claudia Cava, Davide Garolini, Thais S. Sabedot, et al. 2016. “TCGAbiolinks: An R/Bioconductor Package for Integrative Analysis of TCGA Data.” Nucleic Acids Research 44 (8): e71. doi:10.1093/nar/gkv1507.

Furi’o-Tar’i, Pedro, Sonia Tarazona, Toni Gabald’on, Anton J. Enright, and Ana Conesa. 2016. “SpongeScan: A Web for Detecting MicroRNA Binding Elements in LncRNA Sequences.” Nucleic Acids Research 44 (Web Server issue): W176–W180. doi:10.1093/nar/gkw443.

Jeggari, Ashwini, Debora S Marks, and Erik Larsson. 2012. “MiRcode: A Map of Putative MicroRNA Target Sites in the Long Non-Coding Transcriptome.” Bioinformatics 28 (15): 2062–3. doi:10.1093/bioinformatics/bts344.

Langfelder, Peter, and Steve Horvath. 2008. “WGCNA: An R Package for Weighted Correlation Network Analysis.” BMC Bioinformatics 9 (December): 559. doi:10.1186/1471-2105-9-559.

Law, Charity W., Yunshun Chen, Wei Shi, and Gordon K. Smyth. 2014. “Voom: Precision Weights Unlock Linear Model Analysis Tools for RNA-Seq Read Counts.” Genome Biology 15 (February): R29. doi:10.1186/gb-2014-15-2-r29.

Li, Jun-Hao, Shun Liu, Hui Zhou, Liang-Hu Qu, and Jian-Hua Yang. 2014. “StarBase V2.0: Decoding MiRNA-CeRNA, MiRNA-NcRNA and Protein–RNA Interaction Networks from Large-Scale CLIP-Seq Data.” Nucleic Acids Research 42 (Database issue): D92–D97. doi:10.1093/nar/gkt1248.

Love, Michael I., Wolfgang Huber, and Simon Anders. 2014. “Moderated Estimation of Fold Change and Dispersion for RNA-Seq Data with DESeq2.” Genome Biology 15 (December): 550. doi:10.1186/s13059-014-0550-8.

Luo, Weijun, and Cory Brouwer. 2013. “Pathview: An R/Bioconductor Package for Pathway-Based Data Integration and Visualization.” Bioinformatics 29 (14): 1830–1. doi:10.1093/bioinformatics/btt285.

Paci, Paola, Teresa Colombo, and Lorenzo Farina. 2014. “Computational Analysis Identifies a Sponge Interaction Network Between Long Non-Coding RNAs and Messenger RNAs in Human Breast Cancer.” BMC Systems Biology 8 (July): 83. doi:10.1186/1752-0509-8-83.

Ritchie, Matthew E., Belinda Phipson, Di Wu, Yifang Hu, Charity W. Law, Wei Shi, and Gordon K. Smyth. 2015. “Limma Powers Differential Expression Analyses for RNA-Sequencing and Microarray Studies.” Nucleic Acids Research 43 (7): e47. doi:10.1093/nar/gkv007.

Robinson, Mark D., and Alicia Oshlack. 2010. “A Scaling Normalization Method for Differential Expression Analysis of RNA-Seq Data.” Genome Biology 11 (March): R25. doi:10.1186/gb-2010-11-3-r25.

Robinson, Mark D., Davis J. McCarthy, and Gordon K. Smyth. 2010. “EdgeR: A Bioconductor Package for Differential Expression Analysis of Digital Gene Expression Data.” Bioinformatics 26 (1): 139–40. doi:10.1093/bioinformatics/btp616.

Yu, Guangchuang, Li-Gen Wang, Yanyan Han, and Qing-Yu He. 2012. “ClusterProfiler: An R Package for Comparing Biological Themes Among Gene Clusters.” OMICS : A Journal of Integrative Biology 16 (5): 284–87. doi:10.1089/omi.2011.0118.

Yu, Guangchuang, Li-Gen Wang, Guang-Rong Yan, and Qing-Yu He. 2015. “DOSE: An R/Bioconductor Package for Disease Ontology Semantic and Enrichment Analysis.” Bioinformatics 31 (4): 608–9. doi:10.1093/bioinformatics/btu684.

Zhu, Yitan, Peng Qiu, and Yuan Ji. 2014. “TCGA-Assembler: An Open-Source Pipeline for TCGA Data Downloading, Assembling, and Processing.” Nature Methods 11 (6): 599–600. doi:10.1038/nmeth.2956.
