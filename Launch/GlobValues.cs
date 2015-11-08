using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Launch
{
    class GlobValues
    {
        public int nodes { get; set; }
        public int edges { get; set; }
        public int clusters { get; set; }
        public double modularityMinValue { get; set; }
        public double modularityMaxValue { get; set; }
        public int numberOfGraphs { get; set; }
        public double couplingStrength { get; set; }
        public double couplingProb { get; set; }
        public double runningTime { get; set; }
     }
}
