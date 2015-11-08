#region MONO/NET System libraries
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Threading.Tasks;
#endregion

#region Much appreciated thirs party libraries
using MathNet.Numerics.Distributions;
#endregion

#region NETGen libraries
using NETGen.Core;
using NETGen.Visualization;
using NETGen.Layouts.FruchtermanReingold;
using NETGen.NetworkModels.Cluster;
using NETGen.Dynamics.Synchronization;
using System.IO;
using System.Reflection;
using System.Collections;

namespace Launch
{
    static class Modularity
    {
       static Kuramoto sync;
        static ClusterNetwork network;
        static Dictionary<int, double> _clusterOrder = new Dictionary<int, double>();
        static Dictionary<int, bool> pacemaker_mode = new Dictionary<int, bool>();
        static  double runTime = 10d;
        // To read the parameter.config files for a type of network with different modularity
        public static void read_parameters(String configFile,GlobValues glob)
        {
            string[] allLines;
            ArrayList list = new ArrayList();

            using (StreamReader sr = File.OpenText(configFile))
            {
                string s = String.Empty;
                while ((s = sr.ReadLine()) != null)
                {
                    allLines = s.Split(new[] {"="}, StringSplitOptions.None);
                    list.Add(allLines[1]);
                 }

                    glob.nodes = Int32.Parse(list[0].ToString());
                    glob.edges = Int32.Parse(list[1].ToString());
                    glob.clusters = Int32.Parse(list[2].ToString());
                    glob.modularityMinValue = Double.Parse(list[3].ToString());
                    glob.modularityMaxValue = Double.Parse(list[4].ToString());
                    glob.numberOfGraphs = Int32.Parse(list[5].ToString());
                    glob.couplingStrength = Double.Parse(list[6].ToString());
                    glob.couplingProb = Double.Parse(list[7].ToString());
                    glob.runningTime = Double.Parse(list[8].ToString());
                    runTime = glob.runningTime;
            }

        }

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            GlobValues glob = new GlobValues();
            string configFile, dir = Path.GetDirectoryName(Assembly.GetEntryAssembly().Location), inputPath, outputPath;
            String[] path = dir.Split(new string[] { "Launch" }, StringSplitOptions.None);
            inputPath = path[0] + "Launch" + Path.DirectorySeparatorChar + "input";
            configFile = inputPath + Path.DirectorySeparatorChar + "config.param.txt";
           // outputPath = path[0] + "Launch" + Path.DirectorySeparatorChar + "output";
            Console.WriteLine("File is : " + configFile);


           

            Console.WriteLine("Starting the program to generate the network based on modularity..");
            try
            {
                // Read parameters from param.config file

                read_parameters(configFile, glob);
            }
            catch
            {
                Console.WriteLine("Usage: mono Demo.exe [nodes] [edges] [clusters] [resultfile]");
                return;
            }

            // Displays the information

            Console.WriteLine("Given Parameter values");
            Console.WriteLine("\n Nodes: " + glob.nodes + "\n Edges: " + glob.edges + "\n Clusters: " + glob.clusters + "\n Modularity MinValue: " + glob.modularityMinValue + "\n Modularity MaxValue: " + glob.modularityMaxValue);
            Console.WriteLine(" Number of runs: " + glob.numberOfGraphs + "\n Coupling probability value: "+glob.couplingProb*100);

            string sourceNetworkFile = inputPath = path[0] + "Launch" + Path.DirectorySeparatorChar + "Launch" + Path.DirectorySeparatorChar + "bin" + Path.DirectorySeparatorChar + "Debug" + Path.DirectorySeparatorChar + "network.edges";
           
            string sourceResultFile = inputPath = path[0] + "Launch" + Path.DirectorySeparatorChar + "Launch" + Path.DirectorySeparatorChar + "bin" + Path.DirectorySeparatorChar + "Debug" + Path.DirectorySeparatorChar + "result.dat";


            // For loop to make n number of Networks with the given size and modularity ... 
            double modularity = glob.modularityMinValue;

