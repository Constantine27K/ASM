#include <iostream>
#include <vector>
#include <string>
#include <thread>

using namespace std;

//Метод для вывода информации о векторе
string info(vector<int> first, vector<int> second, vector<int> third) {
    string res = "\nVectors:\n";
    res += "(" + to_string(first[0]) + ", " + to_string(first[1]) + ", " + to_string(first[2]) + ")\n";
    res += "(" + to_string(second[0]) + ", " + to_string(second[1]) + ", " + to_string(second[2]) + ")\n";
    res += "(" + to_string(third[0]) + ", " + to_string(third[1]) + ", " + to_string(third[2]) + ") are ";
    return res;
}

//Метод для проверки компланарности 3 векторов
void complanar(vector<int> first, vector<int> second, vector<int> third) {
    int pos = first[0] * second[1] * third[2] +
              first[1] * second[2] * third[0] +
              first[2] * second[0] * third[1];
    int neg = first[2] * second[1] * third[0] +
              first[1] * second[0] * third[2] +
              first[0] * second[2] * third[1];
    int res = pos - neg;
    string inf = info(first, second, third);
    if (res == 0)
        cout << inf + "complanar\n";
}

//Метод для завпуска потоков
void threadFunc(int i, int count, vector<vector<int>> vector) {
    for (int j = i + 1; j < count; ++j) {
        for (int k = j + 1; k < count; ++k) {
            complanar(vector[i], vector[j], vector[k]);
        }
    }
}

int main() {
    vector<vector<int>> vect;
    vector<int> temp;
    string line;
    int count;
    cout << "Введите количество векторов";
    cin >> count;
    while(count <= 0 || count > 10000){
        cout << "Вы ввели недопустимов количество векторов\n"
                "Введите количество векторов";
        cin >> count;
    }
    for (int i = 0; i < count; ++i) {
        int a, b, c;
        cout << "Введите координаты";
        cin >> a >> b >> c;
        temp.push_back(a);
        temp.push_back(b);
        temp.push_back(c);
        vect.push_back(temp);
        temp.erase(temp.begin(), temp.end());
    }

    vector<thread> threads;
    threads.reserve(vect.size());
    for (int i = 0; i < count; ++i) {
        threads.emplace_back(threadFunc, i, count, vect);
    }
    for (int j = 0; j < count; ++j) {
        threads[j].join();
    }
    return 0;
}
