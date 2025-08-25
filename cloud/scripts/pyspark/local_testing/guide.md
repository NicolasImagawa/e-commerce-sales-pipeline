https://www.oracle.com/de/java/technologies/javase/jdk11-archive-downloads.html

Look for the zip folder called jdk-11.0.13_windows-x64_bin.zip

save to c:/tools

Then, add it to PATH:
export JAVA_HOME="/c/tools/jdk-11.0.27"
export PATH="${JAVA_HOME}/bin:${PATH}"

Check the Java version:
java --version

- (Optional) Then, if you plan to use PySpark again, save the PATH commands in bashrc:
    ~/.bashrc

    CTRL + X and Y to save it.

    Then, run:
    source ~/.bashrc

Now, create a folder c:/tools/hadoop-3.2.0 and run the following commands inside the folder:

HADOOP_VERSION="3.2.0"
PREFIX="https://raw.githubusercontent.com/cdarlint/winutils/master/hadoop-${HADOOP_VERSION}/bin/"

FILES="hadoop.dll hadoop.exp hadoop.lib hadoop.pdb libwinutils.lib winutils.exe winutils.pdb"

for FILE in ${FILES}; do
  wget "${PREFIX}/${FILE}"
done

Now, add it to path like we did for the java files:

export HADOOP_HOME="/c/tools/hadoop-3.2.0"
export PATH="${HADOOP_HOME}/bin:${PATH}"

Then, download Spark:
wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz

After it, save it to PATH:
export SPARK_HOME="/c/tools/spark-3.3.2-bin-hadoop3"
export PATH="${SPARK_HOME}/bin:${PATH}"

Inside the spark folder, run:
./bin/spark-shell.cmd

If a firewall message appears, please allow Java to be executed.


Then, add Python to the PYTHONPATH
export PYTHONPATH="${SPARK_HOME}/python/:$PYTHONPATH"
export PYTHONPATH="${SPARK_HOME}/python/lib/py4j-0.10.9.5-src.zip:$PYTHONPATH"