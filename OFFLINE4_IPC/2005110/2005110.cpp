#include <chrono>
#include <iostream>
#include <pthread.h>
#include <random>
#include <unistd.h>
#include <vector>
#include <semaphore.h>

// Constants
#define SLEEP_MULTIPLIER 1000           // Multiplier to convert seconds to milliseconds
#define MAX__DELAY_STEP0_TIME 2         //// Maximum time a visitor can delay "in step 0"
#define MAX_DELAY_STEP1_TIME 3          /// Maximum time a visitor can delay "in step 1"
#define MAX_DELAY_STEP2_TIME 3          /// Maximum time a visitor can delay "in step 2"
#define MAX_DELAY_GLASS_CORRIDOR_TIME 3 /// Maximum time a visitor can delay "in glass corridor"

using namespace std;

int N; // number of standard tickets holder
int M; ////number of premium tickets holder

int standard_count;
int premium_count;

// Mutex lock for output to file for avoiding interleaving
pthread_mutex_t output_lock;

// Mutex lock for BC steps avoiding interleaving
pthread_mutex_t step_0;
pthread_mutex_t step_1;
pthread_mutex_t step_2;

// Mutex lock for gallery2 avoiding interleaving
pthread_mutex_t standard_count_lock;
pthread_mutex_t premium_count_lock;
pthread_mutex_t photobooth_lock;
pthread_mutex_t photobooth_access_lock;

// semaphore for max people count in Gallery1 and glassCoridor (DE)
sem_t gallery1;
sem_t glass_corridore_DE;

// Timing functions
auto start_time = std::chrono::high_resolution_clock::now();

/**
 * Get the elapsed time in milliseconds since the start of the simulation.
 * @return The elapsed time in milliseconds.
 */
long long get_time()
{
    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
        end_time - start_time);
    long long elapsed_time_ms = duration.count();
    return elapsed_time_ms;
}

// Function to generate a Poisson-distributed random number
int get_random_number()
{
    std::random_device rd;
    std::mt19937 generator(rd());

    // Lambda value for the Poisson distribution
    double lambda = 3.234;
    std::poisson_distribution<int> poissonDist(lambda);
    return poissonDist(generator);
}

enum visitor_state
{
    IN_HALLWAY_AB,
    IN_STEP_0,
    IN_STEP_1,
    IN_STEP_2,
    IN_GALLERY_1,
    IN_GLASS_CORRIDOR_DE,
    IN_GALLERY_2
};

/*Class representing a visitor in the simulation.*/

class Visitor
{
public:
    int id;                      // Unique ID for each visitor
    int w;                       // Time visiotor spends "in hallway AB"
    int x;                       // Time visiotor spends "in gallery 1"
    int y;                       // Time visitor spends in "Gallery 2"
    int z;                       // Time visiotr spends in hallway
    int delay_step_0;            // The visitor spends "delay in step 0"
    int delay_step_1;            // The visitor spends "delay in step 1"
    int delay_step_2;            // The visitor spends "delay in step 2"
    int delay_glass_corridor_de; // The visiot spends "delay in glass corridor DE"

    visitor_state state; // Current state of the visitor

    // Constructor to initialize a visiotr with a unique ID
    Visitor(int id, int w, int x, int y, int z)
    {
        this->id = id;
        this->w = w; // hallway
        this->x = x; // gallery 1
        this->y = y; // gallery 2
        this->z = z; // photo booth
        delay_step_0 = MAX__DELAY_STEP0_TIME;
        delay_step_1 = MAX_DELAY_STEP1_TIME;
        delay_step_2 = MAX_DELAY_STEP2_TIME;
        delay_glass_corridor_de = MAX_DELAY_GLASS_CORRIDOR_TIME;
    }
};

vector<Visitor> visitors; // Vector to store all students

// uses mutex lock to write output to avoid interleaving
void write_output(string output)
{
    pthread_mutex_lock(&output_lock);
    cout << output;
    pthread_mutex_unlock(&output_lock);
}

/*Initialize visitors and set the start time for the simulation.*/

