#include <iostream>
#include <thread>
#include <vector>
#include <queue>
#include <mutex>
#include "semaphore.h"
#include <random>

// Микропроект №2
// Ибрагимов Константин
// БПИ192

using namespace std;

// Первая очередь
sem_t cashierFirst;
queue<sem_t *> queueFirst;
mutex mutexQueueFirst;

// Вторая очередь
sem_t cashierSecond;
queue<sem_t *> queueSecond;
mutex mutexQueueSecond;

// Максимальное число очередей на вывод информации
int numberOfClients;
mutex numberOfClientsMutex;
mutex mutexOutput;

static mt19937 mt_rand(chrono::high_resolution_clock::now().time_since_epoch().count());

// Рандомный выбор между очередями.
int randQueue() {
    return mt_rand() % 2;
}

// Симуляция нахождения в очереди.
void queueProcess(int client_num) {
    sem_t *semaphore = new sem_t;
    int numberOfQueue = randQueue();
    sem_init(semaphore, 0, 0);
    if (numberOfQueue == 0) {
        mutexQueueFirst.lock();
        queueFirst.push(semaphore);
        sem_post(&cashierFirst);
        mutexQueueFirst.unlock();
    } else {
        mutexQueueSecond.lock();
        queueSecond.push(semaphore);
        sem_post(&cashierSecond);
        mutexQueueSecond.unlock();
    }

    sem_wait(semaphore);
    mutexOutput.lock();
    cout << "cashier #" << numberOfQueue + 1 << " cater customer #" << client_num + 1 << endl;
    mutexOutput.unlock();
    numberOfClientsMutex.lock();
    numberOfClients--;
    numberOfClientsMutex.unlock();
}

// Симуляция первого кассира.
void cashierFirstProcess() {
    while (!queueFirst.empty()) {
        sem_wait(&cashierFirst);
        mutexQueueFirst.lock();
        sem_post(queueFirst.front());
        queueFirst.pop();
        mutexQueueFirst.unlock();
    }
    sem_post(&cashierSecond);
}

// Симуляция работы второго кассира.
void cashierSecondProcess() {
    while (!queueSecond.empty()) {
        sem_wait(&cashierSecond);
        mutexQueueSecond.lock();
        sem_post(queueSecond.front());
        queueSecond.pop();
        mutexQueueSecond.unlock();
    }
    sem_post(&cashierFirst);
}

// Проверка ввода
void checkInput() {
    if (numberOfClients == 0) {
        cout << "Oh, no clients" << endl;
        exit(EXIT_SUCCESS);
    } else if (numberOfClients < 0) {
        cout << "Wrong input" << endl;
        exit(EXIT_FAILURE);
    } else if (numberOfClients > 100){
        cout << "We have no space for these customers";
        exit(EXIT_FAILURE);
    }
}

int main() {
    srand(time(nullptr));
    cout << "Please input number of customers " << endl;
    cin >> numberOfClients;

    checkInput();

    sem_init(&cashierFirst, 0, 0);
    sem_init(&cashierSecond, 0, 0);

    vector<thread> threads;

    for (int i = 0; i < numberOfClients; ++i)
        threads.emplace_back(queueProcess, i);

    threads.emplace_back(cashierFirstProcess);
    threads.emplace_back(cashierSecondProcess);

    for (auto &thread : threads)
        thread.join();
}