# ProcessWavProject
***调用语音引擎处理数据***

### 1.用法：
- a.启动Nuance引擎：perl runNteServer.pl
- b.开启识别：      perl CallOuterEnglishAsrEnginer.pl input.list 

### 2.输入：
- a.通过config/config.ini配置启动端口和并发数；
- b.通过config/config.ini配置并发数；
- c.待处理的文件列表；

### 3.输出：
- a.实时存入elasticSearch表格，便于后续检索和统计；