void initialize(int w, int x, int y, int z)
{
    standard_count = 0; // N:standard tickets holder (reader) less priority, initially 0
    premium_count = 0;  // M :premium tickets holder (writer) higher priority, initially 0

    for (int i = 0; i < (N + M); i++)
    {
        if (i < N)
        {
            int id = 1001 + i;
            visitors.emplace_back(Visitor(id, w, x, y, z)); // standard tickets holder(1001-1100)
        }
        else
        {
            int id = 2001 + i - N;
            visitors.emplace_back(Visitor(id, w, x, y, z)); // standard tickets holder(1001-1100)
        }
    }

    pthread_mutex_init(&output_lock, NULL);
    pthread_mutex_init(&step_0, NULL);
    pthread_mutex_init(&step_1, NULL);
    pthread_mutex_init(&step_2, NULL);

    pthread_mutex_init(&standard_count_lock, NULL);
    pthread_mutex_init(&premium_count_lock, NULL);
    pthread_mutex_init(&photobooth_lock, NULL);
    pthread_mutex_init(&photobooth_access_lock, NULL);

    sem_init(&gallery1, 0, 5);
    sem_init(&glass_corridore_DE, 0, 3);

    start_time = std::chrono::high_resolution_clock::now(); // Reset start time
}

/**
 * Thread function for visitor activities.
 * Simulates the visitor's hallway entry and in hallway , steps from B to C, reaching Gallery1 and then
 * going through glass corridor DE and reaching Gallery 2.
 * @param arg Pointer to a Visitor object.
 */

void *visitor_activities(void *arg)
{
    Visitor *visitor = (Visitor *)arg;

    write_output("Visitor " + std::to_string(visitor->id) +
                 " has arrived at A at timestamp " + to_string(get_time()) + "\n");
    usleep(visitor->w * SLEEP_MULTIPLIER); // Simulate time at hallway AB
    write_output("Visitor " + to_string(visitor->id) +
                 " has arrived at B at timestamp " + to_string(get_time()) + "\n");

    // // step 0
    pthread_mutex_lock(&step_0);
    // step 0 paise , so hallway chere dise tar mane
    write_output("Visitor " + to_string(visitor->id) +
                 " has arrived at step 0 at timestamp " + to_string(get_time()) + "\n");
    usleep(visitor->delay_step_0 * SLEEP_MULTIPLIER); // Simulate delay at step 0

    // step 1
    pthread_mutex_lock(&step_1);
    // step 1 paise , so step 0 chere dise tar mane
    write_output("Visitor " + to_string(visitor->id) +
                 " has arrived at step 1 at timestamp " + to_string(get_time()) + "\n");
    pthread_mutex_unlock(&step_0);                    // step 0 chere dibe
    usleep(visitor->delay_step_1 * SLEEP_MULTIPLIER); // Simulate delay at step 1

    // step 2
    pthread_mutex_lock(&step_2);
    // step 2 paise , step 1 chere dise tar mane
    write_output("Visitor " + to_string(visitor->id) +
                 " has arrived at step 2 at timestamp " + to_string(get_time()) + "\n");
    pthread_mutex_unlock(&step_1);                    // step 1 chere dibe
    usleep(visitor->delay_step_2 * SLEEP_MULTIPLIER); // Simulate delay at step 2

    // gallery1
    sem_wait(&gallery1);
    // gallery 1 paise , step 2 chere dise tar mane
    write_output("Visitor " + to_string(visitor->id) +
                 " has arrived at C (entered Gallery 1) at time " + to_string(get_time()) + "\n");
    pthread_mutex_unlock(&step_2);         // step 2 chere dibe
    usleep(visitor->x * SLEEP_MULTIPLIER); // Simulate delay at  gallery 1

    // glass corridor
    sem_wait(&glass_corridore_DE);
    // glass corridore paise , gallery 1 chere dibe tar mane
    write_output("Visitor " + to_string(visitor->id) +
                 " has arrived at D (exiting Gallery 1) at time " + to_string(get_time()) + "\n");
    sem_post(&gallery1); // gallery 1 exit korlm , then sleep diye corridor e asi

    usleep(visitor->delay_glass_corridor_de * SLEEP_MULTIPLIER); // Simulate delay at glass corridor DE

    /*GAllery 2 te dhukbo corridor chere diye*/
    sem_post(&glass_corridore_DE);
    /*glass corridor theke ber hoye gallery 2 te jabe*/
    write_output("Visitor " + to_string(visitor->id) +
                 " has arrived E (entered Gallery 2) at time " + to_string(get_time()) + "\n");

    // gallery 2
    /* now in gallery 2 print , now need to do id check and differentiate between standard and premium visitor
    immediate and exclusive access*/

    usleep(visitor->y * SLEEP_MULTIPLIER); // Simulate spend time at Gallery 2

    // extra added
    int random_sleep = get_random_number() % 10;
    if (visitor->id >= 1001 && visitor->id <= 1100)
        usleep(3 * SLEEP_MULTIPLIER); // random sleep to standard people

    write_output("Visitor " + to_string(visitor->id) +
                 " is about to enter the photo booth at timestamp " + to_string(get_time()) + "\n");

    if (visitor->id >= 1001 && visitor->id <= 1100)
    {
        // standard tickets holder
        // shared access of photo booth , less priority
        pthread_mutex_lock(&photobooth_access_lock);

        pthread_mutex_lock(&standard_count_lock);
        standard_count++;
        if (standard_count == 1)
            pthread_mutex_lock(&photobooth_lock);
        pthread_mutex_unlock(&standard_count_lock);

        pthread_mutex_unlock(&photobooth_access_lock);

        // in photo booth
        write_output("Visitor " + to_string(visitor->id) +
                     " is inside the photo booth at timestamp " + to_string(get_time()) + "\n");

        usleep(visitor->z * SLEEP_MULTIPLIER); // simulating spends time in photo booth

        pthread_mutex_lock(&standard_count_lock);
        standard_count--;
        if (standard_count == 0)
            pthread_mutex_unlock(&photobooth_lock);

        pthread_mutex_unlock(&standard_count_lock);
    }
    else if (visitor->id >= 2001 && visitor->id <= 2100)
    {
        // premium tickets holder
        // immediate and exclusive access of photo booth
        pthread_mutex_lock(&premium_count_lock);
        premium_count++;
        if (premium_count == 1)
        {
            pthread_mutex_lock(&photobooth_access_lock); // ekjon o premium thakakalin , photo booth access lock thakbe
        }
        pthread_mutex_unlock(&premium_count_lock);

        // photo booth access lock ase and now this visitor goes to photo booth
        // and access the booth exclusively , using db lock, ensuring that
        pthread_mutex_lock(&photobooth_lock);
        // now is in photo booth-exclusively , duita premium o eksathe booth e thakbe na
        write_output("Visitor " + to_string(visitor->id) +
                     " is inside the photo booth at timestamp " + to_string(get_time()) + "\n");
        usleep(visitor->z * SLEEP_MULTIPLIER); // simulating spends time in photo booth
        pthread_mutex_unlock(&photobooth_lock);

        pthread_mutex_lock(&premium_count_lock);
        premium_count--;
        if (premium_count == 0)
        {
            pthread_mutex_unlock(&photobooth_access_lock);
        }
        pthread_mutex_unlock(&premium_count_lock);
    }

    return NULL;
}

