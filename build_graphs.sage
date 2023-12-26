from sage.graphs.distances_all_pairs import diameter
from sage.graphs.distances_all_pairs import distances_all_pairs

from sage.graphs.connectivity import vertex_connectivity, edge_connectivity
from itertools import combinations
from math import ceil

class integ_circ_graph:
    def __init__(self, N, k, g, jump_set, eigen, metric):
        self.N = N  # Number of vertices
        self.k = k  # Jump size
        self.g = g # Sage graph object
        self.jump_set = jump_set  # Jump set of the circulant graph
        self.eigenvalues = eigen  # Eigenvalues of the integral circulant graph
        self.metric = metric

    def format_metric(self):
        met = f'{float(self.metric):0.3f}'.rstrip('0')
        if met[-1] == '.':
            met += '0'
        return met

    def pretty_show(self, opt_text=""):
        a = plot([],axes=False, figsize=(5,5),title= f'{opt_text}: {self.format_metric()}' +"\n"+"(N = {}, k = {}) \nJump set: {}".format(self.N, self.k, self.jump_set), fontsize=15)
        a += plot(self.g)
        # a += text("Eigenvals: "+ str(len(self.eigenvalues)), (0,0), fontsize=6)
        # a += text("Eigenvals: "+ str((self.eigenvalues)), (0,0), fontsize=6)

        show(a)

    def display_info(self, opt_text=""):
        print(f"Number of Vertices (N): {self.N}")
        print(f"Degree (k): {self.k}")
        if self.g != 0:
            self.pretty_show(opt_text)
        print(f"Jump Set: {self.jump_set}")
        print(f"Eigenvalues: {self.eigenvalues}")


def is_integral(eigen):
    # return True
    return all(eig in ZZ for eig in eigen)




def get_jump_factors(jump_set):
    
    jump_s = set(jump_set)
    
    for i in jump_set:
        fac_list = list(factor(i))
        for j in fac_list:
            jump_s.add(j[0])
    return jump_s



def generate_graphs(N, k):
    
    jump_set_len = ceil(k/2)
    
    elems = [i for i in range(floor(N/2)+1)][1:]

    all_combinations = combinations(elems, jump_set_len)

    result = [list(comb) for comb in all_combinations]
    
    if k % 2 != 0: #if k is odd
        odd_edge = elems[-1]
        print('oddedge: ', odd_edge)
        all_combinations = combinations(elems[:-1], jump_set_len-1)
        result = [list(comb) + [odd_edge] for comb in all_combinations]

    print('RESULT: ', result)
    js_dict = {}

    for res in result:
        js_dict[tuple(res)] = get_jump_factors(res)

    min_diam = float('inf')
    min_diam_graph = integ_circ_graph(0, 0, 0, 0, 0, 0) #graphs.CompleteGraph(1)
    min_diam_n = 0
    
    max_v_conn = float('-inf')
    max_v_conn_graph = integ_circ_graph(0, 0, 0, 0, 0, 0) #graphs.CompleteGraph(1)
    max_v_conn_n = 0

    max_e_conn = float('-inf')
    max_e_conn_graph =  integ_circ_graph(0, 0, 0, 0, 0, 0) #graphs.CompleteGraph(1)
    max_e_conn_n = 0

    min_mpl = float('inf')
    min_mpl_graph = integ_circ_graph(0, 0, 0, 0, 0, 0) #graphs.CompleteGraph(1)
    min_mpl_n = 0

    for jump_set in result:
        jf = js_dict[tuple(jump_set)]
        print('n = ', N, '\tjump_set = ',jump_set )
        
        if N in jf:
            print('----- Skipping n=', n, '-------')
            continue
        
        g = graphs.CirculantGraph(N,jump_set)
            
        eigen = g.spectrum()
        #g.show()
        print(eigen)
        if is_integral(eigen) and g.is_connected():

            dist_all_pairs = distances_all_pairs(g)

            mpl = sum(dist_all_pairs[0].values())/(N-1.0)
            print(dist_all_pairs[0].values())

            print("diam: ", max(dist_all_pairs[0].values()))
            diam = max(dist_all_pairs[0].values())
            # diam = diameter(g, algorithm='iFUB')

            v_conn = vertex_connectivity(g)
            e_conn = edge_connectivity(g)

            print(eigen)
            print(jump_set)
            #g.show()


            if max_v_conn < v_conn:
                max_v_conn = v_conn
                max_v_conn_graph = integ_circ_graph(N, k, g, jump_set, eigen, v_conn)
                max_v_conn_n = N

            if max_e_conn < e_conn:
                max_e_conn = e_conn
                max_e_conn_graph = integ_circ_graph(N, k, g, jump_set, eigen, e_conn)
                max_e_conn_n = N

        
            if min_diam > diam:
                min_diam = diam
                min_diam_n = N
                min_diam_graph = integ_circ_graph(N, k, g, jump_set, eigen, diam)


            if min_mpl > mpl:
                min_mpl = mpl
                min_mpl_n = N
                min_mpl_graph = integ_circ_graph(N, k, g, jump_set, eigen, mpl)

    
    # print('\n\nMinimum diameter\n Min diameter = ', min_diam, '\n')
    # min_diam_graph.display_info("Minimum diameter")
    
    print('\n\nMaximum v connectivity = ', max_v_conn, '\n')
    max_v_conn_graph.display_info("Max vertex connectivity")

    print('\n\nMaximum e connectivity = ', max_e_conn, '\n')
    max_e_conn_graph.display_info("Max edge connectivity")

    # print('\n\nMin MPL = ', min_mpl, '\n')
    # min_mpl_graph.display_info("Min MPL")


#To replicate past experiment: (16,4) check MPL, not integral => must be [1,6]

# generate_graphs(16, 4)

# generate_graphs(12, 4)

# generate_graphs(32, 16)


for n in range(20, 21):
    for k in range(10, 15):
        generate_graphs(n, k)




#generate_graphs(16,7)
 
#generate_graphs(16, 4)

#generate_graphs(14, 7)
#generate_graphs(14, 13)
