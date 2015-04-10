#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#This script runs a full workflow consisting of
# - Generates a Behemoth Corpus from a directory containing many Nutch segments
# - Processes the Behemoth corpus with LegisGATE
# - Indexes the annotated corpus to Elasticsearch 
#

#export behe_home=`pwd .`
export LEGISGATE_HOME=`pwd .`

# initial CLASSPATH
CLASSPATH=""

# add libs to CLASSPATH
SEP=""

for f in $LEGISGATE_HOME/legisgate/libext/*.jar; do
  CLASSPATH=${CLASSPATH}$SEP$f;
  SEP=":"
done

#run it
export HADOOP_CLASSPATH="$CLASSPATH"

LIBJARS=`echo $HADOOP_CLASSPATH | tr : ,`

# Generates a Behemoth Corpus from a directory containing many Nutch segments
#hadoop jar $LEGISGATE_HOME/legisgate/libext/behemoth-io-1.2-SNAPSHOT-job.jar com.digitalpebble.behemoth.io.nutch.NutchSegmentConverterJob -dir data/ behemoth_corpus/legisgate_corpus -libjars "$LIBJARS" 

# Processes the Behemoth corpus with LegisGATE
#hadoop jar $LEGISGATE_HOME/legisgate/libext/behemoth-gate-1.2-SNAPSHOT-job.jar com.digitalpebble.behemoth.gate.GATEDriver behemoth_corpus/legisgate_corpus behemoth_corpus/legisgate_corpus_annotated apps/legisgate2.zip -libjars "$LIBJARS"

# Indexes the annotated corpus to Elasticsearch
hadoop jar $LEGISGATE_HOME/legisgate/libext/behemoth-elasticsearch-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.es.ESIndexerJob -Des.resource=labor/courtdocs,es.nodes=10.3.2.57,es.batch.write.retry.wait=20s behemoth_corpus/legisgate_corpus_annotated

#mvn clean package 

#hadoop jar $behe_home/core/target/behemoth-core-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.util.CorpusGenerator -i $behe_home/gate/src/test/resources/docs -o textcorpus

#hadoop jar $behe_home/core/target/behemoth-core-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.util.CorpusGenerator -i $behe_home/gate/src/test/resources/docs -o textcorpus

# have a quick look at the content
#hadoop fs -libjars $behe_home/core/target/behemoth-core-1.0-SNAPSHOT-job.jar -text textcorpus

# process with GATE
#module=gate
#hadoop fs -copyFromLocal $behe_home/$module/src/test/resources/ANNIE.zip ANNIE.zip
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.gate.GATEDriver -conf $behe_home/conf/behemoth-site.xml textcorpus textcorpusANNIE ANNIE.zip

# generate a XML corpus locally 
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.gate.GATECorpusGenerator -conf $behe_home/conf/behemoth-site.xml -i textcorpusANNIE -o GATEXMLCorpus

# have a look at the seqfile after processing using standard hadoop method
#hadoop fs -libjars $behe_home/core/target/behemoth-core-1.0-SNAPSHOT-job.jar -text textcorpusANNIE/part-*

# extract content from seq files
#hadoop jar ./behemoth-core*job.jar com.digitalpebble.behemoth.util.ContentExtractor -i seq-directory -o seqdirectory-output



# process with Tika
#module=tika
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.tika.TikaDriver -i textcorpus -o textcorpusTika 

# process with Language-ID
#module=language-id
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.languageidentification.LanguageIdDriver -i textcorpusTika -o textcorpusTikaLang

# same but filter on language 
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.languageidentification.LanguageIdDriver -D document.filter.md.keep.lang=en -i textcorpusTika -o -o textcorpusTika-EN


#filter on mime type
#module = core
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.util.CorpusFilter -D document.filter.mimetype.keep=.+html.* -i textcorpusTika -o textcorpusTika-html

#filter on url
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.util.CorpusFilter -D document.filter.url.keep=.+13.* -i textcorpusTika -o textcorpusTika-13

#filter on label
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.util.CorpusFilter -D document.filter.md.keep.label=contract -i textcorpusTika -o textcorpusTika-contracts

#set filter mode
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.util.CorpusFilter -D document.filter.md.mode=OR 

# Cluster/DocumentID dump
#hadoop jar ./behemoth-mahout*job.jar com.digitalpebble.behemoth.mahout.util.ClusterDocIDDumper -i  .../clusteredPoints -o cluster-mapping




# process with UIMA
#module=uima
#hadoop fs -copyFromLocal $behe_home/$module/src/test/resources/WhitespaceTokenizer.pear WhitespaceTokenizer.pear
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.uima.UIMADriver -conf $behe_home/behemoth-site.xml textcorpusTika textcorpusUIMA WhitespaceTokenizer.pear

# generate vectors for Mahout
#module=mahout
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.mahout.SparseVectorsFromBehemoth -i textcorpusUIMA -o textcorpus-vectors -t org.apache.uima.TokenAnnotation --namedVector




# processing a web archive
#module=io
#hadoop fs -copyFromLocal $behe_home/$module/src/test/resources/ClueWeb09_English_Sample.warc ClueWeb09.warc
#hadoop jar $behe_home/$module/target/behemoth-io-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.io.warc.WARCConverterJob -conf $behe_home/conf/behemoth-site.xml ClueWeb09.warc ClueWeb09
#module=gate
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.behemoth.gate.GATEDriver -conf $behe_home/conf/behemoth-site.xml ClueWeb09 ClueWeb09Annie ANNIE.zip

# corpus reader (useful for older version of Hadoop e.g. 0.18.x)
#module=core
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar  com.digitalpebble.behemoth.util.CorpusReader -conf $behe_home/conf/behemoth-site.xml -i ClueWeb09Annie

# corpus filter
#module=core
#hadoop jar $behe_home/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar  com.digitalpebble.behemoth.util.CorpusFilter -D document.filter.md.keep.isCV=true -i input -0 outputCV

# use of SOLR -> requires to have a SOLR instance running
#module=solr
#hadoop jar $behe_solr/$module/target/behemoth-$module-1.0-SNAPSHOT-job.jar com.digitalpebble.solr.SOLRIndexerJob ClueWeb09Annie http://69.89.5.5:8080/solr


