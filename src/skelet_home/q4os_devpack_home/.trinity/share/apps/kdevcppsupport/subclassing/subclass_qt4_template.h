
//---------------------------------------------------------------------------
#ifndef $NEWFILENAMEUC$_H
#define $NEWFILENAMEUC$_H
//---------------------------------------------------------------------------
#include "ui_$BASEFILENAME$.h"
//---------------------------------------------------------------------------
//class $TQTBASECLASS$;
//---------------------------------------------------------------------------
class T$NEWCLASS$ : public $TQTBASECLASS$, public Ui::$BASECLASS$
{
    Q_OBJECT
private:        // User declarations
private slots:  // User declarations
public:         // User declarations
    T$NEWCLASS$(QWidget* parent = 0, Qt::WFlags fl = 0);
    ~T$NEWCLASS$();
};
//---------------------------------------------------------------------------
extern T$NEWCLASS$ *$NEWCLASS$;
//---------------------------------------------------------------------------
#endif // $NEWFILENAMEUC$_H
