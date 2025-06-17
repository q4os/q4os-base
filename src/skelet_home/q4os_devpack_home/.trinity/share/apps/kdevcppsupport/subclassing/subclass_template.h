
//---------------------------------------------------------------------------
#ifndef $NEWFILENAMEUC$_H
#define $NEWFILENAMEUC$_H
//---------------------------------------------------------------------------
// Checking names of source files. You can safely remove this section after successfull compilation.
#define TEST1_$BASECLASS$
#ifdef TEST1_TForm_$NEWFILENAMELC$
#error Using Trinity-TQT you should name your class files *.h/cpp other then *.ui files. The best way is to name the .ui file with some prefix, ie "ui_myform.ui" and class file: "myform.cpp" to avoid such conflicts.
#endif
//---------------------------------------------------------------------------
#include "$BASEFILENAME$.h"
//---------------------------------------------------------------------------
//class $TQTBASECLASS$;
//---------------------------------------------------------------------------
/**
 * @short $NEWCLASS$
 * @author $AUTHOR$ <$EMAIL$>
 * @version $VERSION$
 */
class T$NEWCLASS$ : public $BASECLASS$
{
    TQ_OBJECT

public:
    /*$PUBLIC_FUNCTIONS$*/
    /**
     * Default Constructor
     */
    T$NEWCLASS$( TQWidget* parent = 0, const char* name = 0, WFlags fl = 0 );

    /**
     * Default Destructor
     */
    ~T$NEWCLASS$();

public slots:
    /*$PUBLIC_SLOTS$*/

protected:
    /*$PROTECTED_FUNCTIONS$*/

protected slots:
    /*$PROTECTED_SLOTS$*/

private slots:
    /*$PRIVATE_SLOTS$*/
};
//---------------------------------------------------------------------------
extern T$NEWCLASS$ *$NEWCLASS$;
//---------------------------------------------------------------------------
#endif // $NEWFILENAMEUC$_H
//---------------------------------------------------------------------------