            while (modularity <= glob.modularityMaxValue)
            {
                String outputFile = "Result_M" + modularity;
                outputPath = path[0] + "Launch" + Path.DirectorySeparatorChar + outputFile;
                System.IO.Directory.CreateDirectory(outputPath);

                try
                {

                    for (int n = 1; n <= glob.numberOfGraphs; n++)
                    {
                        network = new ClusterNetwork(glob.nodes, glob.edges, glob.clusters, modularity, true);

                        // Restricting the modularity value upto 1 decimal place
                       // modularity = Math.Round(network.NewmanModularityUndirected, 1);

                        String memberOutputFile = outputPath + Path.DirectorySeparatorChar + "membership.dat";
                        System.IO.StreamWriter sw = System.IO.File.CreateText(memberOutputFile);
                        int i = 0;
                        foreach (Vertex v in network.Vertices)
                        {
                            v.Label = (i++).ToString();
                            sw.WriteLine(network.GetClusterForNode(v).ToString());
                        }
                        sw.Close();
                        Network.SaveToEdgeFile(network, "network.edges");
                        Console.WriteLine("Created network with {0} vertices, {1} edges and modularity {2:0.00}", network.VertexCount, network.EdgeCount, modularity);
                        // To move a file or folder to a new location without renaming it. We rename the files after running the Kuramoto model.

                        string destinationResultFile = outputPath + Path.DirectorySeparatorChar + n + "_res_N" + network.VertexCount + "_E" + network.EdgeCount + "_C" + glob.clusters + "_M" + modularity + "_K" + glob.couplingStrength + ".dat";
                        string destinationNetworkFile = outputPath + Path.DirectorySeparatorChar + n + "_network_N" + network.VertexCount + "_E" + network.EdgeCount + "_C" + glob.clusters + "_M" + modularity + "_K" + glob.couplingStrength + ".edges";

                        System.IO.File.Move(outputPath + Path.DirectorySeparatorChar + "membership.dat", outputPath + Path.DirectorySeparatorChar + n + "_mem_N" + network.VertexCount + "_E" + network.EdgeCount + "_C" + glob.clusters + "_M" + modularity + "_K" + glob.couplingStrength + ".dat");
                        try
                        {
                            Console.WriteLine("Moving the generated files to output directory..");
                            System.IO.File.Move(sourceNetworkFile, destinationNetworkFile);
                        }
                        catch (IOException e)
                        {
                            Console.WriteLine(e.Message);
                        }

                        // Run the Kuramoto model here and store the results in the output directory
                        NetworkColorizer colorizer = new NetworkColorizer();
                        // Distribution of natural frequencies
                        double mean_frequency = 1d;
                        Normal normal = new Normal(mean_frequency, mean_frequency / 5d);



                        sync = new Kuramoto(network,
                                        glob.couplingStrength,
                                        glob.couplingProb,
                                        colorizer,
                                        new Func<Vertex, Vertex[]>(v => { return new Vertex[] { v.RandomNeighbor }; })
                                        );

                        foreach (Vertex v in network.Vertices)
                            sync.NaturalFrequencies[v] = normal.Sample();


                        foreach (int g in network.ClusterIDs)
                            pacemaker_mode[g] = false;

                        sync.OnStep += new Kuramoto.StepHandler(recordOrder);

                        Logger.AddMessage(LogEntryType.AppMsg, "Press enter to start synchronization experiment...");
                        Console.ReadLine();

                        // Run the simulation
                        sync.Run();

                        // Write the time series to the resultfile
                        if (sourceResultFile != null)
                            sync.WriteTimeSeries(sourceResultFile);

                        // Moving results of kuramoto model into output directory
                        System.IO.File.Move(sourceResultFile, destinationResultFile);

                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine("Error: " + e);
                }
                modularity = modularity + 0.1;
            }
            // End line of the program
            Console.WriteLine("Program ended successfully..");

        }

        private static void recordOrder(double time)
                    {
                        
                        // Compute and record global order parameter
                        double globalOrder = sync.GetOrder(network.Vertices.ToArray());

                        foreach (Vertex v in network.Vertices)
                            sync.AddDataPoint(v.Label, sync.CurrentValues[sync._mapping[v]]);

            //  if (time > 30d)
                    if (time > runTime)
                    sync.Stop();

         //   Logger.AddMessage(LogEntryType.SimMsg, string.Format("Time = {000000}", time)); //Avg. Cluster Order = {1:0.00}, Global Order = {2:0.00}", time, avgLocalOrder, globalOrder));
      }
    }           
 }
  #endregion