int main(int argc, char *argv[])
{
    // Read number of visitors from input
    cin >> N >> M;
    int w, x, y, z = 0;
    cin >> w >> x >> y >> z;

    pthread_t visitor_threads[N + M]; // Array to hold visitor threads

    initialize(w, x, y, z); // Initialize visitors all mutex lock

    int remainingVisitors = N + M;
    bool started[N + M];

    // start visitor threads randomly
    while (remainingVisitors)
    {
        int randomVisitor = (get_random_number() % (N + M));
        if (!started[randomVisitor])
        {
            started[randomVisitor] = true;
            pthread_create(&visitor_threads[randomVisitor], NULL, visitor_activities,
                           &visitors[randomVisitor]);
            remainingVisitors--;
            usleep(1000); // sleep for 1 ms
            if (get_time() >
                7000)
            { // if more than 7 seconds is passed, initialize the rest
                break;
            }
        }
    }

    // after waiting for 7(our choice) secs, start the remaining visitor threadss
    for (int i = 0; i < (N + M); i++)
    {
        if (!started[i])
        {
            started[i] = true;
            pthread_create(&visitor_threads[i], NULL, visitor_activities,
                           &visitors[i]);
        }
    }

    // Wait for all visitor threads to finish
    for (int i = 0; i < (N + M); i++)
    {
        pthread_join(visitor_threads[i], NULL);
    }

    return 0;
}

/*
compilation:
 g++ -pthread 2005110.cpp -o 2005110.out
 ./2005110.out in.txt out.txt

 //works better for
 10 6
 2 3 8 5
*/